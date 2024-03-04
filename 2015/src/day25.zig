const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day25.txt");
const testdata = "";

test "day25_part1" {
    const res = part1(data);
    assert(res == 0);
    assert(calcOffset(1, 2) == 3);
    //print("offset: {}\n", .{calcOffset(4, 2)});
    assert(calcOffset(4, 2) == 12);
    assert(calcOffset(3, 4) == 19);
    //print("offset: {}\n", .{calcOffset(2978, 3083)});
}

fn calcOffset(row: usize, col: usize) usize {
    const corner = row + col - 1;
    var offset: usize = 0;
    for (1..corner) |i| {
        offset += i;
    }

    return offset + col;
}

pub fn part1(input: []const u8) usize {
    var words = splitSca(u8, input, ' ');
    for (0..16) |_| _ = words.next();
    const rowword = words.next().?;
    _ = words.next();
    const colword = words.next().?;
    const row = parseInt(usize, rowword[0 .. rowword.len - 1], 10) catch unreachable;
    const col = parseInt(usize, colword[0 .. colword.len - 1], 10) catch unreachable;
    //print("row: {}, col: {}\n", .{ row, col });

    const target = calcOffset(row, col) - 1;
    const start: usize = 20151125;

    var value: usize = start;
    // Starting at 0 makes calculating skips easier
    var steps: usize = 0;
    while (steps < target) {
        steps += 1;
        value = (value * 252533) % 33554393;
        // Data loops, but it doesn't loop early enough to be useful
        //if (value == start) {
        //    print("Found a skip loop at step {}\n", .{steps});
        //    print("Target: {}\n", .{target});
        //    unreachable;
        //}
    }

    return value;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    print("Day 25:\n", .{});
    print("\tPart 1: {}\n", .{res});
    print("\tTime: {}ns\n", .{time});
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
