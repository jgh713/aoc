const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day13.txt");
const testdata = "";

test "day13_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

fn posValid(num: usize, pos: [2]usize) bool {
    const x = pos[0];
    const y = pos[1];
    const val = x * x + 3 * x + 2 * x * y + y + y * y + num;
    const count = @popCount(val);
    return count % 2 == 0;
}

pub fn part1(input: []const u8) usize {
    const num = parseInt(usize, input, 10) catch unreachable;
    var membuffer: [6000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var queue: [500][2]usize = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    var map = Map([2]usize, void).init(alloc);

    map.put(.{ 1, 1 }, {}) catch unreachable;
    queue[0] = .{ 1, 1 };

    var steps: usize = 1;
    var nextstep: usize = 1;
    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) qstart = 0;
        if (qstart == nextstep) {
            steps += 1;
            nextstep = qend;
        }

        const pos = queue[qstart];
        for ([_][2]usize{ .{ pos[0] + 1, pos[1] }, .{ pos[0], pos[1] + 1 }, .{ pos[0] -| 1, pos[1] }, .{ pos[0], pos[1] -| 1 } }) |newpos| {
            if (newpos[0] == 31 and newpos[1] == 39) {
                return steps;
            }
            const e = map.getOrPut(newpos) catch unreachable;
            if (!e.found_existing) {
                if (posValid(num, newpos)) {
                    queue[qend] = newpos;
                    qend += 1;
                    if (qend == queue.len) qend = 0;
                }
            }
        }
    }

    unreachable;
}

test "day13_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    const num = parseInt(usize, input, 10) catch unreachable;
    var membuffer: [6000000]u8 = undefined;
    var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    const alloc = alloc_impl.allocator();

    var queue: [500][2]usize = undefined;
    var qstart: usize = 0;
    var qend: usize = 1;

    var map = Map([2]usize, void).init(alloc);

    map.put(.{ 1, 1 }, {}) catch unreachable;
    queue[0] = .{ 1, 1 };

    var steps: usize = 0;
    var nextstep: usize = 1;
    var count: usize = 0;
    while (qstart != qend) : (qstart += 1) {
        if (qstart == queue.len) qstart = 0;
        if (qstart == nextstep) {
            steps += 1;
            nextstep = qend;
        }
        count += 1;
        if (steps == 50) continue;
        if (steps > 50) break;

        const pos = queue[qstart];
        for ([_][2]usize{ .{ pos[0] + 1, pos[1] }, .{ pos[0], pos[1] + 1 }, .{ pos[0] -| 1, pos[1] }, .{ pos[0], pos[1] -| 1 } }) |newpos| {
            const e = map.getOrPut(newpos) catch unreachable;
            if (!e.found_existing) {
                if (posValid(num, newpos)) {
                    queue[qend] = newpos;
                    qend += 1;
                    if (qend == queue.len) qend = 0;
                    if (qend == qstart) unreachable;
                }
            }
        }
    }

    return count;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 13:\n", .{});
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
