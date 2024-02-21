const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day14.txt");
const testdata = "";

test "day14_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

const Racer = struct {
    speed: u16,
    duration: u16,
    rest: u16,
    total: u16,
};

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var racers: [9]Racer = undefined;
    var ri: u8 = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        for (0..3) |_| _ = words.next();
        const speed = parseInt(u16, words.next().?, 10) catch unreachable;
        for (0..2) |_| _ = words.next();
        const duration = parseInt(u16, words.next().?, 10) catch unreachable;
        for (0..6) |_| _ = words.next();
        const rest = parseInt(u16, words.next().?, 10) catch unreachable;
        racers[ri] = Racer{ .speed = speed, .duration = duration, .rest = rest, .total = rest + duration };
        ri += 1;
    }

    var max: usize = 0;
    for (racers[0..ri]) |racer| {
        var time: usize = 2503;
        var dist: usize = 0;
        while (time > 0) {
            const run = @min(time, racer.duration);
            dist += run * racer.speed;
            time -|= racer.total;
        }
        max = @max(max, dist);
    }

    return max;
}

test "day14_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var racers: [9]Racer = undefined;
    var ri: u8 = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        for (0..3) |_| _ = words.next();
        const speed = parseInt(u16, words.next().?, 10) catch unreachable;
        for (0..2) |_| _ = words.next();
        const duration = parseInt(u16, words.next().?, 10) catch unreachable;
        for (0..6) |_| _ = words.next();
        const rest = parseInt(u16, words.next().?, 10) catch unreachable;
        racers[ri] = Racer{ .speed = speed, .duration = duration, .rest = rest, .total = rest + duration };
        ri += 1;
    }

    var scores: [9]u16 = comptime std.mem.zeroes([9]u16);
    var positions: [9]u16 = comptime std.mem.zeroes([9]u16);

    for (0..2503) |i| {
        for (racers[0..ri], 0..) |racer, rid| {
            if (racer.total > 0) {
                const time = i % racer.total;
                if (time < racer.duration) {
                    positions[rid] += racer.speed;
                }
            }
        }
        var mi: u16 = 0;
        var mv: u16 = 0;
        for (positions, 0..) |pos, pid| {
            if (pos > mv) {
                mi = @intCast(pid);
                mv = pos;
            }
        }
        scores[mi] += 1;
    }

    var max: u16 = 0;
    for (scores) |score| {
        max = @max(max, score);
    }
    const winner = indexOf(u16, &scores, max).?;

    return scores[winner];
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 14:\n", .{});
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
