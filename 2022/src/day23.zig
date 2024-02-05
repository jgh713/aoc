const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day23.txt");
const testdata = "....#..\r\n..###.#\r\n#...#.#\r\n.#...##\r\n#.###..\r\n##.#.##\r\n.#..#..";
const testdata2 = ".....\r\n..##.\r\n..#..\r\n.....\r\n..##.\r\n.....";

test "day23_part1" {
    const res = part1(testdata);
    assert(res == 110);
    const res2 = part1(testdata2);
    assert(res2 == 25);
}

const Point = struct {
    x: isize,
    y: isize,
};

const Elf = struct {
    loc: Point,
    proposed: Point,
    destptr: ?*u3,
};

fn printMap(elves: []Elf, map: Map(Point, *Elf)) void {
    var minx: isize = std.math.maxInt(isize);
    var miny: isize = std.math.maxInt(isize);
    var maxx: isize = 0;
    var maxy: isize = 0;
    for (elves) |elf| {
        minx = @min(minx, elf.loc.x);
        miny = @min(miny, elf.loc.y);
        maxx = @max(maxx, elf.loc.x);
        maxy = @max(maxy, elf.loc.y);
    }
    const w: usize = @abs(maxx - minx);
    const h: usize = @abs(maxy - miny);

    print("minx: {}, miny: {}, maxx: {}, maxy: {}\n", .{ minx, miny, maxx, maxy });
    print("w: {}, h: {}\n", .{ w, h });

    for (0..h + 1) |dy| {
        const idy = @as(isize, @as(u63, @truncate(dy)));
        for (0..w + 1) |dx| {
            const idx = @as(isize, @as(u63, @truncate(dx)));
            const p = Point{ .x = minx + @as(isize, idx), .y = maxy - @as(isize, idy) };
            if (map.contains(p)) {
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
    var map = Map(Point, *Elf).init(gpa);
    var dests = Map(Point, u3).init(gpa);
    var elves: [3000]Elf = undefined;
    var eid: usize = 0;
    var x: isize = 0;
    var y: isize = 75;

    if (builtin.is_test) {
        map.ensureTotalCapacity(30) catch unreachable;
        dests.ensureTotalCapacity(30) catch unreachable;
    } else {
        map.ensureTotalCapacity(3500) catch unreachable;
        dests.ensureTotalCapacity(3500) catch unreachable;
    }

    for (input) |c| {
        switch (c) {
            '\r' => {},
            '\n' => {
                x = 0;
                y -= 1;
            },
            '.' => {
                x += 1;
            },
            '#' => {
                elves[eid] = Elf{ .loc = Point{ .x = x, .y = y }, .proposed = Point{ .x = x, .y = y }, .destptr = null };
                map.putAssumeCapacityNoClobber(elves[eid].loc, &elves[eid]);
                eid += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    var step: usize = 0;
    outerwhile: while (step < 10) : (step += 1) {
        //printMap(elves[0..eid], map);
        // Step 1: Propose moves
        for (elves[0..eid]) |*elf| {
            const loc = elf.loc;
            var valids: [4]bool = .{ true, true, true, true };
            var hit: bool = false;
            for ([_]isize{ -1, 0, 1 }) |dx| {
                for ([_]isize{ -1, 0, 1 }) |dy| {
                    if (dx == 0 and dy == 0) continue;
                    //print("dx: {}, dy: {}\n", .{ dx, dy });
                    const p = Point{ .x = loc.x + dx, .y = loc.y + dy };
                    if (map.contains(p)) {
                        //print("hit for elf: {any} at {any}\n", .{ elf.loc, p });
                        //print("hit: {}\n", .{p});
                        hit = true;
                        if (dy > 0) valids[0] = false;
                        if (dy < 0) valids[1] = false;
                        if (dx < 0) valids[2] = false;
                        if (dx > 0) valids[3] = false;
                    }
                }
            }
            if (hit) {
                const index = for (step..step + 4) |si| {
                    if (valids[si % 4]) break si % 4;
                } else continue;
                var proposed = elf.loc;
                switch (index) {
                    0 => proposed.y += 1,
                    1 => proposed.y -= 1,
                    2 => proposed.x -= 1,
                    3 => proposed.x += 1,
                    else => unreachable,
                }
                elf.proposed = proposed;
                const entry = dests.getOrPutAssumeCapacity(elf.proposed);
                if (entry.found_existing) {
                    entry.value_ptr.* += 1;
                } else {
                    entry.value_ptr.* = 1;
                }
                elf.destptr = entry.value_ptr;
            }
        }

        //var moves: usize = 0;

        //print("Destcounts: {}\n", .{dests.count()});
        if (dests.count() == 0) {
            break :outerwhile;
        }

        // Step 2: Move
        for (elves[0..eid]) |*elf| {
            if (elf.destptr) |vptr| {
                if (vptr.* == 1) {
                    //print("Moving elf: {any} to {any}\n", .{ elf.loc, elf.proposed });
                    //moves += 1;
                    _ = map.remove(elf.loc);
                    elf.loc = elf.proposed;
                    map.putAssumeCapacityNoClobber(elf.loc, elf);
                    elf.destptr = null;
                } else {
                    elf.destptr = null;
                }
            }
        }

        //if (moves == 0) {
        //    return 1;
        //}
        // Step 3: Clear dests for reuse
        dests.clearRetainingCapacity();
    }

    var minx: isize = std.math.maxInt(isize);
    var miny: isize = std.math.maxInt(isize);
    var maxx: isize = 0;
    var maxy: isize = 0;
    for (elves[0..eid]) |elf| {
        minx = @min(minx, elf.loc.x);
        miny = @min(miny, elf.loc.y);
        maxx = @max(maxx, elf.loc.x);
        maxy = @max(maxy, elf.loc.y);
    }
    const w: usize = @abs(maxx - minx) + 1;
    const h: usize = @abs(maxy - miny) + 1;

    //print("minx: {}, miny: {}, maxx: {}, maxy: {}\n", .{ minx, miny, maxx, maxy });
    //print("w: {}, h: {}\n", .{ w, h });

    const area = w * h;

    return area - eid;
}

test "day23_part2" {
    const res = part2(testdata);
    assert(res == 20);
}

pub fn part2(input: []const u8) usize {
    var map = Map(Point, *Elf).init(gpa);
    var dests = Map(Point, u3).init(gpa);
    var elves: [3000]Elf = undefined;
    var eid: usize = 0;
    var x: isize = 0;
    var y: isize = 75;

    if (builtin.is_test) {
        map.ensureTotalCapacity(30) catch unreachable;
        dests.ensureTotalCapacity(30) catch unreachable;
    } else {
        map.ensureTotalCapacity(3500) catch unreachable;
        dests.ensureTotalCapacity(3500) catch unreachable;
    }

    for (input) |c| {
        switch (c) {
            '\r' => {},
            '\n' => {
                x = 0;
                y -= 1;
            },
            '.' => {
                x += 1;
            },
            '#' => {
                elves[eid] = Elf{ .loc = Point{ .x = x, .y = y }, .proposed = Point{ .x = x, .y = y }, .destptr = null };
                map.putAssumeCapacityNoClobber(elves[eid].loc, &elves[eid]);
                eid += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    var step: usize = 0;
    while (true) : (step += 1) {
        //printMap(elves[0..eid], map);
        // Step 1: Propose moves
        for (elves[0..eid]) |*elf| {
            const loc = elf.loc;
            var valids: [4]bool = .{ true, true, true, true };
            var hit: bool = false;
            for ([_]isize{ -1, 0, 1 }) |dx| {
                for ([_]isize{ -1, 0, 1 }) |dy| {
                    if (dx == 0 and dy == 0) continue;
                    //print("dx: {}, dy: {}\n", .{ dx, dy });
                    const p = Point{ .x = loc.x + dx, .y = loc.y + dy };
                    if (map.contains(p)) {
                        //print("hit for elf: {any} at {any}\n", .{ elf.loc, p });
                        //print("hit: {}\n", .{p});
                        hit = true;
                        if (dy > 0) valids[0] = false;
                        if (dy < 0) valids[1] = false;
                        if (dx < 0) valids[2] = false;
                        if (dx > 0) valids[3] = false;
                    }
                }
            }
            if (hit) {
                const index = for (step..step + 4) |si| {
                    if (valids[si % 4]) break si % 4;
                } else continue;
                var proposed = elf.loc;
                switch (index) {
                    0 => proposed.y += 1,
                    1 => proposed.y -= 1,
                    2 => proposed.x -= 1,
                    3 => proposed.x += 1,
                    else => unreachable,
                }
                elf.proposed = proposed;
                const entry = dests.getOrPutAssumeCapacity(elf.proposed);
                if (entry.found_existing) {
                    entry.value_ptr.* += 1;
                } else {
                    entry.value_ptr.* = 1;
                }
                elf.destptr = entry.value_ptr;
            }
        }

        //var moves: usize = 0;

        //print("Destcounts: {}\n", .{dests.count()});
        if (dests.count() == 0) {
            return (step + 1);
        }

        // Step 2: Move
        for (elves[0..eid]) |*elf| {
            if (elf.destptr) |vptr| {
                if (vptr.* == 1) {
                    //print("Moving elf: {any} to {any}\n", .{ elf.loc, elf.proposed });
                    //moves += 1;
                    _ = map.remove(elf.loc);
                    elf.loc = elf.proposed;
                    map.putAssumeCapacityNoClobber(elf.loc, elf);
                    elf.destptr = null;
                } else {
                    elf.destptr = null;
                }
            }
        }

        //if (moves == 0) {
        //    return 1;
        //}
        // Step 3: Clear dests for reuse
        dests.clearRetainingCapacity();
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 23:\n", .{});
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
