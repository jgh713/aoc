const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day15.txt");
const testdata = "1163751742\r\n1381373672\r\n2136511328\r\n3694931569\r\n7463417111\r\n1319128137\r\n1359912421\r\n3125421639\r\n1293138521\r\n2311944581";

test "day15_part1" {
    const res = part1(testdata);
    assert(res == 40);
}

const QItem = struct {
    risk: u32,
    x: i16,
    y: i16,
};

fn queueCmp(_: void, a: QItem, b: QItem) std.math.Order {
    return std.math.order(a.risk, b.risk);
}

pub fn part1(input: []const u8) usize {
    var queue = std.PriorityQueue(QItem, void, queueCmp).init(gpa, {});
    var map: [100][100]u4 = undefined;
    var weights: [100][100]u32 = comptime std.mem.zeroes([100][100]u32);

    var x: i16 = 0;
    var y: i16 = 0;

    for (input) |c| {
        if (c == '\r') {
            continue;
        }
        if (c == '\n') {
            x = 0;
            y += 1;
            continue;
        }
        map[@intCast(y)][@intCast(x)] = @intCast(c - '0');
        x += 1;
    }

    const maxx = x;
    const maxy = y + 1;

    queue.add(QItem{ .x = 0, .y = 0, .risk = 0 }) catch unreachable;

    while (queue.removeOrNull()) |qitem| {
        const qx = qitem.x;
        const qy = qitem.y;
        for ([_][2]i2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } }) |mods| {
            const nx = qx + mods[0];
            const ny = qy + mods[1];
            if (nx < 0 or ny < 0 or nx >= maxx or ny >= maxy) {
                continue;
            }
            if (nx == maxx - 1 and ny == maxy - 1) {
                return qitem.risk + map[@intCast(ny)][@intCast(nx)];
            }
            const risk = qitem.risk + map[@intCast(ny)][@intCast(nx)];
            if (weights[@intCast(ny)][@intCast(nx)] != 0 and weights[@intCast(ny)][@intCast(nx)] <= risk) {
                continue;
            }
            weights[@intCast(ny)][@intCast(nx)] = risk;
            queue.add(QItem{ .risk = risk, .x = nx, .y = ny }) catch unreachable;
        }
    }

    unreachable;
}

test "day15_part2" {
    const res = part2(testdata);
    assert(res == 315);
}

pub fn part2(input: []const u8) usize {
    var queue = std.PriorityQueue(QItem, void, queueCmp).init(gpa, {});
    var map: [500][500]u4 = undefined;
    var weights: [500][500]u32 = comptime std.mem.zeroes([500][500]u32);

    var x: i16 = 0;
    var y: i16 = 0;

    const width: i16 = @intCast(indexOf(u8, input, '\r').?);

    for (input) |c| {
        if (c == '\r') {
            continue;
        }
        if (c == '\n') {
            x = 0;
            y += 1;
            continue;
        }
        const baseval: u4 = @intCast(c - '0');
        for (0..5) |umy| {
            const my: i16 = @intCast(umy);
            const ybase: i16 = my * width;
            for (0..5) |umx| {
                const mx: i16 = @intCast(umx);
                const xbase: i16 = mx * width;
                const dist: i16 = @intCast(my + mx);
                var nv: i16 = dist + baseval;
                if (nv > 9) nv -= 9;
                map[@intCast(ybase + y)][@intCast(xbase + x)] = @intCast(nv);
            }
        }

        x += 1;
    }

    const maxx = x * 5;
    const maxy = (y + 1) * 5;

    //for (map[0..@intCast(maxy)]) |row| {
    //    for (row[0..@intCast(maxx)]) |val| {
    //        print("{}", .{val});
    //    }
    //    print("\n", .{});
    //}

    queue.add(QItem{ .x = 0, .y = 0, .risk = 0 }) catch unreachable;

    while (queue.removeOrNull()) |qitem| {
        const qx = qitem.x;
        const qy = qitem.y;
        for ([_][2]i2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } }) |mods| {
            const nx = qx + mods[0];
            const ny = qy + mods[1];
            if (nx < 0 or ny < 0 or nx >= maxx or ny >= maxy) {
                continue;
            }
            if (nx == maxx - 1 and ny == maxy - 1) {
                return qitem.risk + map[@intCast(ny)][@intCast(nx)];
            }
            const risk = qitem.risk + map[@intCast(ny)][@intCast(nx)];
            if (weights[@intCast(ny)][@intCast(nx)] != 0 and weights[@intCast(ny)][@intCast(nx)] <= risk) {
                continue;
            }
            weights[@intCast(ny)][@intCast(nx)] = risk;
            queue.add(QItem{ .risk = risk, .x = nx, .y = ny }) catch unreachable;
        }
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 15:\n", .{});
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
