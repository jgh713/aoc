const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day15.txt");
const testdata = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15\r\nSensor at x=9, y=16: closest beacon is at x=10, y=16\r\nSensor at x=13, y=2: closest beacon is at x=15, y=3\r\nSensor at x=12, y=14: closest beacon is at x=10, y=16\r\nSensor at x=10, y=20: closest beacon is at x=10, y=16\r\nSensor at x=14, y=17: closest beacon is at x=10, y=16\r\nSensor at x=8, y=7: closest beacon is at x=2, y=10\r\nSensor at x=2, y=0: closest beacon is at x=2, y=10\r\nSensor at x=0, y=11: closest beacon is at x=2, y=10\r\nSensor at x=20, y=14: closest beacon is at x=25, y=17\r\nSensor at x=17, y=20: closest beacon is at x=21, y=22\r\nSensor at x=16, y=7: closest beacon is at x=15, y=3\r\nSensor at x=14, y=3: closest beacon is at x=15, y=3\r\nSensor at x=20, y=1: closest beacon is at x=15, y=3";

test "day15_part1" {
    const res = part1(testdata, 10);
    assert(res == 26);
}

fn nextInt(line: []const u8, index: *usize) isize {
    var i = index.*;
    while (!isDigit(line[i])) i += 1;
    const start = i;
    while (i < line.len and isDigit(line[i])) i += 1;
    const end = i;
    index.* = i;
    return parseInt(isize, line[start..end], 10) catch unreachable;
}

inline fn isDigit(c: u8) bool {
    return (c >= '0' and c <= '9') or c == '-';
}

const Signal = struct {
    sx: isize,
    sy: isize,
    bx: isize,
    by: isize,
};

pub fn part1(input: []const u8, targety: isize) usize {
    var signals: [25]Signal = undefined;
    var si: usize = 0;
    var linemap = Map(isize, void).init(gpa);
    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        var index: usize = 12;
        const sx = nextInt(line, &index);
        const sy = nextInt(line, &index);
        index += 23;
        const bx = nextInt(line, &index);
        const by = nextInt(line, &index);
        signals[si] = .{ .sx = sx, .sy = sy, .bx = bx, .by = by };
        si += 1;
    }

    for (signals[0..si]) |signal| {
        const diffx: isize = @intCast(@abs(signal.sx - signal.bx));
        const diffy: isize = @intCast(@abs(signal.sy - signal.by));
        const dist: isize = diffx + diffy;
        const linediff: isize = @intCast(@abs(signal.sy - targety));
        const ddiff: isize = dist - linediff;
        const yleft = signal.sx - ddiff;
        const yright = signal.sx + ddiff;

        var yval = yleft;
        while (yval <= yright) : (yval += 1) {
            linemap.put(yval, {}) catch unreachable;
        }
    }

    for (signals[0..si]) |signal| {
        if (signal.by == targety) {
            _ = linemap.remove(signal.bx);
        }
    }
    return linemap.count();
}

test "day15_part2" {
    const res = part2(testdata, 20);
    assert(res == 56000011);
}

pub fn part2(input: []const u8, maxsize: usize) usize {
    var signals: [25]Signal = undefined;
    var si: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        var index: usize = 12;
        const sx = nextInt(line, &index);
        const sy = nextInt(line, &index);
        index += 23;
        const bx = nextInt(line, &index);
        const by = nextInt(line, &index);
        signals[si] = .{ .sx = sx, .sy = sy, .bx = bx, .by = by };
        si += 1;
    }

    for (signals[0..si]) |signal| {
        const diffx: isize = @intCast(@abs(signal.sx - signal.bx));
        const diffy: isize = @intCast(@abs(signal.sy - signal.by));
        const dist: isize = diffx + diffy;
        const mid = signal.sx;
        const right = mid + dist + 1;
        const left = mid - dist - 1;
        var px = right;
        var py = signal.sy;

        const steps: [4][3]isize = .{
            .{ -1, -1, mid },
            .{ -1, 1, left },
            .{ 1, 1, mid },
            .{ 1, -1, right },
        };

        for (steps) |step| {
            stepwhile: while (px != step[2]) : ({
                px += step[0];
                py += step[1];
            }) {
                if (px >= 0 and py >= 0 and px <= maxsize and py <= maxsize) {
                    for (signals[0..si]) |tsignal| {
                        const tdiffx: isize = @intCast(@abs(tsignal.sx - tsignal.bx));
                        const tdiffy: isize = @intCast(@abs(tsignal.sy - tsignal.by));
                        const tdist: isize = tdiffx + tdiffy;

                        const pdiffx: isize = @intCast(@abs(px - tsignal.sx));
                        const pdiffy: isize = @intCast(@abs(py - tsignal.sy));
                        const pdist = pdiffx + pdiffy;

                        if (pdist <= tdist) {
                            continue :stepwhile;
                        }
                    }
                    //print("Found at ({}, {})\n", .{ px, py });
                    return @intCast(px * 4000000 + py);
                }
            }
        }
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data, 2000000);
    const time = timer.lap();
    const res2 = part2(data, 4000000);
    const time2 = timer.lap();
    print("Day 15:\n", .{});
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
