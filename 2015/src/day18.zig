const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day18.txt");
const testdata = "";

test "day18_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

fn printMap(map: [100][100]bool) void {
    for (map) |row| {
        for (row) |cell| {
            if (cell) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("\n\n", .{});
}

pub fn part1(input: []const u8) usize {
    var map: [100][100]bool = undefined;
    var x: usize = 0;
    var y: usize = 0;

    for (input) |c| {
        switch (c) {
            '.' => map[y][x] = false,
            '#' => map[y][x] = true,
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '\r' => {},
            else => unreachable,
        }
        x += 1;
    }

    var next: [100][100]bool = undefined;
    for (0..100) |_| {
        for (0..100) |ly| {
            const iy: i8 = @intCast(ly);
            for (0..100) |lx| {
                const ix: i8 = @intCast(lx);
                const count = blk: {
                    var c: u8 = 0;
                    for ([_][2]i8{ .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 }, .{ -1, -1 }, .{ 1, -1 }, .{ -1, 1 }, .{ 1, 1 } }) |diff| {
                        const nx = ix + diff[0];
                        const ny = iy + diff[1];
                        if (nx < 0 or nx >= 100 or ny < 0 or ny >= 100) continue;
                        if (map[@intCast(ny)][@intCast(nx)]) c += 1;
                    }
                    break :blk c;
                };
                var state: bool = false;
                if (map[ly][lx]) {
                    if (count == 2 or count == 3) state = true;
                } else {
                    if (count == 3) state = true;
                }
                next[ly][lx] = state;
            }
        }
        @memcpy(&map, &next);
    }
    var count: usize = 0;
    for (map) |row| {
        for (row) |cell| {
            if (cell) count += 1;
        }
    }
    return count;
}

test "day18_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var map: [100][100]bool = undefined;
    var x: usize = 0;
    var y: usize = 0;

    for (input) |c| {
        switch (c) {
            '.' => map[y][x] = false,
            '#' => map[y][x] = true,
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '\r' => {},
            else => unreachable,
        }
        x += 1;
    }

    var next: [100][100]bool = undefined;
    for (0..100) |_| {
        for (0..100) |ly| {
            const iy: i8 = @intCast(ly);
            for (0..100) |lx| {
                const ix: i8 = @intCast(lx);
                const count = blk: {
                    var c: u8 = 0;
                    for ([_][2]i8{ .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 }, .{ -1, -1 }, .{ 1, -1 }, .{ -1, 1 }, .{ 1, 1 } }) |diff| {
                        const nx = ix + diff[0];
                        const ny = iy + diff[1];
                        if (nx < 0 or nx >= 100 or ny < 0 or ny >= 100) continue;
                        if (map[@intCast(ny)][@intCast(nx)]) c += 1;
                    }
                    break :blk c;
                };
                var state: bool = false;
                if (map[ly][lx]) {
                    if (count == 2 or count == 3) state = true;
                } else {
                    if (count == 3) state = true;
                }
                next[ly][lx] = state;
            }
        }
        next[0][0] = true;
        next[0][99] = true;
        next[99][0] = true;
        next[99][99] = true;
        @memcpy(&map, &next);
    }
    var count: usize = 0;
    for (map) |row| {
        for (row) |cell| {
            if (cell) count += 1;
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
    print("Day 18:\n", .{});
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
