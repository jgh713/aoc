const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day11.txt");
const testdata = "5483143223\r\n2745854711\r\n5264556173\r\n6141336146\r\n6357385478\r\n4167524645\r\n2176841721\r\n6882881134\r\n4846848554\r\n5283751526";

test "day11_part1" {
    const res = part1(testdata);
    assert(res == 1656);
}

pub fn part1(input: []const u8) usize {
    var map: [10][10]u4 = std.mem.zeroes([10][10]u4);

    {
        var lines = splitSeq(u8, input, "\r\n");
        var y: u4 = 0;
        while (lines.next()) |line| : (y += 1) {
            for (line, 0..) |c, i| {
                map[y][i] = @intCast(c - '0');
            }
        }
    }

    var flashes: usize = 0;

    for (1..101) |_| {
        var queue: [100][2]u4 = undefined;
        var qstart: u8 = 0;
        var qend: u8 = 0;

        for (0..10) |y| {
            for (0..10) |x| {
                map[y][x] += 1;
                if (map[y][x] == 10) {
                    queue[qend][0] = @intCast(x);
                    queue[qend][1] = @intCast(y);
                    qend += 1;
                }
            }
        }

        while (qstart < qend) : (qstart += 1) {
            const x: i8 = @intCast(queue[qstart][0]);
            const y: i8 = @intCast(queue[qstart][1]);
            for ([_][2]i2{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, 1 }, .{ 1, -1 }, .{ -1, -1 }, .{ -1, 1 } }) |mods| {
                const inx = x + mods[0];
                const iny = y + mods[1];
                if (inx < 0 or inx >= 10 or iny < 0 or iny >= 10) {
                    continue;
                }
                const nx: u4 = @intCast(inx);
                const ny: u4 = @intCast(iny);
                if (map[ny][nx] == 10) {
                    continue;
                }
                map[ny][nx] += 1;
                if (map[ny][nx] == 10) {
                    queue[qend][0] = nx;
                    queue[qend][1] = ny;
                    qend += 1;
                }
            }
        }

        flashes += qend;
        for (queue[0..qend]) |pos| {
            map[pos[1]][pos[0]] = 0;
        }
    }

    return flashes;
}

test "day11_part2" {
    const res = part2(testdata);
    assert(res == 195);
}

pub fn part2(input: []const u8) usize {
    var map: [10][10]u4 = std.mem.zeroes([10][10]u4);

    {
        var lines = splitSeq(u8, input, "\r\n");
        var y: u4 = 0;
        while (lines.next()) |line| : (y += 1) {
            for (line, 0..) |c, i| {
                map[y][i] = @intCast(c - '0');
            }
        }
    }

    var step: usize = 1;
    while (true) : (step += 1) {
        var queue: [100][2]u4 = undefined;
        var qstart: u8 = 0;
        var qend: u8 = 0;

        for (0..10) |y| {
            for (0..10) |x| {
                map[y][x] += 1;
                if (map[y][x] == 10) {
                    queue[qend][0] = @intCast(x);
                    queue[qend][1] = @intCast(y);
                    qend += 1;
                }
            }
        }

        while (qstart < qend) : (qstart += 1) {
            const x: i8 = @intCast(queue[qstart][0]);
            const y: i8 = @intCast(queue[qstart][1]);
            for ([_][2]i2{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, 1 }, .{ 1, -1 }, .{ -1, -1 }, .{ -1, 1 } }) |mods| {
                const inx = x + mods[0];
                const iny = y + mods[1];
                if (inx < 0 or inx >= 10 or iny < 0 or iny >= 10) {
                    continue;
                }
                const nx: u4 = @intCast(inx);
                const ny: u4 = @intCast(iny);
                if (map[ny][nx] == 10) {
                    continue;
                }
                map[ny][nx] += 1;
                if (map[ny][nx] == 10) {
                    queue[qend][0] = nx;
                    queue[qend][1] = ny;
                    qend += 1;
                }
            }
        }

        if (qend == 100) {
            return step;
        }

        for (queue[0..qend]) |pos| {
            map[pos[1]][pos[0]] = 0;
        }
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 11:\n", .{});
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
