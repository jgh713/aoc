const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day01.txt");
const testdata = "1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000";

test "day01_part1" {
    const res = part1(testdata);
    assert(res == 24000);
}

pub fn part1(input: []const u8) usize {
    const separator = if (indexOf(u8, input, '\r')) |_| "\r\n" else "\n";
    // Lazy way to get the separator between groups without allocation or copying
    const esep = if (std.mem.eql(u8, separator, "\r\n")) "\r\n\r\n" else "\n\n";
    var elves = splitSeq(u8, input, esep);
    var max: usize = 0;
    while (elves.next()) |elf| {
        var foods = splitSeq(u8, elf, separator);
        var total: usize = 0;
        while (foods.next()) |food| {
            total += parseInt(usize, food, 10) catch unreachable;
        }
        max = @max(total, max);
    }
    return max;
}

test "day01_part2" {
    const res = part2(testdata);
    assert(res == 45000);
}

pub fn part2(input: []const u8) usize {
    const separator = if (indexOf(u8, input, '\r')) |_| "\r\n" else "\n";
    // Lazy way to get the separator between groups without allocation or copying
    const esep = if (std.mem.eql(u8, separator, "\r\n")) "\r\n\r\n" else "\n\n";
    var elves = splitSeq(u8, input, esep);
    var maxes: [3]usize = comptime std.mem.zeroes([3]usize);
    while (elves.next()) |elf| {
        var foods = splitSeq(u8, elf, separator);
        var total: usize = 0;
        while (foods.next()) |food| {
            total += parseInt(usize, food, 10) catch unreachable;
        }
        for (0..3) |maxi| {
            if (total > maxes[maxi]) {
                for (0..(2 - maxi)) |mi| {
                    const i = 2 - mi;
                    maxes[i] = maxes[i - 1];
                }
                maxes[maxi] = total;
                break;
            }
        }
    }

    return maxes[0] + maxes[1] + maxes[2];
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 01:\n", .{});
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
