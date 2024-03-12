const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day10.txt");
const testdata = "";

test "day10_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

const Bot = struct {
    low: usize,
    high: usize,
    vals: [2]usize,
};

pub fn part1(input: []const u8) usize {
    var bots: [250]Bot = comptime std.mem.zeroes([250]Bot);

    var queue: [250]usize = undefined;
    var qstart: usize = 0;
    var qend: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        switch (line[0]) {
            'v' => {
                _ = words.next();
                const val = parseInt(usize, words.next().?, 10) catch unreachable;
                for (0..3) |_| _ = words.next();
                const bot = parseInt(usize, words.next().?, 10) catch unreachable;
                if (bots[bot].vals[0] == 0) {
                    bots[bot].vals[0] = val;
                } else {
                    assert(bots[bot].vals[1] == 0);
                    bots[bot].vals[1] = val;
                    queue[qend] = bot;
                    qend += 1;
                }
            },
            'b' => {
                _ = words.next();
                const bot = parseInt(usize, words.next().?, 10) catch unreachable;
                for (0..4) |_| _ = words.next();
                const low = parseInt(usize, words.next().?, 10) catch unreachable;
                for (0..4) |_| _ = words.next();
                const high = parseInt(usize, words.next().?, 10) catch unreachable;
                bots[bot].low = low;
                bots[bot].high = high;
            },
            else => unreachable,
        }
    }

    while (qstart < qend) : (qstart += 1) {
        const botid = queue[qstart];
        const bot = bots[botid];
        const lowval = @min(bot.vals[0], bot.vals[1]);
        const highval = @max(bot.vals[0], bot.vals[1]);
        if (lowval == 17 and highval == 61) {
            return botid;
        }
        const low = bot.low;
        const high = bot.high;
        if (bots[low].vals[0] == 0) {
            bots[low].vals[0] = lowval;
        } else {
            assert(bots[low].vals[1] == 0);
            bots[low].vals[1] = lowval;
            queue[qend] = low;
            qend += 1;
        }
        if (bots[high].vals[0] == 0) {
            bots[high].vals[0] = highval;
        } else {
            assert(bots[high].vals[1] == 0);
            bots[high].vals[1] = highval;
            queue[qend] = high;
            qend += 1;
        }
    }

    unreachable;
}

test "day10_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var bots: [350]Bot = comptime std.mem.zeroes([350]Bot);

    var queue: [250]usize = undefined;
    var qstart: usize = 0;
    var qend: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        switch (line[0]) {
            'v' => {
                _ = words.next();
                const val = parseInt(usize, words.next().?, 10) catch unreachable;
                for (0..3) |_| _ = words.next();
                const bot = parseInt(usize, words.next().?, 10) catch unreachable;
                if (bots[bot].vals[0] == 0) {
                    bots[bot].vals[0] = val;
                } else {
                    assert(bots[bot].vals[1] == 0);
                    bots[bot].vals[1] = val;
                    queue[qend] = bot;
                    qend += 1;
                }
            },
            'b' => {
                _ = words.next();
                const bot = parseInt(usize, words.next().?, 10) catch unreachable;
                for (0..3) |_| _ = words.next();
                const lowtype = words.next().?;
                const low: usize = (parseInt(usize, words.next().?, 10) catch unreachable) + if (lowtype[0] == 'o') @as(usize, 300) else @as(usize, 0);
                for (0..3) |_| _ = words.next();
                const hightype = words.next().?;
                const high: usize = (parseInt(usize, words.next().?, 10) catch unreachable) + if (hightype[0] == 'o') @as(usize, 300) else @as(usize, 0);
                bots[bot].low = low;
                bots[bot].high = high;
            },
            else => unreachable,
        }
    }

    while (qstart < qend) : (qstart += 1) {
        const botid = queue[qstart];
        const bot = bots[botid];
        const lowval = @min(bot.vals[0], bot.vals[1]);
        const highval = @max(bot.vals[0], bot.vals[1]);
        const low = bot.low;
        const high = bot.high;
        if (bots[low].vals[0] == 0) {
            bots[low].vals[0] = lowval;
        } else {
            assert(bots[low].vals[1] == 0);
            bots[low].vals[1] = lowval;
            if (low < 300) {
                queue[qend] = low;
                qend += 1;
            }
        }
        if (bots[high].vals[0] == 0) {
            bots[high].vals[0] = highval;
        } else {
            assert(bots[high].vals[1] == 0);
            bots[high].vals[1] = highval;
            if (high < 300) {
                queue[qend] = high;
                qend += 1;
            }
        }
    }

    return bots[300].vals[0] * bots[301].vals[0] * bots[302].vals[0];
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 10:\n", .{});
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
