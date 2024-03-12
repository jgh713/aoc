const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day01.txt");
const testdata = "R5, L5, R5, R3";
const testdata2 = "R8, R4, R4, R8";

test "day01_part1" {
    const res = part1(testdata);
    assert(res == 12);
}

pub fn part1(input: []const u8) usize {
    var words = splitSeq(u8, input, ", ");
    var x: isize = 0;
    var y: isize = 0;
    var dir: u2 = 0;
    const offsets = [4][2]isize{ .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 } };
    while (words.next()) |word| {
        const turn = word[0];
        const dist = parseInt(isize, word[1..], 10) catch unreachable;
        if (turn == 'R') {
            dir +%= 1;
        } else {
            dir -%= 1;
        }
        x += dist * offsets[dir][0];
        y += dist * offsets[dir][1];
    }

    return @abs(x) + @abs(y);
}

test "day01_part2" {
    const res = part2(testdata2);
    assert(res == 4);
}

pub fn part2(input: []const u8) usize {
    var membuffer: [2000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();
    var words = splitSeq(u8, input, ", ");
    var x: isize = 0;
    var y: isize = 0;
    var dir: u2 = 0;
    const offsets = [4][2]isize{ .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 } };
    var map = std.AutoHashMap([2]isize, void).init(alloc);
    map.put(.{ 0, 0 }, {}) catch unreachable;
    while (words.next()) |word| {
        const turn = word[0];
        const dist = parseInt(usize, word[1..], 10) catch unreachable;
        if (turn == 'R') {
            dir +%= 1;
        } else {
            dir -%= 1;
        }
        for (0..dist) |_| {
            x += offsets[dir][0];
            y += offsets[dir][1];
            const e = map.getOrPut(.{ x, y }) catch unreachable;
            if (e.found_existing) {
                return @abs(x) + @abs(y);
            }
        }
    }

    unreachable;
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
