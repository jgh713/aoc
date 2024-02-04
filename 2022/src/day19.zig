const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day19.txt");
const testdata = "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.\r\nBlueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.";

test "day19_part1" {
    //var state = State{ .costs = .{ .{ 2, 0, 0, 0 }, .{ 3, 0, 0, 0 }, .{ 3, 8, 0, 0 }, .{ 3, 0, 12, 0 } }, .time = 23, .bots = .{ 1174, 0, 0, 0 }, .buildqueue = .{ 0, 0, 0, 0 }, .resources = .{ 861, 0, 0, 0 }, .target = BotType.Clay };
    //const res = state.process();
    //print("Result: {}\n", .{res});
    const res = part1(testdata);
    assert(res == 33);
}

const Cost = [4]u8;

const BotType = enum {
    Ore,
    Clay,
    Obsidian,
    Geode,
};

const Blueprint = struct {
    costs: [4]Cost,
};

fn skipWords(iter: *std.mem.SplitIterator(u8, .sequence), n: usize) void {
    for (0..n) |_| {
        _ = iter.next() orelse unreachable;
    }
}

fn parseBlueprint(line: []const u8) Blueprint {
    var bp = std.mem.zeroes(Blueprint);
    var words = splitSeq(u8, line, " ");

    skipWords(&words, 6);
    bp.costs[@intFromEnum(BotType.Ore)][0] = parseInt(u8, words.next().?, 10) catch unreachable;

    skipWords(&words, 5);
    bp.costs[@intFromEnum(BotType.Clay)][0] = parseInt(u8, words.next().?, 10) catch unreachable;

    skipWords(&words, 5);
    bp.costs[@intFromEnum(BotType.Obsidian)][0] = parseInt(u8, words.next().?, 10) catch unreachable;
    skipWords(&words, 2);
    bp.costs[@intFromEnum(BotType.Obsidian)][1] = parseInt(u8, words.next().?, 10) catch unreachable;

    skipWords(&words, 5);
    bp.costs[@intFromEnum(BotType.Geode)][0] = parseInt(u8, words.next().?, 10) catch unreachable;
    skipWords(&words, 2);
    bp.costs[@intFromEnum(BotType.Geode)][2] = parseInt(u8, words.next().?, 10) catch unreachable;

    return bp;
}

const StateCache = struct {
    time: u8,
    bots: [4]u8,
    resources: [4]u8,
};

const State = struct {
    costs: [4]Cost,
    time: u8,
    bots: [4]u8 = .{ 1, 0, 0, 0 },
    maxes: [4]u8,
    resources: [4]u8 = std.mem.zeroes([4]u8),
    target: BotType = undefined,
    maxtime: u8,
    cachemap: *Map(StateCache, u64),

    pub fn processBlueprint(bp: Blueprint, maxtime: u8) usize {
        var highest: usize = 0;
        var maxes: [4]u8 = std.mem.zeroes([4]u8);

        var cachemap = Map(StateCache, u64).init(gpa);
        defer cachemap.deinit();

        for (bp.costs) |cost| {
            for (0..3) |i| {
                maxes[i] = @max(maxes[i], cost[i]);
            }
        }

        maxes[3] = std.math.maxInt(u8);

        for (0..4) |tid| {
            var state = State{ .time = 0, .maxtime = maxtime, .costs = bp.costs, .target = @enumFromInt(tid), .maxes = maxes, .cachemap = &cachemap };
            if (!state.validTarget(tid)) continue;
            const res = state.process();
            highest = @max(highest, res);
        }
        return highest;
    }

    fn validTarget(self: *@This(), tid: usize) bool {
        if (self.bots[tid] >= self.maxes[tid]) return false;
        if (tid != 3 and self.time < self.maxtime) {
            const timeleft: usize = @intCast(self.maxtime - 1 - self.time);
            const most = (timeleft * self.maxes[tid]);
            if (self.resources[tid] >= most) return false;
        }
        for (0..3) |rid| {
            if (self.costs[tid][rid] > 0 and self.bots[rid] == 0) return false;
        }
        return true;
    }

    fn canBuild(self: *@This(), tid: usize) bool {
        //print("Checking tid: {}\n", .{tid});
        const res = self.resources;
        for (0..3) |resid| {
            //print("Checking resid: {}\n", .{resid});
            if (res[resid] < self.costs[tid][resid]) return false;
            //print("Checked resid: {}\n", .{resid});
        }
        return true;
    }

    fn buildNext(self: *@This()) void {
        var res = self.resources;
        const tid = @intFromEnum(self.target);
        for (0..4) |resid| {
            res[resid] -= self.costs[tid][resid];
        }
        self.bots[tid] += 1;
        self.resources = res;
    }

    fn tick(self: *@This()) void {
        for (0..4) |tid| {
            self.resources[tid] += self.bots[tid];
        }
        self.time += 1;
    }

    fn process(self: *@This()) usize {
        //print("Processing: {any}\n", .{self});
        while (self.time < self.maxtime and !self.canBuild(@intFromEnum(self.target))) {
            self.tick();
            //print("Stepped forward: {any}\n", .{self});
        }

        if (self.time >= self.maxtime) return self.resources[@intFromEnum(BotType.Geode)];

        self.tick();
        self.buildNext();

        //if (self.canBuild(@intFromEnum(BotType.Geode))) {
        //    self.target = BotType.Geode;
        //    return self.process();
        //}

        var highest: usize = 0;
        const cachekey = StateCache{ .time = self.time, .bots = self.bots, .resources = self.resources };
        const entry = self.cachemap.getOrPut(cachekey) catch unreachable;
        print("Valueptr is: {any}\n", .{entry.value_ptr});
        if (entry.found_existing) {
            print("Cache hit: {any}\n", .{entry.key_ptr.*});
            return entry.value_ptr.*;
        } else {
            print("Cache miss: {any}\n", .{entry.key_ptr.*});
            entry.value_ptr.* = 0;
        }

        for (0..4) |tid| {
            if (self.validTarget(tid)) {
                //print("Valid target: {}\n", .{tid});
                var newstate = self.*;
                newstate.target = @enumFromInt(tid);
                highest = @max(highest, newstate.process());
            } else {
                //print("Invalid target: {}\n", .{tid});
            }
        }

        print("Afterptr is: {any}\n", .{entry.value_ptr});
        print("Setting value: {any}\n", .{highest});
        print("Current value is {any}\n", .{entry.value_ptr.*});
        entry.value_ptr.* = highest;
        print("Set value.\n", .{});
        return highest;
    }
};

pub fn part1(input: []const u8) usize {
    var bps: [30]Blueprint = undefined;
    var bpi: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        bps[bpi] = parseBlueprint(line);
        print("Parsed blueprint {}: {any}\n", .{ bpi + 1, bps[bpi] });
        bpi += 1;
    }

    var total: usize = 0;

    for (0..bpi) |i| {
        const res = State.processBlueprint(bps[i], 24);
        total += res * (i + 1);
        print("Blueprint {}: {}\n", .{ i + 1, res });
    }

    return total;
}

test "day19_part2" {
    const res = part2(testdata);
    assert(res == (56 * 62));
}

pub fn part2(input: []const u8) usize {
    var bps: [30]Blueprint = undefined;
    var bpi: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        bps[bpi] = parseBlueprint(line);
        print("Parsed blueprint {}: {any}\n", .{ bpi + 1, bps[bpi] });
        bpi += 1;
        if (bpi == 3) break;
    }

    var total: usize = 1;

    for (0..bpi) |i| {
        const res = State.processBlueprint(bps[i], 32);
        total *= res;
        print("Blueprint {}: {}\n", .{ i + 1, res });
    }

    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 19:\n", .{});
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
