const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day06.txt");
const testdata = "";

test "day06_part1" {
    assert(part1("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7);
    assert(part1("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5);
    assert(part1("nppdvjthqldpwncqszvftbrmjlhg") == 6);
    assert(part1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10);
    assert(part1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11);
}

fn findUniqueStr(str: []const u8, len: u8) usize {
    const offset = len - 1;
    var charcount: [26]u8 = std.mem.zeroes([26]u8);
    var matches: usize = 0;
    for (str[0..offset]) |c| {
        const cv = &charcount[c - 'a'];
        if (cv.* == 1) {
            matches -= 1;
        }
        cv.* += 1;
        if (cv.* == 1) {
            matches += 1;
        }
    }
    for (str[offset..], offset..) |c, ci| {
        const cv = &charcount[c - 'a'];
        if (cv.* == 1) {
            matches -= 1;
        }
        cv.* += 1;
        if (cv.* == 1) {
            matches += 1;
        }
        if (matches == len) {
            return ci + 1;
        }
        const cv2 = &charcount[str[ci - offset] - 'a'];
        if (cv2.* == 1) {
            matches -= 1;
        }
        cv2.* -= 1;
        if (cv2.* == 1) {
            matches += 1;
        }
    }
    unreachable;
}

pub fn part1(input: []const u8) usize {
    return findUniqueStr(input, 4);
}

test "day06_part2" {
    assert(part2("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 19);
    assert(part2("bvwbjplbgvbhsrlpgdmjqwftvncz") == 23);
    assert(part2("nppdvjthqldpwncqszvftbrmjlhg") == 23);
    assert(part2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 29);
    assert(part2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 26);
}

pub fn part2(input: []const u8) usize {
    return findUniqueStr(input, 14);
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 06:\n", .{});
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
