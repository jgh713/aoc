const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");
const testdata = "Time:      7  15   30\nDistance:  9  40  200\n";

test "day6_part1" {
    const res = part1(testdata);
    assert(res == 288);
}

inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

inline fn winner(t: usize, time: usize, dist: usize) bool {
    return (t * (time - t)) > dist;
}

inline fn waysToWin(time: usize, dist: usize) usize {
    var t: usize = 1;
    var cap = time / 2;
    var lookahead: usize = undefined;
    while ((cap - t) >= 5) {
        lookahead = (cap + t) / 2;
        if (winner(lookahead, time, dist)) {
            cap = lookahead;
        } else {
            t = lookahead;
        }
    }
    while (t <= cap) {
        if (winner(t, time, dist)) {
            return time - (t * 2) + 1;
        }
        t += 1;
    }
    return 0;
}

fn part1(input: []const u8) usize {
    var line: u3 = 0;
    var current: usize = 0;
    var times: [4]usize = undefined;
    var time: u3 = 0;
    var dists: [4]usize = undefined;
    var dist: u3 = 0;
    for (input) |c| {
        if (isDigit(c)) {
            current = current * 10 + (c - '0');
            continue;
        }

        if (current > 0) {
            if (line == 0) {
                times[time] = current;
                time += 1;
            } else {
                dists[dist] = current;
                dist += 1;
            }
            current = 0;
        }

        if (c == '\n') {
            line += 1;
        }
    }

    var out: usize = 1;
    for (0..time) |i| {
        out *= waysToWin(times[i], dists[i]);
    }
    return out;
}

test "day6_part2" {
    const res = part2(testdata);
    assert(res == 71503);
}

fn part2(input: []const u8) usize {
    var time: usize = 0;
    var dist: usize = 0;
    var current: usize = 0;
    for (input) |c| {
        if (isDigit(c)) {
            current = current * 10 + (c - '0');
            continue;
        }

        if (c == '\n') {
            if (time == 0) {
                time = current;
            } else {
                dist = current;
            }
            current = 0;
        }
    }

    return waysToWin(time, dist);
}

pub fn main() !void {
    @setEvalBranchQuota(2000);
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time1});
    print("Part2 took {}ns\n", .{time2});

    var res3: usize = 0;
    const throw = timer.lap();
    _ = throw;
    inline for (0..1000) |i| {
        _ = i;
        res3 = part1(data);
    }
    const time3 = timer.lap();
    inline for (0..1000) |i| {
        _ = i;
        res3 = part2(data);
    }
    const time4 = timer.lap();

    print("1000 iterations of part1 took {}ns, averaged to {}ns\n", .{ time3, time3 / 1000 });
    print("1000 iterations of part2 took {}ns, averaged to {}ns\n", .{ time4, time4 / 1000 });
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
