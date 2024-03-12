const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day08.txt");
const testdata = "rect 3x2\r\nrotate column x=1 by 1\r\nrotate row y=0 by 4\r\nrotate column x=1 by 1";

test "day08_part1" {
    const res = part1(testdata);
    assert(res == 6);
}

fn printBoard(rect: [6][50]bool) void {
    for (rect) |row| {
        for (row) |pixel| {
            if (pixel) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("\n", .{});
}

pub fn part1(input: []const u8) usize {
    var rect: [6][50]bool = comptime std.mem.zeroes([6][50]bool);
    var lines = splitSeq(u8, input, "\r\n");

    //print("Start:\n", .{});
    //printBoard(rect);

    while (lines.next()) |line| {
        var words = splitSeq(u8, line, " ");
        const cmd = words.next().?;
        if (std.mem.eql(u8, cmd, "rect")) {
            var size = splitSeq(u8, words.next().?, "x");
            const w = parseInt(usize, size.next().?, 10) catch unreachable;
            const h = parseInt(usize, size.next().?, 10) catch unreachable;
            for (0..h) |y| {
                @memset(rect[y][0..w], true);
            }
        } else if (std.mem.eql(u8, cmd, "rotate")) {
            _ = words.next();
            var idline = splitSeq(u8, words.next().?, "=");
            const axis: u8 = idline.next().?[0];
            const pos = parseInt(usize, idline.next().?, 10) catch unreachable;
            _ = words.next();
            const offset = parseInt(usize, words.next().?, 10) catch unreachable;

            switch (axis) {
                'x' => {
                    var newline: [6]bool = undefined;
                    for (0..6) |y| {
                        const newy = (y + offset) % 6;
                        newline[newy] = rect[y][pos];
                    }
                    for (0..6) |y| {
                        rect[y][pos] = newline[y];
                    }
                },
                'y' => {
                    var newline: [50]bool = undefined;
                    for (0..50) |x| {
                        const newx = (x + offset) % 50;
                        newline[newx] = rect[pos][x];
                    }
                    rect[pos] = newline;
                },
                else => unreachable,
            }
        } else unreachable;
        //print("After: {s}\n", .{line});
        //printBoard(rect);
    }

    var count: usize = 0;
    for (rect) |row| {
        for (row) |pixel| {
            if (pixel) count += 1;
        }
    }

    return count;
}

test "day08_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) []u8 {
    var rect: [6][50]bool = comptime std.mem.zeroes([6][50]bool);
    var lines = splitSeq(u8, input, "\r\n");

    //print("Start:\n", .{});
    //printBoard(rect);

    while (lines.next()) |line| {
        var words = splitSeq(u8, line, " ");
        const cmd = words.next().?;
        if (std.mem.eql(u8, cmd, "rect")) {
            var size = splitSeq(u8, words.next().?, "x");
            const w = parseInt(usize, size.next().?, 10) catch unreachable;
            const h = parseInt(usize, size.next().?, 10) catch unreachable;
            for (0..h) |y| {
                @memset(rect[y][0..w], true);
            }
        } else if (std.mem.eql(u8, cmd, "rotate")) {
            _ = words.next();
            var idline = splitSeq(u8, words.next().?, "=");
            const axis: u8 = idline.next().?[0];
            const pos = parseInt(usize, idline.next().?, 10) catch unreachable;
            _ = words.next();
            const offset = parseInt(usize, words.next().?, 10) catch unreachable;

            switch (axis) {
                'x' => {
                    var newline: [6]bool = undefined;
                    for (0..6) |y| {
                        const newy = (y + offset) % 6;
                        newline[newy] = rect[y][pos];
                    }
                    for (0..6) |y| {
                        rect[y][pos] = newline[y];
                    }
                },
                'y' => {
                    var newline: [50]bool = undefined;
                    for (0..50) |x| {
                        const newx = (x + offset) % 50;
                        newline[newx] = rect[pos][x];
                    }
                    rect[pos] = newline;
                },
                else => unreachable,
            }
        } else unreachable;
        //print("After: {s}\n", .{line});
        //printBoard(rect);
    }

    const buffer = gpa.alloc(u8, (50 * 6) + 6) catch unreachable;

    var i: usize = 0;
    for (rect) |row| {
        for (row) |pixel| {
            if (pixel) {
                i += (std.fmt.bufPrint(buffer[i..], "#", .{}) catch unreachable).len;
            } else {
                i += (std.fmt.bufPrint(buffer[i..], ".", .{}) catch unreachable).len;
            }
        }
        i += (std.fmt.bufPrint(buffer[i..], "\n", .{}) catch unreachable).len;
    }

    return buffer;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 08:\n", .{});
    print("\tPart 1: {}\n", .{res});
    print("\tPart 2:\n{s}\n", .{res2});
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
