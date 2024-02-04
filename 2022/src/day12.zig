const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day12.txt");
const testdata = "Sabqponm\r\nabcryxxl\r\naccszExk\r\nacctuvwj\r\nabdefghi";

test "day12_part1" {
    const res = part1(testdata);
    print("res: {}\n", .{res});
    assert(res == 31);
}

const Tile = struct {
    elevation: i16,
    steps: usize,
    queued: bool,
};

const HillMap = struct {
    tiles: [41][144]Tile,
    start: [2]usize,
    end: [2]usize,
};

fn parseMap(input: []const u8) HillMap {
    var map: [41][144]Tile = comptime std.mem.zeroes([41][144]Tile);
    var x: usize = 0;
    var y: usize = 0;
    var start: [2]usize = undefined;
    var end: [2]usize = undefined;

    for (input) |c| {
        switch (c) {
            'a'...'z' => {
                map[y][x].elevation = c - 'a' + 1;
                x += 1;
            },
            'S' => {
                map[y][x].elevation = 1;
                start = .{ x, y };
                x += 1;
            },
            'E' => {
                map[y][x].elevation = 26;
                end = .{ x, y };
                x += 1;
            },
            '\r' => {},
            '\n' => {
                y += 1;
                x = 0;
            },
            else => unreachable,
        }
    }

    return HillMap{ .tiles = map, .start = start, .end = end };
}

pub fn part1(input: []const u8) usize {
    var map = parseMap(input);

    var queue: [41 * 144][2]isize = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    queue[0] = .{ @intCast(map.start[0]), @intCast(map.start[1]) };

    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) {
            qstart = 0;
        }

        const node = queue[qstart];
        var oldtile = &map.tiles[@intCast(node[1])][@intCast(node[0])];
        oldtile.queued = false;
        const step = map.tiles[@intCast(node[1])][@intCast(node[0])].steps + 1;

        for ([_][2]isize{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } }) |mods| {
            const inx = node[0] + mods[0];
            const iny = node[1] + mods[1];
            if (inx >= 0 and inx < 144 and iny >= 0 and iny < 41) {
                const nx: usize = @abs(inx);
                const ny: usize = @abs(iny);
                const tile = &map.tiles[ny][nx];

                if (tile.elevation == 0) continue;
                if (tile.steps > 0 and tile.steps <= step) continue;
                if (oldtile.elevation < (tile.elevation - 1)) continue;

                tile.steps = step;
                if (!tile.queued) {
                    tile.queued = true;
                    queue[qend] = .{ inx, iny };
                    qend += 1;
                    if (qend == queue.len) {
                        qend = 0;
                    }
                }
            }
        }
    }

    return map.tiles[@intCast(map.end[1])][@intCast(map.end[0])].steps;
}

test "day12_part2" {
    const res = part2(testdata);
    print("res: {}\n", .{res});
    assert(res == 29);
}

pub fn part2(input: []const u8) usize {
    var map = parseMap(input);

    var queue: [41 * 144][2]isize = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    queue[0] = .{ @intCast(map.end[0]), @intCast(map.end[1]) };

    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) {
            qstart = 0;
        }

        const node = queue[qstart];
        var oldtile = &map.tiles[@intCast(node[1])][@intCast(node[0])];
        oldtile.queued = false;
        const step = map.tiles[@intCast(node[1])][@intCast(node[0])].steps + 1;

        for ([_][2]isize{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } }) |mods| {
            const inx = node[0] + mods[0];
            const iny = node[1] + mods[1];
            if (inx >= 0 and inx < 144 and iny >= 0 and iny < 41) {
                const nx: usize = @abs(inx);
                const ny: usize = @abs(iny);
                const tile = &map.tiles[ny][nx];

                if (tile.elevation == 0) continue;
                if (tile.steps > 0 and tile.steps <= step) continue;
                if (oldtile.elevation > (tile.elevation + 1)) continue;

                tile.steps = step;
                if (!tile.queued) {
                    tile.queued = true;
                    queue[qend] = .{ inx, iny };
                    qend += 1;
                    if (qend == queue.len) {
                        qend = 0;
                    }
                }
            }
        }
    }

    var min: usize = std.math.maxInt(usize);

    for (map.tiles) |row| {
        for (row) |tile| {
            if (tile.elevation == 1 and tile.steps > 0) {
                min = @min(min, tile.steps);
            }
        }
    }

    return min;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 12:\n", .{});
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
