const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");
const testdata = "0 3 6 9 12 15\n1 3 6 10 15 21\n10 13 16 21 30 45\n";

test "day9_part1" {
    const res = part1(testdata, false);
    assert(res == 114);
}

inline fn allZeroes(nums: []const i64, count: u8) bool {
    for (nums[0..count]) |num| {
        if (num != 0) {
            return false;
        }
    }
    return true;
}

fn getLineVal(nums: []const i64, count: u8) i128 {
    var newnums: [50]i64 = undefined;

    if (allZeroes(nums, count)) {
        return 0;
    }

    for (0..(count - 1)) |i| {
        newnums[i] = nums[i + 1] - nums[i];
    }

    const diff = getLineVal(&newnums, count - 1);

    return diff + nums[count - 1];
}

fn part1(input: []const u8, isfile: bool) i128 {
    var itline: std.mem.SplitIterator(u8, .sequence) = undefined;
    if (isfile) {
        itline = splitSeq(u8, input, "\r\n");
    } else {
        itline = splitSeq(u8, input, "\n");
    }

    var total: i128 = 0;

    while (itline.next()) |line| {
        var itnum = splitSeq(u8, line, " ");
        var nums: [50]i64 = undefined;
        var i: u8 = 0;
        while (itnum.next()) |num| {
            if (num.len == 0) {
                continue;
            }
            nums[i] = parseInt(i64, num, 10) catch {
                print("Failed to parse number: {s}\n", .{num});
                unreachable;
            };
            i += 1;
        }

        total += getLineVal(&nums, i);
    }

    return total;
}

test "day9_part2" {
    const res = part2(testdata, false);
    assert(res == 2);
}

fn getLineValLeft(nums: []const i64, count: u8) i128 {
    var newnums: [50]i64 = undefined;

    if (allZeroes(nums, count)) {
        return 0;
    }

    for (0..(count - 1)) |i| {
        newnums[i] = nums[i + 1] - nums[i];
    }

    const diff = getLineValLeft(&newnums, count - 1);

    return nums[0] - diff;
}

fn part2(input: []const u8, isfile: bool) i128 {
    var itline: std.mem.SplitIterator(u8, .sequence) = undefined;
    if (isfile) {
        itline = splitSeq(u8, input, "\r\n");
    } else {
        itline = splitSeq(u8, input, "\n");
    }

    var total: i128 = 0;

    while (itline.next()) |line| {
        var itnum = splitSeq(u8, line, " ");
        var nums: [50]i64 = undefined;
        var i: u8 = 0;
        while (itnum.next()) |num| {
            if (num.len == 0) {
                continue;
            }
            nums[i] = parseInt(i64, num, 10) catch {
                print("Failed to parse number: {s}\n", .{num});
                unreachable;
            };
            i += 1;
        }

        total += getLineValLeft(&nums, i);
    }

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data, true);
    const time1 = timer.lap();
    const res2 = part2(data, true);
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
