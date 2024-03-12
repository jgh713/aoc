const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day17.txt");
const testdata = "";

test "day17_part1" {
    assert(std.mem.eql(u8, part1("ihgpwlah"), "DDRRRD"));
    assert(std.mem.eql(u8, part1("kglvqrro"), "DDUDRLRRUDRD"));
    assert(std.mem.eql(u8, part1("ulqzkmiv"), "DRURDRUDDLLDLUURRDULRLDUUDDDRR"));
}

const Loc = struct {
    x: u8,
    y: u8,
    hist: []u8,
};

pub fn part1(input: []const u8) []u8 {
    var membuffer: [1000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var queue: [1000]Loc = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    const start = Loc{ .x = 0, .y = 0, .hist = alloc.alloc(u8, 0) catch unreachable };
    queue[0] = start;

    var hashbuffer: [64]u8 = undefined;
    @memcpy(hashbuffer[0..input.len], input);
    const ilen = input.len;

    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) qstart = 0;
        const loc = queue[qstart];
        @memcpy(hashbuffer[ilen .. ilen + loc.hist.len], loc.hist);
        var hash: [16]u8 = undefined;
        std.crypto.hash.Md5.hash(hashbuffer[0 .. ilen + loc.hist.len], &hash, .{});
        for (0..4) |dir| {
            const open = switch (dir) {
                0 => ((hash[0] >> 4) & 0xF) > 0xA,
                1 => (hash[0] & 0xF) > 0xA,
                2 => ((hash[1] >> 4) & 0xF) > 0xA,
                3 => (hash[1] & 0xF) > 0xA,
                else => unreachable,
            };
            if (!open) continue;
            const canmove = switch (dir) {
                0 => loc.y > 0,
                1 => loc.y < 3,
                2 => loc.x > 0,
                3 => loc.x < 3,
                else => unreachable,
            };
            if (!canmove) continue;
            const nx = switch (dir) {
                0 => loc.x,
                1 => loc.x,
                2 => loc.x - 1,
                3 => loc.x + 1,
                else => unreachable,
            };
            const ny = switch (dir) {
                0 => loc.y - 1,
                1 => loc.y + 1,
                2 => loc.y,
                3 => loc.y,
                else => unreachable,
            };
            const newloc = Loc{
                .x = nx,
                .y = ny,
                .hist = alloc.alloc(u8, loc.hist.len + 1) catch unreachable,
            };
            @memcpy(newloc.hist[0..loc.hist.len], loc.hist);
            newloc.hist[loc.hist.len] = switch (dir) {
                0 => 'U',
                1 => 'D',
                2 => 'L',
                3 => 'R',
                else => unreachable,
            };
            if (newloc.x == 3 and newloc.y == 3) {
                return gpa.dupe(u8, newloc.hist) catch unreachable;
            }
            queue[qend] = newloc;
            qend += 1;
            if (qend == queue.len) qend = 0;
            if (qend == qstart) {
                @panic("Queue full");
            }
        }
    }

    unreachable;
}

test "day17_part2" {
    assert(part2("ihgpwlah") == 370);
    assert(part2("kglvqrro") == 492);
    assert(part2("ulqzkmiv") == 830);
}

pub fn part2(input: []const u8) usize {
    const membuffer: []u8 = gpa.alloc(u8, 100_000_000) catch unreachable;
    defer gpa.free(membuffer);
    var alloc_impl = std.heap.FixedBufferAllocator.init(membuffer);
    const alloc = alloc_impl.allocator();

    var queue: [1000]Loc = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    const start = Loc{ .x = 0, .y = 0, .hist = alloc.alloc(u8, 0) catch unreachable };
    queue[0] = start;

    var hashbuffer: [1024]u8 = undefined;
    @memcpy(hashbuffer[0..input.len], input);
    const ilen = input.len;

    var max: usize = 0;
    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) qstart = 0;
        const loc = queue[qstart];
        @memcpy(hashbuffer[ilen .. ilen + loc.hist.len], loc.hist);
        var hash: [16]u8 = undefined;
        std.crypto.hash.Md5.hash(hashbuffer[0 .. ilen + loc.hist.len], &hash, .{});
        for (0..4) |dir| {
            const open = switch (dir) {
                0 => ((hash[0] >> 4) & 0xF) > 0xA,
                1 => (hash[0] & 0xF) > 0xA,
                2 => ((hash[1] >> 4) & 0xF) > 0xA,
                3 => (hash[1] & 0xF) > 0xA,
                else => unreachable,
            };
            if (!open) continue;
            const canmove = switch (dir) {
                0 => loc.y > 0,
                1 => loc.y < 3,
                2 => loc.x > 0,
                3 => loc.x < 3,
                else => unreachable,
            };
            if (!canmove) continue;
            const nx = switch (dir) {
                0 => loc.x,
                1 => loc.x,
                2 => loc.x - 1,
                3 => loc.x + 1,
                else => unreachable,
            };
            const ny = switch (dir) {
                0 => loc.y - 1,
                1 => loc.y + 1,
                2 => loc.y,
                3 => loc.y,
                else => unreachable,
            };
            const newloc = Loc{
                .x = nx,
                .y = ny,
                .hist = alloc.alloc(u8, loc.hist.len + 1) catch unreachable,
            };
            @memcpy(newloc.hist[0..loc.hist.len], loc.hist);
            newloc.hist[loc.hist.len] = switch (dir) {
                0 => 'U',
                1 => 'D',
                2 => 'L',
                3 => 'R',
                else => unreachable,
            };
            if (newloc.x == 3 and newloc.y == 3) {
                max = @max(max, newloc.hist.len);
            } else {
                queue[qend] = newloc;
                qend += 1;
                if (qend == queue.len) qend = 0;
                if (qend == qstart) {
                    @panic("Queue full");
                }
            }
        }
    }

    return max;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 17:\n", .{});
    print("\tPart 1: {s}\n", .{res});
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
