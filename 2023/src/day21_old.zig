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
    const res = part2(testdata, 49, 5, 11);
    _ = part2old(data);
    const res2 = part2manualish();
    print("Res is {}\n", .{res});
    print("Res2 is {}\n", .{res2});
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

fn part2old(input: []const u8) usize {
    var basemap: [131][131]Tile = comptime std.mem.zeroes([131][131]Tile);
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
    maxy = y + 1;

    print("maxx {}, maxy {}\n", .{ maxx, maxy });

    const mult = 75;

    var map: [][132 * mult]Tile = gpa.alloc([132 * mult]Tile, 132 * mult) catch unreachable;
    defer gpa.free(map);
    for (0..mult) |iy| {
        for (0..mult) |ix| {
            for (0..maxy) |my| {
                for (0..maxx) |mx| {
                    map[iy * maxy + my][ix * maxx + mx] = basemap[my][mx];
                }
            }
        }
    }

    sx = sx + 37 * maxx;
    sy = sy + 37 * maxy;

    maxx = mult * maxx;
    maxy = mult * maxy;

    var step: u32 = 0;
    var queue: [10000][2]u16 = undefined;
    var qlen: u16 = 0;
    var nextqueue: [10000][2]u16 = undefined;
    queue[0] = .{ sx, sy };
    qlen += 1;

    var counts: [2]u32 = .{0} ** 2;
    var solves: [4]f64 = .{0} ** 4;

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
        if (step == 6 or step == 10 or step == 50 or step == 100) {
            //print("Step {}, counts {any}\n", .{ step, counts });
        }
        if (step == (65)) {
            print("Step {}, counts {any} total {}\n", .{ step, counts, counts[0] + counts[1] });
            solves[0] = @floatFromInt(counts[0] + counts[1]);
        }
        if (step == 65 + 131) {
            print("Step {}, counts {any} total {}\n", .{ step, counts, counts[0] + counts[1] });
            solves[1] = @floatFromInt(counts[0] + counts[1]);
        }
        if (step == 65 + 2 * 131) {
            print("Step {}, counts {any} total {}\n", .{ step, counts, counts[0] + counts[1] });
            solves[2] = @floatFromInt(counts[0] + counts[1]);
        }
        if (step == 65 + 3 * 131) {
            print("Step {}, counts {any} total {}\n", .{ step, counts, counts[0] + counts[1] });
            break;
        }

        if (step % 2 == 1) {
            //print("{} / {} = {}\n", .{ counts[0] + counts[1], counts[0], @as(f64, @floatFromInt(counts[0] + counts[1])) / @as(f64, @floatFromInt(counts[0])) });
        }
        if (step == 49) {
            print("Step {}, counts {any} total {}\n", .{ step, counts, counts[0] + counts[1] });
        }
        step += 1;
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

    print("x0 {}, x1 {}, x2 {}\n", .{ x0, x1, x2 });

    return @intCast(x0 * n * n + x1 * n + x2);
}

fn part2manualish() usize {
    const steps: [4]f64 = .{ 65, 196, 327, 458 };
    const totals: [4]f64 = .{ 3917, 34628, 96829, 188962 };
    //print("totals: {any}\n", .{totals});
    //const diffs: [3]usize = .{ totals[1] - totals[0], totals[2] - totals[1], totals[3] - totals[2] };
    //print("diffs: {any}\n", .{diffs});
    //const diffdiffs: [2]usize = .{ diffs[1] - diffs[0], diffs[2] - diffs[1] };
    //print("diffdiffs: {any}\n", .{diffdiffs});
    //
    //var step: usize = 458;
    //var total: usize = 378606;
    //var diff: usize = 185435;
    //const diffdiff: usize = 61812;
    const target: f64 = 26501365;
    //
    //while (step < target) {
    //    step += 131;
    //    diff += diffdiff;
    //    total += diff;
    //}
    //
    //print("Step {}, total {}\n", .{ step, total });

    // Lagrange maybe?

    var result: f64 = 0;
    for (0..3) |i| {
        var term: f64 = totals[i];
        for (0..3) |j| {
            if (i != j) {
                const num: f64 = target - steps[j];
                const den: f64 = steps[i] - steps[j];
                term *= num / den;
            }
        }
        result += term;
    }

    print("Result: {}\n", .{result});

    return @intFromFloat(result);
}

fn part2(input: []const u8, steps: usize, half: u8, full: u8) usize {
    const halfval = part1(input, half);
    const fullval = part1(input, full + 100);

    const squaresteps = (steps - half) / full;

    var fullsquare_count: usize = 1;
    var mod: usize = 0;
    var step: usize = 1;

    while (step < squaresteps) {
        mod += 4;
        fullsquare_count += mod;
        step += 1;
    }

    const fullcount = fullsquare_count * fullval;

    const halfcount = (mod + 4);
    const halfsteps = (halfcount / 2) * fullval;

    const total = fullcount + halfsteps + (steps * 2);

    print("halfval {}, fullval {}, squaresteps {}, fullsquare_count {}, mod {}, fullcount {}, halfcount {}, halfsteps {}, total {}\n", .{ halfval, fullval, squaresteps, fullsquare_count, mod, fullcount, halfcount, halfsteps, total });

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, 64);
    const time = timer.lap();
    // const res2 = 644371718675717;
    const res2 = 632421652138916;
    const time2 = "way too damn long";
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
