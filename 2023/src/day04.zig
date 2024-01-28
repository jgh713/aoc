const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day04.txt");
const testdata = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53\nCard 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19\nCard 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1\nCard 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83\nCard 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36\nCard 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11";

test "day4_test1" {
    const result = part1(testdata);
    assert(result == 13);
    const res2 = part1(data);
    assert(res2 == 22488);
}

const steps = enum { id, wins, checks };

inline fn isDigit(x: u8) bool {
    return x >= '0' and x <= '9';
}

pub fn part1(input: []const u8) usize {
    var total: usize = 0;
    var step = steps.id;
    var current: u8 = 0;
    var winners = [_]u8{0} ** 12;
    var wins: u32 = 0;
    var cardval: u32 = 0;

    for (input) |char| {
        if (char == ':') {
            step = steps.wins;
            continue;
        }

        if (step == steps.id) {
            continue;
        }

        if (char == '|') {
            step = steps.checks;
            continue;
        }

        if (char == '\n') {
            for (winners[0..wins]) |win| {
                if (win == current) {
                    cardval = switch (cardval) {
                        0 => 1,
                        else => cardval * 2,
                    };
                    break;
                }
            }
            current = 0;
            total += cardval;
            cardval = 0;
            wins = 0;
            step = steps.id;
            continue;
        }

        if (isDigit(char)) {
            current = current * 10 + (char - '0');
            continue;
        }

        if (current > 0 and step == steps.wins) {
            winners[wins] = current;
            wins += 1;
            current = 0;
            continue;
        }

        if (current > 0 and step == steps.checks) {
            for (winners[0..wins]) |win| {
                if (win == current) {
                    cardval = switch (cardval) {
                        0 => 1,
                        else => cardval * 2,
                    };
                    break;
                }
            }
            current = 0;
            continue;
        }
    }

    total += cardval;
    return total;
}

fn part1slow(input: []const u8) usize {
    var total: usize = 0;
    var wins: [12][]const u8 = undefined;
    const in = indexOf(u8, input, '\r');
    var delim: []const u8 = "\n";
    if (in != null) {
        delim = "\r\n";
    }

    var lines = splitSeq(u8, input, delim);

    var i: u32 = 1;
    while (lines.next()) |line| {
        var value: usize = 0;
        const start = indexOf(u8, line, ':').? + 2;
        var cards = splitSca(u8, line[start..], '|');
        var winit = splitSca(u8, cards.next().?, ' ');
        var checkit = splitSca(u8, cards.next().?, ' ');
        var wincount: u32 = 0;

        while (winit.next()) |win| {
            if (win.len == 0) {
                continue;
            }
            wins[wincount] = win;
            wincount += 1;
        }

        while (checkit.next()) |check| {
            if (check.len == 0) {
                continue;
            }
            for (wins[0..wincount]) |win| {
                if (std.mem.eql(u8, check, win)) {
                    value = switch (value) {
                        0 => 1,
                        else => value * 2,
                    };
                    break;
                }
            }
        }

        i += 1;
        total += value;
    }

    return total;
}

test "day4_part2" {
    const result = part2(testdata);
    assert(result == 30);
}

pub fn part2(input: []const u8) usize {
    var total: usize = 0;
    var step = steps.id;
    var current: u8 = 0;
    var winners = [_]u8{0} ** 12;
    var wins: u32 = 0;
    var cardval: u32 = 0;
    var id: u32 = 1;
    var extras: [220]u32 = .{1} ** 220;

    for (input) |char| {
        if (char == ':') {
            step = steps.wins;
            continue;
        }

        if (step == steps.id) {
            continue;
        }

        if (char == '|') {
            step = steps.checks;
            continue;
        }

        if (char == '\n') {
            for (winners[0..wins]) |win| {
                if (win == current) {
                    cardval += 1;
                    break;
                }
            }
            current = 0;

            const mult = extras[id];
            if (cardval > 0) {
                const min: u32 = id + 1;
                const cap: u32 = @min(min + cardval, 220);
                for (min..cap) |exi| {
                    extras[exi] += mult;
                }
            }
            total += mult;

            cardval = 0;
            wins = 0;
            step = steps.id;
            id += 1;
            continue;
        }

        if (isDigit(char)) {
            current = current * 10 + (char - '0');
            continue;
        }

        if (current > 0 and step == steps.wins) {
            winners[wins] = current;
            wins += 1;
            current = 0;
            continue;
        }

        if (current > 0 and step == steps.checks) {
            for (winners[0..wins]) |win| {
                if (win == current) {
                    cardval += 1;
                    break;
                }
            }
            current = 0;
            continue;
        }
    }

    if (current > 0) {
        for (winners[0..wins]) |win| {
            if (win == current) {
                cardval = switch (cardval) {
                    0 => 1,
                    else => cardval * 2,
                };
                break;
            }
        }
        current = 0;
    }

    const mult = extras[id];
    if (cardval > 0) {
        const min: u32 = id + 1;
        const cap: u32 = @min(min + cardval, 220);
        for (min..cap) |exi| {
            extras[exi] += mult;
        }
    }
    total += mult;

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time1});
    print("Part2 took {}ns\n", .{time2});
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
