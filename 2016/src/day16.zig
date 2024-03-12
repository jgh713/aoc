const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day16.txt");
const testdata = "";

test "day16_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

pub fn part1(input: []const u8) []u8 {
    var outbuffer: [272]u1 = undefined;
    var holdbuffer: [272]u1 = undefined;
    var end: usize = 0;

    for (input) |c| {
        switch (c) {
            '0' => {
                outbuffer[end] = 0;
                end += 1;
            },
            '1' => {
                outbuffer[end] = 1;
                end += 1;
            },
            else => unreachable,
        }
    }

    while (end < 272) {
        @memcpy(holdbuffer[0..end], outbuffer[0..end]);
        std.mem.reverse(u1, holdbuffer[0..end]);
        for (0..end) |i| {
            holdbuffer[i] +%= 1;
        }
        outbuffer[end] = 0;
        const newend = @min(end * 2 + 1, 272);
        const newlen = newend - end - 1;
        @memcpy(outbuffer[end + 1 .. newend], holdbuffer[0..newlen]);
        end = newend;
    }

    while (end % 2 == 0) {
        end /= 2;
        for (0..end) |i| {
            const a = outbuffer[i * 2];
            const b = outbuffer[i * 2 + 1];
            holdbuffer[i] = if (a == b) 1 else 0;
        }
        @memcpy(outbuffer[0..end], holdbuffer[0..end]);
    }

    const out: []u8 = gpa.alloc(u8, end) catch unreachable;

    for (0..end) |i| {
        out[i] = @as(u8, outbuffer[i]) + '0';
    }

    return out;
}

test "day16_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) []u8 {
    var outbuffer: []u1 = gpa.alloc(u1, 35651584) catch unreachable;
    var holdbuffer: []u1 = gpa.alloc(u1, 35651584) catch unreachable;
    var end: usize = 0;

    for (input) |c| {
        switch (c) {
            '0' => {
                outbuffer[end] = 0;
                end += 1;
            },
            '1' => {
                outbuffer[end] = 1;
                end += 1;
            },
            else => unreachable,
        }
    }

    while (end < 35651584) {
        @memcpy(holdbuffer[0..end], outbuffer[0..end]);
        std.mem.reverse(u1, holdbuffer[0..end]);
        for (0..end) |i| {
            holdbuffer[i] +%= 1;
        }
        outbuffer[end] = 0;
        const newend = @min(end * 2 + 1, 35651584);
        const newlen = newend - end - 1;
        @memcpy(outbuffer[end + 1 .. newend], holdbuffer[0..newlen]);
        end = newend;
    }

    while (end % 2 == 0) {
        end /= 2;
        for (0..end) |i| {
            const a = outbuffer[i * 2];
            const b = outbuffer[i * 2 + 1];
            holdbuffer[i] = if (a == b) 1 else 0;
        }
        @memcpy(outbuffer[0..end], holdbuffer[0..end]);
    }

    const out: []u8 = gpa.alloc(u8, end) catch unreachable;

    for (0..end) |i| {
        out[i] = @as(u8, outbuffer[i]) + '0';
    }

    return out;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 16:\n", .{});
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
