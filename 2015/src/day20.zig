const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day20.txt");
const testdata = "34000000";

test "day20_part1" {
    const res = part1(testdata);
    assert(res == 786240);
}

fn calcHousePresents(house: usize) usize {
    var presents: usize = 0;
    for (1..house / 2 + 1) |i| {
        if (house % i == 0) {
            presents += (house / i) * 10;
        }
    }
    return presents;
}

pub fn part1(input: []const u8) usize {
    const target = parseInt(usize, input, 10) catch unreachable;
    const maxh = target / 10;
    var houses = gpa.alloc(usize, 5000000) catch unreachable;
    defer gpa.free(houses);
    @memset(houses, 0);
    //print("maxh: {}\n", .{maxh});
    for (1..maxh) |val| {
        const count = maxh / val + 1;
        //if (val == 1) print("val: {}, count: {}\n", .{ val, count });
        for (0..count) |hi| {
            houses[val * hi] += hi * 10;
        }
    }

    //print("786240: {}\n", .{houses[786240]});

    for (1..maxh) |i| {
        //print("house: {}, presents: {}\n", .{ i, houses[i] });
        if (houses[i] >= target) {
            return i;
        }
    }
    unreachable;
}

test "day20_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

fn calcPart2(house: usize) usize {
    var sum: usize = 0;
    const cap: usize = std.math.sqrt(house) + 2;
    for (1..cap) |i| {
        if (house % i == 0) {
            if (i <= 50) {
                sum += house / i;
            }
            if (house / i <= 50) {
                sum += i;
            }
        }
    }
    return sum * 11;
}

// Idk why the part1 solution isn't working for part2 so I'm just going with
// brute force and moving on for now. I might revisit this later.
pub fn part2(input: []const u8) usize {
    const target = parseInt(usize, input, 10) catch unreachable;

    var house: usize = 1;
    while (calcPart2(house) < target) {
        house += 1;
    }

    return house;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 20:\n", .{});
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
