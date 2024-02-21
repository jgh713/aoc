const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day08.txt");
const testdata = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\r\nedbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\r\nfgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\r\nfbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\r\naecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\r\nfgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\r\ndbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\r\nbdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\r\negadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\r\ngcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce";

test "day08_part1" {
    const res = part1(testdata);
    assert(res == 26);
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");

    var count: usize = 0;
    while (lines.next()) |line| {
        var parts = splitSeq(u8, line, " | ");
        const inputs = parts.next().?;
        _ = inputs;
        const outputs = parts.next().?;
        var words = splitSeq(u8, outputs, " ");
        while (words.next()) |word| {
            switch (word.len) {
                2, 3, 4, 7 => count += 1,
                else => {},
            }
        }
    }

    //print("count: {}\n", .{count});
    return count;
}

test "day08_part2" {
    const val = parseLine("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf");
    assert(val == 5353);
    const res = part2(testdata);
    assert(res == 61229);
}

fn parseLine(line: []const u8) usize {
    var parts = splitSeq(u8, line, " | ");
    const inputs = parts.next().?;
    const outputs = parts.next().?;
    var ins = splitSca(u8, inputs, ' ');
    var outs = splitSca(u8, outputs, ' ');
    var vals: [10]u7 = comptime std.mem.zeroes([10]u7);
    var fives: [3]u7 = comptime std.mem.zeroes([3]u7);
    var fi: usize = 0;
    var sixes: [3]u7 = comptime std.mem.zeroes([3]u7);
    var si: usize = 0;

    // 2: 1 (cf)
    // 3: 7 (acf)
    // 4: 4 (bcdf)
    // 5: 2 (acdeg), 3 (acdfg), 5 (abdfg)
    // 6: 0 (abcefg), 6 (abdefg), 9 (abcdfg)
    // 7: 8 (abcdefg)
    //
    // bd: 4 not in 1
    //
    // 5: 5-length contains bd
    // 3: 5-length minus 7 minus bd, unknown 1
    // 2: 5-length leftover
    //
    // c: 1 not in 5
    //
    // 0: 6-length with only one of bd
    // 9: 6-length with c

    while (ins.next()) |in| {
        switch (in.len) {
            2 => {
                for (in) |c| {
                    vals[1] |= @as(u7, 1) << @intCast(c - 'a');
                }
            },
            3 => {
                for (in) |c| {
                    vals[7] |= @as(u7, 1) << @intCast(c - 'a');
                }
            },
            4 => {
                for (in) |c| {
                    vals[4] |= @as(u7, 1) << @intCast(c - 'a');
                }
            },
            5 => {
                for (in) |c| {
                    fives[fi] |= @as(u7, 1) << @intCast(c - 'a');
                }
                fi += 1;
            },
            6 => {
                for (in) |c| {
                    sixes[si] |= @as(u7, 1) << @intCast(c - 'a');
                }
                si += 1;
            },
            7 => {
                for (in) |c| {
                    vals[8] |= @as(u7, 1) << @intCast(c - 'a');
                }
            },
            else => unreachable,
        }
    }

    const bd = vals[1] ^ vals[4];

    vals[5] = for (fives) |five| {
        if (@popCount(five & bd) == 2) break five;
    } else unreachable;

    vals[3] = for (fives) |five| {
        if (five == vals[5]) continue;
        if (@popCount((five ^ bd ^ vals[7]) & five) == 1) break five;
    } else unreachable;

    vals[2] = for (fives) |five| {
        if (five == vals[5] or five == vals[3]) continue;
        break five;
    } else unreachable;

    const c = (vals[1] ^ vals[5]) & vals[1];

    vals[0] = for (sixes) |six| {
        if (@popCount(six & bd) == 1) break six;
    } else unreachable;

    vals[9] = for (sixes) |six| {
        if (six == vals[0]) continue;
        if (@popCount(six & c) == 1) break six;
    } else unreachable;

    vals[6] = for (sixes) |six| {
        if (six == vals[9] or six == vals[0]) continue;
        break six;
    } else unreachable;

    var current: usize = 0;

    while (outs.next()) |out| {
        var bits: u7 = 0;
        for (out) |ch| {
            bits |= @as(u7, 1) << @intCast(ch - 'a');
        }
        const val = indexOf(u7, &vals, bits).?;
        current = current * 10 + val;
    }

    return current;
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        total += parseLine(line);
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 08:\n", .{});
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
