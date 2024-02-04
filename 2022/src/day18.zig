const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day18.txt");
const testdata = "2,2,2\r\n1,2,2\r\n3,2,2\r\n2,1,2\r\n2,3,2\r\n2,2,1\r\n2,2,3\r\n2,2,4\r\n2,2,6\r\n1,2,5\r\n3,2,5\r\n2,1,5\r\n2,3,5";

test "day18_part1" {
    const res = part1(testdata);
    assert(res == 64);
}

pub fn part1(input: []const u8) usize {
    var map: [32][32][32]bool = comptime std.mem.zeroes([32][32][32]bool);
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        var coords = splitSeq(u8, line, ",");
        const coord = [3]usize{ parseInt(usize, coords.next().?, 10) catch unreachable, parseInt(usize, coords.next().?, 10) catch unreachable, parseInt(usize, coords.next().?, 10) catch unreachable };
        total += 6;
        for (0..3) |ci| {
            var newcoord = coord;
            newcoord[ci] += 1;
            if (map[newcoord[0]][newcoord[1]][newcoord[2]]) total -= 2;
            if (newcoord[ci] > 1) {
                newcoord[ci] -= 2;
                if (map[newcoord[0]][newcoord[1]][newcoord[2]]) total -= 2;
            }
        }
        map[coord[0]][coord[1]][coord[2]] = true;
    }
    return total;
}

test "day18_part2" {
    const res = part2(testdata);
    assert(res == 58);
}

pub fn part2(input: []const u8) usize {
    var map: [32][32][32]bool = comptime std.mem.zeroes([32][32][32]bool);
    var visited: [32][32][32]bool = comptime std.mem.zeroes([32][32][32]bool);
    var lines = splitSeq(u8, input, "\r\n");
    var maxx: usize = 0;
    var maxy: usize = 0;
    var maxz: usize = 0;
    while (lines.next()) |line| {
        var coords = splitSeq(u8, line, ",");
        const coord = [3]usize{ (parseInt(usize, coords.next().?, 10) catch unreachable) + 1, (parseInt(usize, coords.next().?, 10) catch unreachable) + 1, (parseInt(usize, coords.next().?, 10) catch unreachable) + 1 };
        map[coord[0]][coord[1]][coord[2]] = true;
        maxx = @max(maxx, coord[0]);
        maxy = @max(maxy, coord[1]);
        maxz = @max(maxz, coord[2]);
    }

    maxx += 1;
    maxy += 1;
    maxz += 1;

    var queue: [1000][3]usize = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    queue[0] = .{ 0, 0, 0 };

    var total: usize = 0;

    while (qstart != qend) : (qstart += 1) {
        if (qstart == 1000) qstart = 0;

        const coord = queue[qstart];
        //print("coord: {any}\n", .{coord});

        for (0..3) |ci| {
            var newcoord = coord;
            newcoord[ci] += 1;
            if (map[newcoord[0]][newcoord[1]][newcoord[2]]) {
                total += 1;
            } else if (!visited[newcoord[0]][newcoord[1]][newcoord[2]] and newcoord[0] <= maxx and newcoord[1] <= maxy and newcoord[2] <= maxz) {
                visited[newcoord[0]][newcoord[1]][newcoord[2]] = true;
                queue[qend] = newcoord;
                qend += 1;
                if (qend == 1000) qend = 0;
                if (qend == qstart) unreachable;
            }
            if (newcoord[ci] > 1) {
                newcoord[ci] -= 2;
                if (map[newcoord[0]][newcoord[1]][newcoord[2]]) {
                    total += 1;
                } else if (!visited[newcoord[0]][newcoord[1]][newcoord[2]] and newcoord[0] <= maxx and newcoord[1] <= maxy and newcoord[2] <= maxz) {
                    visited[newcoord[0]][newcoord[1]][newcoord[2]] = true;
                    queue[qend] = newcoord;
                    qend += 1;
                    if (qend == 1000) qend = 0;
                    if (qend == qstart) unreachable;
                }
            }
        }
    }

    print("total: {any}\n", .{total});

    return total;
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
