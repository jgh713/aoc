const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day18.txt");
const testdata = "R 6 (#70c710)\nD 5 (#0dc571)\nL 2 (#5713f0)\nD 2 (#d2c081)\nR 2 (#59c680)\nD 2 (#411b91)\nL 5 (#8ceee2)\nU 2 (#caa173)\nL 1 (#1b58a2)\nU 2 (#caa171)\nR 2 (#7807d2)\nU 3 (#a77fa3)\nL 2 (#015232)\nU 2 (#7a21e3)";

test "day18_part1" {
    const res = part1(testdata);
    assert(res == 62);
}

const Tile = struct {
    color: u24 = 0,
    interior: ?bool = null,
    queued: bool = false,

    fn init() Tile {
        return .{ .color = 0, .interior = null, .queued = false };
    }
};
const mapwidth = 500;
const Tilemap = [mapwidth][mapwidth]Tile;

inline fn neighbors(x: u16, y: u16) [4]?[2]u16 {
    var res: [4]?[2]u16 = comptime std.mem.zeroes([4]?[2]u16);
    var count: u8 = 0;
    if (x > 0) {
        res[count] = .{ x - 1, y };
        count += 1;
    }
    if (x < mapwidth - 1) {
        res[count] = .{ x + 1, y };
        count += 1;
    }
    if (y > 0) {
        res[count] = .{ x, y - 1 };
        count += 1;
    }
    if (y < mapwidth - 1) {
        res[count] = .{ x, y + 1 };
        count += 1;
    }
    return res;
}

fn floodFillExterior(map: *Tilemap, ix: u16, iy: u16) void {
    if (map[iy][ix].interior) |_| return;
    var queue: [100000][2]u16 = undefined;
    var qi: u32 = 1;

    queue[0] = .{ ix, iy };

    while (qi > 0) {
        qi -= 1;
        const pos = queue[qi];
        const x = pos[0];
        const y = pos[1];
        if (map[y][x].interior) |_| continue;
        map[y][x].interior = false;

        for (neighbors(x, y)) |np| {
            if (np) |npc| {
                const nx = npc[0];
                const ny = npc[1];
                if (map[ny][nx].interior == null) {
                    queue[qi] = .{ nx, ny };
                    qi += 1;
                }
            }
        }
    }
}

fn buildMap(map: *Tilemap, input: []const u8) void {
    for (map) |*row| {
        for (row) |*tile| {
            tile.* = Tile.init();
        }
    }

    var x: u16 = 114;
    var y: u16 = 261;
    if (mapwidth < 100) {
        x = 0;
        y = 0;
    }
    var xmod: i2 = 0;
    var ymod: i2 = 0;

    print("Started build\n", .{});

    var lines = splitSca(u8, input, '\n');
    while (lines.next()) |line| {
        var args = splitSca(u8, line, ' ');
        switch (args.next().?[0]) {
            'R' => {
                xmod = 1;
                ymod = 0;
            },
            'L' => {
                xmod = -1;
                ymod = 0;
            },
            'U' => {
                xmod = 0;
                ymod = -1;
            },
            'D' => {
                xmod = 0;
                ymod = 1;
            },
            else => unreachable,
        }

        const distance = parseInt(u8, args.next().?, 16) catch unreachable;
        const color = parseInt(u24, args.next().?[2..8], 16) catch unreachable;

        for (0..distance) |_| {
            x = @intCast(@as(i32, x) + xmod);
            y = @intCast(@as(i32, y) + ymod);
            map[@intCast(y)][@intCast(x)] = Tile{ .color = color, .interior = true };
        }
    }

    print("Gothere\n", .{});

    for (0..mapwidth) |ix| {
        var iy: u32 = 0;
        while (iy < mapwidth and map[iy][ix].interior == null) {
            map[iy][ix].interior = false;
            iy += 1;
        }
        iy = mapwidth - 1;
        while (map[iy][ix].interior == null and iy > 0) {
            map[iy][ix].interior = false;
            iy -= 1;
        }
    }

    for (0..mapwidth) |iy| {
        var ix: u32 = 0;
        while (ix < mapwidth and map[iy][ix].interior == null) {
            map[iy][ix].interior = false;
            ix += 1;
        }
        ix = mapwidth - 1;
        while (map[iy][ix].interior == null and ix > 0) {
            map[iy][ix].interior = false;
            ix -= 1;
        }
    }

    for (0..mapwidth) |iy| {
        for (0..mapwidth) |ix| {
            if (map[iy][ix].interior == null) {
                neighbors: for (neighbors(@intCast(ix), @intCast(iy))) |np| {
                    if (np) |npc| {
                        const nx = npc[0];
                        const ny = npc[1];
                        if (map[ny][nx].interior == false) {
                            floodFillExterior(map, @intCast(ix), @intCast(iy));
                            break :neighbors;
                        }
                    }
                }
            }
        }
    }
}

fn printMap(map: *Tilemap) void {
    for (map) |row| {
        for (row) |tile| {
            if (tile.interior == null) {
                print("?", .{});
            } else if (tile.interior == false) {
                print(".", .{});
            } else {
                print("#", .{});
            }
        }
        print("\n", .{});
    }
}

pub fn part1(input: []const u8) usize {
    const sx: i32 = 0;
    const sy: i32 = 0;
    var x: i32 = sx;
    var y: i32 = sy;

    var top: i128 = 0;
    var bottom: i128 = 0;
    var perimeter: usize = 0;

    var lines = splitSca(u8, input, '\n');
    while (lines.next()) |line| {
        var args = splitSca(u8, line, ' ');
        const dir: u8 = args.next().?[0];

        const distance = parseInt(u8, args.next().?, 10) catch unreachable;
        //const color = parseInt(u24, args.next().?[2..8], 16) catch unreachable;
        //_ = color;

        var nx: i32 = x;
        var ny: i32 = y;

        switch (dir) {
            'R' => {
                nx += distance;
            },
            'L' => {
                nx -= distance;
            },
            'U' => {
                ny -= distance;
            },
            'D' => {
                ny += distance;
            },
            else => unreachable,
        }

        top += @as(i128, x) * ny;
        bottom += @as(i128, y) * nx;
        perimeter += distance;

        x = nx;
        y = ny;
    }

    if (x != sx or y != sy) {
        const nx = sx;
        const ny = sy;

        top += @as(i64, x) * ny;
        bottom += @as(i64, y) * nx;
        perimeter += @as(usize, @abs(@as(i64, sx) - @as(i64, x)) + @abs(@as(i64, sy) - @as(i64, y)));
    }

    const diff = @abs(@as(i256, top) - @as(i256, bottom));

    const res: usize = @intCast((diff + perimeter) / 2 + 1);
    return res;
}

test "day18_part2" {
    const res = part2(testdata);
    assert(res == 952408144115);
}

fn part2Slow(input: []const u8) u128 {
    const sx: i64 = 0;
    const sy: i64 = 0;
    var x: i64 = sx;
    var y: i64 = sy;

    var top: i256 = 0;
    var bottom: i256 = 0;
    var perimeter: u128 = 0;

    var lines = splitSca(u8, input, '\n');
    while (lines.next()) |line| {
        var args = splitSca(u8, line, ' ');
        const dir: u8 = args.next().?[0];
        _ = dir;

        _ = args.next();
        //const distance = parseInt(u8, args.next().?, 10) catch unreachable;
        const color = args.next().?[2..8];
        const distance = parseInt(u20, color[0..5], 16) catch unreachable;

        var nx: i64 = x;
        var ny: i64 = y;

        switch (color[5]) {
            '0' => {
                nx += distance;
            },
            '2' => {
                nx -= distance;
            },
            '3' => {
                ny -= distance;
            },
            '1' => {
                ny += distance;
            },
            else => unreachable,
        }

        top += @as(i128, x) * ny;
        bottom += @as(i128, y) * nx;
        perimeter += distance;

        x = nx;
        y = ny;
    }

    if (x != sx or y != sy) {
        const nx = sx;
        const ny = sy;

        top += @as(i128, x) * ny;
        bottom += @as(i128, y) * nx;
        perimeter += @as(u128, @abs(@as(i64, sx) - @as(i64, x)) + @abs(@as(i64, sy) - @as(i64, y)));
    }

    const diff = @abs(@as(i256, top) - @as(i256, bottom));

    return @intCast((diff + perimeter) / 2 + 1);
}

pub fn part2(input: []const u8) u128 {
    const sx: i128 = 0;
    const sy: i128 = 0;
    var x: i128 = sx;
    var y: i128 = sy;
    var diff: i128 = 0;
    var perimeter: u128 = 0;

    for (input, 0..) |c, i| {
        if (c != '#') continue;

        const color = input[i + 1 .. i + 7];
        const distance = parseInt(u20, color[0..5], 16) catch unreachable;

        var nx: i128 = x;
        var ny: i128 = y;

        switch (color[5]) {
            '0' => {
                nx += distance;
            },
            '2' => {
                nx -= distance;
            },
            '3' => {
                ny -= distance;
            },
            '1' => {
                ny += distance;
            },
            else => unreachable,
        }

        diff += (x * ny) - (y * nx);
        perimeter += distance;

        x = nx;
        y = ny;
    }

    return @intCast((@abs(diff) + perimeter) / 2 + 1);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part 1: {}\n", .{res});
    print("Part1 took {}ns\n", .{time});
    print("Part 2: {}\n", .{res2});
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
