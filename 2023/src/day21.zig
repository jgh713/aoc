const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day21.txt");
const testdata = "...........\n.....###.#.\n.###.##..#.\n..#.#...#..\n....#.#....\n.##..S####.\n.##..#...#.\n.......##..\n.##.#.####.\n.##..##.##.\n...........";

test "day21_part1" {
    const res = part1(testdata, 6);
    assert(res == 16);
}

const Tile = struct {
    wall: bool,
    visited: bool,
    odd: bool,
    queued: bool,
};

fn neighbors(x: u8, y: u8, maxx: u8, maxy: u8) [4]?[2]u8 {
    var res: [4]?[2]u8 = .{null} ** 4;
    if (x > 0) {
        res[0] = .{ x - 1, y };
    }
    if (x < (maxx - 1)) {
        res[1] = .{ x + 1, y };
    }
    if (y > 0) {
        res[2] = .{ x, y - 1 };
    }
    if (y < (maxy - 1)) {
        res[3] = .{ x, y + 1 };
    }
    return res;
}

fn walkMap(input_map: [131][131]Tile, sx: u8, sy: u8, maxx: u8, maxy: u8, steps: u8) usize {
    var map = input_map;
    var step: u32 = 0;
    var queue: [1000][2]u8 = undefined;
    var qlen: u16 = 0;
    var nextqueue: [1000][2]u8 = undefined;
    queue[0] = .{ sx, sy };
    qlen += 1;

    var counts: [2]u32 = .{0} ** 2;

    while (step <= steps) {
        var nlen: u16 = 0;
        for (queue[0..qlen]) |pos| {
            const qx = pos[0];
            const qy = pos[1];
            map[qy][qx].visited = true;
            map[qy][qx].odd = step % 2 == 1;
            counts[step % 2] += 1;
            const ns = neighbors(qx, qy, maxx, maxy);
            for (ns) |nopt| {
                if (nopt) |n| {
                    const nx = n[0];
                    const ny = n[1];
                    if (map[ny][nx].wall or map[ny][nx].visited or map[ny][nx].queued) {
                        continue;
                    }
                    map[ny][nx].queued = true;
                    nextqueue[nlen] = .{ nx, ny };
                    nlen += 1;
                }
            }
        }
        step += 1;
        queue = nextqueue;
        qlen = nlen;
    }

    //print("Res for {}, {} with {} steps is {}\n", .{ sx, sy, steps, counts[steps % 2] });
    return counts[steps % 2];
}

pub fn part1(input: []const u8, steps: u8) usize {
    var map: [131][131]Tile = comptime std.mem.zeroes([131][131]Tile);
    var x: u8 = 0;
    var y: u8 = 0;
    var maxx: u8 = 0;
    var maxy: u8 = 0;
    var sx: u8 = 0;
    var sy: u8 = 0;

    for (input) |c| {
        switch (c) {
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '\r' => continue,
            '#' => map[y][x].wall = true,
            'S' => {
                sx = x;
                sy = y;
            },
            '.' => {},
            else => unreachable,
        }
        x += 1;
    }

    maxx = x;
    maxy = y;

    return walkMap(map, sx, sy, maxx, maxy, steps);
}

test "day21_part2" {
    const res = part2(data);
    print("Res is {}\n", .{res});
    assert(res == 632421652138917);
}

pub fn part2(input: []const u8) usize {
    var map: [131][131]Tile = comptime std.mem.zeroes([131][131]Tile);
    var x: u8 = 0;
    var y: u8 = 0;
    var maxx: u8 = 0;
    var maxy: u8 = 0;
    var sx: u8 = 0;
    var sy: u8 = 0;

    for (input) |c| {
        switch (c) {
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '\r' => continue,
            '#' => map[y][x].wall = true,
            'S' => {
                sx = x;
                sy = y;
            },
            '.' => {},
            else => unreachable,
        }
        x += 1;
    }

    maxx = x;
    maxy = y + 1;

    var squares: [2]usize = undefined;
    squares[0] = walkMap(map, sx, sy, maxx, maxy, 129);
    squares[1] = walkMap(map, sx, sy, maxx, maxy, 130);

    const corners: [4][2]u8 = .{ .{ 0, 0 }, .{ 130, 0 }, .{ 0, 130 }, .{ 130, 130 } };

    var smalls: usize = 0;
    var bigs: usize = 0;
    for (corners) |c| {
        const cx = c[0];
        const cy = c[1];
        smalls += walkMap(map, cx, cy, maxx, maxy, 64);
        bigs += walkMap(map, cx, cy, maxx, maxy, 195);
    }

    const midpoints: [4][2]u8 = .{ .{ 0, 65 }, .{ 65, 0 }, .{ 130, 65 }, .{ 65, 130 } };

    var tips: usize = 0;
    for (midpoints) |c| {
        const cx = c[0];
        const cy = c[1];
        tips += walkMap(map, cx, cy, maxx, maxy, 130);
    }

    const edgelen = (26501365 / 131);
    //print("Edge len is {}\n", .{edgelen});

    var squarecounts: [2]usize = .{ 1, 0 };

    var amt: usize = 0;

    for (0..edgelen) |i| {
        squarecounts[i % 2] += amt;
        amt += 4;
    }

    //print("Squarecounts are {}, {}\n", .{ squarecounts[0], squarecounts[1] });

    const squaresize = squarecounts[0] * squares[0] + squarecounts[1] * squares[1];

    const total = squaresize + (smalls * edgelen) + (bigs * (edgelen - 1)) + tips;

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, 64);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    // Honestly gave up on part2 and solved it by hand.
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
