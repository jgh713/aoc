const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day10.txt");
const testdata = "addx 15\r\naddx -11\r\naddx 6\r\naddx -3\r\naddx 5\r\naddx -1\r\naddx -8\r\naddx 13\r\naddx 4\r\nnoop\r\naddx -1\r\naddx 5\r\naddx -1\r\naddx 5\r\naddx -1\r\naddx 5\r\naddx -1\r\naddx 5\r\naddx -1\r\naddx -35\r\naddx 1\r\naddx 24\r\naddx -19\r\naddx 1\r\naddx 16\r\naddx -11\r\nnoop\r\nnoop\r\naddx 21\r\naddx -15\r\nnoop\r\nnoop\r\naddx -3\r\naddx 9\r\naddx 1\r\naddx -3\r\naddx 8\r\naddx 1\r\naddx 5\r\nnoop\r\nnoop\r\nnoop\r\nnoop\r\nnoop\r\naddx -36\r\nnoop\r\naddx 1\r\naddx 7\r\nnoop\r\nnoop\r\nnoop\r\naddx 2\r\naddx 6\r\nnoop\r\nnoop\r\nnoop\r\nnoop\r\nnoop\r\naddx 1\r\nnoop\r\nnoop\r\naddx 7\r\naddx 1\r\nnoop\r\naddx -13\r\naddx 13\r\naddx 7\r\nnoop\r\naddx 1\r\naddx -33\r\nnoop\r\nnoop\r\nnoop\r\naddx 2\r\nnoop\r\nnoop\r\nnoop\r\naddx 8\r\nnoop\r\naddx -1\r\naddx 2\r\naddx 1\r\nnoop\r\naddx 17\r\naddx -9\r\naddx 1\r\naddx 1\r\naddx -3\r\naddx 11\r\nnoop\r\nnoop\r\naddx 1\r\nnoop\r\naddx 1\r\nnoop\r\nnoop\r\naddx -13\r\naddx -19\r\naddx 1\r\naddx 3\r\naddx 26\r\naddx -30\r\naddx 12\r\naddx -1\r\naddx 3\r\naddx 1\r\nnoop\r\nnoop\r\nnoop\r\naddx -9\r\naddx 18\r\naddx 1\r\naddx 2\r\nnoop\r\nnoop\r\naddx 9\r\nnoop\r\nnoop\r\nnoop\r\naddx -1\r\naddx 2\r\naddx -37\r\naddx 1\r\naddx 3\r\nnoop\r\naddx 15\r\naddx -21\r\naddx 22\r\naddx -6\r\naddx 1\r\nnoop\r\naddx 2\r\naddx 1\r\nnoop\r\naddx -10\r\nnoop\r\nnoop\r\naddx 20\r\naddx 1\r\naddx 2\r\naddx 2\r\naddx -6\r\naddx -11\r\nnoop\r\nnoop\r\nnoop";

test "day10_part1" {
    const res = part1(testdata);
    assert(res == 13140);
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var cycle: isize = 0;
    var register: isize = 1;
    var total: isize = 0;
    while (lines.next()) |line| {
        cycle += 1;
        if (@rem(cycle - 20, 40) == 0) {
            total += (cycle * register);
        }
        if (std.mem.eql(u8, line[0..4], "addx")) {
            const num = parseInt(isize, line[5..], 10) catch unreachable;
            cycle += 1;
            if (@rem(cycle - 20, 40) == 0) {
                total += (cycle * register);
            }
            register += num;
        }
    }
    return @intCast(total);
}

test "day10_part2" {
    const res = part2(testdata);
    const expected = "\n##..##..##..##..##..##..##..##..##..##..\n###...###...###...###...###...###...###.\n####....####....####....####....####....\n#####.....#####.....#####.....#####.....\n######......######......######......####\n#######.......#######.......#######.....\n";
    assert(std.mem.eql(u8, &res, expected));
}

pub fn part2(input: []const u8) [247]u8 {
    var lines = splitSeq(u8, input, "\r\n");
    var cycle: isize = 0;
    var register: isize = 1;
    var total: isize = 0;
    var screen: [6][40]bool = undefined;
    while (lines.next()) |line| {
        cycle += 1;
        if (@rem(cycle - 20, 40) == 0) {
            total += (cycle * register);
        }
        const px: isize = @rem(cycle - 1, 40);
        const py: isize = @divFloor(cycle - 1, 40);
        screen[@intCast(py)][@intCast(px)] = (@abs(register - px) <= 1);
        if (std.mem.eql(u8, line[0..4], "addx")) {
            const num = parseInt(isize, line[5..], 10) catch unreachable;
            cycle += 1;
            const px2: isize = @rem(cycle - 1, 40);
            const py2: isize = @divFloor(cycle - 1, 40);
            screen[@intCast(py2)][@intCast(px2)] = (@abs(register - px2) <= 1);
            if (@rem(cycle - 20, 40) == 0) {
                total += (cycle * register);
            }
            register += num;
        }
    }

    var out: [247]u8 = undefined;
    out[0] = '\n';
    for (screen, 0..) |row, py| {
        const yoffset = py * 41;
        for (row, 1..) |val, px| {
            if (val) {
                out[yoffset + px] = '#';
            } else {
                out[yoffset + px] = '.';
            }
        }
        out[yoffset + 41] = '\n';
    }
    return out;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 10:\n", .{});
    print("\tPart 1: {}\n", .{res});
    print("\tPart 2: {s}\n", .{res2});
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
