const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day13.txt");
const testdata = "Alice would gain 54 happiness units by sitting next to Bob.\r\nAlice would lose 79 happiness units by sitting next to Carol.\r\nAlice would lose 2 happiness units by sitting next to David.\r\nBob would gain 83 happiness units by sitting next to Alice.\r\nBob would lose 7 happiness units by sitting next to Carol.\r\nBob would lose 63 happiness units by sitting next to David.\r\nCarol would lose 62 happiness units by sitting next to Alice.\r\nCarol would gain 60 happiness units by sitting next to Bob.\r\nCarol would gain 55 happiness units by sitting next to David.\r\nDavid would gain 46 happiness units by sitting next to Alice.\r\nDavid would lose 7 happiness units by sitting next to Bob.\r\nDavid would gain 41 happiness units by sitting next to Carol.";

test "day13_part1" {
    const res = part1(testdata);
    assert(res == 330);
}

fn nameid(name: []const u8) u8 {
    return @min(name[0] - 'A', 7);
}

fn happiness(map: [8][8]isize, order: []u8) isize {
    var count: isize = 0;
    for (0..order.len) |i| {
        const j = (i + 1) % order.len;
        count += map[order[i]][order[j]];
        count += map[order[j]][order[i]];
    }
    return count;
}

pub fn part1(input: []const u8) isize {
    var map: [8][8]isize = undefined;
    var lines = splitSeq(u8, input, "\r\n");
    var mapi: u8 = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        const person = nameid(words.next().?);
        _ = words.next();
        var val: isize = switch (words.next().?[0]) {
            'g' => 1,
            'l' => -1,
            else => unreachable,
        };
        val *= parseInt(isize, words.next().?, 10) catch unreachable;
        for (0..6) |_| _ = words.next();
        const neighbor = nameid(words.next().?);
        map[person][neighbor] = val;
        mapi = @max(mapi, person);
    }

    var order: [9]u8 = comptime std.mem.zeroes([9]u8);

    for (0..mapi + 1) |i| {
        order[i] = @intCast(i);
    }

    // Happiness value is the same if shifted around
    // the outside of the array, so we only need permutations
    // for n-1 elements, with the first element fixed.
    const valslice = order[0 .. mapi + 1];
    const modslice = order[1 .. mapi + 1];
    var carr: [7]u8 = comptime std.mem.zeroes([7]u8);
    const c = carr[0..mapi];

    var i: usize = 0;
    //print("v: {any}\n", .{valslice});
    //print("m: {any}\n", .{modslice});
    //print("Len: {any}\n", .{modslice.len});
    var max: isize = happiness(map, valslice);
    while (i < modslice.len) {
        if (c[i] < i) {
            if (i % 2 == 0) {
                std.mem.swap(u8, &modslice[0], &modslice[i]);
            } else {
                std.mem.swap(u8, &modslice[c[i]], &modslice[i]);
            }
            //print("n: {any}\n", .{valslice});
            max = @max(max, happiness(map, valslice));
            c[i] += 1;
            i = 1;
        } else {
            c[i] = 0;
            i += 1;
        }
    }

    return max;
}

test "day13_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

fn happinessNoWrap(map: [8][8]isize, order: []u8) isize {
    var count: isize = 0;
    for (0..order.len - 1) |i| {
        const j = i + 1;
        count += map[order[i]][order[j]];
        count += map[order[j]][order[i]];
    }
    return count;
}

pub fn part2(input: []const u8) isize {
    var map: [8][8]isize = undefined;
    var lines = splitSeq(u8, input, "\r\n");
    var mapi: u8 = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        const person = nameid(words.next().?);
        _ = words.next();
        var val: isize = switch (words.next().?[0]) {
            'g' => 1,
            'l' => -1,
            else => unreachable,
        };
        val *= parseInt(isize, words.next().?, 10) catch unreachable;
        for (0..6) |_| _ = words.next();
        const neighbor = nameid(words.next().?);
        map[person][neighbor] = val;
        mapi = @max(mapi, person);
    }

    var order: [9]u8 = comptime std.mem.zeroes([9]u8);

    for (0..mapi + 1) |i| {
        order[i] = @intCast(i);
    }

    // And now we just treat end of list as the seat that
    // Doesn't matter, and permute the rest.
    const valslice = order[0 .. mapi + 1];
    const modslice = order[0 .. mapi + 1];
    var carr: [8]u8 = comptime std.mem.zeroes([8]u8);
    const c = carr[0 .. mapi + 1];

    var i: usize = 0;
    //print("v: {any}\n", .{valslice});
    //print("m: {any}\n", .{modslice});
    //print("Len: {any}\n", .{modslice.len});
    var max: isize = happinessNoWrap(map, valslice);
    while (i < modslice.len) {
        if (c[i] < i) {
            if (i % 2 == 0) {
                std.mem.swap(u8, &modslice[0], &modslice[i]);
            } else {
                std.mem.swap(u8, &modslice[c[i]], &modslice[i]);
            }
            //print("n: {any}\n", .{valslice});
            max = @max(max, happinessNoWrap(map, valslice));
            c[i] += 1;
            i = 1;
        } else {
            c[i] = 0;
            i += 1;
        }
    }

    return max;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 13:\n", .{});
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
