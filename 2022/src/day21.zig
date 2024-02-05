const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day21.txt");
const testdata = "root: pppw + sjmn\r\ndbpl: 5\r\ncczh: sllz + lgvd\r\nzczc: 2\r\nptdq: humn - dvpt\r\ndvpt: 3\r\nlfqf: 4\r\nhumn: 5\r\nljgn: 2\r\nsjmn: drzm * dbpl\r\nsllz: 4\r\npppw: cczh / lfqf\r\nlgvd: ljgn * ptdq\r\ndrzm: hmdt - zczc\r\nhmdt: 32";

test "day21_part1" {
    const res = part1(testdata);
    assert(res == 152);
}

const Ops = enum {
    Add,
    Sub,
    Mul,
    Div,
};

const Monkey = union(enum) { number: isize, math: struct {
    op: Ops,
    left: [4]u8,
    right: [4]u8,
    human: bool = false,
} };

fn calcNode(map: Map([4]u8, Monkey), key: [4]u8) isize {
    const node = map.get(key).?;
    return switch (node) {
        .number => node.number,
        .math => {
            const left = calcNode(map, node.math.left);
            const right = calcNode(map, node.math.right);
            return switch (node.math.op) {
                Ops.Add => left + right,
                Ops.Sub => left - right,
                Ops.Mul => left * right,
                Ops.Div => @divExact(left, right),
            };
        },
    };
}

pub fn part1(input: []const u8) isize {
    var lines = splitSeq(u8, input, "\r\n");
    var map = Map([4]u8, Monkey).init(gpa);
    while (lines.next()) |line| {
        const key = line[0..4];
        if (line.len > 14) {
            const op = switch (line[11]) {
                '+' => Ops.Add,
                '-' => Ops.Sub,
                '*' => Ops.Mul,
                '/' => Ops.Div,
                else => unreachable,
            };
            const left = line[6..10];
            const right = line[13..17];
            map.put(key.*, .{ .math = .{ .op = op, .left = left.*, .right = right.* } }) catch unreachable;
        } else {
            const num = parseInt(isize, line[6..], 10) catch unreachable;
            map.put(key.*, .{ .number = num }) catch unreachable;
        }
    }

    const root = calcNode(map, "root".*);

    return root;
}

test "day21_part2" {
    const res = part2(testdata);
    assert(res == 301);
}

fn humanBased(map: Map([4]u8, Monkey), key: [4]u8) bool {
    const entry = map.getEntry(key).?;
    const node = entry.value_ptr;
    if (std.mem.eql(u8, &key, "humn")) {
        return true;
    }
    return switch (node.*) {
        .number => false,
        .math => {
            const left = humanBased(map, node.math.left);
            const right = humanBased(map, node.math.right);
            const human = left or right;
            if (human) {
                //print("Marking {s} as human\n", .{key});
                node.math.human = true;
            }
            return human;
        },
    };
}

fn calcFromExpectedValue(map: Map([4]u8, Monkey), key: [4]u8, invalue: isize) isize {
    if (std.mem.eql(u8, &key, "humn")) {
        return invalue;
    }
    const node = map.get(key).?;
    //print("calcFromExpectedValue: {s} {} {any}\n", .{ key, invalue, node });
    //print("Left: {s} - {any}\n", .{ node.math.left, map.get(node.math.left).? });
    //print("Right: {s} - {any}\n", .{ node.math.right, map.get(node.math.right).? });
    var humanleft: bool = false;
    switch (node) {
        .math => {
            humanleft = std.mem.eql(u8, &node.math.left, "humn");
            //if (humanleft) print("FOUND HUMAN\n", .{});
            if (!humanleft) {
                const left = map.get(node.math.left).?;
                //print("Checking left: {s} - {any}\n", .{ node.math.left, left });
                switch (left) {
                    .number => {},
                    .math => {
                        if (left.math.human) {
                            humanleft = true;
                        }
                        //print("Humanleft is now {any}\n", .{humanleft});
                    },
                }
                //print("Humanleft is now {any}\n", .{humanleft});
            }
        },
        .number => unreachable,
    }

    //print("Humanleft: {any}\n", .{humanleft});

    if (humanleft) {
        const rightval = calcNode(map, node.math.right);
        const expectedValue = switch (node.math.op) {
            Ops.Add => invalue - rightval,
            Ops.Sub => invalue + rightval,
            Ops.Mul => @divExact(invalue, rightval),
            Ops.Div => invalue * rightval,
        };
        return calcFromExpectedValue(map, node.math.left, expectedValue);
    } else {
        const leftval = calcNode(map, node.math.left);
        const expectedValue = switch (node.math.op) {
            Ops.Add => invalue - leftval,
            Ops.Sub => leftval - invalue,
            Ops.Mul => @divExact(invalue, leftval),
            Ops.Div => @divExact(leftval, invalue),
        };
        return calcFromExpectedValue(map, node.math.right, expectedValue);
    }
}

fn calcHumanValue(map: Map([4]u8, Monkey)) isize {
    const root = map.get("root".*).?;
    const humanleft = humanBased(map, root.math.left);
    const human = if (humanleft) root.math.left else root.math.right;
    const nonhuman = if (humanleft) root.math.right else root.math.left;

    const expectedValue = calcNode(map, nonhuman);
    return calcFromExpectedValue(map, human, expectedValue);
}

pub fn part2(input: []const u8) isize {
    var lines = splitSeq(u8, input, "\r\n");
    var map = Map([4]u8, Monkey).init(gpa);
    while (lines.next()) |line| {
        const key = line[0..4];
        if (line.len > 14) {
            const op = switch (line[11]) {
                '+' => Ops.Add,
                '-' => Ops.Sub,
                '*' => Ops.Mul,
                '/' => Ops.Div,
                else => unreachable,
            };
            const left = line[6..10];
            const right = line[13..17];
            map.put(key.*, .{ .math = .{ .op = op, .left = left.*, .right = right.* } }) catch unreachable;
        } else {
            const num = parseInt(isize, line[6..], 10) catch unreachable;
            map.put(key.*, .{ .number = num }) catch unreachable;
        }
    }

    const root = calcHumanValue(map);

    return root;
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
