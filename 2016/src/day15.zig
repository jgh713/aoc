const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day15.txt");
const testdata = "Disc #1 has 5 positions; at time=0, it is at position 4.\r\nDisc #2 has 2 positions; at time=0, it is at position 1.";

test "day15_part1" {
    const res = part1(testdata);
    assert(res == 5);
}

const Disc = struct {
    positions: u8,
    start: usize,
};

fn discLess(_: void, a: Disc, b: Disc) bool {
    return a.positions < b.positions;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var discs: [10]Disc = undefined;
    var did: usize = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        for (0..3) |_| _ = words.next();
        const positions = parseInt(u8, words.next().?, 10) catch unreachable;
        for (0..7) |_| _ = words.next();
        const sword = words.next().?;
        const start = parseInt(usize, sword[0 .. sword.len - 1], 10) catch unreachable;
        discs[did] = Disc{ .positions = positions, .start = (start + 1 + did) % positions };
        //print("Disc {}: {any}\n", .{ did + 1, discs[did] });
        did += 1;
    }

    const highest = std.sort.max(Disc, discs[0..did], {}, discLess).?;
    var time: usize = 0;
    if (highest.start != 0) {
        time = highest.positions - highest.start;
    }
    const mod = highest.positions;

    outerloop: while (true) {
        //print("Checking time: {}\n", .{time});
        for (discs[0..did], 1..) |disc, di| {
            _ = di;
            const pos = (disc.start + time) % disc.positions;
            //print("Disc {}: pos: {}\n", .{ di, pos });

            if (pos != 0) {
                time += mod;
                continue :outerloop;
            }
        }
        break;
    }
    return time;
}

test "day15_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var discs: [10]Disc = undefined;
    var did: usize = 0;
    while (lines.next()) |line| {
        var words = splitSca(u8, line, ' ');
        for (0..3) |_| _ = words.next();
        const positions = parseInt(u8, words.next().?, 10) catch unreachable;
        for (0..7) |_| _ = words.next();
        const sword = words.next().?;
        const start = parseInt(usize, sword[0 .. sword.len - 1], 10) catch unreachable;
        discs[did] = Disc{ .positions = positions, .start = (start + 1 + did) % positions };
        //print("Disc {}: {any}\n", .{ did + 1, discs[did] });
        did += 1;
    }

    discs[did] = Disc{ .positions = 11, .start = (1 + did) % 11 };
    did += 1;

    const highest = std.sort.max(Disc, discs[0..did], {}, discLess).?;
    var time: usize = 0;
    if (highest.start != 0) {
        time = highest.positions - highest.start;
    }
    const mod = highest.positions;

    outerloop: while (true) {
        //print("Checking time: {}\n", .{time});
        for (discs[0..did], 1..) |disc, di| {
            _ = di;
            const pos = (disc.start + time) % disc.positions;
            //print("Disc {}: pos: {}\n", .{ di, pos });

            if (pos != 0) {
                time += mod;
                continue :outerloop;
            }
        }
        break;
    }
    return time;
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
