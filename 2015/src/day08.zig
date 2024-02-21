const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day08.txt");
const testdata = "\"\"\r\n\"abc\"\r\n\"aaa\\\"aaa\"\r\n\"\\x27\"";

test "day08_part1" {
    const res = part1(testdata);
    assert(res == 12);
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var skipped: usize = 0;
    while (lines.next()) |line| {
        var i: usize = 1;
        while (i < line.len) : (i += 1) {
            if (line[i] == '\\') {
                const sk: u8 = if (line[i + 1] == 'x') 3 else 1;
                skipped += sk;
                i += sk;
            }
        }
        skipped += 2;
    }
    return skipped;
}

test "day08_part2" {
    const res = part2(testdata);
    assert(res == 19);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var extras: usize = 0;
    while (lines.next()) |line| {
        for (line) |c| {
            switch (c) {
                '\\', '"' => extras += 1,
                else => {},
            }
        }
        extras += 2;
    }
    return extras;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 08:\n", .{});
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
