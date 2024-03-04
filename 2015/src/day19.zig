const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day19.txt");
const testdata = "e => H\r\ne => O\r\nH => HO\r\nH => OH\r\nO => HH\r\n\r\nHOH";

test "day19_part1" {
    const res = part1(testdata);
    assert(res == 4);
}

const RuleNode = struct {
    value: []const u8,
    next: ?*RuleNode,
};

pub fn part1(input: []const u8) usize {
    var membuffer: [2000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var parts = splitSeq(u8, input, "\r\n\r\n");
    var lines = splitSeq(u8, parts.next().?, "\r\n");
    const base = parts.next().?;

    var rules = std.StringArrayHashMap(*RuleNode).init(alloc);
    rules.ensureTotalCapacity(40) catch unreachable;
    while (lines.next()) |line| {
        var lparts = splitSeq(u8, line, " => ");
        const key = lparts.next().?;
        const value = lparts.next().?;
        const node = alloc.create(RuleNode) catch unreachable;
        node.* = RuleNode{ .value = alloc.dupe(u8, value) catch unreachable, .next = null };
        const entry = rules.getOrPutAssumeCapacity(key);
        //print("key: {s}\n", .{key});
        //print("value: {s}\n", .{value});
        if (entry.found_existing) {
            node.next = entry.value_ptr.*;
            entry.value_ptr.* = node;
        } else {
            entry.key_ptr.* = alloc.dupe(u8, key) catch unreachable;
            entry.value_ptr.* = node;
        }
    }

    //var ruleit = rules.iterator();
    //while (ruleit.next()) |rule| {
    //    print("{s} => ", .{rule.key_ptr.*});
    //    var node: ?*RuleNode = rule.value_ptr.*;
    //    while (node) |n| {
    //        print("{s} | ", .{n.value});
    //        node = n.next;
    //    }
    //    print("\n", .{});
    //}

    var buffer: [600]u8 = undefined;
    var map = std.StringHashMap(void).init(alloc);

    for (0..base.len) |i| {
        if (base[i] >= 'a' and base[i] <= 'z') continue;
        @memset(&buffer, 0);
        @memcpy(buffer[0..i], base[0..i]);
        var n = rules.get(base[i .. i + 1]);
        var o: ?*RuleNode = if (i < (base.len - 1)) rules.get(base[i .. i + 2]) else null;
        var ilen: usize = 1;
        while (true) {
            if (n) |np| {
                const vlen = np.value.len;
                const end = base.len + vlen - ilen;
                //print("Replacing {s} with {s}\n", .{ base[i .. i + ilen], np.value });
                @memcpy(buffer[i .. i + vlen], np.value);
                @memcpy(buffer[i + vlen .. end], base[i + ilen ..]);
                //print("Result: {s}\n", .{buffer[0..end]});
                const e = map.getOrPut(buffer[0..end]) catch unreachable;
                if (!e.found_existing) {
                    e.key_ptr.* = alloc.dupe(u8, buffer[0..end]) catch unreachable;
                }
                n = np.next;
            } else if (o) |op| {
                ilen = 2;
                n = op;
                o = null;
            } else {
                break;
            }
        }
    }

    return map.count();
}

test "day19_part2" {
    const res = part2(testdata);
    assert(res == 3);
}

const RuleNode2 = struct {
    value: []const u8,
    next: ?*RuleNode2,
};

// This was an absolute failure from both directions
// And when prioritizing both larger and smaller transformations
fn calcMinDisassemblyOld(cache: *std.StringHashMap(usize), rules: *std.StringArrayHashMap(*RuleNode2), alloc: Allocator, longest: usize, str: []u8) usize {
    if (cache.get(str)) |c| {
        //print("Hit cache for {s}\n", .{str});
        return c;
    }
    //print("In func: {s}\n", .{str});
    var buffer: [600]u8 = undefined;

    var min: usize = std.math.maxInt(usize);
    var ilen = @min(str.len, longest);
    outfor: while (ilen >= 1) : (ilen -= 1) {
        for (0..(str.len - ilen + 1)) |i| {
            //print("i: {}\n", .{i});
            if (str[i] >= 'a' and str[i] <= 'z') continue;
            @memcpy(buffer[0..i], str[0..i]);
            //print("ilen: {}\n", .{ilen});
            const key = str[i .. i + ilen];
            var n = rules.get(key);
            while (n) |np| {
                if (std.mem.eql(u8, np.value, "e")) {
                    if (ilen == str.len) {
                        min = 1;
                        break :outfor;
                    } else {
                        n = np.next;
                        continue;
                    }
                }
                const vlen = np.value.len;
                const end = str.len + vlen - ilen;
                @memcpy(buffer[i .. i + vlen], np.value);
                @memcpy(buffer[i + vlen .. end], str[i + ilen ..]);
                //print("Replacing {s} with {s}\n", .{ key, np.value });
                //print("Result: {s}\n", .{buffer[0..end]});
                const val = calcMinDisassemblyOld(cache, rules, alloc, longest, buffer[0..end]) +| 1;
                min = @min(min, val);
                n = np.next;
            }
        }
    }

    const e = cache.getOrPut(str) catch unreachable;
    e.key_ptr.* = alloc.dupe(u8, str) catch unreachable;
    e.value_ptr.* = min;
    //print("Min of {s}: {}\n", .{ str, min });
    return min;
}

pub fn part2KindaFast(input: []const u8) usize {
    const start = std.mem.indexOfPos(u8, input, 0, "\r\n\r\n").? + 4;
    const base = input[start..];

    var leftends: usize = 0;
    var rightends: usize = 0;
    var separators: usize = 0;
    // Count the number of molecules instead of using
    // raw string length like an idiot
    var total: usize = 0;
    for (0..base.len) |ci| {
        if (base[ci] >= 'A' and base[ci] <= 'Z') total += 1;
        switch (base[ci]) {
            'Y' => separators += 1,
            'R' => leftends += if (ci < base.len - 1 and base[ci + 1] == 'n') 1 else 0,
            'A' => rightends += if (ci < base.len - 1 and base[ci + 1] == 'r') 1 else 0,
            else => continue,
        }
    }

    // Left and right end characters 'Rn' and 'Ar' are
    // always transformed away together so we can remove
    // their count entirely
    const rawlen = total - rightends - leftends;
    // separator always precedes an extra value, so we get rid of
    // both the separator and the extra value
    const midlen = rawlen - (separators * 2);

    // All other operations are 2 units -> 1 unit, so length of
    // solution steps is always going to be this length

    // Except jk we subtract one because we're starting with len
    // of 1

    return midlen - 1;
}

// Can we make it faster?
pub fn part2(input: []const u8) usize {
    const start = std.mem.indexOfPos(u8, input, 0, "\r\n\r\n").? + 4;
    const base = input[start..];

    // Count the number of molecules instead of using
    // raw string length like an idiot
    var total: usize = 0;
    for (0..base.len) |ci| {
        if (base[ci] >= 'A' and base[ci] <= 'Z') total += 1;
        switch (base[ci]) {
            'Y' => total -= 2,
            'R' => total -= 1,
            //'R' => total -= if (ci < base.len - 1 and base[ci + 1] == 'n') 1 else 0,
            'A' => total -= if (ci < base.len - 1 and base[ci + 1] == 'r') 1 else 0,
            else => continue,
        }
    }

    return total - 1;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 19:\n", .{});
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
