const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day14.txt");
const testdata = "O....#....\nO.OO#....#\n.....##...\nOO.#O....O\n.O.....O#.\nO.#..O.#.#\n..O..#O..O\n.......O..\n#....###..\n#OO..#....";

test "day14_part1" {
    const res = part1(testdata, 10);
    assert(res == 136);
}

const Tile = enum {
    Open,
    Rock,
    Wall,
};

const Dirs = enum {
    North,
    East,
    South,
    West,
};

const Walk = struct {
    dir: Dirs,
    x: u8,
    y: u8,
    width: u8,
    started: bool,

    fn next(self: *Walk) ?[2]u8 {
        if (!self.started) {
            self.started = true;
            return .{ self.x, self.y };
        }

        switch (self.dir) {
            .North => {
                self.x += 1;
                if (self.x == self.width) {
                    if (self.y == self.width - 1) return null;
                    self.x = 0;
                    self.y += 1;
                }
            },
            .East => {
                if (self.y == 0) {
                    if (self.x == 0) return null;
                    self.y = self.width - 1;
                    self.x -= 1;
                } else self.y -= 1;
            },
            .South => {
                if (self.x == 0) {
                    if (self.y == 0) return null;
                    self.x = self.width - 1;
                    self.y -= 1;
                } else self.x -= 1;
            },
            .West => {
                self.y += 1;
                if (self.y == self.width) {
                    if (self.x == self.width - 1) return null;
                    self.y = 0;
                    self.x += 1;
                }
            },
        }

        return .{ self.x, self.y };
    }
};

inline fn buildWalk(dir: Dirs, width: u8) Walk {
    switch (dir) {
        .North => return Walk{ .dir = dir, .x = 0, .y = 0, .width = width, .started = false },
        .West => return Walk{ .dir = dir, .x = 0, .y = 0, .width = width, .started = false },
        .South => return Walk{ .dir = dir, .x = width - 1, .y = width - 1, .width = width, .started = false },
        .East => return Walk{ .dir = dir, .x = width - 1, .y = width - 1, .width = width, .started = false },
    }
}

fn shiftMap(comptime width: u8, map: *[width][width]Tile, dir: Dirs) void {
    var xmod: i2 = 0;
    var ymod: i2 = 0;

    switch (dir) {
        .North => ymod = -1,
        .East => xmod = 1,
        .South => ymod = 1,
        .West => xmod = -1,
    }

    var walk = buildWalk(dir, width);

    while (walk.next()) |coords| {
        const x = coords[0];
        const y = coords[1];

        if (map[y][x] != Tile.Rock) continue;

        var nx: i16 = x;
        var ny: i16 = y;
        while (true) {
            nx += xmod;
            ny += ymod;
            if (nx < 0 or nx >= width or ny < 0 or ny >= width) {
                nx -= xmod;
                ny -= ymod;
                break;
            }
            const next = map[@intCast(ny)][@intCast(nx)];
            if (next != Tile.Open) {
                nx -= xmod;
                ny -= ymod;
                break;
            }
        }
        map[y][x] = Tile.Open;
        map[@intCast(ny)][@intCast(nx)] = Tile.Rock;
    }
}

fn calcLoad(comptime width: u8, map: *[width][width]Tile, dir: Dirs) usize {
    var load: usize = 0;
    for (map, 0..) |row, y| {
        for (row, 0..) |tile, x| {
            if (tile == Tile.Rock) {
                load += switch (dir) {
                    .North => (width - y),
                    .East => (width - x),
                    .South => (y + 1),
                    .West => (x + 1),
                };
            }
        }
    }

    return load;
}

pub fn part1(input: []const u8, comptime width: u8) usize {
    var map: [width][width]Tile = undefined;
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        switch (c) {
            'O' => map[y][x] = Tile.Rock,
            '#' => map[y][x] = Tile.Wall,
            '.' => map[y][x] = Tile.Open,
            '\r' => continue,
            '\n' => {
                x = 0;
                y += 1;
                continue;
            },
            else => unreachable,
        }
        x += 1;
    }

    shiftMap(width, &map, Dirs.North);

    return calcLoad(width, &map, Dirs.North);
}

inline fn rotateMap(comptime width: u8, map: *[width][width]Tile) void {
    shiftMap(width, map, Dirs.North);
    shiftMap(width, map, Dirs.West);
    shiftMap(width, map, Dirs.South);
    shiftMap(width, map, Dirs.East);
}

test "day14_part2" {
    const res = try part2(testdata, 10);
    assert(res == 64);
}

pub fn part2(input: []const u8, comptime width: u8) !usize {
    var map: [width][width]Tile = undefined;
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        switch (c) {
            'O' => map[y][x] = Tile.Rock,
            '#' => map[y][x] = Tile.Wall,
            '.' => map[y][x] = Tile.Open,
            '\r' => continue,
            '\n' => {
                x = 0;
                y += 1;
                continue;
            },
            else => unreachable,
        }
        x += 1;
    }

    var cache = std.AutoHashMap([1950]u16, u32).init(gpa);
    var step: u32 = 0;
    var skipped: bool = false;

    while (step < 1000000000) {
        if (!skipped) {
            var key: [1950]u16 = comptime std.mem.zeroes([1950]u16);
            var ki: u16 = 0;
            for (map, 0..) |row, my| {
                for (row, 0..) |tile, mx| {
                    const char: u8 = switch (tile) {
                        .Open => '.',
                        .Rock => 'O',
                        .Wall => '#',
                    };
                    _ = char;
                    if (tile == Tile.Rock) {
                        key[ki] = @intCast((my << 8) | mx);
                        ki += 1;
                    }
                }
            }
            const incache = cache.get(key);
            if (incache) |cached| {
                const cycle = step - cached;
                const remaining = 1000000000 - step;
                step = 1000000000 - (remaining % cycle);
                skipped = true;
                continue;
            } else {
                try cache.put(key, step);
            }
        }
        rotateMap(width, &map);
        step += 1;
    }

    return calcLoad(width, &map, Dirs.North);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, 100);
    const time1 = timer.lap();
    const res2 = try part2(data, 100);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time1});
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
