const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day05.txt");
const testdata = "    [D]    \r\n[N] [C]    \r\n[Z] [M] [P]\r\n 1   2   3 \r\n\r\nmove 1 from 2 to 1\r\nmove 3 from 1 to 3\r\nmove 2 from 2 to 1\r\nmove 1 from 1 to 2";

test "day05_part1" {
    const res = part1(testdata);
    assert(std.mem.eql(u8, res, "CMZ"));
}

pub fn part1(input: []const u8) []u8 {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    var stacks: [10][50]u8 = undefined;
    var stacklen: [10]u8 = comptime std.mem.zeroes([10]u8);

    var rc: u8 = 0;
    const map = parts.next().?;
    var maplines = std.mem.splitBackwardsSequence(u8, map, "\r\n");
    _ = maplines.next();
    while (maplines.next()) |line| {
        var i: usize = 0;
        var ci: usize = 1;
        while (ci < line.len) {
            if (line[ci] != ' ') {
                stacks[i][stacklen[i]] = line[ci] - 'A';
                stacklen[i] += 1;
                rc = @max(rc, @as(u8, @truncate(i)));
            }
            i += 1;
            ci += 4;
        }
    }

    const moves = parts.next().?;
    var movelines = std.mem.splitSequence(u8, moves, "\r\n");
    while (movelines.next()) |line| {
        var words = std.mem.splitSequence(u8, line, " ");
        _ = words.next();
        const count = parseInt(usize, words.next().?, 10) catch unreachable;
        _ = words.next();
        const from = words.next().?[0] - '1';
        _ = words.next();
        const to = words.next().?[0] - '1';
        for (0..count) |_| {
            const part = stacks[from][stacklen[from] - 1];
            stacklen[from] -= 1;
            stacks[to][stacklen[to]] = part;
            stacklen[to] += 1;
        }
    }

    rc += 1;

    var res: []u8 = gpa.alloc(u8, rc) catch unreachable;
    for (0..rc) |i| {
        if (stacklen[i] > 0) {
            res[i] = stacks[i][stacklen[i] - 1] + 'A';
        } else {
            res[i] = ' ';
        }
    }
    //print("{s}\n", .{res});
    return res[0..rc];
}

test "day05_part2" {
    const res = part2(testdata);
    assert(std.mem.eql(u8, res, "MCD"));
}

pub fn part2(input: []const u8) []u8 {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    var stacks: [10][50]u8 = undefined;
    var stacklen: [10]u8 = comptime std.mem.zeroes([10]u8);

    var rc: u8 = 0;
    const map = parts.next().?;
    var maplines = std.mem.splitBackwardsSequence(u8, map, "\r\n");
    _ = maplines.next();
    while (maplines.next()) |line| {
        var i: usize = 0;
        var ci: usize = 1;
        while (ci < line.len) {
            if (line[ci] != ' ') {
                stacks[i][stacklen[i]] = line[ci] - 'A';
                stacklen[i] += 1;
                rc = @max(rc, @as(u8, @truncate(i)));
            }
            i += 1;
            ci += 4;
        }
    }

    const moves = parts.next().?;
    var movelines = std.mem.splitSequence(u8, moves, "\r\n");
    while (movelines.next()) |line| {
        var words = std.mem.splitSequence(u8, line, " ");
        _ = words.next();
        const count = parseInt(usize, words.next().?, 10) catch unreachable;
        _ = words.next();
        const from = words.next().?[0] - '1';
        _ = words.next();
        const to = words.next().?[0] - '1';
        const fc = stacklen[from];
        const tc = stacklen[to];
        for (fc - count..fc, tc..tc + count) |fi, ti| {
            stacks[to][ti] = stacks[from][fi];
        }
        stacklen[from] -= @truncate(count);
        stacklen[to] += @truncate(count);
    }

    rc += 1;

    var res: []u8 = gpa.alloc(u8, rc) catch unreachable;
    for (0..rc) |i| {
        if (stacklen[i] > 0) {
            res[i] = stacks[i][stacklen[i] - 1] + 'A';
        } else {
            res[i] = ' ';
        }
    }
    print("{s}\n", .{res});
    return res[0..rc];
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 05:\n", .{});
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
