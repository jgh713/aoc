const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day02.txt");
const testdata = "2x3x4\r\n1x1x10";

test "day02_part1" {
    const res = part1(testdata);
    assert(res == 101);
}

pub fn part1(input: []const u8) usize {
    var lineit = splitSeq(u8, input, "\r\n");
    var count: usize = 0;
    while (lineit.next()) |line| {
        var min: usize = comptime std.math.maxInt(usize);
        var vals: [3]usize = undefined;
        var numit = splitSca(u8, line, 'x');
        var i: usize = 0;
        while (numit.next()) |num| {
            const val = parseInt(usize, num, 10) catch unreachable;
            vals[i] = val;
            i += 1;
        }
        for ([_][2]usize{ .{ vals[0], vals[1] }, .{ vals[0], vals[2] }, .{ vals[1], vals[2] } }) |lw| {
            const area = lw[0] * lw[1];
            min = @min(min, area);
            count += 2 * area;
        }
        count += min;
    }
    return count;
}

test "day02_part2" {
    const res = part2(testdata);
    assert(res == 48);
}

pub fn part2(input: []const u8) usize {
    var lineit = splitSeq(u8, input, "\r\n");
    var count: usize = 0;
    while (lineit.next()) |line| {
        var min: usize = comptime std.math.maxInt(usize);
        var vals: [3]usize = undefined;
        var numit = splitSca(u8, line, 'x');
        var i: usize = 0;
        while (numit.next()) |num| {
            const val = parseInt(usize, num, 10) catch unreachable;
            vals[i] = val;
            i += 1;
        }
        for ([_][2]usize{ .{ vals[0], vals[1] }, .{ vals[0], vals[2] }, .{ vals[1], vals[2] } }) |lw| {
            const perim = lw[0] * 2 + lw[1] * 2;
            min = @min(min, perim);
        }
        count += min;
        count += vals[0] * vals[1] * vals[2];
    }
    return count;
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
