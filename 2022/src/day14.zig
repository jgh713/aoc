const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day14.txt");
const testdata = "498,4 -> 498,6 -> 496,6\r\n503,4 -> 502,4 -> 502,9 -> 494,9";

test "day14_part1" {
    const res = part1(testdata);
    assert(res == 24);
}

const Point = struct {
    x: usize,
    y: usize,
};

fn parsePoint(input: []const u8) Point {
    var coords = splitSeq(u8, input, ",");
    return Point{ .x = parseInt(usize, coords.next().?, 10) catch unreachable, .y = parseInt(usize, coords.next().?, 10) catch unreachable };
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    // Unconventional index map[x][y] for vertical-search performance
    var map: [1000][1000]bool = comptime std.mem.zeroes([1000][1000]bool);

    var lowest_y: usize = 0;

    while (lines.next()) |line| {
        var coords = splitSeq(u8, line, " -> ");
        var start = parsePoint(coords.next().?);
        map[start.x][start.y] = true;
        while (coords.next()) |coord| {
            const end = parsePoint(coord);
            const minx = @min(start.x, end.x);
            const maxx = @max(start.x, end.x);
            const miny = @min(start.y, end.y);
            const maxy = @max(start.y, end.y);
            // Higher y value = lower position
            lowest_y = @max(lowest_y, maxy);
            if (minx != maxx and miny != maxy) unreachable;
            if (minx == maxx and miny == maxy) unreachable;
            if (minx != maxx) {
                for (minx..maxx + 1) |mx| {
                    map[mx][miny] = true;
                }
            } else {
                for (miny..maxy + 1) |my| {
                    map[minx][my] = true;
                }
            }
            start = end;
        }
    }

    var hist: [1000]Point = undefined;
    var hi: usize = 0;
    var count: usize = 0;

    hist[0] = Point{ .x = 500, .y = 0 };

    stepwhile: while (true) {
        const last = hist[hi];
        if (last.y == lowest_y) return count;
        for ([_]Point{ Point{ .x = last.x, .y = last.y + 1 }, Point{ .x = last.x - 1, .y = last.y + 1 }, Point{ .x = last.x + 1, .y = last.y + 1 } }) |pt| {
            if (!map[pt.x][pt.y]) {
                hi += 1;
                hist[hi] = pt;
                continue :stepwhile;
            }
        }
        map[last.x][last.y] = true;
        hi -= 1;
        count += 1;
    }

    unreachable;
}

test "day14_part2" {
    const res = part2(testdata);
    assert(res == 93);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    // Unconventional index map[x][y] for vertical-search performance
    var map: [1000][1000]bool = comptime std.mem.zeroes([1000][1000]bool);

    var lowest_y: usize = 0;

    while (lines.next()) |line| {
        var coords = splitSeq(u8, line, " -> ");
        var start = parsePoint(coords.next().?);
        map[start.x][start.y] = true;
        while (coords.next()) |coord| {
            const end = parsePoint(coord);
            const minx = @min(start.x, end.x);
            const maxx = @max(start.x, end.x);
            const miny = @min(start.y, end.y);
            const maxy = @max(start.y, end.y);
            // Higher y value = lower position
            lowest_y = @max(lowest_y, maxy);
            if (minx != maxx and miny != maxy) unreachable;
            if (minx == maxx and miny == maxy) unreachable;
            if (minx != maxx) {
                for (minx..maxx + 1) |mx| {
                    map[mx][miny] = true;
                }
            } else {
                for (miny..maxy + 1) |my| {
                    map[minx][my] = true;
                }
            }
            start = end;
        }
    }

    lowest_y += 1;

    var hist: [1000]Point = undefined;
    var hi: usize = 0;
    var count: usize = 0;

    hist[0] = Point{ .x = 500, .y = 0 };

    stepwhile: while (true) {
        const last = hist[hi];
        if (last.y < lowest_y) {
            for ([_]Point{ Point{ .x = last.x, .y = last.y + 1 }, Point{ .x = last.x - 1, .y = last.y + 1 }, Point{ .x = last.x + 1, .y = last.y + 1 } }) |pt| {
                if (!map[pt.x][pt.y]) {
                    hi += 1;
                    hist[hi] = pt;
                    continue :stepwhile;
                }
            }
        }
        map[last.x][last.y] = true;
        count += 1;
        if (std.meta.eql(last, Point{ .x = 500, .y = 0 })) return count;
        hi -= 1;
    }

    unreachable;
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
