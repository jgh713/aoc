const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day07.txt");
const testdata = "123 -> x\r\n456 -> y\r\nx AND y -> d\r\nx OR y -> e\r\nx LSHIFT 2 -> f\r\ny RSHIFT 2 -> g\r\nNOT x -> h\r\nNOT y -> a";

const Ops = enum {
    Literal,
    And,
    Or,
    LShift,
    RShift,
    Not,
};

const Val = union(enum) {
    node: u16,
    literal: u16,
};

const Node = struct {
    op: Ops,
    vals: [2]Val,
};

fn nodeId(node: []const u8) u10 {
    if (node[0] < 'a') {
        print("nodeId: {s}\n", .{node});
        unreachable;
    }
    const offset = 'a' - 1;
    if (node.len == 1) {
        return node[0] - offset;
    } else {
        return @as(u10, node[0] - offset) << 5 | (node[1] - offset);
    }
}

fn parseNode(node: []const u8) Val {
    switch (node[0]) {
        '0'...'9' => return .{ .literal = parseInt(u16, node, 10) catch unreachable },
        'a'...'z' => return .{ .node = nodeId(node) },
        else => unreachable,
    }
}

const Kit = struct {
    map: [1024]Node,

    pub fn init(input: []const u8) @This() {
        var out: @This() = undefined;
        var lineit = splitSeq(u8, input, "\r\n");
        while (lineit.next()) |line| {
            //print("line: {s}\n", .{line});
            var parts = splitSeq(u8, line, " -> ");
            var argit = splitSca(u8, parts.next().?, ' ');
            var args: [3]?[]const u8 = undefined;
            for (0..3) |i| {
                args[i] = argit.next();
            }
            const op: Ops = op: {
                if (args[1] == null) {
                    switch (args[0].?[0]) {
                        '0'...'9' => break :op .Literal,
                        'a'...'z' => break :op .Literal,
                        else => unreachable,
                    }
                }
                if (args[2] == null) {
                    break :op .Not;
                }
                switch (args[1].?[0]) {
                    'A' => break :op .And,
                    'O' => break :op .Or,
                    'L' => break :op .LShift,
                    'R' => break :op .RShift,
                    else => unreachable,
                }
            };
            const dest = parts.next().?;
            const destid: u10 = nodeId(dest);
            //print("dest: {s} -> {d}\n", .{ dest, destid });
            var node: Node = undefined;
            node.op = op;
            switch (op) {
                .Literal => {
                    node.vals[0] = parseNode(args[0].?);
                },
                .And, .Or => {
                    node.vals[0] = parseNode(args[0].?);
                    node.vals[1] = parseNode(args[2].?);
                },
                .LShift, .RShift => {
                    node.vals[0] = parseNode(args[0].?);
                    node.vals[1] = parseNode(args[2].?);
                },
                .Not => {
                    node.vals[0] = parseNode(args[1].?);
                },
            }
            out.map[destid] = node;
        }
        //print("Parsed.\n", .{});
        return out;
    }

    pub fn calcNode(self: *@This(), nodeid: u16) u16 {
        //print("Checking node {d}\n", .{nodeid});
        const node = self.map[nodeid];
        switch (node.op) {
            .Literal => return self.calcValue(node.vals[0]),
            .And => return self.calcValue(node.vals[0]) & self.calcValue(node.vals[1]),
            .Or => return self.calcValue(node.vals[0]) | self.calcValue(node.vals[1]),
            .LShift => return self.calcValue(node.vals[0]) << @intCast(self.calcValue(node.vals[1])),
            .RShift => return self.calcValue(node.vals[0]) >> @intCast(self.calcValue(node.vals[1])),
            .Not => return ~self.calcValue(node.vals[0]),
        }
    }

    fn calcValue(self: *@This(), val: Val) u16 {
        switch (val) {
            .literal => return val.literal,
            .node => {
                const res = self.calcNode(val.node);
                self.map[val.node] = .{ .op = .Literal, .vals = .{ Val{ .literal = res }, Val{ .literal = 0 } } };
                return res;
            },
        }
    }
};

test "day07_part1" {
    const res = part1(testdata);
    assert(res == 65079);
}

pub fn part1(input: []const u8) usize {
    var kit = Kit.init(input);
    return kit.calcNode(nodeId("a"));
}

test "day07_part2" {
    //const res = part2(testdata);
    //assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var kit = Kit.init(input);
    var kit2 = kit;
    const val = kit.calcNode(nodeId("a"));
    kit2.map[nodeId("b")] = .{ .op = .Literal, .vals = .{ Val{ .literal = val }, Val{ .literal = 0 } } };
    return kit2.calcNode(nodeId("a"));
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 07:\n", .{});
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
