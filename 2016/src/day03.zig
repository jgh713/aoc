const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day03.txt");
const testdata = "";

test "day03_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

fn getInt(s: []const u8) u16 {
    var out: u16 = 0;
    for (s) |c| {
        switch (c) {
            '0'...'9' => out = out * 10 + c - '0',
            ' ' => continue,
            else => unreachable,
        }
    }
    return out;
}

fn isTriangle(parts: [3]u16) bool {
    return parts[0] + parts[1] > parts[2] and
        parts[0] + parts[2] > parts[1] and
        parts[1] + parts[2] > parts[0];
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;
    while (lines.next()) |line| {
        var parts: [3]u16 = undefined;
        parts[0] = getInt(line[2..5]);
        parts[1] = getInt(line[7..10]);
        parts[2] = getInt(line[12..15]);
        if (isTriangle(parts)) {
            count += 1;
        }
    }
    return count;
}

test "day03_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;
    var y: u8 = 0;
    var parts: [3][3]u16 = undefined;
    while (lines.next()) |line| {
        parts[0][y] = getInt(line[2..5]);
        parts[1][y] = getInt(line[7..10]);
        parts[2][y] = getInt(line[12..15]);
        y += 1;
        if (y == 3) {
            for (parts) |tri| {
                if (isTriangle(tri)) {
                    count += 1;
                }
            }
            y = 0;
        }
    }
    return count;
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
