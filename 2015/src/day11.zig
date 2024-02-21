const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day11.txt");
const testdata = "ghijklmn";

test "day11_part1" {
    const res = part1(testdata);
    assert(std.mem.eql(u8, &res, "ghjaabcc"));
}

fn validPass(p: []const u8) bool {
    var inc: u4 = 0;
    var lastpair: u4 = 15;
    var inc_done: bool = false;
    var pairs: u4 = 0;
    var last = p[0];
    for (p[1..], 1..) |c, i| {
        if (c == 'i' or c == 'o' or c == 'l') {
            return false;
        }
        if (c == last and lastpair != i - 1) {
            pairs += 1;
            lastpair = @intCast(i);
        }
        if (c == last + 1) {
            inc += 1;
            if (inc == 2) {
                inc_done = true;
            }
        } else {
            inc = 0;
        }
        last = c;
    }
    return pairs >= 2 and inc_done;
}

pub fn part1(input: []const u8) [8]u8 {
    var out: [8]u8 = undefined;
    @memcpy(&out, input);

    while (!validPass(&out)) {
        var i: u8 = 7;
        while (i >= 0) {
            if (out[i] == 'z') {
                out[i] = 'a';
                i -= 1;
            } else {
                out[i] += 1;
                switch (out[i]) {
                    'i', 'o', 'l' => out[i] += 1,
                    else => {},
                }
                break;
            }
        }
    }

    return out;
}

test "day11_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) [8]u8 {
    var out: [8]u8 = undefined;
    @memcpy(&out, input);
    var hits: u4 = 0;

    while (true) {
        if (validPass(&out)) {
            hits += 1;
            if (hits == 2) {
                break;
            }
        }
        var i: u8 = 7;
        while (i >= 0) {
            if (out[i] == 'z') {
                out[i] = 'a';
                i -= 1;
            } else {
                out[i] += 1;
                switch (out[i]) {
                    'i', 'o', 'l' => out[i] += 1,
                    else => {},
                }
                break;
            }
        }
    }

    return out;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 11:\n", .{});
    print("\tPart 1: {s}\n", .{res});
    print("\tPart 2: {s}\n", .{res2});
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
