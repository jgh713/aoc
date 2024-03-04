const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day23.txt");
const testdata = "";

test "day23_part1" {
    //const res = part1(testdata);
    //assert(res == 0);
}

const Instruction = union(enum) {
    half: struct {
        reg: u8,
    },
    triple: struct {
        reg: u8,
    },
    increment: struct {
        reg: u8,
    },
    jump: struct {
        offset: i8,
    },
    jump_even: struct {
        reg: u8,
        offset: i8,
    },
    jump_one: struct {
        reg: u8,
        offset: i8,
    },
};

fn parseJump(num: []const u8) i8 {
    const mul: i8 = switch (num[0]) {
        '-' => -1,
        '+' => 1,
        else => unreachable,
    };
    return mul * (parseInt(i8, num[1..], 10) catch unreachable);
}

pub fn part1(input: []const u8) usize {
    var instruction_buffer: [50]Instruction = undefined;
    var icount: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        const instruction: Instruction = blk: {
            switch (line[0]) {
                'h' => break :blk Instruction{ .half = .{ .reg = (line[4] - 'a') } },
                't' => break :blk Instruction{ .triple = .{ .reg = (line[4] - 'a') } },
                'i' => break :blk Instruction{ .increment = .{ .reg = (line[4] - 'a') } },
                'j' => break {
                    switch (line[2]) {
                        'o' => break :blk Instruction{ .jump_one = .{ .reg = (line[4] - 'a'), .offset = parseJump(line[7..]) } },
                        'e' => break :blk Instruction{ .jump_even = .{ .reg = (line[4] - 'a'), .offset = parseJump(line[7..]) } },
                        'p' => break :blk Instruction{ .jump = .{ .offset = parseJump(line[4..]) } },
                        else => unreachable,
                    }
                },
                else => unreachable,
            }
        };
        instruction_buffer[icount] = instruction;
        icount += 1;
    }

    const instructions = instruction_buffer[0..icount];
    const end = icount;
    var registers: [8]usize = comptime std.mem.zeroes([8]usize);

    var i: isize = 0;
    while (i >= 0 and i < end) {
        const inst = instructions[@intCast(i)];
        switch (inst) {
            .half => |hv| {
                registers[hv.reg] /= 2;
                i += 1;
            },
            .triple => |tv| {
                registers[tv.reg] *= 3;
                i += 1;
            },
            .increment => |iv| {
                registers[iv.reg] += 1;
                i += 1;
            },
            .jump => |jv| {
                i += jv.offset;
            },
            .jump_even => |jev| {
                if (registers[jev.reg] % 2 == 0) {
                    i += jev.offset;
                } else {
                    i += 1;
                }
            },
            .jump_one => |jov| {
                if (registers[jov.reg] == 1) {
                    i += jov.offset;
                } else {
                    i += 1;
                }
            },
        }
    }
    return registers[1];
}

test "day23_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var instruction_buffer: [50]Instruction = undefined;
    var icount: usize = 0;

    var lines = splitSeq(u8, input, "\r\n");
    while (lines.next()) |line| {
        const instruction: Instruction = blk: {
            switch (line[0]) {
                'h' => break :blk Instruction{ .half = .{ .reg = (line[4] - 'a') } },
                't' => break :blk Instruction{ .triple = .{ .reg = (line[4] - 'a') } },
                'i' => break :blk Instruction{ .increment = .{ .reg = (line[4] - 'a') } },
                'j' => break {
                    switch (line[2]) {
                        'o' => break :blk Instruction{ .jump_one = .{ .reg = (line[4] - 'a'), .offset = parseJump(line[7..]) } },
                        'e' => break :blk Instruction{ .jump_even = .{ .reg = (line[4] - 'a'), .offset = parseJump(line[7..]) } },
                        'p' => break :blk Instruction{ .jump = .{ .offset = parseJump(line[4..]) } },
                        else => unreachable,
                    }
                },
                else => unreachable,
            }
        };
        instruction_buffer[icount] = instruction;
        icount += 1;
    }

    const instructions = instruction_buffer[0..icount];
    const end = icount;
    var registers: [8]usize = comptime std.mem.zeroes([8]usize);
    registers[0] = 1;

    var i: isize = 0;
    while (i >= 0 and i < end) {
        const inst = instructions[@intCast(i)];
        switch (inst) {
            .half => |hv| {
                registers[hv.reg] /= 2;
                i += 1;
            },
            .triple => |tv| {
                registers[tv.reg] *= 3;
                i += 1;
            },
            .increment => |iv| {
                registers[iv.reg] += 1;
                i += 1;
            },
            .jump => |jv| {
                i += jv.offset;
            },
            .jump_even => |jev| {
                if (registers[jev.reg] % 2 == 0) {
                    i += jev.offset;
                } else {
                    i += 1;
                }
            },
            .jump_one => |jov| {
                if (registers[jov.reg] == 1) {
                    i += jov.offset;
                } else {
                    i += 1;
                }
            },
        }
    }
    return registers[1];
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
