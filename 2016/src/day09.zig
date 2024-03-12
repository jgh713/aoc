const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day09.txt");
const testdata = "";

test "day09_part1" {
    assert(part1("ADVENT") == 6);
    assert(part1("A(1x5)BC") == 7);
    assert(part1("(3x3)XYZ") == 9);
    assert(part1("A(2x2)BCD(2x2)EFG") == 11);
    assert(part1("(6x1)(1x3)A") == 6);
    assert(part1("X(8x2)(3x3)ABCY") == 18);
}

pub fn part1(input: []const u8) usize {
    var start: usize = 0;
    var count: usize = 0;
    while (true) {
        const left = std.mem.indexOfScalarPos(u8, input, start, '(') orelse break;
        count += left - start;
        const right = std.mem.indexOfScalarPos(u8, input, left, ')').?;
        const word = input[left + 1 .. right];
        const x = indexOf(u8, word, 'x').?;
        const len = @min(parseInt(usize, word[0..x], 10) catch unreachable, input.len - right -| 1);
        const rep = parseInt(usize, word[x + 1 ..], 10) catch unreachable;
        start = right + len + 1;
        //print("startslice now: {s}\n", .{input[start..]});
        count += len * rep;
    }
    count += input.len - start;
    //print("input: {s}\n", .{input});
    //print("count: {}\n", .{count});
    return count;
}

test "day09_part2" {
    assert(part2("(3x3)XYZ") == 9);
    assert(part2("X(8x2)(3x3)ABCY") == 20);
    assert(part2("(27x12)(20x12)(13x14)(7x10)(1x12)A") == 241920);
    assert(part2("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN") == 445);
}

pub fn part2(input: []const u8) usize {
    var start: usize = 0;
    var count: usize = 0;
    while (true) {
        const left = std.mem.indexOfScalarPos(u8, input, start, '(') orelse break;
        count += left - start;
        const right = std.mem.indexOfScalarPos(u8, input, left, ')').?;
        const word = input[left + 1 .. right];
        const x = indexOf(u8, word, 'x').?;
        const len = @min(parseInt(usize, word[0..x], 10) catch unreachable, input.len - right -| 1);
        const rep = parseInt(usize, word[x + 1 ..], 10) catch unreachable;
        start = right + len + 1;
        //print("startslice now: {s}\n", .{input[start..]});
        count += part2(input[right + 1 .. right + len + 1]) * rep;
    }
    count += input.len - start;
    //print("input: {s}\n", .{input});
    //print("count: {}\n", .{count});
    return count;
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
