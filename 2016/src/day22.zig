const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day22.txt");
const testdata = "";

test "day22_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

const Node = struct {
    x: u8,
    y: u8,
    size: u16,
    used: u16,
    avail: u16,
    use: u8,
};

fn getInt(s: []const u8) u16 {
    //print("getInt: {s}\n", .{s});
    if (s[0] == ' ') {
        if (s[1] == ' ') {
            return parseInt(u16, s[2..], 10) catch unreachable;
        }
        return parseInt(u16, s[1..], 10) catch unreachable;
    }
    return parseInt(u16, s, 10) catch unreachable;
}

pub fn part1(input: []const u8) usize {
    var nodes: [1100]Node = undefined;
    var nid: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");
    for (0..2) |_| _ = lines.next();
    while (lines.next()) |line| {
        const space = indexOf(u8, line, ' ').?;
        const xyline = line[16..space];
        var xys = splitSeq(u8, xyline, "-y");
        const x = parseInt(u8, xys.next().?, 10) catch unreachable;
        const y = parseInt(u8, xys.next().?, 10) catch unreachable;
        const size = getInt(line[24..27]);
        const used = getInt(line[30..33]);
        const avail = getInt(line[37..40]);
        const use: u8 = @intCast(getInt(line[43..46]));
        nodes[nid] = Node{ .x = x, .y = y, .size = size, .used = used, .avail = avail, .use = use };
        //print("Line: {s}\n", .{line});
        //print("Node: {} {} {} {} {} {}\n", .{ x, y, size, used, avail, use });
        nid += 1;
    }

    var count: usize = 0;
    for (nodes[0..nid]) |a| {
        if (a.used == 0) continue;
        for (nodes[0..nid]) |b| {
            if (a.x == b.x and a.y == b.y) {
                continue;
            }
            if (a.used <= b.avail) {
                count += 1;
            }
        }
    }
    return count;
}

test "day22_part2" {}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");

    var empty: [2]u8 = undefined;
    var maxx: u8 = 0;
    var minblocked: u8 = std.math.maxInt(u8);
    for (0..2) |_| _ = lines.next();
    while (lines.next()) |line| {
        const space = indexOf(u8, line, ' ').?;
        const xyline = line[16..space];
        var xys = splitSeq(u8, xyline, "-y");
        const x = parseInt(u8, xys.next().?, 10) catch unreachable;
        const y = parseInt(u8, xys.next().?, 10) catch unreachable;
        //const size = getInt(line[24..27]);
        //_ = size;
        const used = getInt(line[30..33]);
        //const avail = getInt(line[37..40]);
        //_ = avail;
        //const use: u8 = @intCast(getInt(line[43..46]));
        if (used > 200) {
            minblocked = @min(minblocked, x);
        }
        if (used == 0) {
            empty = .{ x, y };
        }
        maxx = @max(maxx, x);
        //nodes[nid] = Node{ .x = x, .y = y, .size = size, .used = used, .avail = avail, .use = use };
        //print("Line: {s}\n", .{line});
        //print("Node: {} {} {} {} {} {}\n", .{ x, y, size, used, avail, use });
        //nid += 1;
    }

    print("Empty: {} {}\n", .{ empty[0], empty[1] });
    print("minblocked: {}\n", .{minblocked});

    const target = .{ maxx - 1, 0 };
    const distx = target[0] - empty[0];
    const disty = empty[1] - target[1];

    // This many steps to move the empty node to the left of the target
    const startdist = distx + disty + 1;

    // This many steps to get around the wall of blocked nodes
    const blockdist = (empty[0] - minblocked + 1) * 2;

    // And then 5 steps to move the target left each time
    const dist = startdist + blockdist + (target[0] * 5);

    return dist;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 22:\n", .{});
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
