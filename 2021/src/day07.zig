const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day07.txt");
const testdata = "16,1,2,0,4,2,7,1,2,14";

test "day07_part1" {
    const res = part1(testdata);
    assert(res == 37);
}

pub fn part1(input: []const u8) usize {
    var locs: [2000]u16 = comptime std.mem.zeroes([2000]u16);
    var nums = splitSca(u8, input, ',');
    var max: usize = 0;

    while (nums.next()) |num| {
        const val = parseInt(u16, num, 10) catch unreachable;
        max = @max(max, val);
        locs[val] += 1;
    }

    var fuel: usize = 0;

    var l: usize = 0;
    var r: usize = max;

    while (l != r) {
        const lc = locs[l];
        const rc = locs[r];

        //print("l: {}, r: {}, lc: {}, rc: {}\n", .{ l, r, lc, rc });

        if (lc > rc) {
            var nr = r - 1;
            while (locs[nr] == 0) {
                nr -= 1;
            }
            locs[nr] += rc;
            fuel += (r - nr) * rc;
            r = nr;
        } else {
            var nl = l + 1;
            while (locs[nl] == 0) {
                nl += 1;
            }
            locs[nl] += lc;
            fuel += (nl - l) * lc;
            l = nl;
        }
    }

    return fuel;
}

test "day07_part2" {
    const res = part2(testdata);
    assert(res == 168);
}

const Crabs = struct {
    count: u16,
    cost: u32,
};

pub fn part2(input: []const u8) usize {
    var locs: [2000]Crabs = comptime std.mem.zeroes([2000]Crabs);
    var nums = splitSca(u8, input, ',');
    var max: usize = 0;

    while (nums.next()) |num| {
        const val = parseInt(u16, num, 10) catch unreachable;
        max = @max(max, val);
        locs[val].count += 1;
        locs[val].cost += 1;
    }

    var fuel: usize = 0;

    var l: usize = 0;
    var r: usize = max;

    while (l != r) {
        const lc = locs[l];
        const rc = locs[r];

        //print("l: {}, r: {}, lc: {}, rc: {}\n", .{ l, r, lc, rc });

        if (lc.cost > rc.cost) {
            const nr = r - 1;
            locs[nr].count += rc.count;
            locs[nr].cost += rc.cost + rc.count;
            fuel += rc.cost;
            r = nr;
        } else {
            const nl = l + 1;
            locs[nl].count += lc.count;
            locs[nl].cost += lc.cost + lc.count;
            fuel += lc.cost;
            l = nl;
        }
    }

    //print("fuel: {}\n", .{fuel});

    return fuel;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 07:\n", .{});
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
