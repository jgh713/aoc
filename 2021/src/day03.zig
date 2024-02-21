const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day03.txt");
const testdata = "00100\r\n11110\r\n10110\r\n10111\r\n10101\r\n01111\r\n00111\r\n11100\r\n10000\r\n11001\r\n00010\r\n01010";

test "day03_part1" {
    const res = part1(testdata);
    assert(res == 198);
}

pub fn part1(input: []const u8) usize {
    var counts: [12]isize = comptime std.mem.zeroes([12]isize);
    var lines = splitSeq(u8, input, "\r\n");
    const len = lines.peek().?.len;
    while (lines.next()) |line| {
        for (line, 0..) |c, i| {
            switch (c) {
                '1' => counts[i] += 1,
                '0' => counts[i] -= 1,
                else => unreachable,
            }
        }
    }

    var common: usize = 0;
    var rare: usize = 0;

    for (0..len) |i| {
        const bit: u1 = if (counts[i] > 0) 1 else 0;
        common <<= 1;
        common |= bit;
        rare <<= 1;
        rare |= ~bit;
    }

    //print("common: {b}\n", .{common});
    //print("rare: {b}\n", .{rare});

    return common * rare;
}

test "day03_part2" {
    const res = part2(testdata);
    assert(res == 230);
}

const Node = struct {
    count: isize,
    zero: ?*Node,
    one: ?*Node,
};

pub fn part2(input: []const u8) usize {
    var nodes: [4096]Node = comptime std.mem.zeroes([4096]Node);
    var ni: usize = 1;

    var lines = splitSeq(u8, input, "\r\n");
    const len = lines.peek().?.len;
    while (lines.next()) |line| {
        var node: *Node = &nodes[0];
        switch (line[0]) {
            '1' => node.count += 1,
            '0' => node.count -= 1,
            else => unreachable,
        }
        for (0..line.len) |i| {
            switch (line[i]) {
                '1' => {
                    if (node.one == null) {
                        node.one = &nodes[ni];
                        ni += 1;
                    }
                    node = node.one.?;
                },
                '0' => {
                    if (node.zero == null) {
                        node.zero = &nodes[ni];
                        ni += 1;
                    }
                    node = node.zero.?;
                },
                else => unreachable,
            }
            if (i == line.len - 1) {
                break;
            }
            switch (line[i + 1]) {
                '1' => node.count += 1,
                '0' => node.count -= 1,
                else => unreachable,
            }
        }
    }

    var common: usize = 0;
    var rare: usize = 0;

    var node: *Node = &nodes[0];
    for (0..len) |_| {
        const bit: u1 = if (node.count == 0) 1 else if (node.count > 0) 1 else 0;
        common <<= 1;
        common |= bit;
        node = if (bit == 1) node.one.? else node.zero.?;
    }

    node = &nodes[0];
    for (0..len) |_| {
        //print("nodecount: {any}\n", .{node.count});
        const bit: u1 = if (node.count == 0) 0 else if ((node.count > 0 and (node.zero != null or node.one == null)) or (node.zero != null and node.one == null)) 0 else 1;
        //print("bit: {}\n", .{bit});
        rare <<= 1;
        rare |= bit;
        node = if (bit == 1) node.one.? else node.zero.?;
    }

    //print("common: {b}\n", .{common});
    //print("rare: {b}\n", .{rare});

    return common * rare;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 03:\n", .{});
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
