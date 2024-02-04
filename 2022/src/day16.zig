const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day16.txt");
const testdata = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB\r\nValve BB has flow rate=13; tunnels lead to valves CC, AA\r\nValve CC has flow rate=2; tunnels lead to valves DD, BB\r\nValve DD has flow rate=20; tunnels lead to valves CC, AA, EE\r\nValve EE has flow rate=3; tunnels lead to valves FF, DD\r\nValve FF has flow rate=0; tunnels lead to valves EE, GG\r\nValve GG has flow rate=0; tunnels lead to valves FF, HH\r\nValve HH has flow rate=22; tunnel leads to valve GG\r\nValve II has flow rate=0; tunnels lead to valves AA, JJ\r\nValve JJ has flow rate=21; tunnel leads to valve II";

test "day16_part1" {
    const res = part1(testdata);
    assert(res == 1651);
}

const Path = struct {
    target: u10,
    distance: u8,
};

const Tunnel = struct {
    id: u10,
    pressure: usize,
    open: bool = false,
    exits: [5]u10 = undefined,
    ecount: u3 = 0,
    paths: [15]Path = undefined,
    pcount: u8 = 0,
    visited: bool = false,
};

fn idkey(key: []const u8) u10 {
    const left = key[0] - '@';
    const right = key[1] - '@';
    return (@as(u10, left) << 5) | right;
}

fn keyid(id: u10) [2]u8 {
    const left: u8 = @truncate(id >> 5);
    const right: u8 = @truncate(id & 0b11111);
    return [_]u8{ left + '@', right + '@' };
}

fn parseTunnels(input: []const u8) [1024]Tunnel {
    var lines = splitSeq(u8, input, "\r\n");
    var tunnels: [1024]Tunnel = comptime std.mem.zeroes([1024]Tunnel);

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        const id = idkey(line[6..8]);
        const semic = indexOf(u8, line, ';').?;
        //print("pline: {s}\n", .{line[23..semic]});
        const pressure = parseInt(u8, line[23..semic], 10) catch unreachable;
        //print("semic24: {c}\n", .{line[semic + 24]});
        const offset = if (line[semic + 23] == 's') semic + 25 else semic + 24;
        var tunnelit = splitSeq(u8, line[offset..], ", ");
        var tunnel = Tunnel{ .pressure = pressure, .id = id };
        while (tunnelit.next()) |t| {
            //print("tunnel: {s}\n", .{t});
            const tnid = idkey(t);
            tunnel.exits[tunnel.ecount] = tnid;
            tunnel.ecount += 1;
        }
        tunnels[id] = tunnel;
    }

    return tunnels;
}

fn shortestDistance(aid: u10, bid: u10, tunnelmap: [1024]Tunnel) u8 {
    //print("shortestDistance: {s} -> {s}\n", .{ keyid(aid), keyid(bid) });
    var dists: [1024]u8 = undefined;
    var visited: [1024]bool = comptime std.mem.zeroes([1024]bool);
    var queue: [60]u10 = undefined;
    dists[aid] = 0;
    queue[0] = aid;
    var qstart: usize = 0;
    var qend: usize = 1;
    while (qend > qstart) : (qstart += 1) {
        const id = queue[qstart];
        //print("id: {s}\n", .{keyid(id)});
        const tunnel = tunnelmap[id];
        for (tunnel.exits[0..tunnel.ecount]) |exit| {
            if (visited[exit]) continue;
            //print("Stepped to {s}\n", .{keyid(exit)});
            visited[exit] = true;
            dists[exit] = dists[id] + 1;
            if (exit == bid) return dists[exit];
            queue[qend] = exit;
            qend += 1;
        }
    }
    unreachable;
}

fn buildPaths(tunnels: []*Tunnel, tunnelmap: *[1024]Tunnel) void {
    var start = &tunnelmap.*[idkey("AA")];
    for (0..tunnels.len) |ti| {
        start.paths[start.pcount] = Path{ .target = tunnels[ti].id, .distance = shortestDistance(idkey("AA"), tunnels[ti].id, tunnelmap.*) + 1 };
        start.pcount += 1;
        //print("Dist from AA to {s} is {d}\n", .{ keyid(tunnels[ti].id), start.paths[start.pcount - 1].distance });
        for (ti + 1..tunnels.len) |tj| {
            const tuni = tunnels[ti];
            const tunj = tunnels[tj];
            const dist = shortestDistance(tuni.id, tunj.id, tunnelmap.*);
            //print("Dist from {s} to {s} is {d}\n", .{ keyid(tuni.id), keyid(tunj.id), dist });
            tuni.paths[tuni.pcount] = Path{ .target = tunj.id, .distance = dist + 1 };
            tuni.pcount += 1;
            tunj.paths[tunj.pcount] = Path{ .target = tuni.id, .distance = dist + 1 };
            tunj.pcount += 1;
        }
    }
}

fn calcHighestPressure(tunnelmap: *[1024]Tunnel, tunnel: *Tunnel, time: u8, sum: usize) usize {
    //print("Calculating from {s} at time {d} with sum {d}\n", .{ keyid(tunnel.id), time, sum });
    if (time <= 2) return sum;
    var highest = sum;
    for (tunnel.paths[0..tunnel.pcount]) |pid| {
        //print("Stepping to {s}\n", .{keyid(pid.target)});
        const path = &tunnelmap.*[pid.target];
        if (path.visited) continue;
        //print("Not visited.\n", .{});
        if (pid.distance >= time) continue;
        const newtime = time - pid.distance;
        if (newtime >= 30) continue;
        const newsum = sum + (path.pressure * (newtime));
        path.visited = true;
        highest = @max(highest, calcHighestPressure(tunnelmap, path, newtime, newsum));
        path.visited = false;
    }
    return highest;
}

pub fn part1(input: []const u8) usize {
    var tunnelmap = parseTunnels(input);
    var tunnels: [15]*Tunnel = undefined;
    var tid: usize = 0;
    for (&tunnelmap) |*tunnel| {
        if (tunnel.pressure == 0) continue;
        tunnels[tid] = tunnel;
        tid += 1;
    }

    buildPaths(tunnels[0..tid], &tunnelmap);

    const res = calcHighestPressure(&tunnelmap, &tunnelmap[idkey("AA")], 30, 0);

    //print("Highest pressure: {}\n", .{res});

    return res;
}

test "day16_part2" {
    const res = part2(testdata);
    assert(res == 1707);
}

const State = struct {
    time: u8 = 0,
    tar1: u10 = 0,
    d1: u8 = 0,
    tar2: u10 = 0,
    d2: u8 = 0,
    sum: usize = 0,
    steps: [15][2]usize = undefined,
    stepcount: u8 = 0,
};

pub fn part2(input: []const u8) usize {
    var tunnelmap = parseTunnels(input);
    var tunnels: [15]*Tunnel = undefined;
    var tid: usize = 0;
    for (&tunnelmap) |*tunnel| {
        if (tunnel.pressure == 0) continue;
        tunnels[tid] = tunnel;
        tid += 1;
    }

    buildPaths(tunnels[0..tid], &tunnelmap);

    const maxint = @as(u16, 0b1) << @truncate(tid);
    var highest: usize = 0;
    const min = (tid / 3);
    const max = (min * 2);
    for (0..maxint) |mask| {
        const pop = @popCount(mask);
        if (pop <= min or pop >= max) continue;
        for (0..tid) |ti| {
            tunnels[ti].visited = (mask & (@as(u16, 0b1) << @truncate(ti))) != 0;
        }
        const res = calcHighestPressure(&tunnelmap, &tunnelmap[idkey("AA")], 26, 0);
        const notmask = ~mask;
        for (0..tid) |ti| {
            tunnels[ti].visited = (notmask & (@as(u16, 0b1) << @truncate(ti))) != 0;
        }
        const res2 = calcHighestPressure(&tunnelmap, &tunnelmap[idkey("AA")], 26, 0);
        highest = @max(highest, res + res2);
    }

    //print("Highest pressure: {}\n", .{highest});

    return highest;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 16:\n", .{});
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
