const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day25.txt");
const testdata = "1=-0-2\r\n12111\r\n2=0=\r\n21\r\n2=01\r\n111\r\n20012\r\n112\r\n1=-1=\r\n1-12\r\n12\r\n1=\r\n122";

test "day25_part1" {
    assert(snafuToDecimal("1=-0-2") == 1747);
    assert(snafuToDecimal("12111") == 906);
    assert(snafuToDecimal("2=0=") == 198);
    assert(snafuToDecimal("21") == 11);
    assert(snafuToDecimal("2=01") == 201);
    assert(snafuToDecimal("111") == 31);
    assert(snafuToDecimal("20012") == 1257);
    assert(snafuToDecimal("112") == 32);
    assert(snafuToDecimal("1=-1=") == 353);
    assert(snafuToDecimal("1-12") == 107);
    assert(snafuToDecimal("12") == 7);
    assert(snafuToDecimal("1=") == 3);
    assert(snafuToDecimal("122") == 37);

    //
    //        1              1
    //        2              2
    //        3             1=
    //        4             1-
    //        5             10
    //        6             11
    //        7             12
    //        8             2=
    //        9             2-
    //       10             20
    //       15            1=0
    //       20            1-0
    //     2022         1=11-2
    //    12345        1-0---0
    //314159265  1121-1110-1=0
    assert(std.mem.eql(u8, decimalToSnafu(1), "1"));
    assert(std.mem.eql(u8, decimalToSnafu(2), "2"));
    assert(std.mem.eql(u8, decimalToSnafu(3), "1="));
    assert(std.mem.eql(u8, decimalToSnafu(4), "1-"));
    assert(std.mem.eql(u8, decimalToSnafu(5), "10"));
    assert(std.mem.eql(u8, decimalToSnafu(6), "11"));
    assert(std.mem.eql(u8, decimalToSnafu(7), "12"));
    assert(std.mem.eql(u8, decimalToSnafu(8), "2="));
    assert(std.mem.eql(u8, decimalToSnafu(9), "2-"));
    assert(std.mem.eql(u8, decimalToSnafu(10), "20"));
    assert(std.mem.eql(u8, decimalToSnafu(15), "1=0"));
    assert(std.mem.eql(u8, decimalToSnafu(20), "1-0"));
    assert(std.mem.eql(u8, decimalToSnafu(2022), "1=11-2"));
    assert(std.mem.eql(u8, decimalToSnafu(12345), "1-0---0"));
    assert(std.mem.eql(u8, decimalToSnafu(314159265), "1121-1110-1=0"));

    const res = part1(testdata);
    assert(std.mem.eql(u8, res, "2=-1=0"));
}

fn snafuToDecimal(s: []const u8) usize {
    var res: isize = 0;
    for (0..s.len) |i| {
        const c = s[s.len - 1 - i];
        var base: isize = 1;
        for (0..i) |_| {
            base *= 5;
        }
        const val = switch (c) {
            '0'...'2' => (c - '0') * base,
            '-' => -base,
            '=' => -base * 2,
            else => unreachable,
        };
        res += val;
    }

    assert(res >= 0);

    return @abs(res);
}

fn decimalToSnafu(n: usize) []u8 {
    var current: isize = @intCast(@as(u63, @truncate(n)));
    var i: usize = 1;
    var base: isize = 5;
    while (n > @divTrunc(base, 2)) : (base *= 5) {
        i += 1;
    }

    const str = gpa.alloc(u8, i) catch unreachable;

    for (0..i) |j| {
        base = @divExact(base, 5);
        const hold: isize = current + (base * 2) + @divFloor(base, 2);
        const val: isize = @divFloor(hold, base) - 2;
        current -= val * base;
        str[j] = switch (val) {
            -2 => '=',
            -1 => '-',
            0 => '0',
            1 => '1',
            2 => '2',
            else => unreachable,
        };
    }

    return str;
}

pub fn part1(input: []const u8) []u8 {
    var lines = splitSeq(u8, input, "\r\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        total += snafuToDecimal(line);
    }

    return decimalToSnafu(total);
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    print("Day 25:\n", .{});
    print("\tPart 1: {s}\n", .{res});
    print("\tTime: {}ns\n", .{time});
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
