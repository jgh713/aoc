const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const testdata = "1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet";
const testdata2 = "two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";
const data = @embedFile("data/day01.txt");

test "day1_part1" {
    const input = testdata;
    const expected = 142;
    const result = part1(input);
    assert(result == expected);
}

test "day1_part2" {
    const input = testdata2;
    const expected = 281;
    const result = try part2(input);
    assert(result == expected);
}

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn part1(input: []const u8) u32 {
    var first: u8 = 10;
    var last: u8 = 10;
    var total: u32 = 0;
    for (input) |c| {
        if (isDigit(c)) {
            if (first == 10) {
                first = c - '0';
            }
            last = c - '0';
        } else if (c == '\n') {
            total += (first * 10) + last;
            first = 10;
            last = 0;
        }
    }
    if (first != 10) {
        total += (first * 10) + last;
    }
    return total;
}

const numstrings: [10][]const u8 = .{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn getDigit(chars: []const u8, index: usize) !u8 {
    const c = chars[index];
    if (isDigit(c)) {
        return c - '0';
    }
    const maxlen = chars.len - index;
    for (numstrings, 0..) |num, i| {
        if (maxlen < num.len) {
            continue;
        }
        if (std.mem.eql(u8, chars[index .. index + num.len], num)) {
            return @intCast(i);
        }
    }
    return 10;
}

fn part2(input: []const u8) !u32 {
    var first: u8 = 10;
    var last: u8 = 10;
    var total: u32 = 0;
    for (input, 0..) |c, index| {
        const digit: u8 = try getDigit(input, index);
        if (digit != 10) {
            if (first == 10) {
                first = digit;
            }
            last = digit;
        } else if (c == '\n') {
            total += (first * 10) + last;
            first = 10;
            last = 0;
        }
    }
    if (first != 10) {
        total += (first * 10) + last;
    }
    return total;
}

pub fn main() !void {
    const result = part1(data);
    print("Part1 result is {d}\n", .{result});
    const result2 = try part2(data);
    print("Part2 result is {d}\n", .{result2});
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
