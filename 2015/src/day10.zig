const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day10.txt");
const testdata = "";

test "day10_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

pub fn processLine(line: []u8, out: []u8) void {
    var i: usize = 0;
    var j: usize = 0;
    var len: usize = 0;
    @memset(out, 0);

    //print("l: {s}\n", .{line});
    while (i < line.len) {
        while (j < line.len and line[i] == line[j]) j += 1;
        const count = j - i;
        len += (std.fmt.bufPrint(out[len..], "{}{c}", .{ count, line[i] }) catch unreachable).len;
        i = j;
    }
    //print("o: {s}\n", .{out});
}

pub fn part1(input: []const u8) usize {
    var buffer: [524288]u8 = comptime std.mem.zeroes([524288]u8);
    var buf2: [524288]u8 = comptime std.mem.zeroes([524288]u8);
    const bufstr: [*:0]u8 = @ptrCast(&buffer[0]);

    @memcpy(buffer[0..input.len], input);

    for (0..40) |i| {
        _ = i;
        processLine(std.mem.span(bufstr), &buf2);
        buffer = buf2;
        //print("{s}\n", .{bufstr});
        //print("{}\n", .{i});
    }

    return std.mem.span(bufstr).len;
}

test "day10_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    const buffer = gpa.alloc(u8, 16777216) catch unreachable;
    const buf2 = gpa.alloc(u8, 16777216) catch unreachable;
    const bufstr: [*:0]u8 = @ptrCast(&buffer[0]);
    @memset(buffer, 0);

    @memcpy(buffer[0..input.len], input);

    for (0..50) |i| {
        _ = i;
        processLine(std.mem.span(bufstr), buf2);
        //print("Buf: {s}\n", .{bufstr});
        //print("Buf2: {s}\n", .{buf2});
        @memcpy(buffer, buf2);
        //print("Buf3: {s}\n", .{bufstr});
        //print("{s}\n", .{bufstr});
        //print("{}\n", .{i});
    }

    return std.mem.span(bufstr).len;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 10:\n", .{});
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
