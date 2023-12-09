const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const testdata = "LLR\n\nAAA = (BBB, BBB)\nBBB = (AAA, ZZZ)\nZZZ = (ZZZ, ZZZ)";

test "day8_part1" {
    const res = part1(testdata);
    assert(res == 6);
}

fn part1(input: []const u8) u32 {
    var step: u16 = 0;
    var steps: [310]u1 = undefined;

    while (input[step] != '\n') {
        step += 1;
    }

    if (input[step - 1] == '\r') {
        step -= 1;
    }

    for (input[0..step], 0..) |c, i| {
        steps[i] = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
    }

    var current: u16 = 0;
    var map: [65535][2]u16 = undefined;
    var this: u16 = 0;
    var left: u16 = 0;

    for (input[step + 1 ..]) |c| {
        switch (c) {
            'A'...'Z' => {
                current = (current << 5) | (c - 'A');
            },
            '(' => {
                this = current;
                current = 0;
            },
            ',' => {
                left = current;
                current = 0;
            },
            ')' => {
                map[this][0] = left;
                map[this][1] = current;
                current = 0;
            },
            else => continue,
        }
    }

    var loc: u16 = 0;
    var count: u32 = 0;
    const dest = (25 << 10) | (25 << 5) | 25;
    while (loc != dest) {
        loc = map[loc][steps[count % step]];
        count += 1;
    }

    return count;
}

const Loop = struct {
    offset: u64,
    length: u64,
};

inline fn getLoop(start: u16, map: [65535][2]u16, step: u16) Loop {
    var offset: u64 = 0;
    var loc: u16 = start;
    var count: u32 = 0;
    while (true) {
        loc = map[loc][(count % step)];
        count += 1;
        if (loc & 0b11111 == 25) {
            offset = count;
        }
        if (loc == start) {
            return Loop{ .offset = offset, .length = count };
        }
    }
}

fn part2(input: []const u8) u32 {
    var step: u16 = 0;
    var steps: [310]u1 = undefined;

    while (input[step] != '\n') {
        step += 1;
    }

    if (input[step - 1] == '\r') {
        step -= 1;
    }

    for (input[0..step], 0..) |c, i| {
        steps[i] = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
    }

    var current: u16 = 0;
    var map: [65535][2]u16 = undefined;
    var this: u16 = 0;
    var left: u16 = 0;
    var node: u4 = 0;
    var nodes: [10]u16 = undefined;

    for (input[step + 1 ..]) |c| {
        switch (c) {
            'A'...'Z' => {
                current = (current << 5) | (c - 'A');
            },
            '(' => {
                this = current;
                current = 0;
            },
            ',' => {
                left = current;
                current = 0;
            },
            ')' => {
                map[this][0] = left;
                map[this][1] = current;
                current = 0;
                if (this & 0b11111 == 0) {
                    nodes[node] = this;
                    node += 1;
                }
            },
            else => continue,
        }
    }

    var loops: [10]Loop = undefined;
    for (0..node) |i| {
        print("Node {}\n", .{i});
        loops[i] = getLoop(nodes[i], map, step);
        print("Got loop {} with offset {} and length {}\n", .{ i, loops[i].offset, loops[i].length });
    }

    return 0;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time1});
    print("Part2 took {}ns\n", .{time2});
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
