const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day11.txt");
const testdata = "Monkey 0:\r\n  Starting items: 79, 98\r\n  Operation: new = old * 19\r\n  Test: divisible by 23\r\n    If true: throw to monkey 2\r\n    If false: throw to monkey 3\r\n\r\nMonkey 1:\r\n  Starting items: 54, 65, 75, 74\r\n  Operation: new = old + 6\r\n  Test: divisible by 19\r\n    If true: throw to monkey 2\r\n    If false: throw to monkey 0\r\n\r\nMonkey 2:\r\n  Starting items: 79, 60, 97\r\n  Operation: new = old * old\r\n  Test: divisible by 13\r\n    If true: throw to monkey 1\r\n    If false: throw to monkey 3\r\n\r\nMonkey 3:\r\n  Starting items: 74\r\n  Operation: new = old + 3\r\n  Test: divisible by 17\r\n    If true: throw to monkey 0\r\n    If false: throw to monkey 1";

test "day11_part1" {
    const res = part1(testdata);
    assert(res == 10605);
}

const WorrySize = u128;

const Monkey = struct {
    items: [36]WorrySize = undefined,
    itemcount: u8 = 0,
    inspections: usize = 0,
    operation: Operation = undefined,
    testdiv: u8 = 0,
    iftrue: u8 = 0,
    iffalse: u8 = 0,

    pub fn init(input: []const u8) [10]Monkey {
        var monkeys: [10]Monkey = std.mem.zeroes([10]Monkey);

        var mlines = splitSeq(u8, input, "\r\n\r\n");
        while (mlines.next()) |mline| {
            var lines = splitSeq(u8, mline, "\r\n");
            const mid = parseInt(usize, lines.next().?[7..8], 10) catch unreachable;
            var monkey = Monkey{};
            var items = splitSeq(u8, lines.next().?[18..], ", ");
            while (items.next()) |item| {
                const itemnum = parseInt(u16, item, 10) catch unreachable;
                monkey.items[monkey.itemcount] = itemnum;
                monkey.itemcount += 1;
            }

            const opline = lines.next().?[19..];
            var ops = splitSeq(u8, opline, " ");
            var op: Operation = undefined;
            const op1 = ops.next().?;
            const op2 = ops.next().?;
            const op3 = ops.next().?;
            op.lhs = if (std.mem.eql(u8, op1, "old")) 0 else parseInt(u8, op1, 10) catch unreachable;
            op.rhs = if (std.mem.eql(u8, op3, "old")) 0 else parseInt(u8, op3, 10) catch unreachable;
            op.op = if (std.mem.eql(u8, op2, "+")) Ops.Add else Ops.Mul;
            monkey.operation = op;

            monkey.testdiv = parseInt(u8, lines.next().?[21..], 10) catch unreachable;
            monkey.iftrue = parseInt(u8, lines.next().?[29..], 10) catch unreachable;
            monkey.iffalse = parseInt(u8, lines.next().?[30..], 10) catch unreachable;

            monkeys[mid] = monkey;
        }

        return monkeys;
    }

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        try writer.print("-", .{});
        for (0..self.itemcount) |i| {
            try writer.print("{}", .{self.items[i]});
            if (i < self.itemcount - 1) {
                try writer.print(", ", .{});
            }
        }
        try writer.print("-", .{});
    }
};

const Ops = enum { Add, Mul };

const Operation = struct {
    lhs: u8,
    rhs: u8,
    op: Ops,
};

fn doOperation(value: WorrySize, op: Operation) WorrySize {
    const lhs: WorrySize = if (op.lhs == 0) value else op.lhs;
    const rhs: WorrySize = if (op.rhs == 0) value else op.rhs;
    switch (op.op) {
        .Add => return lhs + rhs,
        .Mul => return lhs * rhs,
    }
}

fn runCycle(monkeys: *[10]Monkey, comptime worried: bool) void {
    var product: usize = 1;
    for (monkeys) |*monkey| {
        if (monkey.testdiv > 0) {
            product *= monkey.testdiv;
        }
    }

    for (monkeys, 0..) |*monkey, mid| {
        _ = mid;
        monkey.inspections += monkey.itemcount;
        for (monkey.items[0..monkey.itemcount]) |startworry| {
            var worry = doOperation(startworry, monkey.operation);
            if (!worried) worry /= 3;
            const next = if (worry % monkey.testdiv == 0) &monkeys[monkey.iftrue] else &monkeys[monkey.iffalse];
            next.items[next.itemcount] = worry % product;
            next.itemcount += 1;
        }
        monkey.itemcount = 0;
    }
}

fn compMonkey(_: @TypeOf(.{}), a: Monkey, b: Monkey) bool {
    return a.inspections > b.inspections;
}

pub fn part1(input: []const u8) usize {
    var monkeys: [10]Monkey = Monkey.init(input);

    for (0..20) |_| {
        runCycle(&monkeys, false);
    }

    sort(Monkey, &monkeys, .{}, compMonkey);

    return monkeys[0].inspections * monkeys[1].inspections;
}

test "day11_part2" {
    const res = part2(testdata);
    assert(res == 2713310158);
}

pub fn part2(input: []const u8) usize {
    var monkeys: [10]Monkey = Monkey.init(input);

    for (0..10000) |_| {
        runCycle(&monkeys, true);
    }

    sort(Monkey, &monkeys, .{}, compMonkey);

    return monkeys[0].inspections * monkeys[1].inspections;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 11:\n", .{});
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
