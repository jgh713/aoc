const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day12.txt");
const testdata = "";

const Value = union(enum) {
    int: isize,
    register: usize,
};

const Instruction = union(enum) {
    cpy: struct {
        value: Value,
        register: usize,
    },
    inc: usize,
    dec: usize,
    jnz: struct {
        value: Value,
        offset: isize,
    },
};

test "day12_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

pub fn part1(input: []const u8) usize {
    var instructions: [25]Instruction = undefined;
    var iid: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        switch (line[0]) {
            'i' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .inc = register };
                iid += 1;
            },
            'd' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .dec = register };
                iid += 1;
            },
            'c' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const register = words.next().?[0] - 'a';
                instructions[iid] = .{ .cpy = .{ .value = value, .register = register } };
                iid += 1;
            },
            'j' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const offset = parseInt(isize, words.next().?, 10) catch unreachable;
                instructions[iid] = .{ .jnz = .{ .value = value, .offset = offset } };
                iid += 1;
            },
            else => unreachable,
        }
    }

    var inst: isize = 0;
    var registers = comptime std.mem.zeroes([4]isize);
    while (inst < iid) {
        switch (instructions[@intCast(inst)]) {
            .inc => |iv| {
                registers[iv] += 1;
                inst += 1;
            },
            .dec => |dv| {
                registers[dv] -= 1;
                inst += 1;
            },
            .cpy => |cv| {
                const value = switch (cv.value) {
                    .int => cv.value.int,
                    .register => registers[cv.value.register],
                };
                registers[cv.register] = value;
                inst += 1;
            },
            .jnz => |jv| {
                const value = switch (jv.value) {
                    .int => jv.value.int,
                    .register => registers[jv.value.register],
                };
                if (value != 0) {
                    inst += jv.offset;
                } else {
                    inst += 1;
                }
            },
        }
    }
    return @intCast(registers[0]);
}

test "day12_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var instructions: [25]Instruction = undefined;
    var iid: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        switch (line[0]) {
            'i' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .inc = register };
                iid += 1;
            },
            'd' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .dec = register };
                iid += 1;
            },
            'c' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const register = words.next().?[0] - 'a';
                instructions[iid] = .{ .cpy = .{ .value = value, .register = register } };
                iid += 1;
            },
            'j' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const offset = parseInt(isize, words.next().?, 10) catch unreachable;
                instructions[iid] = .{ .jnz = .{ .value = value, .offset = offset } };
                iid += 1;
            },
            else => unreachable,
        }
    }

    var inst: isize = 0;
    var registers = comptime std.mem.zeroes([4]isize);
    registers[2] = 1;
    while (inst < iid) {
        switch (instructions[@intCast(inst)]) {
            .inc => |iv| {
                registers[iv] += 1;
                inst += 1;
            },
            .dec => |dv| {
                registers[dv] -= 1;
                inst += 1;
            },
            .cpy => |cv| {
                const value = switch (cv.value) {
                    .int => cv.value.int,
                    .register => registers[cv.value.register],
                };
                registers[cv.register] = value;
                inst += 1;
            },
            .jnz => |jv| {
                const value = switch (jv.value) {
                    .int => jv.value.int,
                    .register => registers[jv.value.register],
                };
                if (value != 0) {
                    inst += jv.offset;
                } else {
                    inst += 1;
                }
            },
        }
    }
    return @intCast(registers[0]);
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 12:\n", .{});
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
