const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day17.txt");
const testdata = "";

test "day17_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

pub fn part1(input: []const u8) usize {
    var nums: [20]u16 = undefined;
    var ni: u8 = 0;
    var num: u16 = 0;

    for (input) |c| {
        switch (c) {
            '0'...'9' => num = num * 10 + (c - '0'),
            '\n' => {
                nums[ni] = num;
                ni += 1;
                num = 0;
            },
            '\r' => {},
            else => unreachable,
        }
    }

    if (num > 0) {
        nums[ni] = num;
        ni += 1;
    }

    const max = std.math.maxInt(u20);
    var i: u20 = 0;
    var count: usize = 0;

    while (i < max) {
        var sum: u16 = 0;
        for (0..ni) |j| {
            if (i & (@as(u20, 1) << @intCast(j)) > 0) {
                sum += nums[j];
            }
        }
        //print("sum: {}\n", .{sum});
        if (sum == 150) count += 1;
        i += 1;
    }

    return count;
}

test "day17_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var nums: [20]u16 = undefined;
    var ni: u8 = 0;
    var num: u16 = 0;

    for (input) |c| {
        switch (c) {
            '0'...'9' => num = num * 10 + (c - '0'),
            '\n' => {
                nums[ni] = num;
                ni += 1;
                num = 0;
            },
            '\r' => {},
            else => unreachable,
        }
    }

    if (num > 0) {
        nums[ni] = num;
        ni += 1;
    }

    const max = std.math.maxInt(u20);
    var i: u20 = 0;
    var count: usize = 0;
    var mincount: u8 = 20;

    while (i < max) {
        var sum: u16 = 0;
        for (0..ni) |j| {
            if (i & (@as(u20, 1) << @intCast(j)) > 0) {
                sum += nums[j];
            }
        }
        //print("sum: {}\n", .{sum});
        if (sum == 150) {
            const pc = @popCount(i);
            if (pc < mincount) {
                mincount = pc;
                count = 1;
            } else if (pc == mincount) {
                count += 1;
            }
        }
        i += 1;
    }

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
