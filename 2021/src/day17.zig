const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day17.txt");
const testdata = "target area: x=20..30, y=-10..-5";

test "day17_part1" {
    const res = part1(testdata);
    assert(res == 45);
}

pub fn part1(input: []const u8) usize {
    const coords = input[13..];
    const comma = indexOf(u8, coords, ',').?;
    const xcors = coords[2..comma];
    const ycors = coords[comma + 4 ..];

    var xit = splitSeq(u8, xcors, "..");
    var yit = splitSeq(u8, ycors, "..");

    const x1: usize = @abs(parseInt(isize, xit.next().?, 10) catch unreachable);
    const x2: usize = @abs(parseInt(isize, xit.next().?, 10) catch unreachable);
    const y1: isize = parseInt(isize, yit.next().?, 10) catch unreachable;
    const y2: isize = parseInt(isize, yit.next().?, 10) catch unreachable;

    const xmin = blk: {
        var dist: usize = 0;
        for (1..x2) |i| {
            dist += i;
            if (dist >= x1) break :blk i;
        }
        unreachable;
    };
    const xmax = @abs(x2);
    const ymin = @min(y1, y2);
    const ymax = @max(y1, y2);
    const speedmax: isize = @intCast(@max(@abs(y1), @abs(y2)));
    const speedmin: isize = -speedmax;

    //print("ymax: {} ymin: {} xmax: {} xmin: {}\n", .{ ymax, ymin, xmax, xmin });

    var ymap = std.AutoHashMap(usize, isize).init(gpa);

    var ymaxhit: usize = 0;

    {
        var y: isize = speedmin;
        while (y <= speedmax) : (y += 1) {
            //print("Checking speed {}\n", .{y});
            var yspeed: isize = y;
            var yloc: isize = 0;
            var step: usize = 0;
            var max: isize = 0;
            while (yloc >= ymin) {
                step += 1;
                yloc += yspeed;
                //print("Step {} yloc {}\n", .{ step, yloc });
                yspeed -= 1;
                max = @max(max, yloc);
                if (yloc >= ymin and yloc <= ymax) {
                    ymaxhit = @max(ymaxhit, step);
                    //print("Starting speed {} hits range at step {}, maxh is {}\n", .{ y, step, max });
                    const entry = ymap.getOrPut(step) catch unreachable;
                    if (entry.found_existing) {
                        entry.value_ptr.* = @max(entry.value_ptr.*, max);
                    } else {
                        entry.value_ptr.* = max;
                    }
                }
            }
        }
    }

    var xminhit: usize = std.math.maxInt(usize);
    var maxh: usize = 0;
    for (xmin..xmax + 1) |startspeed| {
        var xspeed = startspeed;
        var xloc: usize = 0;
        var step: usize = 0;
        while (xloc <= x2) {
            step += 1;
            xloc += xspeed;
            xspeed -= 1;
            if (xloc >= x1 and xloc <= x2) {
                //print("Starting x-speed {} hits range at step {}\n", .{ startspeed, step });
                if (ymap.get(step)) |val| {
                    //print("Maxh for step is {}.\n", .{val});
                    const uval: usize = @intCast(val);
                    maxh = @max(maxh, uval);
                }
            }
            if (xspeed == 0) {
                xminhit = @min(xminhit, step + 1);
                break;
            }
        }
    }

    for (xminhit..ymaxhit + 1) |step| {
        if (ymap.get(step)) |val| {
            //print("Maxh for infstep is {}.\n", .{val});
            const uval: usize = @intCast(val);
            maxh = @max(maxh, uval);
        }
    }

    return maxh;
}

test "day17_part2" {
    const res = part2(testdata);
    assert(res == 112);
}

pub fn part2(input: []const u8) usize {
    const coords = input[13..];
    const comma = indexOf(u8, coords, ',').?;
    const xcors = coords[2..comma];
    const ycors = coords[comma + 4 ..];

    var xit = splitSeq(u8, xcors, "..");
    var yit = splitSeq(u8, ycors, "..");

    const x1: usize = @abs(parseInt(isize, xit.next().?, 10) catch unreachable);
    const x2: usize = @abs(parseInt(isize, xit.next().?, 10) catch unreachable);
    const y1: isize = parseInt(isize, yit.next().?, 10) catch unreachable;
    const y2: isize = parseInt(isize, yit.next().?, 10) catch unreachable;

    const xmin = blk: {
        var dist: usize = 0;
        for (1..x2) |i| {
            dist += i;
            if (dist >= x1) break :blk i;
        }
        unreachable;
    };
    const xmax = @abs(x2);
    const ymin = @min(y1, y2);
    const ymax = @max(y1, y2);
    const speedmax: isize = @intCast(@max(@abs(y1), @abs(y2)));
    const speedmin: isize = -speedmax;

    //print("ymax: {} ymin: {} xmax: {} xmin: {}\n", .{ ymax, ymin, xmax, xmin });

    var ymap = std.AutoArrayHashMap(isize, [2]usize).init(gpa);

    var ymaxhit: usize = 0;

    {
        var y: isize = speedmin;
        while (y <= speedmax) : (y += 1) {
            //print("Checking speed {}\n", .{y});
            var yspeed: isize = y;
            var yloc: isize = 0;
            var step: usize = 0;
            var max: isize = 0;
            var minhit: usize = 0;
            var maxhit: usize = 0;
            while (yloc >= ymin) {
                step += 1;
                yloc += yspeed;
                //print("Step {} yloc {}\n", .{ step, yloc });
                yspeed -= 1;
                max = @max(max, yloc);
                if (yloc >= ymin and yloc <= ymax) {
                    ymaxhit = @max(ymaxhit, step);
                    if (minhit == 0) minhit = step;
                    maxhit = step;
                    //print("Starting yspeed {} hits range at step {}\n", .{ y, step });
                }
            }
            if (minhit > 0) {
                ymap.put(y, .{ minhit, maxhit }) catch unreachable;
            }
        }
    }

    //var ymit = ymap.iterator();

    //while (ymit.next()) |entry| {
    //    print("Step: {} Value: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    //}

    var count: usize = 0;
    for (xmin..xmax + 1) |startspeed| {
        var xminhit: usize = 0;
        var xmaxhit: usize = 0;
        var xspeed = startspeed;
        var xloc: usize = 0;
        var step: usize = 0;
        while (xloc <= x2) {
            step += 1;
            xloc += xspeed;
            xspeed -= 1;
            if (xloc >= x1 and xloc <= x2) {
                if (xminhit == 0) {
                    xminhit = step;
                }
                xmaxhit = step;
            }
            if (xspeed == 0) {
                xmaxhit = ymaxhit;
                break;
            }
        }
        if (xminhit > 0) {
            //print("Startx: {} Xminhit: {} Xmaxhit: {}\n", .{ startspeed, xminhit, xmaxhit });
            var ylit = ymap.iterator();
            while (ylit.next()) |entry| {
                const bounds = entry.value_ptr.*;
                if (bounds[0] <= xmaxhit and bounds[1] >= xminhit) {
                    count += 1;
                }
            }
        }
    }

    //print("Count: {}\n", .{count});

    return count;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 17:\n", .{});
    print("\tPart 1: {}\n", .{res});
    print("\tPart 2: {}\n", .{res2});
    print("\tTime: {}ns\n", .{time});
    print("\tTime: {}ns\n", .{time2});
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
