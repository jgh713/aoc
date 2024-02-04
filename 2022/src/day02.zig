const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day02.txt");
const testdata = "A Y\r\nB X\r\nC Z";

test "day02_part1" {
    const res = part1(testdata);
    assert(res == 15);
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    comptime var points: [3][3]u8 = undefined;
    comptime {
        for (0..3) |oppmove| {
            for (0..3) |mymove| {
                var pts: u8 = 1;
                pts += mymove;
                if (oppmove == mymove) {
                    pts += 3;
                } else if ((oppmove + 1) % 3 == mymove) {
                    pts += 6;
                }
                points[oppmove][mymove] = pts;
            }
        }
    }
    var total: usize = 0;
    while (lines.next()) |line| {
        const oppmove = line[0] - 'A';
        const mymove = line[2] - 'X';
        total += points[oppmove][mymove];
    }
    return total;
}

test "day02_part2" {
    const res = part2(testdata);
    assert(res == 12);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    comptime var points: [3][3]u8 = undefined;
    comptime {
        for (0..3) |oppmove| {
            for (0..3) |outcome| {
                var pts: u8 = 1;
                const mymove = (oppmove + 2 + outcome) % 3;
                pts += mymove;
                pts += outcome * 3;
                points[oppmove][outcome] = pts;
            }
        }
    }
    var total: usize = 0;
    while (lines.next()) |line| {
        const oppmove = line[0] - 'A';
        const outcome = line[2] - 'X';
        total += points[oppmove][outcome];
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 02:\n", .{});
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
