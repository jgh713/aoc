const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day02.txt");
const testdata = "ULL\r\nRRDDD\r\nLURDL\r\nUUUUD";

test "day02_part1" {
    const res = part1(testdata);
    assert(std.mem.eql(u8, res, "1985"));
}

pub fn part1(input: []const u8) []u8 {
    var buffer: [16]u8 = undefined;
    var lines = splitSeq(u8, input, "\r\n");

    var x: u8 = 1;
    var y: u8 = 1;
    var bi: u8 = 0;

    while (lines.next()) |line| {
        for (line) |c| {
            switch (c) {
                'U' => if (y > 0) {
                    y -= 1;
                },
                'D' => if (y < 2) {
                    y += 1;
                },
                'L' => if (x > 0) {
                    x -= 1;
                },
                'R' => if (x < 2) {
                    x += 1;
                },
                else => unreachable,
            }
        }
        buffer[bi] = '1' + (y * 3 + x);
        bi += 1;
    }
    return gpa.dupe(u8, buffer[0..bi]) catch unreachable;
}

test "day02_part2" {
    const res = part2(testdata);
    assert(std.mem.eql(u8, res, "5DB3"));
}

pub fn part2(input: []const u8) []u8 {
    var buffer: [16]u8 = undefined;
    var lines = splitSeq(u8, input, "\r\n");

    var x: u8 = 0;
    var y: u8 = 2;
    var bi: u8 = 0;

    const pad: [5][5]u8 = .{
        [_]u8{ 0, 0, '1', 0, 0 },
        [_]u8{ 0, '2', '3', '4', 0 },
        [_]u8{ '5', '6', '7', '8', '9' },
        [_]u8{ 0, 'A', 'B', 'C', 0 },
        [_]u8{ 0, 0, 'D', 0, 0 },
    };

    while (lines.next()) |line| {
        for (line) |c| {
            var nx = x;
            var ny = y;
            switch (c) {
                'U' => ny -|= 1,
                'D' => ny += 1,
                'L' => nx -|= 1,
                'R' => nx += 1,
                else => unreachable,
            }
            if (nx < 5 and ny < 5 and pad[ny][nx] != 0) {
                x = nx;
                y = ny;
            }
        }
        buffer[bi] = pad[y][x];
        bi += 1;
    }
    //print("buf: {s}\n", .{buffer[0..bi]});
    return gpa.dupe(u8, buffer[0..bi]) catch unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 02:\n", .{});
    print("\tPart 1: {s}\n", .{res});
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
