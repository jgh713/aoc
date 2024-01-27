const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day11.txt");
const testdata = "...#......\n.......#..\n#.........\n..........\n......#...\n.#........\n.........#\n..........\n.......#..\n#...#.....";

test "day11" {
    const galaxy = parseInput(testdata);
    var res = day11(galaxy, 2);
    assert(res == 374);
    res = day11(galaxy, 10);
    assert(res == 1030);
    res = day11(galaxy, 100);
    assert(res == 8410);
}

const Loc = struct {
    x: u8,
    y: u8,
};

fn day11slow(input: []const u8, width: u32) u128 {
    var x: u8 = 0;
    var y: u8 = 0;
    var cols: [140]bool = [1]bool{false} ** 140;
    var rows: [140]bool = [1]bool{false} ** 140;
    var galaxies: [450]Loc = undefined;
    var galaxy: u16 = 0;

    for (input) |c| {
        switch (c) {
            '\r' => {
                continue;
            },
            '\n' => {
                x = 0;
                y += 1;
            },
            '.' => {
                x += 1;
            },
            '#' => {
                cols[x] = true;
                rows[y] = true;
                galaxies[galaxy] = .{ .x = x, .y = y };
                galaxy += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    var total: u128 = 0;
    var extras: u32 = 0;

    for (galaxies[0 .. galaxy - 1], 0..) |gal1, gi| {
        for (galaxies[gi + 1 .. galaxy]) |gal2| {
            var min: usize = @min(gal1.x, gal2.x);
            var max: usize = @max(gal1.x, gal2.x);
            total += max - min;
            for (min..max) |ix| {
                extras += if (cols[ix]) 0 else 1;
            }
            min = @min(gal1.y, gal2.y);
            max = @max(gal1.y, gal2.y);
            total += max - min;
            for (min..max) |iy| {
                extras += if (rows[iy]) 0 else 1;
            }
        }
    }

    total += extras * (width - 1);

    return total;
}

fn day11mid(input: []const u8, width: u32) u128 {
    var x: u8 = 0;
    var y: u8 = 0;
    var cols: [140]u8 = [1]u8{0} ** 140;
    var rows: [140]u8 = [1]u8{0} ** 140;

    for (input) |c| {
        switch (c) {
            '\r' => {},
            '\n' => {
                x = 0;
                y += 1;
            },
            '.' => {
                x += 1;
            },
            '#' => {
                cols[x] += 1;
                rows[y] += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    var total: u128 = 0;
    var extras: u128 = 0;

    for (rows[0..], 0..) |r1, ri1| {
        if (r1 == 0) continue;
        for (rows[ri1 + 1 ..], ri1 + 1..) |r2, ri2| {
            if (r2 == 0) continue;
            const size: u32 = r1 * r2;
            total += (ri2 - ri1) * size;
            for (ri1..ri2) |ix| {
                if (rows[ix] == 0) {
                    extras += size;
                }
            }
        }
    }

    for (cols[0..], 0..) |c1, ci1| {
        if (c1 == 0) continue;
        for (cols[(ci1 + 1)..], (ci1 + 1)..) |c2, ci2| {
            if (c2 == 0) continue;
            const size: u32 = c1 * c2;
            total += (ci2 - ci1) * size;
            for (ci1..ci2) |iy| {
                if (cols[iy] == 0) {
                    extras += size;
                }
            }
        }
    }

    total += extras * (width - 1);

    return total;
}

const Galaxy = struct {
    count: u16,
    cols: [140]u8,
    rows: [140]u8,
};

pub fn parseInput(input: []const u8) Galaxy {
    var x: u8 = 0;
    var y: u8 = 0;
    var cols: [140]u8 = [1]u8{0} ** 140;
    var rows: [140]u8 = [1]u8{0} ** 140;
    var gcount: u16 = 0;

    for (input) |c| {
        if (c == '#') {
            cols[x] += 1;
            rows[y] += 1;
            gcount += 1;
        }

        x += 1;
        if ((c) == '\n') {
            y += 1;
            x = 0;
        }
    }

    return Galaxy{ .count = gcount, .cols = cols, .rows = rows };
}

pub fn day11(galaxy: Galaxy, width: u32) u128 {
    const cols = galaxy.cols;
    const rows = galaxy.rows;
    const gcount = galaxy.count;

    var total: u128 = 0;
    var extras: u128 = 0;

    var left: u16 = 0;
    var right: u16 = gcount;

    for (rows[0..]) |rval| {
        left += rval;
        right -= rval;
        const size = left * right;
        total += size;
        extras += if (rval == 0) size else 0;
    }

    left = 0;
    right = gcount;

    for (cols[0..]) |cval| {
        left += cval;
        right -= cval;
        const size = left * right;
        total += size;
        extras += if (cval == 0) size else 0;
    }

    return total + extras * (width - 1);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const galaxy = parseInput(data);
    const parsetime = timer.lap();
    const res = day11(galaxy, 2);
    const time1 = timer.lap();
    const res2 = day11(galaxy, 1000000);
    const time2 = timer.lap();
    print("Part 1: {}\n", .{res});
    print("Part 2: {}\n", .{res2});
    print("Parse took {}ns\n", .{parsetime});
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
