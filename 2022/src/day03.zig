const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day03.txt");
const testdata = "vJrwpWtwJgWrhcsFMMfFFhFp\r\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\r\nPmmdzqPrVvPwwTWBwg\r\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\r\nttgJtRGJQctTZtZT\r\nCrZsJsPPZsGzwwsLwLmpwMDw";

test "day03_part1" {
    const res = part1(testdata);
    assert(res == 157);
}
inline fn charid(c: u8) u8 {
    switch (c) {
        'a'...'z' => return c - 'a',
        'A'...'Z' => return c - 'A' + 26,
        else => unreachable,
    }
}

fn parseLine(line: []const u8) usize {
    var found: [52]bool = comptime std.mem.zeroes([52]bool);
    const half = line.len / 2;
    for (0..half) |i| {
        const c = line[i];
        found[charid(c)] = true;
    }
    for (half..line.len) |i| {
        const c = line[i];
        if (found[charid(c)]) {
            return (charid(c) + 1);
        }
    }
    unreachable;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        total += parseLine(line);
    }
    return total;
}

test "day03_part2" {
    const res = part2(testdata);
    assert(res == 70);
}

fn lineInt(line: []const u8) usize {
    var out: usize = 0;
    for (0..line.len) |i| {
        const c = line[i];
        out |= @as(usize, 1) << @truncate(charid(c));
    }
    return out;
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        var match = lineInt(line);
        match &= lineInt(lines.next().?);
        match &= lineInt(lines.next().?);
        const clz = @clz(match);
        total += (64 - clz);
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 03:\n", .{});
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
