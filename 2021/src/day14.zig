const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day14.txt");
const testdata = "NNCB\r\n\r\nCH -> B\r\nHH -> N\r\nCB -> H\r\nNH -> C\r\nHB -> C\r\nHC -> B\r\nHN -> C\r\nNN -> C\r\nBH -> H\r\nNC -> B\r\nNB -> B\r\nBN -> B\r\nBB -> N\r\nBC -> B\r\nCC -> N\r\nCN -> C";

test "day14_part1" {
    const res = part1(testdata);
    assert(res == 1588);
}

fn parsePair(pair: u10, rmap: [1024]u5, cache: *Map(u20, [26]usize), depth: u8) [26]usize {
    //print("{c}{c}\n", .{ @as(u8, @intCast((pair >> 5))) + 'A', @as(u8, @intCast(pair & 0b11111)) + 'A' });
    if (depth > 1) {
        const cacheid = @as(u20, pair) << 10 | depth;
        if (cache.get(cacheid)) |v| {
            return v;
        }
    }
    var counts: [26]usize = comptime std.mem.zeroes([26]usize);
    const new: u5 = rmap[pair];
    //print("-> {c}\n", .{@as(u8, new) + 'A'});
    counts[new] += 1;

    if (depth > 1) {
        const left = (pair & 0b1111100000) | new;
        const right = (pair & 0b11111) | @as(u10, new) << 5;
        const leftvals = parsePair(left, rmap, cache, depth - 1);
        const rightvals = parsePair(right, rmap, cache, depth - 1);
        for (leftvals, 0..) |v, i| {
            counts[i] += v;
        }
        for (rightvals, 0..) |v, i| {
            counts[i] += v;
        }
    }

    if (depth > 1) {
        const cacheid = @as(u20, pair) << 10 | depth;
        cache.putNoClobber(cacheid, counts) catch unreachable;
    }

    return counts;
}

pub fn part1(input: []const u8) usize {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    const chain = parts.next().?;
    var reactions = splitSeq(u8, parts.next().?, "\r\n");
    var rmap: [1024]u5 = comptime std.mem.zeroes([1024]u5);

    while (reactions.next()) |react| {
        var rparts = splitSeq(u8, react, " -> ");
        const left = rparts.next().?;
        const right = rparts.next().?;
        var id: u10 = 0;
        id |= @as(u10, @intCast(left[0] - 'A')) << 5;
        id |= left[1] - 'A';
        rmap[id] = @intCast(right[0] - 'A');
        //print("{s} -> {s}\n", .{ left, right });
    }

    var counts: [26]usize = comptime std.mem.zeroes([26]usize);

    for (chain) |c| {
        counts[c - 'A'] += 1;
    }

    var cache = Map(u20, [26]usize).init(gpa);
    defer cache.deinit();

    for (0..chain.len - 1) |i| {
        //print("New pair: {s}\n", .{chain[i .. i + 2]});
        const pair: u10 = @as(u10, chain[i] - 'A') << 5 | chain[i + 1] - 'A';
        const paircounts = parsePair(pair, rmap, &cache, 10);
        for (paircounts, 0..) |v, pi| {
            counts[pi] += v;
        }
    }

    var max: usize = 0;
    var min: usize = std.math.maxInt(usize);

    for (counts) |v| {
        if (v > 0) {
            max = @max(max, v);
            min = @min(min, v);
        }
    }

    //print("{any}\n", .{counts});

    return max - min;
}

test "day14_part2" {
    const res = part2(testdata);
    assert(res == 2188189693529);
}

pub fn part2(input: []const u8) usize {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    const chain = parts.next().?;
    var reactions = splitSeq(u8, parts.next().?, "\r\n");
    var rmap: [1024]u5 = comptime std.mem.zeroes([1024]u5);

    while (reactions.next()) |react| {
        var rparts = splitSeq(u8, react, " -> ");
        const left = rparts.next().?;
        const right = rparts.next().?;
        var id: u10 = 0;
        id |= @as(u10, @intCast(left[0] - 'A')) << 5;
        id |= left[1] - 'A';
        rmap[id] = @intCast(right[0] - 'A');
        //print("{s} -> {s}\n", .{ left, right });
    }

    var counts: [26]usize = comptime std.mem.zeroes([26]usize);

    for (chain) |c| {
        counts[c - 'A'] += 1;
    }

    var cache = Map(u20, [26]usize).init(gpa);
    defer cache.deinit();

    for (0..chain.len - 1) |i| {
        //print("New pair: {s}\n", .{chain[i .. i + 2]});
        const pair: u10 = @as(u10, chain[i] - 'A') << 5 | chain[i + 1] - 'A';
        const paircounts = parsePair(pair, rmap, &cache, 40);
        for (paircounts, 0..) |v, pi| {
            counts[pi] += v;
        }
    }

    var max: usize = 0;
    var min: usize = std.math.maxInt(usize);

    for (counts) |v| {
        if (v > 0) {
            max = @max(max, v);
            min = @min(min, v);
        }
    }

    //print("{any}\n", .{counts});

    return max - min;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 14:\n", .{});
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
