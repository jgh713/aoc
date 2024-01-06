const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day21.txt");
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

fn part1(input: []const u8, steps: u8) usize {
    var map: [131][131]Tile = std.mem.zeroes([131][131]Tile);
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

    //for (0..maxy) |iy| {
    //    for (0..maxx) |ix| {
    //        if (iy == sy and ix == sx) {
    //            print("S", .{});
    //        } else if (map[iy][ix].wall) {
    //            print("#", .{});
    //        } else if (!map[iy][ix].visited) {
    //            print(".", .{});
    //        } else if (map[iy][ix].odd) {
    //            print("O", .{});
    //        } else if (!map[iy][ix].odd) {
    //            print("E", .{});
    //        } else {
    //            print("?", .{});
    //        }
    //    }
    //    print("\n", .{});
    //}

    //print("counts: {}, {}\n", .{ counts[0], counts[1] });

    return counts[steps % 2];
}

test "day21_part2" {
    const res = part2(data);
    print("Res is {}\n", .{res});
}

fn neighbors16(x: u16, y: u16, maxx: u16, maxy: u16) [4]?[2]u16 {
    var res: [4]?[2]u16 = .{null} ** 4;
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

fn part2(input: []const u8) usize {
    var basemap: [131][131]Tile = std.mem.zeroes([131][131]Tile);
    var x: u8 = 0;
    var y: u8 = 0;
    var maxx: u16 = 0;
    var maxy: u16 = 0;
    var sx: u16 = 0;
    var sy: u16 = 0;

    for (input) |c| {
        switch (c) {
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '\r' => continue,
            '#' => basemap[y][x].wall = true,
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

    const mult = 11;

    var map: [132 * mult][132 * mult]Tile = undefined;
    for (0..mult) |iy| {
        for (0..mult) |ix| {
            for (0..maxy) |my| {
                for (0..maxx) |mx| {
                    map[iy * maxy + my][ix * maxx + mx] = basemap[my][mx];
                }
            }
        }
    }

    sx = sx + 5 * maxx;
    sy = sy + 5 * maxy;

    maxx = mult * maxx;
    maxy = mult * maxy;

    var step: u32 = 0;
    var queue: [10000][2]u16 = undefined;
    var qlen: u16 = 0;
    var nextqueue: [10000][2]u16 = undefined;
    queue[0] = .{ sx, sy };
    qlen += 1;

    var counts: [2]u32 = .{0} ** 2;
    var solves: [3]f64 = .{0} ** 3;
    var last: usize = 0;

    outerwhile: while (true) {
        var nlen: u16 = 0;
        for (queue[0..qlen]) |pos| {
            const qx = pos[0];
            const qy = pos[1];
            map[qy][qx].visited = true;
            map[qy][qx].odd = step % 2 == 1;
            counts[step % 2] += 1;
            const ns = neighbors16(qx, qy, maxx, maxy);
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
        if (step >= 65) {
            if ((step - 65) % 131 == 0) {
                const diff = counts[step % 2] - last;
                print("Step {}, counts {}\n", .{ step, counts[step % 2] });
                print("Diff {}\n", .{diff});
                last = counts[step % 2];
            }
        }
        if (step > 1000) {
            solves[0] = 0;
            break :outerwhile;
        }
        queue = nextqueue;
        qlen = nlen;
    }

    // Cramer's rule is a miserable bastard and working this out sucked.
    // Honestly should have just done this by hand.

    const n = (26501365 - 65) / 131;

    print("N {}\n", .{n});

    print("Solves: {d}, {d}, {d}\n", .{ solves[0], solves[1], solves[2] });

    const da: f64 = -2.0;
    const d0 = -solves[0] + (2.0 * solves[1]) - solves[2];
    const d1 = (3.0 * solves[0]) - (4.0 * solves[1]) + solves[2];
    const d2 = -2.0 * solves[0];

    const x0: i64 = @intFromFloat(d0 / da);
    const x1: i64 = @intFromFloat(d1 / da);
    const x2: i64 = @intFromFloat(d2 / da);

    return @intCast(x0 * n * n + x1 * n + x2);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, 64);
    const time = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part1 took {}ns\n", .{time});
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
