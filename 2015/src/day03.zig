const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day03.txt");
const testdata = "^>v<";

test "day03_part1" {
    const res = part1(testdata);
    assert(res == 4);
}

pub fn part1(input: []const u8) usize {
    var map: [200][200]bool = comptime std.mem.zeroes([200][200]bool);
    var x: usize = 100;
    var y: usize = 100;
    var count: usize = 1;
    map[y][x] = true;

    for (input) |c| {
        switch (c) {
            '^' => y += 1,
            'v' => y -= 1,
            '>' => x += 1,
            '<' => x -= 1,
            else => unreachable,
        }
        if (!map[y][x]) {
            count += 1;
            map[y][x] = true;
        }
    }

    return count;
}

test "day03_part2" {
    const res = part2(testdata);
    assert(res == 3);
}

pub fn part2(input: []const u8) usize {
    var map: [200][200]bool = comptime std.mem.zeroes([200][200]bool);
    var pos: [2][2]usize = .{ .{ 100, 100 }, .{ 100, 100 } };
    var count: usize = 1;
    var step: usize = 0;
    map[100][100] = true;

    for (input) |c| {
        const which = step % 2;
        switch (c) {
            '^' => pos[which][1] += 1,
            'v' => pos[which][1] -= 1,
            '>' => pos[which][0] += 1,
            '<' => pos[which][0] -= 1,
            else => unreachable,
        }
        if (!map[pos[which][1]][pos[which][0]]) {
            count += 1;
            map[pos[which][1]][pos[which][0]] = true;
        }
        step += 1;
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
