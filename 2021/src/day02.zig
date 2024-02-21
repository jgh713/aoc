const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day02.txt");
const testdata = "forward 5\r\ndown 5\r\nforward 8\r\nup 3\r\ndown 8\r\nforward 2";

test "day02_part1" {
    const res = part1(testdata);
    assert(res == 150);
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var x: usize = 0;
    var y: usize = 0;

    while (lines.next()) |line| {
        switch (line[0]) {
            'f' => x += parseInt(usize, line[8..], 10) catch unreachable,
            'd' => y += parseInt(usize, line[5..], 10) catch unreachable,
            'u' => y -= parseInt(usize, line[3..], 10) catch unreachable,
            else => unreachable,
        }
    }
    return x * y;
}

test "day02_part2" {
    const res = part2(testdata);
    assert(res == 900);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var x: isize = 0;
    var y: isize = 0;
    var aim: isize = 0;

    while (lines.next()) |line| {
        switch (line[0]) {
            'f' => {
                const dist = parseInt(isize, line[8..], 10) catch unreachable;
                x += dist;
                y += aim * dist;
            },
            'd' => aim += parseInt(isize, line[5..], 10) catch unreachable,
            'u' => aim -= parseInt(isize, line[3..], 10) catch unreachable,
            else => unreachable,
        }
    }
    return @abs(x * y);
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 02:\n", .{});
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
