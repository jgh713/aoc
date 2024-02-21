const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day15.txt");
const testdata = "Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8\r\nCinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3";

test "day15_part1" {
    const res = part1(testdata);
    assert(res == 62842880);
}

fn score(items: [4]@Vector(4, i32), counts: [4]i32, max: u8) i32 {
    var vals: @Vector(4, i32) = .{ 0, 0, 0, 0 };
    for (0..max) |i| {
        //print("count: {}\n", .{counts[i]});
        //print("item: {any}\n", .{items[i]});
        vals += items[i] * @as(@Vector(4, i32), @splat(counts[i]));
    }
    const lt = @reduce(.Or, vals < @as(@Vector(4, i32), @splat(1)));
    if (lt) return 0;
    return @reduce(.Mul, vals);
}

pub fn part1(input: []const u8) isize {
    var items: [4]@Vector(4, i32) = undefined;
    var ic: u8 = 0;
    {
        var lines = splitSeq(u8, input, "\r\n");
        while (lines.next()) |line| {
            var words = splitSca(u8, line, ' ');
            for (0..2) |_| _ = words.next();
            var w = words.next().?;
            const capacity = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const durability = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const flavor = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const texture = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            items[ic] = .{ capacity, durability, flavor, texture };
            ic += 1;
        }
    }

    var counts: [4]i32 = .{ 1, 1, 1, 1 };
    for (0..100 - ic) |_| {
        var mi: usize = 5;
        var mv: i32 = 0;
        for (0..ic) |i| {
            var newcount = counts;
            newcount[i] += 1;
            const s = score(items, newcount, ic);
            if (s > mv) {
                mv = s;
                mi = i;
            }
        }
        counts[mi] += 1;
    }
    //print("counts: {any}\n", .{counts});
    return score(items, counts, ic);
}

test "day15_part2" {
    const res = part2(testdata);
    assert(res == 57600000);
}

inline fn calories(counts: [4]i32, cals: [4]i32, max: u8) i32 {
    var total: i32 = 0;
    for (0..max) |i| {
        total += counts[i] * cals[i];
    }
    return total;
}

pub fn part2(input: []const u8) i32 {
    var items: [4]@Vector(4, i32) = undefined;
    var cals: [4]i32 = undefined;
    var ic: u8 = 0;
    {
        var lines = splitSeq(u8, input, "\r\n");
        while (lines.next()) |line| {
            var words = splitSca(u8, line, ' ');
            for (0..2) |_| _ = words.next();
            var w = words.next().?;
            const capacity = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const durability = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const flavor = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            w = words.next().?;
            const texture = parseInt(i32, w[0 .. w.len - 1], 10) catch unreachable;
            _ = words.next();
            const calos = parseInt(i32, words.next().?, 10) catch unreachable;
            items[ic] = .{ capacity, durability, flavor, texture };
            cals[ic] = calos;
            ic += 1;
        }
    }

    var counts: [4]i32 = .{ 0, 0, 0, 0 };
    var i: u8 = ic - 1;
    var mv: i32 = 0;
    outerloop: while (true) {
        while (calories(counts, cals, ic) > 500) {
            if (i == 0) {
                break :outerloop;
            } else {
                i -= 1;
                counts[i] += 1;
                counts[i + 1] = 0;
            }
        }
        i = ic - 1;
        while (calories(counts, cals, ic) < 500) {
            counts[i] += 1;
        }
        if (calories(counts, cals, ic) == 500) {
            if (@reduce(.Add, @as(@Vector(4, i32), counts)) == 100) {
                mv = @max(mv, score(items, counts, ic));
            }
            // Prevents infinite loops if exactly 500
            counts[i] += 1;
        }
    }

    return mv;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 15:\n", .{});
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
