const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day05.txt");
const testdata = "0,9 -> 5,9\r\n8,0 -> 0,8\r\n9,4 -> 3,4\r\n2,2 -> 2,1\r\n7,0 -> 7,4\r\n6,4 -> 2,0\r\n0,9 -> 2,9\r\n3,4 -> 1,4\r\n0,0 -> 8,8\r\n5,5 -> 8,2";

test "day05_part1" {
    const res = part1(testdata);
    assert(res == 5);
}

const Point = struct {
    x: u16,
    y: u16,
};

const IPoint = struct {
    x: i32,
    y: i32,

    pub fn from(p: Point) IPoint {
        return IPoint{ .x = @intCast(p.x), .y = @intCast(p.y) };
    }
};

fn between(p: Point, q: Point, r: Point) bool {
    return q.x <= @max(p.x, r.x) and q.x >= @min(p.x, r.x) and
        q.y <= @max(p.y, r.y) and q.y >= @min(p.y, r.y);
}

const Orientation = enum {
    Collinear,
    Clockwise,
    Counterclockwise,
};

fn orient(p: Point, q: Point, r: Point) Orientation {
    const ip = IPoint.from(p);
    const iq = IPoint.from(q);
    const ir = IPoint.from(r);

    const val = (iq.y - ip.y) * (ir.x - iq.x) - (iq.x - ip.x) * (ir.y - iq.y);

    if (val == 0) return .Collinear;
    return if (val > 0) .Clockwise else .Counterclockwise;
}

fn intersect(p1: Point, q1: Point, p2: Point, q2: Point) bool {
    const o1 = orient(p1, q1, p2);
    const o2 = orient(p1, q1, q2);
    const o3 = orient(p2, q2, p1);
    const o4 = orient(p2, q2, q1);

    if (o1 != o2 and o3 != o4) return true;

    if (o1 == .Collinear and between(p1, p2, q1)) return true;
    if (o2 == .Collinear and between(p1, q2, q1)) return true;
    if (o3 == .Collinear and between(p2, p1, q2)) return true;
    if (o4 == .Collinear and between(p2, q1, q2)) return true;

    return false;
}

//pub fn part1(input: []const u8) usize {
//    var lines = splitSeq(u8, input, "\r\n");
//    var map: [500][2]Point = undefined;
//    var mi: usize = 0;
//
//    while (lines.next()) |line| {
//        var parts = splitSeq(u8, line, " -> ");
//        var from = splitSeq(u8, parts.next().?, ",");
//        var to = splitSeq(u8, parts.next().?, ",");
//        var mline: [2]Point = undefined;
//        mline[0] = Point{ .x = parseInt(u16, from.next().?, 10) catch unreachable, .y = parseInt(u16, from.next().?, 10) catch unreachable };
//        mline[1] = Point{ .x = parseInt(u16, to.next().?, 10) catch unreachable, .y = parseInt(u16, to.next().?, 10) catch unreachable };
//        if (mline[0].x == mline[1].x or mline[0].y == mline[1].y) {
//            map[mi] = mline;
//            mi += 1;
//        }
//    }
//
//    var count: usize = 0;
//
//    for (0..mi - 1) |i| {
//        for (i + 1..mi) |j| {
//            if (intersect(map[i][0], map[i][1], map[j][0], map[j][1])) {
//                count += 1;
//            }
//        }
//    }
//
//    print("Count: {}\n", .{count});
//
//    return count;
//}

fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var map = Map(Point, void).init(gpa);
    var dupes = Map(Point, void).init(gpa);

    while (lines.next()) |line| {
        var parts = splitSeq(u8, line, " -> ");
        var fromline = splitSeq(u8, parts.next().?, ",");
        var toline = splitSeq(u8, parts.next().?, ",");
        const from = Point{ .x = parseInt(u16, fromline.next().?, 10) catch unreachable, .y = parseInt(u16, fromline.next().?, 10) catch unreachable };
        const to = Point{ .x = parseInt(u16, toline.next().?, 10) catch unreachable, .y = parseInt(u16, toline.next().?, 10) catch unreachable };
        if (from.x == to.x) {
            const fy = @min(from.y, to.y);
            const ty = @max(from.y, to.y);
            for (fy..ty + 1) |it| {
                const p = Point{ .x = from.x, .y = @intCast(it) };
                if (map.contains(p)) {
                    dupes.put(p, void{}) catch unreachable;
                } else {
                    map.put(p, void{}) catch unreachable;
                }
            }
        } else if (from.y == to.y) {
            const fx = @min(from.x, to.x);
            const tx = @max(from.x, to.x);
            for (fx..tx + 1) |it| {
                const p = Point{ .x = @intCast(it), .y = from.y };
                if (map.contains(p)) {
                    dupes.put(p, void{}) catch unreachable;
                } else {
                    map.put(p, void{}) catch unreachable;
                }
            }
        }
    }

    return dupes.count();
}

test "day05_part2" {
    const res = part2(testdata);
    assert(res == 12);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var map = Map(Point, void).init(gpa);
    var dupes = Map(Point, void).init(gpa);

    while (lines.next()) |line| {
        var parts = splitSeq(u8, line, " -> ");
        var fromline = splitSeq(u8, parts.next().?, ",");
        var toline = splitSeq(u8, parts.next().?, ",");
        const from = Point{ .x = parseInt(u16, fromline.next().?, 10) catch unreachable, .y = parseInt(u16, fromline.next().?, 10) catch unreachable };
        const to = Point{ .x = parseInt(u16, toline.next().?, 10) catch unreachable, .y = parseInt(u16, toline.next().?, 10) catch unreachable };
        const xmod: u2 = if (from.x > to.x) 0 else if (from.x == to.x) 1 else 2;
        const ymod: u2 = if (from.y > to.y) 0 else if (from.y == to.y) 1 else 2;
        var p: Point = Point{ .x = from.x, .y = from.y };
        while (true) {
            if (map.contains(p)) {
                dupes.put(p, void{}) catch unreachable;
            } else {
                map.put(p, void{}) catch unreachable;
            }
            if (p.x == to.x and p.y == to.y) break;
            p.x += xmod;
            p.y += ymod;
            p.x -= 1;
            p.y -= 1;
        }
    }

    //print("Dupes: {}\n", .{dupes.count()});

    return dupes.count();
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 05:\n", .{});
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
