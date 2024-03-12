const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day25.txt");
const testdata = "";

test "day25_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

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
    out: usize,
};

pub fn part1(input: []const u8) usize {
    var instructions: [45]Instruction = undefined;
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
            'o' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .out = register };
                iid += 1;
            },
            else => unreachable,
        }
    }

    const State = struct {
        valid: bool = true,
        expected: u1 = 0,
        inst: isize = 0,
        registers: [4]isize = std.mem.zeroes([4]isize),
    };

    var states: [256]State = undefined;
    for (0..256) |sid| {
        states[sid] = State{};
        states[sid].registers[0] = @intCast(sid);
    }
    var count: usize = 256;

    while (count > 1) {
        for (0..256) |sid| {
            if (!states[sid].valid) continue;
            if (states[sid].inst < 0 or states[sid].inst >= iid) {
                states[sid].valid = false;
                //print("Count is now {}\n", .{count});
                count -= 1;
                continue;
            }
            switch (instructions[@intCast(states[sid].inst)]) {
                .inc => |iv| {
                    states[sid].registers[iv] += 1;
                    states[sid].inst += 1;
                },
                .dec => |dv| {
                    states[sid].registers[dv] -= 1;
                    states[sid].inst += 1;
                },
                .cpy => |cv| {
                    const value = switch (cv.value) {
                        .int => cv.value.int,
                        .register => states[sid].registers[cv.value.register],
                    };
                    states[sid].registers[cv.register] = value;
                    states[sid].inst += 1;
                },
                .jnz => |jv| {
                    const value = switch (jv.value) {
                        .int => jv.value.int,
                        .register => states[sid].registers[jv.value.register],
                    };
                    if (value != 0) {
                        states[sid].inst += jv.offset;
                    } else {
                        states[sid].inst += 1;
                    }
                },
                .out => |ov| {
                    const value = states[sid].registers[ov];
                    //print("Checking register {} with value {}\n", .{ ov, value });
                    if (value != states[sid].expected) {
                        //print("Value expected for sid {} is {}, but got {}\n", .{ sid, states[sid].expected, value });
                        states[sid].valid = false;
                        count -= 1;
                        //print("Count is now {}\n", .{count});
                        continue;
                    }
                    //print("Value expected for sid {} is {}\n", .{ sid, value });
                    states[sid].expected +%= 1;
                    states[sid].inst += 1;
                },
            }
        }
    }

    for (0..256) |sid| {
        if (states[sid].valid) {
            return sid;
        }
    }

    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    print("Day 25:\n", .{});
    print("\tPart 1: {}\n", .{res});
    print("\tTime: {}ns\n", .{time});
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
