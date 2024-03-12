const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day06.txt");
const testdata = "eedadn\r\ndrvtee\r\neandsr\r\nraavrd\r\natevrs\r\ntsrnev\r\nsdttsa\r\nrasrtv\r\nnssdts\r\nntnada\r\nsvetve\r\ntesnvt\r\nvntsnd\r\nvrdear\r\ndvrsen\r\nenarar";

test "day06_part1" {
    const res = part1(testdata);
    assert(std.mem.eql(u8, res, "easter"));
}

pub fn part1(input: []const u8) []u8 {
    var counts: [9][26]usize = undefined;
    for (&counts) |*count| {
        @memset(count, 0);
    }
    var lines = splitSeq(u8, input, "\r\n");
    const width = lines.peek().?.len;
    while (lines.next()) |line| {
        for (line, 0..) |c, ci| {
            counts[ci][c - 'a'] += 1;
        }
    }

    const out = gpa.alloc(u8, width) catch unreachable;
    for (counts[0..width], 0..) |col, coli| {
        var max: usize = 0;
        var maxc: u8 = 0;
        for (col, 0..) |c, ci| {
            if (c > max) {
                max = c;
                maxc = 'a' + @as(u8, @intCast(ci));
            }
        }
        out[coli] = maxc;
    }
    return out;
}

test "day06_part2" {
    const res = part2(testdata);
    assert(std.mem.eql(u8, res, "advent"));
}

pub fn part2(input: []const u8) []u8 {
    var counts: [9][26]usize = undefined;
    for (&counts) |*count| {
        @memset(count, 0);
    }
    var lines = splitSeq(u8, input, "\r\n");
    const width = lines.peek().?.len;
    while (lines.next()) |line| {
        for (line, 0..) |c, ci| {
            counts[ci][c - 'a'] += 1;
        }
    }

    const out = gpa.alloc(u8, width) catch unreachable;
    for (counts[0..width], 0..) |col, coli| {
        var min: usize = std.math.maxInt(usize);
        var minc: u8 = 0;
        for (col, 0..) |c, ci| {
            if (c > 0 and c < min) {
                min = c;
                minc = 'a' + @as(u8, @intCast(ci));
            }
        }
        out[coli] = minc;
    }
    return out;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 06:\n", .{});
    print("\tPart 1: {s}\n", .{res});
    print("\tPart 2: {s}\n", .{res2});
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
