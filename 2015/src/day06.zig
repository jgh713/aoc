const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day06.txt");
const testdata = "turn on 0,0 through 999,999\r\ntoggle 0,0 through 999,0\r\nturn off 499,499 through 500,500";
const testdata2 = "turn on 0,0 through 0,0\r\ntoggle 0,0 through 999,999";

test "day06_part1" {
    const res = part1(testdata);
    assert(res == 998996);
}

const Ops = enum {
    On,
    Off,
    Toggle,
};

fn rangeId(x: usize, y: usize) usize {
    return y * 1000 + x;
}

pub fn part1(input: []const u8) usize {
    var map = std.bit_set.ArrayBitSet(u8, 1000000).initEmpty();
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var start: usize = 0;
        const op = switch (line[6]) {
            'n' => blk: {
                start = 8;
                break :blk Ops.On;
            },
            ' ' => blk: {
                start = 7;
                break :blk Ops.Toggle;
            },
            'f' => blk: {
                start = 9;
                break :blk Ops.Off;
            },
            else => unreachable,
        };
        var words = splitSeq(u8, line[start..], " ");
        var starts = splitSeq(u8, words.next().?, ",");
        _ = words.next().?;
        var ends = splitSeq(u8, words.next().?, ",");
        const sx = parseInt(usize, starts.next().?, 10) catch unreachable;
        const sy = parseInt(usize, starts.next().?, 10) catch unreachable;
        const ex = parseInt(usize, ends.next().?, 10) catch unreachable;
        const ey = parseInt(usize, ends.next().?, 10) catch unreachable;

        for (sy..ey + 1) |y| {
            switch (op) {
                Ops.On => map.setRangeValue(.{ .start = rangeId(sx, y), .end = rangeId(ex, y) + 1 }, true),
                Ops.Off => map.setRangeValue(.{ .start = rangeId(sx, y), .end = rangeId(ex, y) + 1 }, false),
                Ops.Toggle => {
                    for (sx..ex + 1) |x| {
                        map.toggle(rangeId(x, y));
                    }
                },
            }
        }
    }
    return map.count();
}

test "day06_part2" {
    const res = part2(testdata2);
    assert(res == 2000001);
}

pub fn part2(input: []const u8) usize {
    var map = comptime std.mem.zeroes([1000]@Vector(1000, u8));
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var start: usize = 0;
        const op = switch (line[6]) {
            'n' => blk: {
                start = 8;
                break :blk Ops.On;
            },
            ' ' => blk: {
                start = 7;
                break :blk Ops.Toggle;
            },
            'f' => blk: {
                start = 9;
                break :blk Ops.Off;
            },
            else => unreachable,
        };
        var words = splitSeq(u8, line[start..], " ");
        var starts = splitSeq(u8, words.next().?, ",");
        _ = words.next().?;
        var ends = splitSeq(u8, words.next().?, ",");
        const sx = parseInt(usize, starts.next().?, 10) catch unreachable;
        const sy = parseInt(usize, starts.next().?, 10) catch unreachable;
        const ex = parseInt(usize, ends.next().?, 10) catch unreachable;
        const ey = parseInt(usize, ends.next().?, 10) catch unreachable;

        //print("op: {}, sx: {}, sy: {}, ex: {}, ey: {}\n", .{ op, sx, sy, ex, ey });

        var vec = comptime std.mem.zeroes(@Vector(1000, u8));
        const val: u8 = switch (op) {
            Ops.On => 1,
            Ops.Off => 1,
            Ops.Toggle => 2,
        };
        for (sx..ex + 1) |x| {
            vec[x] = val;
        }
        //print("xvec: {any}\n", .{vec});
        for (sy..ey + 1) |y| {
            //print("y: {}\n", .{y});
            switch (op) {
                Ops.On, Ops.Toggle => map[y] +|= vec,
                Ops.Off => map[y] -|= vec,
            }
        }
        var incount: usize = 0;
        for (map) |row| {
            incount += @reduce(.Add, row);
        }
        //print("post-op incount is {}\n", .{incount});
    }
    var count: usize = 0;
    for (map) |row| {
        for (0..1000) |x| {
            count += row[x];
        }
    }
    print("Count: {}\n", .{count});
    return count;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 06:\n", .{});
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
