const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day09.txt");
const testdata = "R 4\r\nU 4\r\nL 3\r\nD 1\r\nR 4\r\nD 1\r\nL 5\r\nR 2";
const testdata2 = "R 5\r\nU 8\r\nL 8\r\nD 3\r\nR 17\r\nD 10\r\nL 25\r\nU 20";

test "day09_part1" {
    const res = part1(testdata);
    assert(res == 13);
}

pub fn part1(input: []const u8) usize {
    var hv = [2]isize{ 0, 0 };
    var tv = [2]isize{ 0, 0 };

    var map = std.AutoHashMap([2]isize, void).init(gpa);
    map.put(tv, {}) catch unreachable;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        const dir: [2]isize = switch (line[0]) {
            'R' => .{ 1, 0 },
            'L' => .{ -1, 0 },
            'U' => .{ 0, 1 },
            'D' => .{ 0, -1 },
            else => unreachable,
        };
        const dist = parseInt(usize, line[2..], 10) catch unreachable;

        for (0..dist) |_| {
            hv[0] += dir[0];
            hv[1] += dir[1];

            const dx = @abs(hv[0] - tv[0]);
            const dy = @abs(hv[1] - tv[1]);
            if (dx > 1 or dy > 1) {
                if (tv[0] < hv[0]) tv[0] += 1;
                if (tv[0] > hv[0]) tv[0] -= 1;
                if (tv[1] < hv[1]) tv[1] += 1;
                if (tv[1] > hv[1]) tv[1] -= 1;
                map.put(tv, {}) catch unreachable;
            }
        }
    }

    return map.count();
}

test "day09_part2" {
    const res = part2(testdata2);
    assert(res == 36);
}

pub fn part2(input: []const u8) usize {
    var chain: [10][2]isize = comptime std.mem.zeroes([10][2]isize);

    var map = std.AutoHashMap([2]isize, void).init(gpa);
    map.put(chain[9], {}) catch unreachable;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        const dir: [2]isize = switch (line[0]) {
            'R' => .{ 1, 0 },
            'L' => .{ -1, 0 },
            'U' => .{ 0, 1 },
            'D' => .{ 0, -1 },
            else => unreachable,
        };
        const dist = parseInt(usize, line[2..], 10) catch unreachable;

        for (0..dist) |_| {
            chain[0][0] += dir[0];
            chain[0][1] += dir[1];

            for (1..10) |ci| {
                const li = ci - 1;
                const dx = @abs(chain[ci][0] - chain[li][0]);
                const dy = @abs(chain[ci][1] - chain[li][1]);
                if (dx > 1 or dy > 1) {
                    if (chain[ci][0] < chain[li][0]) chain[ci][0] += 1;
                    if (chain[ci][0] > chain[li][0]) chain[ci][0] -= 1;
                    if (chain[ci][1] < chain[li][1]) chain[ci][1] += 1;
                    if (chain[ci][1] > chain[li][1]) chain[ci][1] -= 1;
                    if (ci == 9) {
                        map.put(chain[9], {}) catch unreachable;
                    }
                } else break;
            }
        }
    }

    return map.count();
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
