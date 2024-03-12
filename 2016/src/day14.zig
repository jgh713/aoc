const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day14.txt");
const testdata = "abc";

test "day14_part1" {
    const res = part1(testdata);
    assert(res == 22728);
}

pub fn md5Thread(input: []const u8, hashblock: []u8, start: usize, end: usize, extraloop: bool) void {
    var strbuffer: [32]u8 = undefined;
    @memcpy(strbuffer[0..input.len], input);
    const inlen = input.len;
    const writebuffer = strbuffer[input.len..];

    for (start..end) |id| {
        const write = std.fmt.bufPrintIntToSlice(writebuffer, id, 10, .lower, .{});
        const written = strbuffer[0 .. inlen + write.len];
        var hash: [16]u8 = undefined;
        var hash4: [33]u8 = undefined;
        const offset = id * 33;
        std.crypto.hash.Md5.hash(written, &hash, .{});
        if (extraloop) {
            for (0..2016) |_| {
                var newhash: [32]u8 = undefined;
                for (hash[0..16], 0..) |hv, hi| {
                    const v1: u8 = hv >> 4;
                    const v2: u8 = hv & 0xF;
                    newhash[hi * 2] = if (v1 < 10) v1 + '0' else v1 + 'a' - 10;
                    newhash[hi * 2 + 1] = if (v2 < 10) v2 + '0' else v2 + 'a' - 10;
                }
                std.crypto.hash.Md5.hash(&newhash, &hash, .{});
            }
        }
        for (hash, 0..) |hv, hi| {
            const v1: u8 = hv >> 4;
            const v2: u8 = hv & 0xF;
            hash4[hi * 2] = v1;
            hash4[hi * 2 + 1] = v2;
        }
        hash4[32] = std.math.maxInt(u8);
        @memcpy(hashblock[offset .. offset + 33], &hash4);
        //print("Hashed {s}\n", .{written});
    }
    //print("Thread {} done\n", .{std.Thread.getCurrentId()});
}

pub fn md5Thread2(hashblock: []u8, queue: anytype, mutex: *std.Thread.Mutex, start: usize, end: usize) void {
    var hits: [100000]usize = undefined;
    var hitid: usize = 0;

    for (start..end) |id| {
        const offset = id * 33;
        const hash = hashblock[offset .. offset + 32];
        infor: for (0..30) |hid| {
            if (hash[hid] == hash[hid + 1] and hash[hid] == hash[hid + 2]) {
                const hstart = (id + 1) * 33;
                const hend = hstart + (1000 * 33);
                const buffer: [5]u8 = .{ hash[hid], hash[hid], hash[hid], hash[hid], hash[hid] };
                const index = std.mem.indexOf(u8, hashblock[hstart..hend], &buffer);
                if (index != null) {
                    hits[hitid] = id;
                    hitid += 1;
                }
                break :infor;
            }
        }
    }

    mutex.lock();
    for (hits[0..hitid]) |id| {
        queue.add(id) catch unreachable;
    }
    mutex.unlock();
}

pub fn sortFn(_: void, a: usize, b: usize) std.math.Order {
    return std.math.order(a, b);
}

pub fn part1(input: []const u8) usize {
    const threadcount = 32;

    //const hashcount = 1_000_000;
    const hashcount = 40_000;
    const hashblock: []u8 = gpa.alloc(u8, hashcount * 33) catch unreachable;
    const blocksize = hashcount / threadcount;

    var threads: [threadcount]std.Thread = undefined;

    for (0..threadcount) |tid| {
        const start = tid * blocksize;
        const end = if (tid == threadcount - 1) hashcount else start + blocksize;
        threads[tid] = std.Thread.spawn(.{}, md5Thread, .{ input, hashblock, start, end, false }) catch unreachable;
    }

    for (0..threadcount) |tid| {
        threads[tid].join();
    }

    var queue = std.PriorityQueue(usize, void, sortFn).init(gpa, {});
    var mutex = std.Thread.Mutex{};

    for (0..threadcount) |tid| {
        const start = tid * blocksize;
        const end = if (tid == threadcount - 1) hashcount - 1000 else start + blocksize;
        threads[tid] = std.Thread.spawn(.{}, md5Thread2, .{ hashblock, &queue, &mutex, start, end }) catch unreachable;
    }

    for (0..threadcount) |tid| {
        threads[tid].join();
    }

    //print("Found: {}\n", .{queue.count()});

    //for (0..63) |i| {
    //    print("Key {} at {}\n", .{ i + 1, queue.remove() });
    //}
    for (0..63) |_| {
        _ = queue.remove();
    }

    const res = queue.remove();

    //print("Result: {}\n", .{res});

    return res;
}

test "day14_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    const threadcount = 32;

    //const hashcount = 1_000_000;
    const hashcount = 40_000;
    const hashblock: []u8 = gpa.alloc(u8, hashcount * 33) catch unreachable;
    const blocksize = hashcount / threadcount;

    var threads: [threadcount]std.Thread = undefined;

    for (0..threadcount) |tid| {
        const start = tid * blocksize;
        const end = if (tid == threadcount - 1) hashcount else start + blocksize;
        threads[tid] = std.Thread.spawn(.{}, md5Thread, .{ input, hashblock, start, end, true }) catch unreachable;
    }

    for (0..threadcount) |tid| {
        threads[tid].join();
    }

    var queue = std.PriorityQueue(usize, void, sortFn).init(gpa, {});
    var mutex = std.Thread.Mutex{};

    for (0..threadcount) |tid| {
        const start = tid * blocksize;
        const end = if (tid == threadcount - 1) hashcount - 1000 else start + blocksize;
        threads[tid] = std.Thread.spawn(.{}, md5Thread2, .{ hashblock, &queue, &mutex, start, end }) catch unreachable;
    }

    for (0..threadcount) |tid| {
        threads[tid].join();
    }

    //print("Found: {}\n", .{queue.count()});

    //for (0..63) |i| {
    //    print("Key {} at {}\n", .{ i + 1, queue.remove() });
    //}
    for (0..63) |_| {
        _ = queue.remove();
    }

    const res = queue.remove();

    //print("Result: {}\n", .{res});

    return res;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 14:\n", .{});
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
