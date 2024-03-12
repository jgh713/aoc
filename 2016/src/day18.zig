const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day18.txt");
const testdata = "";

test "day18_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

pub fn part1(input: []const u8) usize {
    var row: [100]u1 = undefined;
    var hold: [100]u1 = undefined;
    var count: usize = 0;

    for (input, 0..) |c, i| {
        switch (c) {
            '.' => {
                row[i] = 1;
                count += 1;
            },
            '^' => row[i] = 0,
            else => unreachable,
        }
    }

    var rows: usize = 1;

    while (rows < 40) {
        for (0..100) |i| {
            const val: u1 = blk: {
                if (i == 0) {
                    break :blk row[i + 1];
                } else if (i == 99) {
                    break :blk row[i - 1];
                } else {
                    if (row[i - 1] == row[i + 1]) {
                        break :blk 1;
                    }
                    break :blk 0;
                }
            };
            hold[i] = val;
            count += val;
        }
        row = hold;
        rows += 1;
    }
    return count;
}

test "day18_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var row: [100]u1 = undefined;
    var hold: [100]u1 = undefined;
    var count: usize = 0;

    for (input, 0..) |c, i| {
        switch (c) {
            '.' => {
                row[i] = 1;
                count += 1;
            },
            '^' => row[i] = 0,
            else => unreachable,
        }
    }

    var rows: usize = 1;

    while (rows < 400000) {
        for (0..100) |i| {
            const val: u1 = blk: {
                if (i == 0) {
                    break :blk row[i + 1];
                } else if (i == 99) {
                    break :blk row[i - 1];
                } else {
                    if (row[i - 1] == row[i + 1]) {
                        break :blk 1;
                    }
                    break :blk 0;
                }
            };
            hold[i] = val;
            count += val;
        }
        row = hold;
        rows += 1;
    }
    return count;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 18:\n", .{});
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
