const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");
const testdata = "#.##..##.\n..#.##.#.\n##......#\n##......#\n..#.##.#.\n..##..##.\n#.#.##.#.\n\n#...##..#\n#....#..#\n..##..###\n#####.##.\n#####.##.\n..##..###\n#....#..#\n\n";

test "day13_part1" {
    const res = part1(testdata);
    assert(res == 405);
}

fn calcMirrors(map: [20][20]bool, maxy: u5, maxx: u5) usize {
    var rows: [20]u20 = undefined;
    var cols: [20]u20 = undefined;

    for (0..maxy) |y| {
        var int: u20 = @as(u20, 1) << maxx;
        for (0..maxx) |x| {
            int |= @as(u20, @intFromBool(map[y][x])) << @intCast(x);
        }
        rows[y] = int;
    }

    for (0..maxx) |x| {
        var int: u20 = @as(u20, 1) << maxy;
        for (0..maxy) |y| {
            int = int | (@as(u20, @intFromBool(map[y][x])) << @intCast(y));
        }
        cols[x] = int;
    }

    var total: usize = 0;

    for (1..(maxy)) |starty| {
        var top: u5 = @intCast(starty);
        var bottom: u5 = @intCast(starty - 1);
        const hit = hit: while (true) {
            if (top == 0 or bottom == (maxy - 1)) {
                break :hit true;
            }
            top -= 1;
            bottom += 1;
            if (rows[top] != rows[bottom]) {
                break :hit false;
            }
        };
        if (hit) {
            total += (100 * starty);
        }
    }

    for (1..(maxx)) |startx| {
        var left: u5 = @intCast(startx);
        var right: u5 = @intCast(startx - 1);
        const hit = hit: while (true) {
            if (left == 0 or right == (maxx - 1)) {
                break :hit true;
            }
            left -= 1;
            right += 1;
            if (cols[left] != cols[right]) {
                break :hit false;
            }
        };
        if (hit) {
            total += startx;
        }
    }
    return total;
}

fn part1(input: []const u8) usize {
    var x: u5 = 0;
    var y: u5 = 0;
    var maxx: u5 = 0;

    var map: [20][20]bool = undefined;
    var total: usize = 0;

    for (input) |c| {
        switch (c) {
            '\n' => {
                if (x > 0) {
                    maxx = x;
                    x = 0;
                    y += 1;
                } else {
                    total += calcMirrors(map, y, maxx);
                    x = 0;
                    y = 0;
                }
                continue;
            },
            '\r' => continue,
            '#' => map[y][x] = true,
            '.' => map[y][x] = false,
            else => unreachable,
        }
        x += 1;
    }

    return total;
}

test "day13_part2" {
    const res = part2(testdata);
    assert(res == 400);
}

fn calcSmudges(map: [20][20]bool, maxy: u5, maxx: u5) usize {
    var rows: [20]u20 = undefined;
    var cols: [20]u20 = undefined;

    for (0..maxy) |y| {
        var int: u20 = @as(u20, 1) << maxx;
        for (0..maxx) |x| {
            int |= @as(u20, @intFromBool(map[y][x])) << @intCast(x);
        }
        rows[y] = int;
    }

    for (0..maxx) |x| {
        var int: u20 = @as(u20, 1) << maxy;
        for (0..maxy) |y| {
            int = int | (@as(u20, @intFromBool(map[y][x])) << @intCast(y));
        }
        cols[x] = int;
    }

    var total: usize = 0;

    for (1..(maxy)) |starty| {
        var top: u5 = @intCast(starty);
        var bottom: u5 = @intCast(starty - 1);
        var mismatches: usize = 0;
        mmloop: while (true) {
            if (top == 0 or bottom == (maxy - 1)) {
                break :mmloop;
            }
            top -= 1;
            bottom += 1;
            const comp = rows[top] ^ rows[bottom];
            mismatches += @popCount(comp);
        }
        if (mismatches == 1) {
            total += (100 * starty);
        }
    }

    for (1..(maxx)) |startx| {
        var left: u5 = @intCast(startx);
        var right: u5 = @intCast(startx - 1);
        var mismatches: usize = 0;
        mmloop: while (true) {
            if (left == 0 or right == (maxx - 1)) {
                break :mmloop;
            }
            left -= 1;
            right += 1;
            const comp = cols[left] ^ cols[right];
            mismatches += @popCount(comp);
        }
        if (mismatches == 1) {
            total += startx;
        }
    }
    return total;
}

fn part2(input: []const u8) usize {
    var x: u5 = 0;
    var y: u5 = 0;
    var maxx: u5 = 0;

    var map: [20][20]bool = undefined;
    var total: usize = 0;

    for (input) |c| {
        switch (c) {
            '\n' => {
                if (x > 0) {
                    maxx = x;
                    x = 0;
                    y += 1;
                } else {
                    total += calcSmudges(map, y, maxx);
                    x = 0;
                    y = 0;
                }
                continue;
            },
            '\r' => continue,
            '#' => map[y][x] = true,
            '.' => map[y][x] = false,
            else => unreachable,
        }
        x += 1;
    }

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
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
