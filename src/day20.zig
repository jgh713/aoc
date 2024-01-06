const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day20.txt");
const testdata1 = "broadcaster -> za, zb, zc\n%za -> zb\n%zb -> zc\n%zc -> zi\n&zi -> za";
const testdata2 = "broadcaster -> za\n%za -> zi, zc\n&zi -> zb\n%zb -> zc\n&zc -> zo";

test "day20_part1" {
    const res = part1(testdata1);
    assert(res == 32000000);
    const res2 = part1(testdata2);
    assert(res2 == 11687500);
}

const NodeType = enum { Untyped, Flip, And };

const Parent = struct {
    id: u16,
    last: bool,
};

const Node = struct {
    type: NodeType,
    targets: [8]u16,
    tcount: u4,
    parents: [16]Parent,
    pcount: u4,
    on: bool,
};

const Signal = struct {
    target: u16,
    high: bool,
    sender: u16,
};
fn nodeId(name: []const u8) u16 {
    const out = (@as(u16, (name[0] - 'a')) << 8 | (name[1] - 'a'));
    //print("Node id: {} ({s}) - ({s})\n", .{ out, name, idToName(out) });
    return out;
}

fn idToName(id: u16) [2]u8 {
    return .{ @as(u8, @truncate((id >> 8) & 0x1f)) + 'a', @as(u8, @truncate(id & 0x1f)) + 'a' };
}

fn buildNodes(input: []const u8, pnodes: *[]Node) void {
    var nodes = pnodes.*;
    var lines = if (indexOf(u8, input, '\r')) |_| splitSeq(u8, input, "\r\n") else splitSeq(u8, input, "\n");
    while (lines.next()) |line| {
        var lineit = splitSeq(u8, line, " -> ");
        const name = lineit.next().?;
        const targetstr = lineit.next().?;
        const ntype = switch (name[0]) {
            'b' => NodeType.Untyped,
            '%' => NodeType.Flip,
            '&' => NodeType.And,
            else => unreachable,
        };
        const id = if (ntype == NodeType.Untyped) 0 else nodeId(name[1..]);
        var node = &nodes[id];
        node.type = ntype;
        var targets = splitSeq(u8, targetstr, ", ");
        var ti: u4 = 0;
        while (targets.next()) |target| {
            const tid = nodeId(target);
            node.targets[ti] = tid;
            ti += 1;
            const pid = nodes[tid].pcount;
            nodes[tid].parents[pid] = Parent{ .id = id, .last = false };
            nodes[tid].pcount += 1;
        }
        node.tcount = ti;
    }
}

fn runSignals(pnodes: *[]Node, heads: []u16, steps: usize, nodecache: *[60]*Node, cachecount: u8) usize {
    var nodes = pnodes.*;
    var queue = gpa.alloc(Signal, 1024) catch unreachable;
    defer gpa.free(queue);
    var signalcount: [2]usize = .{ 0, 0 };
    var stepcount: usize = 0;

    while (stepcount < steps) {
        //print("Step {}\n", .{stepcount});
        var qstart: u16 = 0;
        var qend: u16 = 0;
        signalcount[0] += 1;
        for (heads) |head| {
            queue[qend] = .{ .target = head, .high = false, .sender = 0 };
            qend += 1;
            if (qend == 1024) {
                qend = 0;
            }
            if (qend == qstart) {
                print("Queue overflow\n", .{});
                unreachable;
            }
            signalcount[0] += 1;
        }

        queuewhile: while (qstart != qend) : (qstart += 1) {
            if (qstart == 1024) {
                qstart = 0;
            }
            const signal = queue[qstart];
            var node = &nodes[signal.target];
            var out: bool = false;
            switch (node.type) {
                .Flip => {
                    if (signal.high) continue :queuewhile;
                    node.on = !node.on;
                    out = node.on;
                },
                .And => {
                    nodefor: for (node.parents[0..node.pcount]) |*parent| {
                        if (parent.id == signal.sender) {
                            parent.last = signal.high;
                            break :nodefor;
                        }
                    }
                    out = outloop: for (node.parents[0..node.pcount]) |*parent| {
                        if (!parent.last) {
                            break :outloop true;
                        }
                    } else false;
                },
                else => continue :queuewhile,
            }
            for (node.targets[0..node.tcount]) |target| {
                queue[qend] = .{ .target = target, .high = out, .sender = signal.target };
                qend += 1;
                if (qend == 1024) {
                    qend = 0;
                }
                if (qend == qstart) {
                    print("Queue overflow\n", .{});
                    unreachable;
                }
                signalcount[@intFromBool(out)] += 1;
            }
        }

        //print("{} - {}\n", .{ signalcount[0], signalcount[1] });
        stepcount += 1;

        const looped: bool = loopfor: for (nodecache.*[0..cachecount]) |node| {
            switch (node.type) {
                .Flip => {
                    if (node.on) {
                        break :loopfor false;
                    }
                },
                .And => {
                    for (node.parents[0..node.pcount]) |*parent| {
                        if (parent.last) {
                            break :loopfor false;
                        }
                    }
                },
                else => unreachable,
            }
        } else true;

        if (looped) {
            const looplen = stepcount;
            const lows_per_loop = signalcount[0];
            const highs_per_loop = signalcount[1];
            const loops_to_skip = steps / looplen;
            const total_loop_signals: [2]usize = .{ lows_per_loop * loops_to_skip, highs_per_loop * loops_to_skip };
            signalcount = total_loop_signals;
            stepcount = looplen * loops_to_skip;
        }
    }

    return signalcount[0] * signalcount[1];
}

fn part1(input: []const u8) u64 {
    var nodes: []Node = gpa.alloc(Node, 65536) catch unreachable;
    defer gpa.free(nodes);
    for (nodes) |*node| {
        node.* = std.mem.zeroes(Node);
    }
    buildNodes(input, &nodes);

    //for (nodes, 0..) |*node, nid| {
    //    if (node.type != NodeType.Untyped) {
    //        const name = idToName(@intCast(nid));
    //        print("Node {s} ({}) ->", .{ name, nid });
    //        for (node.targets[0..node.tcount]) |target| {
    //            const tname = idToName(target);
    //            print(" {s} ({}), ", .{ tname, target });
    //        }
    //        print("\n", .{});
    //    }
    //}

    var nodeCache: [60]*Node = undefined;
    var cachecount: u8 = 0;
    for (nodes) |*node| {
        if (node.type != NodeType.Untyped) {
            nodeCache[cachecount] = node;
            cachecount += 1;
        }
    }

    var heads: [4]u16 = undefined;
    const headcount = nodes[0].tcount;
    for (0..headcount) |i| {
        heads[i] = nodes[0].targets[i];
    }

    return runSignals(&nodes, heads[0..headcount], 1000, &nodeCache, cachecount);
}

test "day20_part2" {
    const res = part2(data);
    assert(res == 221453937522197);
}

fn gcd(ai: u64, bi: u64) u64 {
    var a = ai;
    var b = bi;
    while (b != 0) {
        const t = b;
        b = a % b;
        a = t;
    }
    return a;
}

fn lcm(a: u64, b: u64) u64 {
    return (a / gcd(a, b)) * b;
}

fn calc_lcm(in: [4]usize) u64 {
    const r1 = lcm(in[0], in[1]);
    const r2 = lcm(in[2], in[3]);
    return lcm(r1, r2);
}

fn findLowRX(pnodes: *[]Node, heads: []u16) u64 {
    var nodes = pnodes.*;
    var queue = gpa.alloc(Signal, 1024) catch unreachable;
    defer gpa.free(queue);
    var stepcount: usize = 0;
    const outid = nodeId("rx");
    var offsets: [4]usize = .{0} ** 4;

    while (true) {
        var qstart: u16 = 0;
        var qend: u16 = 0;
        var outcount: usize = 0;
        for (heads) |head| {
            queue[qend] = .{ .target = head, .high = false, .sender = 0 };
            qend += 1;
            if (qend == 1024) {
                qend = 0;
            }
            if (qend == qstart) {
                print("Queue overflow\n", .{});
                unreachable;
            }
        }

        queuewhile: while (qstart != qend) : (qstart += 1) {
            if (qstart == 1024) {
                qstart = 0;
            }
            const signal = queue[qstart];
            var node = &nodes[signal.target];
            var out: bool = false;
            switch (node.type) {
                .Flip => {
                    if (signal.high) continue :queuewhile;
                    node.on = !node.on;
                    out = node.on;
                },
                .And => {
                    nodefor: for (node.parents[0..node.pcount], 0..) |*parent, pcount| {
                        if (parent.id == signal.sender) {
                            if (signal.target == nodeId("hf") and signal.high) {
                                if (offsets[pcount] == 0) {
                                    //print("Found offset {} for {}\n", .{ stepcount, pcount });
                                    offsets[pcount] = stepcount + 1;
                                    if (offsets[0] != 0 and offsets[1] != 0 and offsets[2] != 0 and offsets[3] != 0) {
                                        return calc_lcm(offsets);
                                    }
                                }
                            }
                            parent.last = signal.high;
                            break :nodefor;
                        }
                    }
                    out = outloop: for (node.parents[0..node.pcount]) |*parent| {
                        if (!parent.last) {
                            break :outloop true;
                        }
                    } else false;
                },
                else => continue :queuewhile,
            }
            for (node.targets[0..node.tcount]) |target| {
                queue[qend] = .{ .target = target, .high = out, .sender = signal.target };
                if (target == outid and !out) {
                    outcount += 1;
                }
                qend += 1;
                if (qend == 1024) {
                    qend = 0;
                }
                if (qend == qstart) {
                    print("Queue overflow\n", .{});
                    unreachable;
                }
            }
        }

        if (outcount == 1) {
            return stepcount + 1;
        }
        //print("{} - {}\n", .{ signalcount[0], signalcount[1] });
        stepcount += 1;
    }
}

fn part2(input: []const u8) u64 {
    var nodes: []Node = gpa.alloc(Node, 65536) catch unreachable;
    defer gpa.free(nodes);
    for (nodes) |*node| {
        node.* = std.mem.zeroes(Node);
    }
    buildNodes(input, &nodes);

    var heads: [4]u16 = undefined;
    const headcount = nodes[0].tcount;
    for (0..headcount) |i| {
        heads[i] = nodes[0].targets[i];
    }

    return findLowRX(&nodes, heads[0..headcount]);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time});
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
