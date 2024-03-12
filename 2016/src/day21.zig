const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day21.txt");
const testdata = "";

test "day21_part1" {
    const res = part1(data);
    print("{s}\n", .{res});
    assert(std.mem.eql(u8, res, "bcgdehfa"));
    for (0..8) |i| {
        var dist = i;
        if (dist >= 4) dist += 1;
        const new = (i + dist + 1) % 8;
        print("{d} -> {d}\n", .{ i, new });
    }
}

fn rotatePass(pass: [8]u8, n: isize) [8]u8 {
    var res: [8]u8 = undefined;
    for (0..pass.len) |i| {
        const ii: isize = @intCast(i);
        res[@intCast(@mod(ii + n, pass.len))] = pass[i];
    }
    return res;
}

pub fn part1(input: []const u8) []u8 {
    var pass: [8]u8 = if (builtin.is_test) "hgcbdaef".* else "abcdefgh".*;
    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        //print("Pass: {s}\n", .{pass});
        //print("Line: {s}\n", .{line});
        var words = splitSca(u8, line, ' ');
        const w1 = words.next().?;
        if (std.mem.eql(u8, w1, "swap")) {
            const w2 = words.next().?;
            if (std.mem.eql(u8, w2, "position")) {
                const x = parseInt(u8, words.next().?, 10) catch unreachable;
                for (0..2) |_| _ = words.next();
                const y = parseInt(u8, words.next().?, 10) catch unreachable;
                std.mem.swap(u8, &pass[x], &pass[y]);
            } else if (std.mem.eql(u8, w2, "letter")) {
                const a = words.next().?[0];
                for (0..2) |_| _ = words.next();
                const b = words.next().?[0];
                for (0..pass.len) |i| {
                    if (pass[i] == a) {
                        pass[i] = b;
                    } else if (pass[i] == b) {
                        pass[i] = a;
                    }
                }
            } else unreachable;
        } else if (std.mem.eql(u8, w1, "rotate")) {
            const w2 = words.next().?;
            if (std.mem.eql(u8, w2, "right")) {
                const dist = parseInt(isize, words.next().?, 10) catch unreachable;
                pass = rotatePass(pass, dist);
            } else if (std.mem.eql(u8, w2, "left")) {
                const dist = parseInt(isize, words.next().?, 10) catch unreachable;
                pass = rotatePass(pass, -dist);
            } else if (std.mem.eql(u8, w2, "based")) {
                for (0..4) |_| _ = words.next();
                const c = words.next().?[0];
                const idx = indexOf(u8, pass[0..], c).?;
                var dist: isize = @intCast(idx + 1);
                if (idx >= 4) dist += 1;
                pass = rotatePass(pass, dist);
            } else unreachable;
        } else if (std.mem.eql(u8, w1, "reverse")) {
            _ = words.next();
            const x = parseInt(u8, words.next().?, 10) catch unreachable;
            _ = words.next();
            const y = parseInt(u8, words.next().?, 10) catch unreachable;
            std.mem.reverse(u8, pass[x .. y + 1]);
        } else if (std.mem.eql(u8, w1, "move")) {
            _ = words.next();
            const x = parseInt(u8, words.next().?, 10) catch unreachable;
            for (0..2) |_| _ = words.next();
            const y = parseInt(u8, words.next().?, 10) catch unreachable;
            const c = pass[x];
            if (y > x) {
                for (x..y) |i| {
                    pass[i] = pass[i + 1];
                }
            } else if (y < x) {
                var i: usize = x;
                while (i > y) {
                    pass[i] = pass[i - 1];
                    i -= 1;
                }
            }
            pass[y] = c;
        } else unreachable;
    }
    return gpa.dupe(u8, &pass) catch unreachable;
}

test "day21_part2" {
    const res = part2(data);
    assert(std.mem.eql(u8, res, "hgcbdaef"));
}

const unshifts: [8]isize = .{
    -1,
    -1,
    2,
    -2,
    1,
    -3,
    0,
    4,
};

pub fn part2(input: []const u8) []u8 {
    var pass: [8]u8 = if (builtin.is_test) "bcgdehfa".* else "fbgdceah".*;
    var lines = std.mem.splitBackwardsSequence(u8, input, "\r\n");
    while (lines.next()) |line| {
        //print("Pass: {s}\n", .{pass});
        //print("Line: {s}\n", .{line});
        var words = splitSca(u8, line, ' ');
        const w1 = words.next().?;
        if (std.mem.eql(u8, w1, "swap")) {
            const w2 = words.next().?;
            if (std.mem.eql(u8, w2, "position")) {
                const x = parseInt(u8, words.next().?, 10) catch unreachable;
                for (0..2) |_| _ = words.next();
                const y = parseInt(u8, words.next().?, 10) catch unreachable;
                std.mem.swap(u8, &pass[x], &pass[y]);
            } else if (std.mem.eql(u8, w2, "letter")) {
                const a = words.next().?[0];
                for (0..2) |_| _ = words.next();
                const b = words.next().?[0];
                for (0..pass.len) |i| {
                    if (pass[i] == a) {
                        pass[i] = b;
                    } else if (pass[i] == b) {
                        pass[i] = a;
                    }
                }
            } else unreachable;
        } else if (std.mem.eql(u8, w1, "rotate")) {
            const w2 = words.next().?;
            if (std.mem.eql(u8, w2, "right")) {
                const dist = parseInt(isize, words.next().?, 10) catch unreachable;
                pass = rotatePass(pass, -dist);
            } else if (std.mem.eql(u8, w2, "left")) {
                const dist = parseInt(isize, words.next().?, 10) catch unreachable;
                pass = rotatePass(pass, dist);
            } else if (std.mem.eql(u8, w2, "based")) {
                for (0..4) |_| _ = words.next();
                const c = words.next().?[0];
                const idx = indexOf(u8, pass[0..], c).?;
                const dist = unshifts[idx];
                pass = rotatePass(pass, dist);
            } else unreachable;
        } else if (std.mem.eql(u8, w1, "reverse")) {
            _ = words.next();
            const x = parseInt(u8, words.next().?, 10) catch unreachable;
            _ = words.next();
            const y = parseInt(u8, words.next().?, 10) catch unreachable;
            std.mem.reverse(u8, pass[x .. y + 1]);
        } else if (std.mem.eql(u8, w1, "move")) {
            _ = words.next();
            const y = parseInt(u8, words.next().?, 10) catch unreachable;
            for (0..2) |_| _ = words.next();
            const x = parseInt(u8, words.next().?, 10) catch unreachable;
            const c = pass[x];
            if (y > x) {
                for (x..y) |i| {
                    pass[i] = pass[i + 1];
                }
            } else if (y < x) {
                var i: usize = x;
                while (i > y) {
                    pass[i] = pass[i - 1];
                    i -= 1;
                }
            }
            pass[y] = c;
        } else unreachable;
    }
    return gpa.dupe(u8, &pass) catch unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 21:\n", .{});
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
