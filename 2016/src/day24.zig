const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day24.txt");
const testdata = "###########\r\n#0.1.....2#\r\n#.#######.#\r\n#4.......3#\r\n###########";

test "day24_part1" {
    const res = part1(testdata);
    print("Test data: {}\n", .{res});
    assert(res == 14);
}

const Tile = union(enum) {
    wall: void,
    empty: void,
    loc: u8,
};

fn runThread(locid: usize, basemap: *[37][181]Tile, locs: [][2]u8, basedistances: *[10][10]usize, mutex: *std.Thread.Mutex) void {
    var map: [37][181]Tile = basemap.*;
    var visited: [10]bool = undefined;
    @memset(&visited, false);
    visited[locid] = true;
    var distances: [10]usize = undefined;
    @memset(&distances, 0);
    var queue: [100][2]u8 = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;
    queue[0] = locs[locid];
    map[locs[locid][1]][locs[locid][0]] = .wall;

    var steps: usize = 1;
    var nextstep: usize = 1;
    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) qstart = 0;

        if (qstart == nextstep) {
            nextstep = qend;
            steps += 1;
        }

        const loc = queue[qstart];
        const x = loc[0];
        const y = loc[1];
        //print("Thread {}: {} {}\n", .{ locid, x, y });

        for ([4][2]u8{ .{ x + 1, y }, .{ x - 1, y }, .{ x, y + 1 }, .{ x, y - 1 } }) |nloc| {
            const nx = nloc[0];
            const ny = nloc[1];
            switch (map[ny][nx]) {
                .wall => continue,
                .empty => {
                    queue[qend] = .{ nx, ny };
                    qend += 1;
                    if (qend == queue.len) qend = 0;
                    if (qend == qstart) @panic("Queue full");
                    map[ny][nx] = .wall;
                },
                .loc => |lid| {
                    visited[lid] = true;
                    //print("Thread {}: {any} -> {any} = {}\n", .{ locid, locs[locid], locs[lid], steps });
                    distances[lid] = steps;
                    const done = for (visited[0..locs.len]) |v| {
                        if (!v) {
                            break false;
                        }
                    } else true;
                    if (done) {
                        mutex.lock();
                        for (0..locs.len) |i| {
                            basedistances[locid][i] = distances[i];
                        }
                        mutex.unlock();
                        return;
                    }
                    queue[qend] = .{ nx, ny };
                    qend += 1;
                    if (qend == queue.len) qend = 0;
                    if (qend == qstart) @panic("Queue full");
                    map[ny][nx] = .wall;
                },
            }
        }
    }

    unreachable;
}

const Step = struct {
    loc: u8,
    visited: [10]bool,
    steps: usize,
};

fn stepLess(_: void, a: Step, b: Step) std.math.Order {
    return std.math.order(a.steps, b.steps);
}

pub fn part1(input: []const u8) usize {
    var map: [37][181]Tile = undefined;
    var locs: [10][2]u8 = undefined;

    var x: u8 = 0;
    var y: u8 = 0;

    var maxloc: usize = 0;
    for (input) |c| {
        switch (c) {
            '\r' => continue,
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '#' => map[y][x] = .wall,
            '.' => map[y][x] = .empty,
            '0'...'9' => {
                map[y][x] = .{ .loc = c - '0' };
                locs[c - '0'] = .{ x, y };
                maxloc = @max(maxloc, c - '0');
            },
            else => unreachable,
        }
        x += 1;
    }

    var threads: [10]std.Thread = undefined;
    var distances: [10][10]usize = undefined;
    var mutex = std.Thread.Mutex{};

    //print("Maxloc: {}\n", .{maxloc});
    //print("Locs: {any}\n", .{locs[0 .. maxloc + 1]});

    for (0..maxloc + 1) |tid| {
        threads[tid] = std.Thread.spawn(.{}, runThread, .{ tid, &map, locs[0 .. maxloc + 1], &distances, &mutex }) catch unreachable;
    }

    for (0..maxloc + 1) |tid| {
        threads[tid].join();
    }

    //for (0..maxloc + 1) |i| {
    //    for (0..maxloc + 1) |j| {
    //        print("{} -> {} = {}\n", .{ i, j, distances[i][j] });
    //        assert(distances[i][j] == distances[j][i]);
    //    }
    //}

    var membuffer: [6000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var queue = std.PriorityQueue(Step, void, stepLess).init(alloc, {});

    var start: Step = .{
        .loc = 0,
        .visited = std.mem.zeroes([10]bool),
        .steps = 0,
    };

    start.visited[0] = true;

    queue.add(start) catch unreachable;

    var min: usize = std.math.maxInt(usize);

    outwhile: while (queue.count() > 0) {
        const step = queue.remove();
        const loc = step.loc;
        for (0..maxloc + 1) |i| {
            if (step.visited[i]) {
                continue;
            }
            var newstep: Step = .{
                .loc = @intCast(i),
                .visited = step.visited,
                .steps = step.steps + distances[loc][i],
            };
            //print("Step: {} -> {} = {}\n", .{ loc, i, distances[loc][i] });
            //print("Oldstep: {}\n", .{step.steps});
            //print("Newstep: {}\n", .{newstep.steps});
            newstep.visited[i] = true;
            const unvisited = indexOf(bool, newstep.visited[0 .. maxloc + 1], false);
            if (unvisited == null) {
                min = @min(min, newstep.steps);
                continue :outwhile;
            }
            queue.add(newstep) catch unreachable;
        }
    }

    return min;
}

test "day24_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var map: [37][181]Tile = undefined;
    var locs: [10][2]u8 = undefined;

    var x: u8 = 0;
    var y: u8 = 0;

    var maxloc: usize = 0;
    for (input) |c| {
        switch (c) {
            '\r' => continue,
            '\n' => {
                y += 1;
                x = 0;
                continue;
            },
            '#' => map[y][x] = .wall,
            '.' => map[y][x] = .empty,
            '0'...'9' => {
                map[y][x] = .{ .loc = c - '0' };
                locs[c - '0'] = .{ x, y };
                maxloc = @max(maxloc, c - '0');
            },
            else => unreachable,
        }
        x += 1;
    }

    var threads: [10]std.Thread = undefined;
    var distances: [10][10]usize = undefined;
    var mutex = std.Thread.Mutex{};

    //print("Maxloc: {}\n", .{maxloc});
    //print("Locs: {any}\n", .{locs[0 .. maxloc + 1]});

    for (0..maxloc + 1) |tid| {
        threads[tid] = std.Thread.spawn(.{}, runThread, .{ tid, &map, locs[0 .. maxloc + 1], &distances, &mutex }) catch unreachable;
    }

    for (0..maxloc + 1) |tid| {
        threads[tid].join();
    }

    //for (0..maxloc + 1) |i| {
    //    for (0..maxloc + 1) |j| {
    //        print("{} -> {} = {}\n", .{ i, j, distances[i][j] });
    //        assert(distances[i][j] == distances[j][i]);
    //    }
    //}

    var membuffer: [6000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var queue = std.PriorityQueue(Step, void, stepLess).init(alloc, {});

    var start: Step = .{
        .loc = 0,
        .visited = std.mem.zeroes([10]bool),
        .steps = 0,
    };

    start.visited[0] = true;

    queue.add(start) catch unreachable;

    var min: usize = std.math.maxInt(usize);

    outwhile: while (queue.count() > 0) {
        const step = queue.remove();
        const loc = step.loc;
        for (0..maxloc + 1) |i| {
            if (step.visited[i]) {
                continue;
            }
            var newstep: Step = .{
                .loc = @intCast(i),
                .visited = step.visited,
                .steps = step.steps + distances[loc][i],
            };
            //print("Step: {} -> {} = {}\n", .{ loc, i, distances[loc][i] });
            //print("Oldstep: {}\n", .{step.steps});
            //print("Newstep: {}\n", .{newstep.steps});
            newstep.visited[i] = true;
            const unvisited = indexOf(bool, newstep.visited[0 .. maxloc + 1], false);
            if (unvisited == null) {
                min = @min(min, newstep.steps + distances[i][0]);
                continue :outwhile;
            }
            queue.add(newstep) catch unreachable;
        }
    }

    return min;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 24:\n", .{});
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
