const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day05.txt");
const testdata = "ugknbfddgicrmopn\r\naaa\r\njchzalrnumimnmhp\r\nhaegwjzuvuyypxyu\r\ndvszwmarrgswjxmb";
const testdata2 = "qjhvhtzxzqqjkmpb\r\nxxyxx\r\nuurcxstgmygtbstg\r\nieodomkazucvgmuy";

test "day05_part1" {
    const res = part1(testdata);
    assert(res == 2);
}

pub fn part1(input: []const u8) usize {
    var count: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var vowels: usize = 0;
        var double: bool = false;
        var last: u8 = 0;
        const nice: bool = for (line) |c| {
            switch (c) {
                'a', 'e', 'i', 'o', 'u' => vowels += 1,
                'b', 'd', 'q', 'y' => {
                    if (c == last + 1) break false;
                },
                else => {},
            }
            if (c == last) double = true;
            last = c;
        } else blk: {
            break :blk if (vowels >= 3 and double) true else false;
        };
        count += @intFromBool(nice);
    }
    return count;
}

test "day05_part2" {
    const res = part2(testdata2);
    assert(res == 2);
}

pub fn part2(input: []const u8) usize {
    var count: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var cache: [1024]u8 = comptime std.mem.zeroes([1024]u8);
        var pair: bool = false;
        var double: bool = false;
        var last: u8 = 0;
        var last2: u8 = 0;
        const nice: bool = for (line, 0..) |c, i| {
            if (c == last2) {
                if (pair) break true;
                double = true;
            }
            if (last != 0) {
                const cid: u10 = @as(u10, (last - 'a')) << 5 | (c - 'a');
                if (cache[cid] != 0) {
                    if (i - cache[cid] > 1) {
                        if (double) break true;
                        pair = true;
                    }
                } else {
                    cache[cid] = @intCast(i);
                }
            }
            last2 = last;
            last = c;
        } else false;
        count += @intFromBool(nice);
    }
    return count;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 05:\n", .{});
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
