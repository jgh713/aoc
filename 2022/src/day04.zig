const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day04.txt");
const testdata = "2-4,6-8\r\n2-3,4-5\r\n5-7,7-9\r\n2-8,3-7\r\n6-6,4-6\r\n2-6,4-8";

test "day04_part1" {
    const res = part1(testdata);
    assert(res == 2);
}

fn parseLine(line: []const u8) [4]usize {
    var vals: [4]usize = comptime std.mem.zeroes([4]usize);
    var i: usize = 0;
    for (line) |c| {
        switch (c) {
            '0'...'9' => {
                vals[i] *= 10;
                vals[i] += c - '0';
            },
            '-', ',' => {
                i += 1;
            },
            else => unreachable,
        }
    }
    return vals;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        const vals: [4]usize = parseLine(line);
        if ((vals[0] <= vals[2] and vals[1] >= vals[3]) or
            (vals[2] <= vals[0] and vals[3] >= vals[1]))
            total += 1;
    }
    return total;
}

test "day04_part2" {
    const res = part2(testdata);
    assert(res == 4);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        const vals: [4]usize = parseLine(line);
        if (vals[0] <= vals[3] and vals[2] <= vals[1])
            total += 1;
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 04:\n", .{});
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
