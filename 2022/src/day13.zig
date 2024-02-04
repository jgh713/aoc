const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day13.txt");
const testdata = "[1,1,3,1,1]\r\n[1,1,5,1,1]\r\n\r\n[[1],[2,3,4]]\r\n[[1],4]\r\n\r\n[9]\r\n[[8,7,6]]\r\n\r\n[[4,4],4,4]\r\n[[4,4],4,4,4]\r\n\r\n[7,7,7,7]\r\n[7,7,7]\r\n\r\n[]\r\n[3]\r\n\r\n[[[]]]\r\n[[]]\r\n\r\n[1,[2,[3,[4,[5,6,7]]]],8,9]\r\n[1,[2,[3,[4,[5,6,0]]]],8,9]";

test "day13_part1" {
    const res = part1(testdata);
    assert(res == 13);
}

const EmptyArray = bool;

const NodeVal = union(enum) {
    Array: *ArrayNode,
    Int: usize,
    Empty: EmptyArray,

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        switch (self) {
            .Array => |arr| {
                try writer.print("{}", .{arr});
            },
            .Int => |int| {
                try writer.print("{}", .{int});
            },
            .Empty => |_| {
                try writer.print("[]", .{});
            },
        }
    }
};

const ArrayNode = struct {
    next: ?*ArrayNode,
    value: NodeVal,

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        try writer.print("[", .{});
        try writer.print("{}", .{self.value});
        var next = self.next;
        while (next) |nnode| {
            try writer.print(",", .{});
            try writer.print("{}", .{nnode.value});
            next = nnode.next;
        }
        try writer.print("]", .{});
    }
};

const Parse = struct {
    node: *ArrayNode,
    lastindex: usize,
};

const Compare = enum {
    Bad,
    Good,
    Equal,
};

fn parseLine(line: []const u8) Parse {
    if (line[1] == ']') {
        const parse = Parse{ .node = gpa.create(ArrayNode) catch unreachable, .lastindex = 1 };
        parse.node.* = ArrayNode{ .next = null, .value = NodeVal{ .Empty = false } };
        return parse;
    }
    var startnode: ?*ArrayNode = null;
    var onode = startnode;
    var i: usize = 1;
    while (true) {
        switch (line[i]) {
            '0'...'9' => {
                var intval = parseInt(usize, line[i .. i + 1], 10) catch unreachable;
                i += 1;
                while (i < line.len and line[i] >= '0' and line[i] <= '9') {
                    intval *= 10;
                    intval += parseInt(usize, line[i .. i + 1], 10) catch unreachable;
                    i += 1;
                }
                if (onode) |node| {
                    node.next = gpa.create(ArrayNode) catch unreachable;
                    onode = node.next;
                    onode.?.* = ArrayNode{ .next = null, .value = NodeVal{ .Int = intval } };
                } else {
                    startnode = gpa.create(ArrayNode) catch unreachable;
                    onode = startnode;
                    onode.?.* = ArrayNode{ .next = null, .value = NodeVal{ .Int = intval } };
                }
            },
            ',' => {
                i += 1;
            },
            '[' => {
                const res = parseLine(line[i..]);
                var set: bool = false;
                switch (res.node.value) {
                    .Empty => |eval| {
                        if (!eval) {
                            if (onode) |node| {
                                node.next = res.node;
                                onode = node.next;
                            } else {
                                startnode = res.node;
                                onode = startnode;
                            }
                            onode.?.value = NodeVal{ .Empty = true };
                            set = true;
                        }
                    },
                    else => {},
                }
                //print("Res: {any}\n", .{res.node});
                if (!set) {
                    if (onode) |node| {
                        node.next = gpa.create(ArrayNode) catch unreachable;
                        node.next.?.* = ArrayNode{ .next = null, .value = NodeVal{ .Array = res.node } };
                        onode = node.next;
                    } else {
                        startnode = gpa.create(ArrayNode) catch unreachable;
                        onode = startnode;
                        onode.?.* = ArrayNode{ .next = null, .value = NodeVal{ .Array = res.node } };
                    }
                }
                i += res.lastindex + 1;
            },
            ']' => {
                return Parse{ .node = if (startnode) |sn| sn else unreachable, .lastindex = i };
            },
            else => unreachable,
        }
    }
    unreachable;
}

fn compareLines(left: *const ArrayNode, right: *const ArrayNode) Compare {
    var leftnode = left;
    var rightnode = right;

    //print("Left: {}\n", .{leftnode});
    //print("Right: {}\n\n", .{rightnode});

    while (true) {
        switch (leftnode.value) {
            .Empty => |_| {
                switch (rightnode.value) {
                    .Empty => |_| {},
                    .Int => |_| return Compare.Good,
                    .Array => |_| return Compare.Good,
                }
            },
            .Int => |lint| {
                switch (rightnode.value) {
                    .Int => |rint| {
                        if (lint < rint) {
                            return Compare.Good;
                        } else if (lint > rint) {
                            return Compare.Bad;
                        }
                    },
                    .Empty => |_| return Compare.Bad,
                    .Array => |rarr| {
                        var newarr = ArrayNode{ .next = null, .value = NodeVal{ .Int = lint } };
                        const newleft = ArrayNode{ .next = null, .value = NodeVal{ .Array = &newarr } };
                        const res = compareLines(&newleft, rarr);
                        switch (res) {
                            Compare.Bad => return Compare.Bad,
                            Compare.Good => return Compare.Good,
                            Compare.Equal => {},
                        }
                    },
                }
            },
            .Array => |larr| {
                switch (rightnode.value) {
                    .Array => |rarr| {
                        const res = compareLines(larr, rarr);
                        switch (res) {
                            Compare.Bad => return Compare.Bad,
                            Compare.Good => return Compare.Good,
                            Compare.Equal => {},
                        }
                    },
                    .Empty => |_| return Compare.Bad,
                    .Int => |rint| {
                        var newarr = ArrayNode{ .next = null, .value = NodeVal{ .Int = rint } };
                        const newright = ArrayNode{ .next = null, .value = NodeVal{ .Array = &newarr } };
                        const res = compareLines(leftnode, &newright);
                        switch (res) {
                            Compare.Bad => return Compare.Bad,
                            Compare.Good => return Compare.Good,
                            Compare.Equal => {},
                        }
                    },
                }
            },
        }

        if (leftnode.next) |nlnode| {
            leftnode = nlnode;
            if (rightnode.next) |nrnode| {
                rightnode = nrnode;
            } else {
                return Compare.Bad;
            }
        } else if (rightnode.next) |nrnode| {
            rightnode = nrnode;
            return Compare.Good;
        } else {
            return Compare.Equal;
        }
    }
    unreachable;
}

pub fn part1(input: []const u8) usize {
    var pairs = splitSeq(u8, input, "\r\n\r\n");
    var pid: usize = 0;
    var total: usize = 0;
    while (pairs.next()) |pair| {
        pid += 1;
        var lines = splitSeq(u8, pair, "\r\n");
        const left = parseLine(lines.next().?);
        const right = parseLine(lines.next().?);
        //print("{}\n", .{left.node});
        //print("{}\n\n", .{right.node});
        const res = compareLines(left.node, right.node);
        switch (res) {
            Compare.Bad => {},
            Compare.Good => {
                total += pid;
            },
            Compare.Equal => unreachable,
        }
    }
    return total;
}

test "day13_part2" {
    const res = part2(testdata);
    assert(res == 140);
}

fn compNodes(_: @TypeOf(.{}), a: *ArrayNode, b: *ArrayNode) bool {
    const res = compareLines(a, b);
    switch (res) {
        Compare.Good => return true,
        else => return false,
    }
}

pub fn part2(input: []const u8) usize {
    var nodes: [302]*ArrayNode = undefined;
    var ni: usize = 2;
    var pairs = splitSeq(u8, input, "\r\n\r\n");
    var pid: usize = 0;
    const div1 = parseLine("[[2]]").node;
    const div2 = parseLine("[[6]]").node;
    nodes[0] = div1;
    nodes[1] = div2;
    while (pairs.next()) |pair| {
        pid += 1;
        var lines = splitSeq(u8, pair, "\r\n");
        const left = parseLine(lines.next().?);
        const right = parseLine(lines.next().?);
        //print("{}\n", .{left.node});
        //print("{}\n\n", .{right.node});
        nodes[ni] = left.node;
        nodes[ni + 1] = right.node;
        ni += 2;
    }

    sort(*ArrayNode, nodes[0..ni], .{}, compNodes);

    var total: usize = 1;
    for (nodes, 1..) |node, nix| {
        if (node == div1) {
            total *= nix;
        }
        if (node == div2) {
            total *= nix;
        }
    }
    return total;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 13:\n", .{});
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
