const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day09.txt");
const testdata = "2199943210\r\n3987894921\r\n9856789892\r\n8767896789\r\n9899965678";

test "day09_part1" {
    const res = part1(testdata);
    assert(res == 15);
}

pub fn part1(input: []const u8) usize {
    var map: [100][100]u4 = undefined;
    var lines = splitSeq(u8, input, "\r\n");
    const maxx = lines.peek().?.len;

    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            map[y][x] = @intCast(c - '0');
        }
    }
    const maxy = y;

    var total: usize = 0;

    for (0..maxy) |uy| {
        const iy: isize = @intCast(uy);
        outfor: for (0..maxx) |ux| {
            const ix: isize = @intCast(ux);
            const val = map[uy][ux];
            infor: for ([_][2]i2{ .{ 0, -1 }, .{ 0, 1 }, .{ -1, 0 }, .{ 1, 0 } }) |mods| {
                const iny = iy + mods[0];
                const inx = ix + mods[1];
                if (iny < 0 or iny >= maxy or inx < 0 or inx >= maxx) {
                    continue :infor;
                }
                if (map[@intCast(iny)][@intCast(inx)] <= val) continue :outfor;
            }
            total += val + 1;
        }
    }

    return total;
}

test "day09_part2" {
    const res = part2(testdata);
    assert(res == 1134);
}

pub fn part2(input: []const u8) usize {
    var map: [100][100]u4 = undefined;
    var lines = splitSeq(u8, input, "\r\n");
    const maxx = lines.peek().?.len;

    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            map[y][x] = @intCast(c - '0');
        }
    }
    const maxy = y;

    var highest: [3]usize = comptime std.mem.zeroes([3]usize);

    for (0..maxy) |uy| {
        const iy: isize = @intCast(uy);
        outfor: for (0..maxx) |ux| {
            const ix: isize = @intCast(ux);
            const val = map[uy][ux];
            infor: for ([_][2]i2{ .{ 0, -1 }, .{ 0, 1 }, .{ -1, 0 }, .{ 1, 0 } }) |mods| {
                const iny = iy + mods[0];
                const inx = ix + mods[1];
                if (iny < 0 or iny >= maxy or inx < 0 or inx >= maxx) {
                    continue :infor;
                }
                if (map[@intCast(iny)][@intCast(inx)] <= val) continue :outfor;
            }

            var visited: [100][100]bool = comptime std.mem.zeroes([100][100]bool);
            var queue: [100][2]isize = undefined;
            queue[0] = .{ ix, iy };
            var qstart: usize = 0;
            var qend: usize = 1;

            var count: usize = 1;
            visited[@intCast(iy)][@intCast(ix)] = true;
            while (qstart != qend) : (qstart += 1) {
                if (qstart == 100) qstart = 0;
                const qix = queue[qstart][0];
                const qiy = queue[qstart][1];
                for ([_][2]i2{ .{ 0, -1 }, .{ 0, 1 }, .{ -1, 0 }, .{ 1, 0 } }) |mods| {
                    const qiny = qiy + mods[0];
                    const qinx = qix + mods[1];
                    if (qiny < 0 or qiny >= maxy or qinx < 0 or qinx >= maxx) {
                        continue;
                    }
                    if (map[@intCast(qiny)][@intCast(qinx)] == 9) continue;
                    if (visited[@intCast(qiny)][@intCast(qinx)]) continue;
                    queue[qend] = .{ qinx, qiny };
                    visited[@intCast(qiny)][@intCast(qinx)] = true;
                    count += 1;
                    qend += 1;
                    if (qend == 100) qend = 0;
                    if (qend == qstart) unreachable;
                }
            }
            //print("Basin has size {}\n", .{count});
            for (0..3) |i| {
                if (count > highest[i]) {
                    var j: usize = 2;
                    while (j > i) : (j -= 1) {
                        highest[j] = highest[j - 1];
                    }
                    highest[i] = count;
                    break;
                }
            }
        }
    }

    return highest[0] * highest[1] * highest[2];
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 09:\n", .{});
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
