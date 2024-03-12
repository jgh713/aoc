const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day20.txt");
const testdata = "5-8\r\n0-2\r\n4-7";

test "day20_part1" {
    const res = part1(testdata);
    assert(res == 3);
}

const Range = struct {
    min: usize,
    max: usize,
};

fn sortRange(_: void, a: Range, b: Range) bool {
    return a.min < b.min;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var ranges: [1100]Range = undefined;
    var rid: usize = 0;
    while (lines.next()) |line| {
        var parts = splitSca(u8, line, '-');
        const min = parseInt(usize, parts.next().?, 10) catch unreachable;
        const max = parseInt(usize, parts.next().?, 10) catch unreachable;
        ranges[rid] = Range{ .min = min, .max = max };
        rid += 1;
    }

    sort(Range, ranges[0..rid], {}, sortRange);

    outfor: for (ranges[0..rid]) |range| {
        const i = range.max + 1;
        for (ranges[0..rid]) |crange| {
            if (i >= crange.min and i <= crange.max) {
                continue :outfor;
            }
        }
        return i;
    }
    return 0;
}

test "day20_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var ranges: [1100]Range = undefined;
    var rid: usize = 0;
    while (lines.next()) |line| {
        var parts = splitSca(u8, line, '-');
        const min = parseInt(usize, parts.next().?, 10) catch unreachable;
        const max = parseInt(usize, parts.next().?, 10) catch unreachable;
        ranges[rid] = Range{ .min = min, .max = max };
        rid += 1;
    }

    sort(Range, ranges[0..rid], {}, sortRange);

    var total: usize = 0;
    var ip: usize = 0;
    var ri: usize = 0;
    while (ip <= 4294967295) {
        const range = ranges[ri];
        if (ip < range.min) {
            total += range.min - ip;
            ip = range.min;
            continue;
        }
        if (ip <= range.max) {
            ip = range.max + 1;
            continue;
        }
        ri += 1;
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 20:\n", .{});
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
