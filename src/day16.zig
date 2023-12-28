const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day16.txt");
const testdata = ".|...\\....\n|.-.\\.....\n.....|-...\n........|.\n..........\n.........\\\n..../.\\\\..\n.-.-/..|..\n.|....-|.\\\n..//.|....";

test "day16_part1" {
    const res = part1(testdata, 10);
    assert(res == 46);
}

const Dirs = enum {
    Up,
    Down,
    Left,
    Right,
    SplitVertical,
    SplitHorizontal,
};

const Tile = struct {
    map: [4]Dirs,
    energized: bool,
    visits: [4]bool,
};

inline fn getDirs(c: u8) [4]Dirs {
    switch (c) {
        '|' => return .{ Dirs.Up, Dirs.Down, Dirs.SplitVertical, Dirs.SplitVertical },
        '-' => return .{ Dirs.SplitHorizontal, Dirs.SplitHorizontal, Dirs.Left, Dirs.Right },
        '/' => return .{ Dirs.Right, Dirs.Left, Dirs.Down, Dirs.Up },
        '\\' => return .{ Dirs.Left, Dirs.Right, Dirs.Up, Dirs.Down },
        '.' => return .{ Dirs.Up, Dirs.Down, Dirs.Left, Dirs.Right },
        else => unreachable,
    }
}

inline fn nextStep(width: u8, dir: Dirs, x: u8, y: u8) ?[2]u8 {
    var xmod: i2 = 0;
    var ymod: i2 = 0;
    switch (dir) {
        Dirs.Up => ymod = -1,
        Dirs.Down => ymod = 1,
        Dirs.Left => xmod = -1,
        Dirs.Right => xmod = 1,
        else => unreachable,
    }
    if (xmod < 0 and x == 0) return null;
    if (ymod < 0 and y == 0) return null;

    const nx: i16 = @as(i16, xmod) + x;
    const ny: i16 = @as(i16, ymod) + y;

    if (nx >= width or ny >= width) return null;

    return .{ @intCast(nx), @intCast(ny) };
}

fn walkLine(comptime width: u8, grid: *[width][width]Tile, ix: u8, iy: u8, idir: Dirs) void {
    var dir: Dirs = idir;
    var x: u8 = ix;
    var y: u8 = iy;
    while (true) {
        if (grid[y][x].visits[@intFromEnum(dir)]) return;
        grid[y][x].energized = true;
        grid[y][x].visits[@intFromEnum(dir)] = true;

        dir = grid[y][x].map[@intFromEnum(dir)];
        dir = switch (dir) {
            Dirs.SplitVertical => blk: {
                const onext = nextStep(width, Dirs.Up, x, y);
                if (onext) |next| {
                    walkLine(width, grid, next[0], next[1], Dirs.Up);
                }
                break :blk Dirs.Down;
            },
            Dirs.SplitHorizontal => blk: {
                const onext = nextStep(width, Dirs.Left, x, y);
                if (onext) |next| {
                    walkLine(width, grid, next[0], next[1], Dirs.Left);
                }
                break :blk Dirs.Right;
            },
            else => dir,
        };
        const next = nextStep(width, dir, x, y) orelse return;
        x = next[0];
        y = next[1];
    }
}

fn part1(input: []const u8, comptime width: u8) usize {
    var grid: [width][width]Tile = std.mem.zeroes([width][width]Tile);
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        if (c == '\r') continue;
        if (c == '\n') {
            x = 0;
            y += 1;
            continue;
        }

        grid[y][x].map = getDirs(c);
        x += 1;
    }

    walkLine(width, &grid, 0, 0, Dirs.Right);

    var total: usize = 0;
    for (grid) |row| {
        for (row) |tile| {
            if (tile.energized) total += 1;
        }
    }

    return total;
}

test "day16_part2" {
    const res = part2(testdata, 10);
    assert(res == 51);
}

fn resetGrid(comptime width: u8, grid: *[width][width]Tile) void {
    for (grid) |*row| {
        for (row) |*tile| {
            tile.energized = false;
            tile.visits = .{ false, false, false, false };
        }
    }
}

fn countGrid(comptime width: u8, grid: *[width][width]Tile) usize {
    var total: usize = 0;
    for (grid) |row| {
        for (row) |tile| {
            if (tile.energized) total += 1;
        }
    }
    return total;
}

fn tryGrid(comptime width: u8, grid: *[width][width]Tile, x: u8, y: u8, dir: Dirs) usize {
    walkLine(width, grid, x, y, dir);
    const total = countGrid(width, grid);
    resetGrid(width, grid);
    return total;
}

fn part2(input: []const u8, comptime width: u8) usize {
    var grid: [width][width]Tile = std.mem.zeroes([width][width]Tile);
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        if (c == '\r') continue;
        if (c == '\n') {
            x = 0;
            y += 1;
            continue;
        }

        grid[y][x].map = getDirs(c);
        x += 1;
    }

    var max: usize = 0;

    for (0..width) |vi| {
        const i: u8 = @intCast(vi);
        max = @max(max, tryGrid(width, &grid, i, 0, Dirs.Down));
        max = @max(max, tryGrid(width, &grid, 0, i, Dirs.Right));
        max = @max(max, tryGrid(width, &grid, (width - 1), i, Dirs.Left));
        max = @max(max, tryGrid(width, &grid, i, (width - 1), Dirs.Up));
    }

    return max;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, 110);
    const time = timer.lap();
    const res2 = part2(data, 110);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time});
    print("Part2 took {}ns\n", .{time2});
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
