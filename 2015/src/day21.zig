const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day21.txt");
const testdata = "";

test "day21_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

const Item = struct {
    cost: u16,
    damage: u8,
    armor: u8,
};

const weapons = [_]Item{
    .{ .cost = 8, .damage = 4, .armor = 0 },
    .{ .cost = 10, .damage = 5, .armor = 0 },
    .{ .cost = 25, .damage = 6, .armor = 0 },
    .{ .cost = 40, .damage = 7, .armor = 0 },
    .{ .cost = 74, .damage = 8, .armor = 0 },
};

const armors = [_]Item{
    .{ .cost = 0, .damage = 0, .armor = 0 },
    .{ .cost = 13, .damage = 0, .armor = 1 },
    .{ .cost = 31, .damage = 0, .armor = 2 },
    .{ .cost = 53, .damage = 0, .armor = 3 },
    .{ .cost = 75, .damage = 0, .armor = 4 },
    .{ .cost = 102, .damage = 0, .armor = 5 },
};

const rings = [_]Item{
    .{ .cost = 0, .damage = 0, .armor = 0 },
    .{ .cost = 25, .damage = 1, .armor = 0 },
    .{ .cost = 50, .damage = 2, .armor = 0 },
    .{ .cost = 100, .damage = 3, .armor = 0 },
    .{ .cost = 20, .damage = 0, .armor = 1 },
    .{ .cost = 40, .damage = 0, .armor = 2 },
    .{ .cost = 80, .damage = 0, .armor = 3 },
};

const Stats = struct {
    hp: u8,
    damage: u8,
    armor: u8,
};

fn winFight(player: Stats, boss: Stats) bool {
    const pdmg = @max(1, player.damage -| boss.armor);
    const bdmg = @max(1, boss.damage -| player.armor);

    const pturns = (boss.hp + pdmg - 1) / pdmg;
    const bturns = (player.hp + bdmg - 1) / bdmg;

    return pturns <= bturns;
}

inline fn getInt(line: []const u8) u8 {
    const off = indexOf(u8, line, ':').? + 2;
    return parseInt(u8, line[off..], 10) catch unreachable;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    const boss = Stats{
        .hp = getInt(lines.next().?),
        .damage = getInt(lines.next().?),
        .armor = getInt(lines.next().?),
    };
    var min: u16 = std.math.maxInt(u16);
    for (weapons) |w| {
        for (armors) |a| {
            for (rings) |r1| {
                for (rings) |r2| {
                    if (r1.cost == r2.cost and r1.cost > 0) continue;

                    const cost = w.cost + a.cost + r1.cost + r2.cost;
                    if (cost > min) continue;
                    const damage = w.damage + a.damage + r1.damage + r2.damage;
                    const armor = w.armor + a.armor + r1.armor + r2.armor;

                    const player = Stats{ .hp = 100, .damage = damage, .armor = armor };

                    if (winFight(player, boss)) {
                        min = @min(cost, min);
                    }
                }
            }
        }
    }
    return min;
}

test "day21_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    const boss = Stats{
        .hp = getInt(lines.next().?),
        .damage = getInt(lines.next().?),
        .armor = getInt(lines.next().?),
    };
    var max: u16 = 0;
    for (weapons) |w| {
        for (armors) |a| {
            for (rings) |r1| {
                for (rings) |r2| {
                    if (r1.cost == r2.cost and r1.cost > 0) continue;

                    const cost = w.cost + a.cost + r1.cost + r2.cost;
                    if (cost < max) continue;
                    const damage = w.damage + a.damage + r1.damage + r2.damage;
                    const armor = w.armor + a.armor + r1.armor + r2.armor;

                    const player = Stats{ .hp = 100, .damage = damage, .armor = armor };

                    if (!winFight(player, boss)) {
                        max = @max(cost, max);
                    }
                }
            }
        }
    }
    return max;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 21:\n", .{});
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
