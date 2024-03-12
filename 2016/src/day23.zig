const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day23.txt");
const testdata = "cpy 2 a\r\ntgl a\r\ntgl a\r\ntgl a\r\ncpy 1 a\r\ndec a\r\ndec a";

test "day23_part1" {
    const res = part1(testdata);
    assert(res == 3);
}

const Value = union(enum) {
    int: isize,
    register: usize,
};

const Instruction = union(enum) {
    tgl: Value,
    inc: Value,
    dec: Value,
    cpy: struct {
        value: Value,
        register: Value,
    },
    jnz: struct {
        value: Value,
        offset: Value,
    },
};

pub fn part1(input: []const u8) usize {
    var instructions: [30]Instruction = undefined;
    var iid: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        switch (line[0]) {
            'i' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .inc = .{ .register = register } };
                iid += 1;
            },
            'd' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .dec = .{ .register = register } };
                iid += 1;
            },
            'c' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const to = words.next().?;
                const register: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .cpy = .{ .value = value, .register = register } };
                iid += 1;
            },
            'j' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const to = words.next().?;
                const offset: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .jnz = .{ .value = value, .offset = offset } };
                iid += 1;
            },
            't' => {
                const to = line[4..];
                const val: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .tgl = val };
                iid += 1;
            },
            else => unreachable,
        }
    }

    var inst: isize = 0;
    var registers = comptime std.mem.zeroes([4]isize);
    registers[0] = 7;
    while (inst < iid) {
        //print("instructions: {any}\n", .{instructions[0..iid]});
        //print("registers: {any}\n", .{registers});
        //print("inst: {}\n", .{inst});
        //print("instruction: {any}\n", .{instructions[@intCast(inst)]});
        switch (instructions[@intCast(inst)]) {
            .inc => |iv| {
                const reg = switch (iv) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => iv.register,
                };
                registers[reg] += 1;
                inst += 1;
            },
            .dec => |dv| {
                const reg = switch (dv) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => dv.register,
                };
                registers[reg] -= 1;
                inst += 1;
            },
            .cpy => |cv| {
                const register = switch (cv.register) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => cv.register.register,
                };
                const value = switch (cv.value) {
                    .int => cv.value.int,
                    .register => registers[cv.value.register],
                };
                registers[register] = value;
                inst += 1;
            },
            .jnz => |jv| {
                const value = switch (jv.value) {
                    .int => jv.value.int,
                    .register => registers[jv.value.register],
                };
                const offset = switch (jv.offset) {
                    .int => jv.offset.int,
                    .register => registers[jv.offset.register],
                };
                if (value != 0) {
                    inst += offset;
                } else {
                    inst += 1;
                }
            },
            .tgl => |tv| {
                const tgl_inst: usize = switch (tv) {
                    .int => |tiv| @intCast(@as(isize, @intCast(tiv)) + inst),
                    .register => |trv| @intCast(registers[trv] + inst),
                };
                //print("tgl_inst: {}\n", .{tgl_inst});

                switch (instructions[tgl_inst]) {
                    .cpy => |cv| {
                        instructions[tgl_inst] = .{ .jnz = .{ .value = cv.value, .offset = cv.register } };
                    },
                    .inc => |iv| {
                        instructions[tgl_inst] = .{ .dec = iv };
                    },
                    .dec => |dv| {
                        instructions[tgl_inst] = .{ .inc = dv };
                    },
                    .jnz => |jv| {
                        instructions[tgl_inst] = .{ .cpy = .{ .value = jv.value, .register = jv.offset } };
                    },
                    .tgl => |tnv| {
                        instructions[tgl_inst] = .{ .inc = tnv };
                    },
                }
                inst += 1;
            },
        }
    }
    return @intCast(registers[0]);
}

test "day23_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var instructions: [30]Instruction = undefined;
    var iid: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        //print("line: {s}\n", .{line});
        switch (line[0]) {
            'i' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .inc = .{ .register = register } };
                iid += 1;
            },
            'd' => {
                const register = line[4] - 'a';
                instructions[iid] = .{ .dec = .{ .register = register } };
                iid += 1;
            },
            'c' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const to = words.next().?;
                const register: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .cpy = .{ .value = value, .register = register } };
                iid += 1;
            },
            'j' => {
                var words = splitSca(u8, line[4..], ' ');
                const from = words.next().?;
                const value: Value = if (from[0] >= 'a' and from[0] <= 'z') .{ .register = from[0] - 'a' } else .{ .int = parseInt(isize, from, 10) catch unreachable };
                const to = words.next().?;
                const offset: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .jnz = .{ .value = value, .offset = offset } };
                iid += 1;
            },
            't' => {
                const to = line[4..];
                const val: Value = if (to[0] >= 'a' and to[0] <= 'z') .{ .register = to[0] - 'a' } else .{ .int = parseInt(isize, to, 10) catch unreachable };
                instructions[iid] = .{ .tgl = val };
                iid += 1;
            },
            else => unreachable,
        }
    }

    var last_jnz: usize = std.math.maxInt(usize);
    var last_registers: [4]isize = comptime std.mem.zeroes([4]isize);
    var inst: isize = 0;
    var registers = comptime std.mem.zeroes([4]isize);
    registers[0] = 12;
    while (inst < iid) {
        //print("instructions: {any}\n", .{instructions[0..iid]});
        //print("registers: {any}\n", .{registers});
        //print("inst: {}\n", .{inst});
        //print("instruction: {any}\n", .{instructions[@intCast(inst)]});
        switch (instructions[@intCast(inst)]) {
            .inc => |iv| {
                const reg = switch (iv) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => iv.register,
                };
                registers[reg] += 1;
                inst += 1;
            },
            .dec => |dv| {
                const reg = switch (dv) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => dv.register,
                };
                registers[reg] -= 1;
                inst += 1;
            },
            .cpy => |cv| {
                const register = switch (cv.register) {
                    .int => {
                        inst += 1;
                        continue;
                    },
                    .register => cv.register.register,
                };
                const value = switch (cv.value) {
                    .int => cv.value.int,
                    .register => registers[cv.value.register],
                };
                registers[register] = value;
                inst += 1;
            },
            .jnz => |jv| {
                const value = switch (jv.value) {
                    .int => jv.value.int,
                    .register => registers[jv.value.register],
                };
                const offset = switch (jv.offset) {
                    .int => jv.offset.int,
                    .register => registers[jv.offset.register],
                };
                if (value != 0) {
                    if (inst == last_jnz) {
                        const diff = last_registers[jv.value.register] - registers[jv.value.register];
                        const count = @divTrunc(registers[jv.value.register], diff);
                        //print("skipping: {}\n", .{count});
                        for (0..4) |i| {
                            const rdiff = registers[i] - last_registers[i];
                            registers[i] += rdiff * count;
                        }
                        inst += 1;
                        last_jnz = std.math.maxInt(usize);
                        continue;
                    }
                    last_jnz = @intCast(inst);
                    last_registers = registers;
                    inst += offset;
                } else {
                    inst += 1;
                }
            },
            .tgl => |tv| {
                const tgl_inst: usize = switch (tv) {
                    .int => |tiv| @intCast(@as(isize, @intCast(tiv)) + inst),
                    .register => |trv| @intCast(registers[trv] + inst),
                };
                //print("tgl_inst: {}\n", .{tgl_inst});

                if (tgl_inst >= iid) {
                    inst += 1;
                    continue;
                }
                switch (instructions[tgl_inst]) {
                    .cpy => |cv| {
                        instructions[tgl_inst] = .{ .jnz = .{ .value = cv.value, .offset = cv.register } };
                    },
                    .inc => |iv| {
                        instructions[tgl_inst] = .{ .dec = iv };
                    },
                    .dec => |dv| {
                        instructions[tgl_inst] = .{ .inc = dv };
                    },
                    .jnz => |jv| {
                        instructions[tgl_inst] = .{ .cpy = .{ .value = jv.value, .register = jv.offset } };
                    },
                    .tgl => |tnv| {
                        instructions[tgl_inst] = .{ .inc = tnv };
                    },
                }
                inst += 1;
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
    print("Day 23:\n", .{});
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
