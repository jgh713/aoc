const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day12.txt");
const testdata = "{\"a\":{\"b\":4},\"c\":-1}";

test "day12_part1" {
    const res = part1(testdata);
    assert(res == 3);
}

fn countObj(obj: std.json.Value) isize {
    var count: isize = 0;
    switch (obj) {
        .array => |arr| {
            for (arr.items) |item| {
                count += countObj(item);
            }
        },
        .bool => return 0,
        .float => unreachable,
        .integer => |v| return v,
        .number_string => unreachable,
        .object => |o| {
            var it = o.iterator();
            while (it.next()) |item| {
                count += countObj(item.value_ptr.*);
            }
        },
        .string => return 0,
        .null => unreachable,
    }
    return count;
}

fn countObjNoReds(obj: std.json.Value) isize {
    var count: isize = 0;
    switch (obj) {
        .array => |arr| {
            for (arr.items) |item| {
                count += countObjNoReds(item);
            }
        },
        .bool => return 0,
        .float => unreachable,
        .integer => |v| return v,
        .number_string => unreachable,
        .object => |o| {
            var it = o.iterator();
            while (it.next()) |item| {
                if (std.mem.eql(u8, item.key_ptr.*, "red")) {
                    return 0;
                }
                switch (item.value_ptr.*) {
                    .string => |s| {
                        if (std.mem.eql(u8, s, "red")) {
                            return 0;
                        }
                    },
                    else => {},
                }
                count += countObjNoReds(item.value_ptr.*);
            }
        },
        .string => return 0,
        .null => unreachable,
    }
    return count;
}

pub fn part1(input: []const u8) isize {
    const obj = std.json.parseFromSlice(std.json.Value, gpa, input, .{}) catch unreachable;
    return countObj(obj.value);
}

test "day12_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) isize {
    const obj = std.json.parseFromSlice(std.json.Value, gpa, input, .{}) catch unreachable;
    return countObjNoReds(obj.value);
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
