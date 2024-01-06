const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day17.txt");
const testdata = "2413432311323\n3215453535623\n3255245654254\n3446585845452\n4546657867536\n1438598798454\n4457876987766\n3637877979653\n4654967986887\n4564679986453\n1224686865563\n2546548887735\n4322674655533";
const testdata2 = "111111111111\n999999999991\n999999999991\n999999999991\n999999999991";

test "day17_part1" {
    const res = part1(testdata);
    assert(res == 102);
}

const Dirs = enum {
    North,
    East,
    South,
    West,
};

inline fn dirToMod(dir: Dirs) [2]i2 {
    switch (dir) {
        .North => return .{ 0, -1 },
        .East => return .{ 1, 0 },
        .South => return .{ 0, 1 },
        .West => return .{ -1, 0 },
    }
}

inline fn modToDirs(mod: [2]i2) Dirs {
    if (mod[0] == 0 and mod[1] == -1) return .North;
    if (mod[0] == 1 and mod[1] == 0) return .East;
    if (mod[0] == 0 and mod[1] == 1) return .South;
    if (mod[0] == -1 and mod[1] == 0) return .West;
    unreachable;
}

const QueuePoint = struct {
    cost: usize,
    x: u8,
    y: u8,
    dir: [2]i2,
};

fn qpLessThan(context: void, a: QueuePoint, b: QueuePoint) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}

fn dijkstra(maxx: u8, maxy: u8, weightmap: [142][142]u4, min_steps: u8, max_steps: u8) usize {
    var queue = std.PriorityQueue(QueuePoint, void, qpLessThan).init(gpa, void{});
    var map: [142][142][4]usize = undefined;
    for (0..maxy) |y| {
        for (0..maxx) |x| {
            for (0..4) |dir| {
                map[y][x][dir] = std.math.maxInt(usize);
            }
        }
    }

    queue.add(QueuePoint{ .cost = 0, .x = 0, .y = 0, .dir = .{ 0, 0 } }) catch unreachable;

    while (true) {
        const point = queue.remove();
        if (point.x == maxx - 1 and point.y == maxy - 1) {
            return point.cost;
        }
        if ((point.dir[0] != 0 or point.dir[1] != 0) and point.cost > map[point.y][point.x][@intFromEnum(modToDirs(point.dir))]) continue;
        dirfor: for (0..4) |dirint| {
            const stepmods = dirToMod(@enumFromInt(dirint));
            if (point.dir[0] == stepmods[0] and point.dir[1] == stepmods[1]) continue :dirfor;
            if (point.dir[0] == -stepmods[0] and point.dir[1] == -stepmods[1]) continue :dirfor;
            var cost = point.cost;
            stepfor: for (1..max_steps + 1) |dist| {
                const inx = @as(i16, point.x) + @as(i8, stepmods[0]) * @as(i8, @intCast(dist));
                const iny = @as(i16, point.y) + @as(i8, stepmods[1]) * @as(i8, @intCast(dist));
                if (inx >= maxx or iny >= maxy or inx < 0 or iny < 0) break :stepfor;
                const nx: u8 = @intCast(inx);
                const ny: u8 = @intCast(iny);
                cost += weightmap[ny][nx];
                if (dist < min_steps) continue :stepfor;
                if (cost < map[ny][nx][dirint]) {
                    map[ny][nx][dirint] = cost;
                    queue.add(QueuePoint{ .cost = cost, .x = nx, .y = ny, .dir = stepmods }) catch unreachable;
                }
            }
        }
    }

    unreachable;
}

fn part1(input: []const u8) usize {
    var map: [142][142]u4 = undefined;
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        switch (c) {
            '0'...'9' => {
                map[y][x] = @intCast(c - '0');
                x += 1;
            },
            '\n' => {
                x = 0;
                y += 1;
            },
            else => {},
        }
    }

    const maxx = x;
    const maxy = y + 1;

    return dijkstra(maxx, maxy, map, 1, 3);
}

test "day17_part2" {
    const res = part2(testdata);
    assert(res == 94);
    const res2 = part2(testdata2);
    assert(res2 == 71);
}

fn part2(input: []const u8) usize {
    var map: [142][142]u4 = undefined;
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        switch (c) {
            '0'...'9' => {
                map[y][x] = @intCast(c - '0');
                x += 1;
            },
            '\n' => {
                x = 0;
                y += 1;
            },
            else => {},
        }
    }

    const maxx = x;
    const maxy = y + 1;

    return dijkstra(maxx, maxy, map, 4, 10);
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
