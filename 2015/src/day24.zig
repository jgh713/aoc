const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day24.txt");
const testdata = "1\r\n2\r\n3\r\n4\r\n5\r\n7\r\n8\r\n9\r\n10\r\n11";

test "day24_part1" {
    const res = part1(testdata);
    print("res = {}\n", .{res});
    assert(res == 99);
}

const RunData = struct {
    packages: []usize,
    min: usize,
    max: usize,
    target: usize,
    lock: *std.Thread.Mutex,
    minq: *usize,
    mincount: *usize,
};

fn runOptions(info: RunData) void {
    var mask: usize = info.min;
    const packages = info.packages;
    var min: usize = std.math.maxInt(usize);
    var mincount: usize = std.math.maxInt(usize);
    while (mask < info.max) : (mask += 1) {
        var sum: usize = 0;
        var q: usize = 1;
        for (packages, 0..) |pack, pi| {
            if (((mask >> @intCast(pi)) & 1) == 1) {
                sum += pack;
                q *= pack;
            }
        }
        const count = @popCount(mask);
        if (sum == info.target) {
            //print("mask = {}, sum = {}, count = {}\n", .{ mask, sum, count });
            if (count < mincount) {
                mincount = count;
                min = q;
            } else if (count == mincount and sum < q) {
                min = q;
            }
        }
    }

    info.lock.lock();
    if (mincount < info.mincount.*) {
        info.minq.* = min;
        info.mincount.* = mincount;
    } else if (mincount == info.mincount.* and min < info.minq.*) {
        info.minq.* = min;
        info.mincount.* = mincount;
    }
    info.lock.unlock();
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var package_buffer: [30]usize = undefined;
    var pi: usize = 0;
    var total: usize = 0;

    while (lines.next()) |line| {
        const weight = parseInt(usize, line, 10) catch unreachable;
        package_buffer[pi] = weight;
        pi += 1;
        total += weight;
    }

    // Input is pre-sorted, no need to sort it again
    const packages = package_buffer[0..pi];
    const group_weight = @divExact(total, 3);

    const threads = 32;
    var threadmap: [threads]std.Thread = undefined;

    const max = @as(usize, 1) << @intCast(packages.len);
    const block_size = max / threads;

    var lock = std.Thread.Mutex{};
    var minq: usize = std.math.maxInt(usize);
    var mincount: usize = std.math.maxInt(usize);

    for (0..threads) |tid| {
        const tmin = tid * block_size;
        const tmax = if (tid + 1 == threads) max else (tid + 1) * block_size;
        const info = RunData{
            .packages = packages,
            .min = tmin,
            .max = tmax,
            .target = group_weight,
            .lock = &lock,
            .minq = &minq,
            .mincount = &mincount,
        };
        threadmap[tid] = std.Thread.spawn(.{}, runOptions, .{info}) catch unreachable;
    }

    for (threadmap) |thread| {
        thread.join();
    }

    return minq;
}

test "day24_part2" {
    const res = part2(testdata);
    assert(res == 44);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var package_buffer: [30]usize = undefined;
    var pi: usize = 0;
    var total: usize = 0;

    while (lines.next()) |line| {
        const weight = parseInt(usize, line, 10) catch unreachable;
        package_buffer[pi] = weight;
        pi += 1;
        total += weight;
    }

    // Input is pre-sorted, no need to sort it again
    const packages = package_buffer[0..pi];
    const group_weight = @divExact(total, 4);

    const threads = 32;
    var threadmap: [threads]std.Thread = undefined;

    const max = @as(usize, 1) << @intCast(packages.len);
    const block_size = max / threads;

    var lock = std.Thread.Mutex{};
    var minq: usize = std.math.maxInt(usize);
    var mincount: usize = std.math.maxInt(usize);

    for (0..threads) |tid| {
        const tmin = tid * block_size;
        const tmax = if (tid + 1 == threads) max else (tid + 1) * block_size;
        const info = RunData{
            .packages = packages,
            .min = tmin,
            .max = tmax,
            .target = group_weight,
            .lock = &lock,
            .minq = &minq,
            .mincount = &mincount,
        };
        threadmap[tid] = std.Thread.spawn(.{}, runOptions, .{info}) catch unreachable;
    }

    for (threadmap) |thread| {
        thread.join();
    }

    return minq;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 24:\n", .{});
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
