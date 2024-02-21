const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day10.txt");
const testdata = "[({(<(())[]>[[{[]{<()<>>\r\n[(()[<>])]({[<{<<[]>>(\r\n{([(<{}[<>[]}>{[]{[(<()>\r\n(((({<>}<{<{<>}{[]{[]{}\r\n[[<[([]))<([[{}[[()]]]\r\n[{[{({}]{}}([{[{{{}}([]\r\n{<[[]]>}<{[{[{[]{()[[[]\r\n[<(<(<(<{}))><([]([]()\r\n<{([([[(<>()){}]>(<<{{\r\n<{([{{}}[<[[[<>{}]]]>[]]";

test "day10_part1" {
    const res = part1(testdata);
    assert(res == 26397);
}

const Chars = enum {
    Paren,
    Brace,
    Bracket,
    Angle,
};

fn getClose(c: Chars) u8 {
    return switch (c) {
        Chars.Paren => ')',
        Chars.Brace => '}',
        Chars.Bracket => ']',
        Chars.Angle => '>',
    };
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var stack: [100]Chars = undefined;

    var total: usize = 0;

    lineloop: while (lines.next()) |line| {
        var si: usize = 0;
        for (line) |c| {
            const next = switch (c) {
                '{' => Chars.Brace,
                '(' => Chars.Paren,
                '[' => Chars.Bracket,
                '<' => Chars.Angle,
                '}', ')', '>', ']' => {
                    const close = getClose(stack[si - 1]);
                    if (c != close) {
                        total += switch (c) {
                            ')' => 3,
                            ']' => 57,
                            '}' => 1197,
                            '>' => 25137,
                            else => unreachable,
                        };
                        continue :lineloop;
                    }
                    si -= 1;
                    continue;
                },
                else => unreachable,
            };
            stack[si] = next;
            si += 1;
        }
    }

    return total;
}

test "day10_part2" {
    const res = part2(testdata);
    assert(res == 288957);
}

fn lessThan(_: void, a: usize, b: usize) bool {
    return a < b;
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var stack: [100]Chars = undefined;

    var vals: [100]usize = undefined;
    var vi: usize = 0;

    lineloop: while (lines.next()) |line| {
        var si: usize = 0;
        for (line) |c| {
            const next = switch (c) {
                '{' => Chars.Brace,
                '(' => Chars.Paren,
                '[' => Chars.Bracket,
                '<' => Chars.Angle,
                '}', ')', '>', ']' => {
                    const close = getClose(stack[si - 1]);
                    if (c != close) {
                        continue :lineloop;
                    }
                    si -= 1;
                    continue;
                },
                else => unreachable,
            };
            stack[si] = next;
            si += 1;
        }

        var val: usize = 0;
        while (si > 0) {
            si -= 1;
            val *= 5;
            val += switch (stack[si]) {
                Chars.Paren => 1,
                Chars.Bracket => 2,
                Chars.Brace => 3,
                Chars.Angle => 4,
            };
            //print("tval: {}\n", .{val});
        }
        //print("line: {s}\n", .{line});
        //print("val: {}\n", .{val});
        vals[vi] = val;
        vi += 1;
    }

    sort(usize, vals[0..vi], {}, lessThan);

    return vals[vi / 2];
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
