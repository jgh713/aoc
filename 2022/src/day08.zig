const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day08.txt");
const testdata = "30373\r\n25512\r\n65332\r\n33549\r\n35390";

test "day08_part1" {
    const res = part1(testdata);
    assert(res == 21);
}

fn walkFrom(map: [100][100]u8, visible: *[100][100]bool, size: usize, start: [2]u8, dir: [2]i4) void {
    var pos: [2]i16 = .{ @intCast(start[0]), @intCast(start[1]) };
    var highest: isize = -1;
    while (pos[0] >= 0 and pos[1] >= 0 and pos[0] < size and pos[1] < size) {
        const px: usize = @intCast(pos[0]);
        const py: usize = @intCast(pos[1]);
        if (map[py][px] > highest) {
            visible[py][px] = true;
            highest = map[py][px];
        }
        pos[0] += dir[0];
        pos[1] += dir[1];
    }
}

pub fn part1(input: []const u8) usize {
    const size = indexOf(u8, input, '\r').?;
    var map: [100][100]u8 = undefined;
    var visible: [100][100]bool = comptime std.mem.zeroes([100][100]bool);
    var x: usize = 0;
    var y: usize = 0;
    for (input) |c| {
        switch (c) {
            '\r' => continue,
            '\n' => {
                x = 0;
                y += 1;
            },
            '0'...'9' => {
                map[y][x] = c - '0';
                x += 1;
            },
            else => unreachable,
        }
    }

    for (0..size) |i| {
        walkFrom(map, &visible, size, .{ @truncate(i), 0 }, .{ 0, 1 });
        walkFrom(map, &visible, size, .{ 0, @truncate(i) }, .{ 1, 0 });
        walkFrom(map, &visible, size, .{ @truncate(i), @truncate(size - 1) }, .{ 0, -1 });
        walkFrom(map, &visible, size, .{ @truncate(size - 1), @truncate(i) }, .{ -1, 0 });
    }

    var total: usize = 0;
    for (0..size) |by| {
        for (0..size) |bx| {
            total += @intFromBool(visible[by][bx]);
        }
    }

    return total;
}

test "day08_part2" {
    const res = part2(testdata);
    assert(res == 8);
}

fn treesVisible(map: [100][100]u8, size: usize, start: [2]u8, dir: [2]i4) usize {
    var pos: [2]i16 = .{ @intCast(start[0]), @intCast(start[1]) };
    const highest: usize = map[@as(usize, @intCast(start[1]))][@as(usize, @intCast(start[0]))];
    var count: usize = 0;
    pos[0] += dir[0];
    pos[1] += dir[1];
    while (pos[0] >= 0 and pos[1] >= 0 and pos[0] < size and pos[1] < size) {
        const px: usize = @intCast(pos[0]);
        const py: usize = @intCast(pos[1]);
        count += 1;
        if (map[py][px] >= highest) {
            return @intCast(count);
        }
        pos[0] += dir[0];
        pos[1] += dir[1];
    }
    return @intCast(count);
}

pub fn part2(input: []const u8) usize {
    const size = indexOf(u8, input, '\r').?;
    var map: [100][100]u8 = undefined;
    var x: usize = 0;
    var y: usize = 0;
    for (input) |c| {
        switch (c) {
            '\r' => continue,
            '\n' => {
                x = 0;
                y += 1;
            },
            '0'...'9' => {
                map[y][x] = c - '0';
                x += 1;
            },
            else => unreachable,
        }
    }

    var highest: usize = 0;
    for (1..size - 1) |py| {
        for (1..size - 1) |px| {
            var score: usize = 1;
            for ([_][2]i4{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } }) |dir| {
                score *= treesVisible(map, size, .{ @truncate(px), @truncate(py) }, dir);
                if (score == 0) break;
            }
            highest = @max(highest, score);
        }
    }

    return highest;
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
