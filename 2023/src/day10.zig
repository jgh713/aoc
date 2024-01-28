const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day10.txt");
const testdata = "-L|F7\n7S-7|\nL|7||\n-L-J|\nL|-JF";
const testdata2 = "FF7FSF7F7F7F7F7F---7\nL|LJ||||||||||||F--J\nFL-7LJLJ||||||LJL-77\nF--JF--7||LJLJIF7FJ-\nL---JF-JLJIIIIFJLJJ7\n|F|F-JF---7IIIL7L|7|\n|FFJF7L7F-JF7IIL---7\n7-L-JL7||F7|L7F-7F7|\nL.L7LFJ|||||FJL7||LJ\nL7JLJL-JLJLJL--JLJ.L";

test "day10_part1" {
    const res = part1(testdata);
    assert(res == 4);
}

const dirs = enum {
    up,
    right,
    down,
    left,
};

const MapNode = struct {
    steps: [4]?dirs = .{null} ** 4,
};

inline fn gps(x: u8, y: u8) u16 {
    return (@as(u16, y) << 8) | x;
}

test "gps" {
    assert(gps(0, 0) == 0);
    assert(gps(1, 0) == 1);
    assert(gps(0, 1) == 256);
    assert(gps(1, 1) == 257);
    assert(gps(255, 255) == 65535);
    assert(gps(0, 255) == 65280);
    assert(gps(255, 0) == 255);

    assert(gpstep(gps(0, 0), dirs.right) == gps(1, 0));
    assert(gpstep(gps(0, 0), dirs.down) == gps(0, 1));
}

inline fn gpstep(loc: u16, dir: dirs) u16 {
    return switch (dir) {
        dirs.up => loc - 256,
        dirs.right => loc + 1,
        dirs.down => loc + 256,
        dirs.left => loc - 1,
    };
}

inline fn oppDir(dir: dirs) dirs {
    return switch (dir) {
        dirs.up => dirs.down,
        dirs.right => dirs.left,
        dirs.down => dirs.up,
        dirs.left => dirs.right,
    };
}

const NodeStep = struct {
    node: u16,
    step: dirs,
};

pub fn part1(input: []const u8) u32 {
    var map: [65536]MapNode = .{.{}} ** 65536;

    var x: u8 = 1;
    var y: u8 = 1;
    var start: u16 = 0;

    for (input) |c| {
        switch (c) {
            '|' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.down;
            },
            '-' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.right;
            },
            'L' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.right;
            },
            'J' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.up;
            },
            'F' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.right;
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.down;
            },
            '7' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.down;
            },
            'S' => {
                start = gps(x, y);
            },
            else => {},
        }

        x += 1;
        if (c == '\n') {
            x = 1;
            y += 1;
        }
    }

    var nodes: [2]NodeStep = undefined;
    var inode: u2 = 0;

    inline for (.{ dirs.up, dirs.right, dirs.down, dirs.left }) |dir| {
        const next = gpstep(start, dir);
        for (map[next].steps) |ostep| {
            if (ostep) |step| {
                if (gpstep(next, step) == start) {
                    nodes[inode] = NodeStep{ .node = next, .step = dir };
                    inode += 1;
                    break;
                }
            }
        }
    }

    var steps: u32 = 1;

    while (nodes[0].node != nodes[1].node) {
        steps += 1;
        for (&nodes) |*node| {
            const nextdir = map[node.node].steps[@intFromEnum(node.step)].?;
            const nextloc = gpstep(node.node, nextdir);
            node.node = nextloc;
            node.step = nextdir;
        }
    }
    return steps;
}

test "day10_part2" {
    const res = part2(testdata2);
    assert(res == 10);
}

const NodeType = enum { unknown, loop, left, right };
const NodeStatus = enum { none, partial, walked };

const WalkNode = struct {
    steps: [4]?dirs = .{null} ** 4,
    type: NodeType = .unknown,
    status: NodeStatus = .none,
};

fn assignNodes(map: *[65536]WalkNode, node: *NodeStep, in_dir: dirs, nextdir: dirs, inleft: bool) void {
    const dir = oppDir(in_dir);
    const start = @intFromEnum(dir);
    const flip = @intFromEnum(nextdir);
    var left = inleft;
    for (1..4) |i| {
        const thisdir = (start + i) % 4;
        if (thisdir == flip) {
            left = !left;
            continue;
        }

        const neighborxy = gpstep(node.node, @enumFromInt(thisdir));
        const nx = neighborxy & 0xFF;
        const ny = neighborxy >> 8;
        if (nx == 0 or nx == 150 or ny == 0 or ny == 150) {
            continue;
        }
        var neighbor = &map[neighborxy];
        if (neighbor.type == .unknown) {
            neighbor.type = if (left) .left else .right;
            neighbor.status = .partial;
        }
    }
}

fn part2overcomplicated(input: []const u8) u32 {
    var timer = std.time.Timer.start() catch unreachable;
    var map: [65536]WalkNode = .{.{}} ** 65536;

    var x: u8 = 1;
    var y: u8 = 1;
    var start: u16 = 0;

    const allocTime = timer.lap();

    for (input) |c| {
        switch (c) {
            '|' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.down;
            },
            '-' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.right;
            },
            'L' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.right;
            },
            'J' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.up;
            },
            'F' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.right;
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.down;
            },
            '7' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.down;
            },
            'S' => {
                start = gps(x, y);
                map[start].type = .loop;
                map[start].status = .walked;
            },
            else => {},
        }

        x += 1;
        if (c == '\n') {
            x = 1;
            y += 1;
        }
    }

    const parseTime = timer.lap();

    var nodes: [2]NodeStep = undefined;
    var inode: u2 = 0;

    inline for (.{ dirs.up, dirs.right, dirs.down, dirs.left }) |dir| {
        const next = gpstep(start, dir);
        for (map[next].steps) |ostep| {
            if (ostep) |step| {
                if (gpstep(next, step) == start) {
                    nodes[inode] = NodeStep{ .node = next, .step = dir };
                    map[next].type = .loop;
                    map[next].status = .walked;
                    inode += 1;
                    break;
                }
            }
        }
    }

    const adjTime = timer.lap();
    var steps: u32 = 1;

    while (nodes[0].node != nodes[1].node) {
        steps += 1;
        for (0..1) |i| {
            var node = &nodes[i];
            const dir = node.step;
            const nextdir = map[node.node].steps[@intFromEnum(node.step)].?;
            assignNodes(&map, node, dir, nextdir, (i != 0));
            const nextloc = gpstep(node.node, nextdir);
            node.node = nextloc;
            node.step = nextdir;
            map[nextloc].status = .walked;
            map[nextloc].type = .loop;
        }
    }

    const loopTime = timer.lap();

    var pts: [65536]u16 = .{0} ** 65536;
    var ptc: u16 = 0;
    var pt: u16 = 0;

    for (map, 0..) |node, i| {
        if (node.status == .partial) {
            pts[ptc] = @intCast(i);
            ptc += 1;
        }
    }

    const ptcTime = timer.lap();

    while (pt < ptc) {
        const node = &map[pts[pt]];
        assert(node.status == .partial);
        assert(node.type != .unknown);
        for (0..4) |idir| {
            const dir: dirs = @enumFromInt(idir);
            const next = gpstep(pts[pt], dir);
            const nx = next & 0xFF;
            const ny = next >> 8;
            if (nx == 0 or nx == 150 or ny == 0 or ny == 150) {
                continue;
            }
            if (map[next].status == .none) {
                map[next].type = node.type;
                map[next].status = .partial;
                pts[ptc] = next;
                ptc += 1;
            }
        }
        pt += 1;
    }

    const fillTime = timer.lap();

    const search = if (@intFromEnum(map[gps(149, 149)].type) == @intFromEnum(NodeType.left)) @intFromEnum(NodeType.right) else @intFromEnum(NodeType.left);
    var count: u32 = 0;

    for (map) |node| {
        if (@intFromEnum(node.type) == search) {
            count += 1;
        }
    }

    const searchTime = timer.lap();

    print("Alloc: {}ns\n", .{allocTime});
    print("Parse: {}ns\n", .{parseTime});
    print("Adj: {}ns\n", .{adjTime});
    print("Loop: {}ns\n", .{loopTime});
    print("PTC: {}ns\n", .{ptcTime});
    print("Fill: {}ns\n", .{fillTime});
    print("Search: {}ns\n", .{searchTime});

    return count;
}

const QuickNode = struct { steps: [4]?dirs = .{null} ** 4, loop: bool = false };

inline fn exists(step: ?dirs) bool {
    const x = step orelse return false;
    _ = x;
    return true;
}

pub fn part2(input: []const u8) u32 {
    var map: [65536]QuickNode = comptime [1]QuickNode{.{}} ** 65536;

    var x: u8 = 1;
    var y: u8 = 1;
    var start: u16 = 0;

    for (input) |c| {
        switch (c) {
            '|' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.down;
            },
            '-' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.right;
            },
            'L' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.up;
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.right;
            },
            'J' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.down)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.up;
            },
            'F' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.right;
                map[gps(x, y)].steps[@intFromEnum(dirs.left)] = dirs.down;
            },
            '7' => {
                map[gps(x, y)].steps[@intFromEnum(dirs.up)] = dirs.left;
                map[gps(x, y)].steps[@intFromEnum(dirs.right)] = dirs.down;
            },
            'S' => {
                start = gps(x, y);
                map[start].loop = true;
            },
            else => {},
        }

        x += 1;
        if (c == '\n') {
            x = 1;
            y += 1;
        }
    }

    var nodes: [2]NodeStep = undefined;
    var inode: u2 = 0;
    var sdirs: [4]dirs = undefined;
    var sdir: u4 = 0;

    inline for (.{ dirs.up, dirs.right, dirs.down, dirs.left }) |dir| {
        const next = gpstep(start, dir);
        for (map[next].steps) |ostep| {
            if (ostep) |step| {
                if (gpstep(next, step) == start) {
                    nodes[inode] = NodeStep{ .node = next, .step = dir };
                    map[next].loop = true;
                    inode += 1;
                    sdirs[sdir] = oppDir(dir);
                    sdirs[sdir + 1] = dir;
                    sdir += 2;
                    break;
                }
            }
        }
    }

    map[start].steps[@intFromEnum(sdirs[0])] = sdirs[3];
    map[start].steps[@intFromEnum(sdirs[2])] = sdirs[1];

    var steps: u32 = 1;

    while (nodes[0].node != nodes[1].node) {
        steps += 1;
        for (0..1) |i| {
            var node = &nodes[i];
            const nextdir = map[node.node].steps[@intFromEnum(node.step)].?;
            const nextloc = gpstep(node.node, nextdir);
            node.node = nextloc;
            node.step = nextdir;
            map[nextloc].loop = true;
        }
    }

    var inloop: bool = false;
    var loopcount: u32 = 0;
    var count: u32 = 0;
    var lastin: dirs = undefined;

    for (map) |this| {
        if (!this.loop) {
            count += @intFromBool(inloop);
            continue;
        }

        if (exists(this.steps[1])) {
            if (!exists(this.steps[3])) {
                const tdir = this.steps[1].?;
                if (tdir == lastin) {
                    inloop = !inloop;
                }
            }
            continue;
        }

        lastin = this.steps[3] orelse lastin;
        loopcount += 1;
        inloop = !inloop;
    }
    return count;
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
