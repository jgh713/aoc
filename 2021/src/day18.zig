const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day18.txt");
const exampledata = "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]\r\n[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]\r\n[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]\r\n[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]\r\n[7,[5,[[3,8],[1,4]]]]\r\n[[2,[2,2]],[8,[8,1]]]\r\n[2,9]\r\n[1,[[[9,3],9],[[9,0],[0,7]]]]\r\n[[[5,[7,4]],7],1]\r\n[[[[4,2],2],6],[8,7]]";
const testdata = "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]\r\n[[[5,[2,8]],4],[5,[[9,9],0]]]\r\n[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]\r\n[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]\r\n[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]\r\n[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]\r\n[[[[5,4],[7,7]],8],[[8,3],8]]\r\n[[9,3],[[9,9],[6,[4,9]]]]\r\n[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]\r\n[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]";

test "day18_part1" {
    //var node = Number.init(gpa, "[1,1]");
    //const node2 = Number.init(gpa, "[2,2]");
    //const node3 = Number.init(gpa, "[3,3]");
    //const node4 = Number.init(gpa, "[4,4]");
    //node = node.add(gpa, node2);
    //node = node.add(gpa, node3);
    //node = node.add(gpa, node4);
    ////print("{any}\n", .{node});
    //const node5 = Number.init(gpa, "[5,5]");
    //node = node.add(gpa, node5);
    ////print("{any}\n", .{node});
    //const node6 = Number.init(gpa, "[6,6]");
    //node = node.add(gpa, node6);
    ////print("{any}\n", .{node});
    //
    //const node7 = Number.init(gpa, "[[1,2],[[3,4],5]]");
    //
    //assert(node7.magnitude() == 143);

    //print("\n", .{});
    //const n1 = Number.init(gpa, "[[[[4,3],4],4],[7,[[8,4],9]]]");
    //const n2 = Number.init(gpa, "[1,1]");
    //const new = n1.add(gpa, n2);
    //print("{any}\n", .{new});

    const res = part1(exampledata);
    assert(res == 3488);

    const res2 = part1(testdata);
    assert(res2 == 4140);
}

const InternalError = error{RuleApplied};

const Node = union(enum) {
    Number: *Number,
    Int: usize,
};

const Number = struct {
    left: Node,
    right: Node,

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        try writer.print("[", .{});
        switch (self.left) {
            .Number => |left| {
                try writer.print("{}", .{left});
            },
            .Int => |val| {
                try writer.print("{}", .{val});
            },
        }
        try writer.print(",", .{});
        switch (self.right) {
            .Number => |right| {
                try writer.print("{}", .{right});
            },
            .Int => |val| {
                try writer.print("{}", .{val});
            },
        }
        try writer.print("]", .{});
    }

    pub fn init(alloc: Allocator, line: []const u8) *Number {
        const node = alloc.create(Number) catch unreachable;
        const end = node.parseLine(alloc, line);
        //print("End: {}, Len: {}\n", .{ end, line.len });
        assert(end == line.len);
        return node;
    }

    pub fn deinit(self: *@This(), alloc: Allocator) void {
        switch (self.left) {
            .Number => |left| {
                left.deinit(alloc);
            },
            else => {},
        }
        switch (self.right) {
            .Number => |right| {
                right.deinit(alloc);
            },
            else => {},
        }
        alloc.destroy(self);
    }

    /// Parses one pair, returns index of end brackets
    pub fn parseLine(self: *@This(), alloc: Allocator, line: []const u8) usize {
        var i: usize = 1;
        switch (line[i]) {
            '[' => {
                //print("Left node\n", .{});
                const left = alloc.create(Number) catch unreachable;
                const offset = left.parseLine(alloc, line[i..]);
                self.left = .{ .Number = left };
                i += offset;
            },
            '0'...'9' => {
                //print("Left int\n", .{});
                var j: usize = i;
                while (line[j] >= '0' and line[j] <= '9') j += 1;
                self.left = .{ .Int = parseInt(usize, line[i..j], 10) catch unreachable };
                i = j;
            },
            else => unreachable,
        }
        assert(line[i] == ',');
        i += 1;
        switch (line[i]) {
            '[' => {
                //print("Right node\n", .{});
                const right = alloc.create(Number) catch unreachable;
                const offset = right.parseLine(alloc, line[i..]);
                self.right = .{ .Number = right };
                i += offset;
            },
            '0'...'9' => {
                //print("Right int\n", .{});
                var j: usize = i;
                while (line[j] >= '0' and line[j] <= '9') j += 1;
                self.right = .{ .Int = parseInt(usize, line[i..j], 10) catch unreachable };
                i = j;
            },
            else => unreachable,
        }
        assert(line[i] == ']');
        return i + 1;
    }

    pub fn add(self: *@This(), alloc: Allocator, other: *@This()) *Number {
        const node = alloc.create(Number) catch unreachable;
        node.left = .{ .Number = self };
        node.right = .{ .Number = other };
        //print("Post-add: \t\t\t{any}\n", .{node});
        node.processRules(alloc);
        return node;
    }

    fn processRules(self: *@This(), alloc: Allocator) void {
        while (true) {
            var blankval: usize = 0;
            var holdptr = &blankval;
            var addhold: usize = 0;
            self.processExplodes(alloc, 0, &holdptr, &addhold, self);
            self.processSplits(alloc) catch {
                //print("Post-split: \t\t\t{any}\n", .{self});
                continue;
            };
            break;
        }
    }

    fn processExplodes(self: *@This(), alloc: Allocator, depth: usize, lastleft: **usize, rightadd: *usize, topnode: *Number) void {
        switch (self.left) {
            .Number => |left| {
                if (depth >= 3) {
                    if (rightadd.* > 0) {
                        left.left.Int += rightadd.*;
                        rightadd.* = 0;
                        //print("Adding r-left, topnode: \t{any}\n", .{topnode});
                    }
                    rightadd.* += left.right.Int;
                    self.left = .{ .Int = 0 };
                    //print("Exploding left, topnode: \t{any}\n", .{topnode});
                    lastleft.*.* += left.left.Int;
                    lastleft.* = &self.left.Int;
                    left.deinit(alloc);
                    //print("Adding l-left, topnode: \t{any}\n", .{topnode});
                } else {
                    left.processExplodes(alloc, depth + 1, lastleft, rightadd, topnode);
                }
            },
            else => {
                if (rightadd.* > 0) {
                    self.left.Int += rightadd.*;
                    rightadd.* = 0;
                    //print("Adding r-left, topnode: \t{any}\n", .{topnode});
                }
                lastleft.* = &self.left.Int;
            },
        }
        switch (self.right) {
            .Number => |right| {
                if (depth >= 3) {
                    if (rightadd.* > 0) {
                        right.left.Int += rightadd.*;
                        rightadd.* = 0;
                        //print("Adding r-right, topnode: \t{any}\n", .{topnode});
                    }
                    rightadd.* += right.right.Int;
                    self.right = .{ .Int = 0 };
                    //print("Exploding right, topnode: \t{any}\n", .{topnode});
                    lastleft.*.* += right.left.Int;
                    lastleft.* = &self.right.Int;
                    right.deinit(alloc);
                    //print("Adding l-right, topnode: \t{any}\n", .{topnode});
                } else {
                    right.processExplodes(alloc, depth + 1, lastleft, rightadd, topnode);
                }
            },
            .Int => {
                if (rightadd.* > 0) {
                    self.right.Int += rightadd.*;
                    rightadd.* = 0;
                    //print("Adding r-right, topnode: \t{any}\n", .{topnode});
                }
                lastleft.* = &self.right.Int;
            },
        }
    }

    fn processSplits(self: *@This(), alloc: Allocator) !void {
        switch (self.left) {
            .Number => |left| {
                try left.processSplits(alloc);
            },
            .Int => |val| {
                if (val >= 10) {
                    const newnode = alloc.create(Number) catch unreachable;
                    newnode.left = .{ .Int = val / 2 };
                    newnode.right = .{ .Int = val / 2 + val % 2 };
                    self.left = .{ .Number = newnode };
                    return InternalError.RuleApplied;
                }
            },
        }
        switch (self.right) {
            .Number => |right| {
                try right.processSplits(alloc);
            },
            .Int => |val| {
                if (val >= 10) {
                    const newnode = alloc.create(Number) catch unreachable;
                    newnode.left = .{ .Int = val / 2 };
                    newnode.right = .{ .Int = val / 2 + val % 2 };
                    self.right = .{ .Number = newnode };
                    return InternalError.RuleApplied;
                }
            },
        }
    }

    pub fn magnitude(self: *@This()) usize {
        const leftval = switch (self.left) {
            .Number => |left| left.magnitude(),
            .Int => |val| val,
        };
        const rightval = switch (self.right) {
            .Number => |right| right.magnitude(),
            .Int => |val| val,
        };
        return (3 * leftval) + (2 * rightval);
    }
};

pub fn part1(input: []const u8) usize {
    var buffer: [40000]u8 = undefined;
    var fba_impl = std.heap.FixedBufferAllocator.init(&buffer);
    const fba = fba_impl.allocator();
    var lines = splitSeq(u8, input, "\r\n");
    var node = Number.init(fba, lines.first());
    //print("{any}\n", .{node});
    while (lines.next()) |line| {
        const newnode = Number.init(fba, line);
        //print("Adding {any}\n", .{newnode});
        node = node.add(fba, newnode);
        //print("Result: {any}\n", .{node});
        //return 0;
    }
    //print("Magnitude: {}\n", .{node.magnitude()});
    return node.magnitude();
}

test "day18_part2" {
    const res = part2(testdata);
    assert(res == 3993);
}

pub fn part2(input: []const u8) usize {
    var buffer: [2000]u8 = undefined;
    var fba_impl = std.heap.FixedBufferAllocator.init(&buffer);
    const fba = fba_impl.allocator();
    var lineit = splitSeq(u8, input, "\r\n");
    var lines: [100][]const u8 = undefined;
    var li: usize = 0;
    //print("{any}\n", .{node});
    while (lineit.next()) |line| {
        lines[li] = line;
        li += 1;
    }

    var max: usize = 0;
    for (0..li - 1) |i| {
        for (i + 1..li) |j| {
            var l = Number.init(fba, lines[i]);
            var r = Number.init(fba, lines[j]);
            l = l.add(fba, r);
            max = @max(max, l.magnitude());
            l = Number.init(fba, lines[i]);
            r = Number.init(fba, lines[j]);
            r = r.add(fba, l);
            max = @max(max, r.magnitude());
            fba_impl.reset();
        }
    }
    //print("Magnitude: {}\n", .{node.magnitude()});
    return max;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 18:\n", .{});
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
