const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day05.txt");
const testdata = "abc";

test "day05_part1" {
    const res = part1(testdata);
    assert(std.mem.eql(u8, res, "18f47a30"));
}

pub fn part1(input: []const u8) []u8 {
    var strbuffer: [32]u8 = undefined;
    @memcpy(strbuffer[0..input.len], input);
    const inlen = input.len;
    const writebuffer = strbuffer[input.len..];
    var password: [8]u8 = undefined;
    var pi: u8 = 0;

    var id: usize = 1;
    while (pi < 8) : (id += 1) {
        const write = std.fmt.bufPrintIntToSlice(writebuffer, id, 10, .lower, .{});
        const written = strbuffer[0 .. inlen + write.len];
        var hash: [16]u8 = undefined;
        std.crypto.hash.Md5.hash(written, &hash, .{});
        if (hash[0] == 0 and hash[1] == 0 and hash[2] & 0xF0 == 0) {
            _ = std.fmt.bufPrintIntToSlice(password[pi .. pi + 1], (hash[2] & 0x0F), 16, .lower, .{});
            pi += 1;
        }
    }
    print("Password: {s}\n", .{password});
    return gpa.dupe(u8, password[0..]) catch unreachable;
}

test "day05_part2" {
    const res = part2(testdata);
    assert(std.mem.eql(u8, res, "05ace8e3"));
}

pub fn part2(input: []const u8) []u8 {
    var strbuffer: [32]u8 = undefined;
    @memcpy(strbuffer[0..input.len], input);
    const inlen = input.len;
    const writebuffer = strbuffer[input.len..];
    var password: [8]u8 = comptime std.mem.zeroes([8]u8);

    var id: usize = 1;
    while (true) : (id += 1) {
        const write = std.fmt.bufPrintIntToSlice(writebuffer, id, 10, .lower, .{});
        const written = strbuffer[0 .. inlen + write.len];
        var hash: [16]u8 = undefined;
        std.crypto.hash.Md5.hash(written, &hash, .{});
        if (hash[0] == 0 and hash[1] == 0 and hash[2] & 0xF0 == 0) {
            const i = hash[2] & 0x0F;
            const val = hash[3] >> 4;
            if (i < 8 and password[i] == 0) {
                _ = std.fmt.bufPrintIntToSlice(password[i .. i + 1], val, 16, .lower, .{});
                if (indexOf(u8, &password, 0) == null) break;
            }
        }
    }
    print("Password: {s}\n", .{password});
    return gpa.dupe(u8, password[0..]) catch unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 05:\n", .{});
    print("\tPart 1: {s}\n", .{res});
    print("\tPart 2: {s}\n", .{res2});
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
