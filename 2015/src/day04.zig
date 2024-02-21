const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day04.txt");
const testdata = "pqrstuv";

test "day04_part1" {
    const res = part1(testdata);
    assert(res == 1048970);
}

const Errors = error{TestError};

pub fn part1(input: []const u8) usize {
    var strdata: [20]u8 = comptime (std.mem.zeroes([20]u8));
    var outbuf: [16]u8 = undefined;
    const start = input.len;
    for (0..start) |i| {
        strdata[i] = input[i];
    }
    var i: usize = 1;

    const x = blk: {
        break :blk Errors.TestError;
    };
    print("x: {}\n", .{x});

    _ = switch (i) {
        1 => std.fmt.bufPrint(strdata[start..], "{}", .{i}),
        else => std.fmt.bufPrint(strdata[start..], "{}", .{i}),
    } catch {
        unreachable;
    };

    while (true) : (i += 1) {
        const slice = std.fmt.bufPrint(strdata[start..], "{}", .{i}) catch unreachable;
        std.crypto.hash.Md5.hash(strdata[0 .. start + slice.len], &outbuf, .{});
        if (outbuf[0] == 0 and outbuf[1] == 0 and outbuf[2] <= 0x0F) return i;
    }

    unreachable;
}

test "day04_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var strdata: [20]u8 = comptime (std.mem.zeroes([20]u8));
    var outbuf: [16]u8 = undefined;
    const start = input.len;
    for (0..start) |i| {
        strdata[i] = input[i];
    }
    var i: usize = 1;

    while (true) : (i += 1) {
        const slice = std.fmt.bufPrint(strdata[start..], "{}", .{i}) catch unreachable;
        std.crypto.hash.Md5.hash(strdata[0 .. start + slice.len], &outbuf, .{});
        if (std.mem.eql(u8, outbuf[0..3], &comptime std.mem.zeroes([3]u8))) return i;
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 04:\n", .{});
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
