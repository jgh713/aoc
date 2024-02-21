const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day13.txt");
const testdata = "6,10\r\n0,14\r\n9,10\r\n0,3\r\n10,4\r\n4,11\r\n6,0\r\n6,12\r\n4,1\r\n0,13\r\n10,12\r\n3,4\r\n3,0\r\n8,4\r\n1,10\r\n2,14\r\n8,10\r\n9,0\r\n\r\nfold along y=7\r\nfold along x=5";

test "day13_part1" {
    const res = part1(testdata);
    assert(res == 17);
}

const Fold = struct {
    axis: u1,
    pos: u16,
};

pub fn part1(input: []const u8) usize {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    const dotlines = parts.next().?;
    const foldlines = parts.next().?;
    var folds: [12]Fold = undefined;
    var fi: usize = 0;

    var foldit = splitSeq(u8, foldlines, "\r\n");
    while (foldit.next()) |fold| {
        switch (fold[11]) {
            'x' => folds[fi] = Fold{ .axis = 0, .pos = parseInt(u16, fold[13..], 10) catch unreachable },
            'y' => folds[fi] = Fold{ .axis = 1, .pos = parseInt(u16, fold[13..], 10) catch unreachable },
            else => unreachable,
        }
        fi += 1;
    }

    var dots = Map([2]u16, void).init(gpa);
    var maxx: u16 = 0;
    var maxy: u16 = 0;

    var dotit = splitSeq(u8, dotlines, "\r\n");
    while (dotit.next()) |dot| {
        var pts = splitSeq(u8, dot, ",");
        const x = parseInt(u16, pts.next().?, 10) catch unreachable;
        const y = parseInt(u16, pts.next().?, 10) catch unreachable;
        var pt: [2]u16 = .{ x, y };
        for (folds[0..1]) |fold| {
            if (pt[fold.axis] >= fold.pos) {
                pt[fold.axis] -= 2 * (pt[fold.axis] - fold.pos);
            }
        }
        dots.put(pt, {}) catch unreachable;
        maxx = @max(maxx, pt[0]);
        maxy = @max(maxy, pt[1]);
    }

    //print("\n", .{});
    //for (0..maxy + 1) |y| {
    //    for (0..maxx + 1) |x| {
    //        if (dots.contains([2]u16{ @intCast(x), @intCast(y) })) {
    //            print("#", .{});
    //        } else {
    //            print(".", .{});
    //        }
    //    }
    //    print("\n", .{});
    //}

    //print("{}\n", .{dots.count()});

    return dots.count();
}

test "day13_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var parts = splitSeq(u8, input, "\r\n\r\n");
    const dotlines = parts.next().?;
    const foldlines = parts.next().?;
    var folds: [12]Fold = undefined;
    var fi: usize = 0;

    var foldit = splitSeq(u8, foldlines, "\r\n");
    while (foldit.next()) |fold| {
        switch (fold[11]) {
            'x' => folds[fi] = Fold{ .axis = 0, .pos = parseInt(u16, fold[13..], 10) catch unreachable },
            'y' => folds[fi] = Fold{ .axis = 1, .pos = parseInt(u16, fold[13..], 10) catch unreachable },
            else => unreachable,
        }
        fi += 1;
    }

    var dots = Map([2]u16, void).init(gpa);
    var maxx: u16 = 0;
    var maxy: u16 = 0;

    var dotit = splitSeq(u8, dotlines, "\r\n");
    while (dotit.next()) |dot| {
        var pts = splitSeq(u8, dot, ",");
        const x = parseInt(u16, pts.next().?, 10) catch unreachable;
        const y = parseInt(u16, pts.next().?, 10) catch unreachable;
        var pt: [2]u16 = .{ x, y };
        for (folds) |fold| {
            if (pt[fold.axis] >= fold.pos) {
                pt[fold.axis] -= 2 * (pt[fold.axis] - fold.pos);
            }
        }
        dots.put(pt, {}) catch unreachable;
        maxx = @max(maxx, pt[0]);
        maxy = @max(maxy, pt[1]);
    }

    print("\n", .{});
    for (0..maxy + 1) |y| {
        for (0..maxx + 1) |x| {
            if (dots.contains([2]u16{ @intCast(x), @intCast(y) })) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }

    //print("{}\n", .{dots.count()});

    return 0;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 13:\n", .{});
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
