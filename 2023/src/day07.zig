const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day07.txt");
const testdata = "32T3K 765\nT55J5 684\nKK677 28\nKTJJT 220\nQQQJA 483\n";

test "day1_part1" {
    const res = part1(testdata);
    assert(res == 6440);
}

const Card = struct { value: u32, bid: u16 };

inline fn handval(hand: [14]u4) u32 {
    var max: u4 = 0;
    var sec: u4 = 0;
    for (hand[1..]) |count| {
        if (count > max) {
            sec = max;
            max = count;
        } else if (count > sec) {
            sec = count;
        }
    }

    max += hand[0];

    if (max == 5) {
        return 7;
    } else if (max == 4) {
        return 6;
    } else if (max == 3) {
        if (sec == 2) {
            return 5;
        } else {
            return 4;
        }
    } else if (max == 2) {
        if (sec == 2) {
            return 3;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}

fn cardLess(c: @TypeOf(.{}), a: Card, b: Card) bool {
    _ = c;
    return a.value < b.value;
}

pub fn part1(input: []const u8) u64 {
    var cards: [1000]Card = undefined;
    var card: u16 = 0;
    var left: bool = true;
    var cleft: u32 = 0;
    var cright: u16 = 0;
    var hand: [14]u4 = .{0} ** 14;

    for (input) |c| {
        if (c == '\r') {
            continue;
        }
        if (c == ' ') {
            left = false;
            continue;
        }

        if (c == '\n') {
            cards[card] = Card{ .value = cleft + (handval(hand) << 20), .bid = cright };
            left = true;
            card += 1;
            cleft = 0;
            cright = 0;
            hand = .{0} ** 14;
            continue;
        }

        const val = switch (c) {
            '0'...'9' => (c - '0'),
            'T' => 10,
            'J' => 11,
            'Q' => 12,
            'K' => 13,
            'A' => 14,
            else => {
                print("Invalid card: {c}\n", .{c});
                unreachable;
            },
        };

        if (left) {
            cleft = (cleft << 4) + val;
            hand[val - 1] += 1;
        } else {
            cright = cright * 10 + val;
        }
    }

    sort(Card, &cards, .{}, cardLess);

    var res: u64 = 0;

    for (cards[0..card], 0..) |c, i| {
        res += c.bid * (i + 1);
    }

    return res;
}

test "day7_part2" {
    const res = part2(testdata);
    assert(res == 5905);
}

pub fn part2(input: []const u8) u64 {
    var cards: [1000]Card = undefined;
    var card: u16 = 0;
    var left: bool = true;
    var cleft: u32 = 0;
    var cright: u16 = 0;
    var hand: [14]u4 = .{0} ** 14;

    for (input) |c| {
        if (c == '\r') {
            continue;
        }
        if (c == ' ') {
            left = false;
            continue;
        }

        if (c == '\n') {
            cards[card] = Card{ .value = cleft + (handval(hand) << 20), .bid = cright };
            left = true;
            card += 1;
            cleft = 0;
            cright = 0;
            hand = .{0} ** 14;
            continue;
        }

        const val = switch (c) {
            '0'...'9' => (c - '0'),
            'T' => 10,
            'J' => 1,
            'Q' => 12,
            'K' => 13,
            'A' => 14,
            else => {
                print("Invalid card: {c}\n", .{c});
                unreachable;
            },
        };

        if (left) {
            cleft = (cleft << 4) + val;
            hand[val - 1] += 1;
        } else {
            cright = cright * 10 + val;
        }
    }

    sort(Card, &cards, .{}, cardLess);

    var res: u64 = 0;

    for (cards[0..card], 0..) |c, i| {
        res += c.bid * (i + 1);
    }

    return res;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns \n", .{time1});
    print("Part2 took {}ns \n", .{time2});
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
