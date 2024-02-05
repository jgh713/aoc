const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day24.txt");
const testdata = "#.######\r\n#>>.<^<#\r\n#.<..<<#\r\n#>v.><>#\r\n#<^v^^>#\r\n######.#";

test "day24_part1" {
    const res = part1(testdata);
    assert(res == 18);
}

const Blizzard = struct {
    offset: i16,
    direction: i2,
};

const Point = struct {
    x: i16,
    y: i16,
};

pub fn part1(input: []const u8) usize {
    var x: isize = -1;
    var y: isize = -1;
    // Torn here, if possible positions at each step remains low,
    // iterating these and checking individually is probably faster
    // than trying to parse the whole thing over every step and
    // checking for cached collision locations. Will have to test.
    var blizzrows: [35][100]Blizzard = undefined;
    var rowids: [35]u8 = comptime std.mem.zeroes([35]u8);
    var blizzcols: [100][35]Blizzard = undefined;
    var colids: [100]u8 = comptime std.mem.zeroes([100]u8);

    for (input) |c| {
        switch (c) {
            '\n' => {
                x = -1;
                y += 1;
            },
            '\r' => {},
            '#' => x += 1,
            '.' => x += 1,
            '^' => {
                const ax = @abs(x);
                blizzcols[ax][colids[ax]] = Blizzard{ .offset = @intCast(y), .direction = -1 };
                colids[ax] += 1;
                x += 1;
            },
            'v' => {
                const ax = @abs(x);
                blizzcols[ax][colids[ax]] = Blizzard{ .offset = @intCast(y), .direction = 1 };
                colids[ax] += 1;
                x += 1;
            },
            '<' => {
                const ay = @abs(y);
                blizzrows[ay][rowids[ay]] = Blizzard{ .offset = @intCast(x), .direction = -1 };
                rowids[ay] += 1;
                x += 1;
            },
            '>' => {
                const ay = @abs(y);
                blizzrows[ay][rowids[ay]] = Blizzard{ .offset = @intCast(x), .direction = 1 };
                rowids[ay] += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    const maxx = x - 1;
    const maxy = y;

    var valids = Map(Point, void).init(gpa);
    _ = valids.put(Point{ .x = 0, .y = -1 }, {}) catch unreachable;
    var possibles = Map(Point, void).init(gpa);

    var step: u32 = 1;

    while (valids.count() > 0) : (step += 1) {
        //print("Step {}\n", .{step - 1});
        //var px: i16 = -1;
        //var py: i16 = -1;
        //while (py <= maxy) : (py += 1) {
        //    px = -1;
        //    while (px <= maxx) : (px += 1) {
        //        if (valids.contains(Point{ .x = px, .y = py })) {
        //            print("X", .{});
        //            continue;
        //        }
        //        if (px < 0 or py < 0 or px >= maxx or py >= maxy) {
        //            if (px == 0 and py == -1) {
        //                print(".", .{});
        //            } else {
        //                print("#", .{});
        //            }
        //            continue;
        //        }
        //        var found: u4 = 0;
        //        var last: u8 = '.';
        //        for (blizzrows[@abs(py)][0..rowids[@abs(py)]]) |blizz| {
        //            const bx = @mod(blizz.offset + (@as(isize, blizz.direction) * (step - 1)), maxx);
        //            if (px == bx) {
        //                found += 1;
        //                last = if (blizz.direction > 0) '>' else '<';
        //            }
        //        }
        //        for (blizzcols[@abs(px)][0..colids[@abs(px)]]) |blizz| {
        //            const by = @mod(blizz.offset + (@as(isize, blizz.direction) * (step - 1)), maxy);
        //            if (py == by) {
        //                found += 1;
        //                last = if (blizz.direction > 0) 'v' else '^';
        //            }
        //        }
        //        if (found > 1) {
        //            print("{}", .{found});
        //        } else {
        //            print("{c}", .{last});
        //        }
        //    }
        //    print("\n", .{});
        //}
        //print("\n", .{});

        var vit = valids.keyIterator();
        while (vit.next()) |valid| {
            for ([_][2]i2{ .{ 0, 0 }, .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 } }) |dir| {
                const nx = valid.x + dir[0];
                const ny = valid.y + dir[1];
                if (nx < 0 or nx >= maxx or ny < 0 or ny >= maxy) {
                    if (nx == 0 and ny == -1) {
                        _ = possibles.put(Point{ .x = nx, .y = ny }, {}) catch unreachable;
                        continue;
                    }
                    if (ny == maxy and nx == (maxx - 1)) {
                        //print("Part 1: {}\n", .{step});
                        return step;
                    }
                    continue;
                }
                const newx = @abs(nx);
                const newy = @abs(ny);
                const isvalid: bool = for (blizzrows[newy][0..rowids[newy]]) |blizz| {
                    const bx = @mod(blizz.offset + (@as(isize, blizz.direction) * step), maxx);
                    if (newx == bx) {
                        break false;
                    }
                } else for (blizzcols[newx][0..colids[newx]]) |blizz| {
                    const by = @mod(blizz.offset + (@as(isize, blizz.direction) * step), maxy);
                    if (newy == by) {
                        break false;
                    }
                } else true;
                if (isvalid) {
                    const newpoint = Point{ .x = nx, .y = ny };
                    _ = possibles.put(newpoint, {}) catch unreachable;
                }
            }
        }

        const hold = valids;
        valids = possibles;
        possibles = hold;
        possibles.clearRetainingCapacity();
    }

    unreachable;
}

test "day24_part2" {
    const res = part2(testdata);
    assert(res == 54);
}

pub fn part2(input: []const u8) usize {
    var x: i16 = -1;
    var y: i16 = -1;
    // Torn here, if possible positions at each step remains low,
    // iterating these and checking individually is probably faster
    // than trying to parse the whole thing over every step and
    // checking for cached collision locations. Will have to test.
    var blizzrows: [35][100]Blizzard = undefined;
    var rowids: [35]u8 = comptime std.mem.zeroes([35]u8);
    var blizzcols: [100][35]Blizzard = undefined;
    var colids: [100]u8 = comptime std.mem.zeroes([100]u8);

    for (input) |c| {
        switch (c) {
            '\n' => {
                x = -1;
                y += 1;
            },
            '\r' => {},
            '#' => x += 1,
            '.' => x += 1,
            '^' => {
                const ax = @abs(x);
                blizzcols[ax][colids[ax]] = Blizzard{ .offset = @intCast(y), .direction = -1 };
                colids[ax] += 1;
                x += 1;
            },
            'v' => {
                const ax = @abs(x);
                blizzcols[ax][colids[ax]] = Blizzard{ .offset = @intCast(y), .direction = 1 };
                colids[ax] += 1;
                x += 1;
            },
            '<' => {
                const ay = @abs(y);
                blizzrows[ay][rowids[ay]] = Blizzard{ .offset = @intCast(x), .direction = -1 };
                rowids[ay] += 1;
                x += 1;
            },
            '>' => {
                const ay = @abs(y);
                blizzrows[ay][rowids[ay]] = Blizzard{ .offset = @intCast(x), .direction = 1 };
                rowids[ay] += 1;
                x += 1;
            },
            else => unreachable,
        }
    }

    const maxx: i16 = x - 1;
    const maxy: i16 = y;

    var valids = Map(Point, void).init(gpa);
    var possibles = Map(Point, void).init(gpa);

    var step: u32 = 1;

    const starts = [_]Point{ .{ .x = 0, .y = -1 }, .{ .x = (maxx - 1), .y = maxy }, .{ .x = 0, .y = -1 } };
    const ends = [_]Point{ .{ .x = (maxx - 1), .y = maxy }, .{ .x = 0, .y = -1 }, .{ .x = (maxx - 1), .y = maxy } };
    for (starts, ends) |start, end| {
        valids.clearRetainingCapacity();
        possibles.clearRetainingCapacity();
        _ = valids.put(Point{ .x = start.x, .y = start.y }, {}) catch unreachable;
        mapwhile: while (true) : (step += 1) {
            if (valids.count() == 0) {
                unreachable;
            }
            //print("Step {}\n", .{step - 1});
            //var px: i16 = -1;
            //var py: i16 = -1;
            //while (py <= maxy) : (py += 1) {
            //    px = -1;
            //    while (px <= maxx) : (px += 1) {
            //        if (valids.contains(Point{ .x = px, .y = py })) {
            //            print("X", .{});
            //            continue;
            //        }
            //        if (px < 0 or py < 0 or px >= maxx or py >= maxy) {
            //            if (px == 0 and py == -1) {
            //                print(".", .{});
            //            } else {
            //                print("#", .{});
            //            }
            //            continue;
            //        }
            //        var found: u4 = 0;
            //        var last: u8 = '.';
            //        for (blizzrows[@abs(py)][0..rowids[@abs(py)]]) |blizz| {
            //            const bx = @mod(blizz.offset + (@as(isize, blizz.direction) * (step - 1)), maxx);
            //            if (px == bx) {
            //                found += 1;
            //                last = if (blizz.direction > 0) '>' else '<';
            //            }
            //        }
            //        for (blizzcols[@abs(px)][0..colids[@abs(px)]]) |blizz| {
            //            const by = @mod(blizz.offset + (@as(isize, blizz.direction) * (step - 1)), maxy);
            //            if (py == by) {
            //                found += 1;
            //                last = if (blizz.direction > 0) 'v' else '^';
            //            }
            //        }
            //        if (found > 1) {
            //            print("{}", .{found});
            //        } else {
            //            print("{c}", .{last});
            //        }
            //    }
            //    print("\n", .{});
            //}
            //print("\n", .{});

            var vit = valids.keyIterator();
            while (vit.next()) |valid| {
                for ([_][2]i2{ .{ 0, 0 }, .{ -1, 0 }, .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 } }) |dir| {
                    const nx = valid.x + dir[0];
                    const ny = valid.y + dir[1];
                    if (nx < 0 or nx >= maxx or ny < 0 or ny >= maxy) {
                        if (nx == start.x and ny == start.y) {
                            _ = possibles.put(Point{ .x = nx, .y = ny }, {}) catch unreachable;
                            continue;
                        }
                        if (ny == end.y and nx == end.x) {
                            //print("Part 1: {}\n", .{step});
                            break :mapwhile;
                        }
                        continue;
                    }
                    const newx = @abs(nx);
                    const newy = @abs(ny);
                    const isvalid: bool = for (blizzrows[newy][0..rowids[newy]]) |blizz| {
                        const bx = @mod(blizz.offset + (@as(isize, blizz.direction) * step), maxx);
                        if (newx == bx) {
                            break false;
                        }
                    } else for (blizzcols[newx][0..colids[newx]]) |blizz| {
                        const by = @mod(blizz.offset + (@as(isize, blizz.direction) * step), maxy);
                        if (newy == by) {
                            break false;
                        }
                    } else true;
                    if (isvalid) {
                        const newpoint = Point{ .x = nx, .y = ny };
                        _ = possibles.put(newpoint, {}) catch unreachable;
                    }
                }
            }

            const hold = valids;
            valids = possibles;
            possibles = hold;
            possibles.clearRetainingCapacity();
        }
        //print("Step is now {}\n", .{step});
    }

    return step;
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
