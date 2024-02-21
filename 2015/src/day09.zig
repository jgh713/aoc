const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day09.txt");
const testdata = "London to Dublin = 464\r\nLondon to Belfast = 518\r\nDublin to Belfast = 141";

test "day09_part1" {
    const res = part1(testdata);
    assert(res == 605);
}

const City = struct {
    distances: [26]usize,
};

const CityIds = std.ComptimeStringMap(u8, .{
    .{ "London", 0 },
    .{ "Dublin", 1 },
    .{ "Belfast", 2 },
    .{ "Tristram", 0 },
    .{ "AlphaCentauri", 1 },
    .{ "Tambi", 2 },
    .{ "Faerun", 3 },
    .{ "Norrath", 4 },
    .{ "Snowdin", 5 },
    .{ "Straylight", 6 },
    .{ "Arbre", 7 },
});

const CityMap = struct {
    cities: [26]City = std.mem.zeroes([26]City),
    ids: [8]u8 = undefined,
    idc: u8 = 0,

    pub fn init(input: []const u8) @This() {
        var map = CityMap{};
        var lines = splitSeq(u8, input, "\r\n");
        var max: u8 = 0;
        while (lines.next()) |line| {
            var parts = splitSca(u8, line, ' ');
            const from = parts.next().?;
            const fromid = CityIds.get(from).?;
            _ = parts.next().?;
            const to = parts.next().?;
            const toid = CityIds.get(to).?;
            _ = parts.next().?;
            const dist = parseInt(usize, parts.next().?, 10) catch unreachable;
            max = @max(max, fromid + 1);
            max = @max(max, toid + 1);
            map.cities[fromid].distances[toid] = dist;
            map.cities[toid].distances[fromid] = dist;
            //print("From: {}, To: {}, Dist: {}\n", .{ fromid, toid, dist });
        }
        map.idc = max;
        for (0..max) |i| {
            map.ids[i] = @intCast(i);
        }
        return map;
    }

    pub fn walkMap(self: *const @This()) usize {
        var min: usize = comptime std.math.maxInt(usize);
        for (0..self.idc) |startloc| {
            var bitset = std.bit_set.IntegerBitSet(8).initEmpty();
            bitset.set(startloc);
            const city = self.cities[self.ids[startloc]];
            const res = self.walkFrom(city, bitset);
            min = @min(min, res);
        }
        //print("Min: {}\n", .{min});
        return min;
    }

    pub fn walkFrom(self: *const @This(), loc: City, map: std.bit_set.IntegerBitSet(8)) usize {
        const steps_left = self.idc - map.count();
        //print("Steps left: {}\n", .{steps_left});
        var min: usize = comptime std.math.maxInt(usize);
        for (0..self.idc) |nextloc| {
            if (map.isSet(nextloc)) {
                continue;
            }
            if (steps_left == 1) {
                return loc.distances[self.ids[nextloc]];
            }
            const stepdist = loc.distances[self.ids[nextloc]];
            //print("Stepdist: {}\n", .{stepdist});
            var newmap = map;
            newmap.set(nextloc);
            const dist = self.walkFrom(self.cities[self.ids[nextloc]], newmap) + stepdist;
            //print("Dist: {}\n", .{dist});
            min = @min(min, dist);
        }
        //print("Min: {}\n", .{min});
        return min;
    }

    pub fn walkMapSlow(self: *const @This()) usize {
        var max: usize = 0;
        //print("IDC: {}\n", .{self.idc});
        for (0..self.idc) |startloc| {
            var bitset = std.bit_set.IntegerBitSet(8).initEmpty();
            bitset.set(startloc);
            const city = self.cities[self.ids[startloc]];
            const res = self.walkFromSlow(city, bitset);
            //print("Res: {}\n", .{res});
            max = @max(max, res);
        }
        //print("Max: {}\n", .{max});
        return max;
    }

    pub fn walkFromSlow(self: *const @This(), loc: City, map: std.bit_set.IntegerBitSet(8)) usize {
        const steps_left = self.idc - map.count();
        var max: usize = 0;
        for (0..self.idc) |nextloc| {
            if (map.isSet(nextloc)) {
                continue;
            }
            if (steps_left == 1) {
                return loc.distances[self.ids[nextloc]];
            }
            const stepdist = loc.distances[self.ids[nextloc]];
            var newmap = map;
            newmap.set(nextloc);
            const dist = self.walkFromSlow(self.cities[self.ids[nextloc]], newmap) + stepdist;
            max = @max(max, dist);
        }
        return max;
    }
};

pub fn part1(input: []const u8) usize {
    var map = CityMap.init(input);
    return map.walkMap();
}

test "day09_part2" {
    const res = part2(testdata);
    assert(res == 982);
}

pub fn part2(input: []const u8) usize {
    var map = CityMap.init(input);
    return map.walkMapSlow();
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 09:\n", .{});
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
