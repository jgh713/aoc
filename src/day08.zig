const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const testdata = "LLR\n\nAAA = (BBB, BBB)\nBBB = (AAA, ZZZ)\nZZZ = (ZZZ, ZZZ)";

test "day8_part1" {
    const res = part1(testdata);
    assert(res == 6);
}

fn part1(input: []const u8) u32 {
    var step: u16 = 0;
    var steps: [310]u1 = undefined;

    while (input[step] != '\n') {
        step += 1;
    }

    if (input[step - 1] == '\r') {
        step -= 1;
    }

    for (input[0..step], 0..) |c, i| {
        steps[i] = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
    }

    var current: u16 = 0;
    var map: [65535][2]u16 = undefined;
    var this: u16 = 0;
    var left: u16 = 0;

    for (input[step + 1 ..]) |c| {
        switch (c) {
            'A'...'Z' => {
                current = (current << 5) | (c - 'A');
            },
            '(' => {
                this = current;
                current = 0;
            },
            ',' => {
                left = current;
                current = 0;
            },
            ')' => {
                map[this][0] = left;
                map[this][1] = current;
                current = 0;
            },
            else => continue,
        }
    }

    var loc: u16 = 0;
    var count: u32 = 0;
    const dest = (25 << 10) | (25 << 5) | 25;
    while (loc != dest) {
        loc = map[loc][steps[count % step]];
        count += 1;
    }

    return count;
}

const Loop = struct {
    offset: u64,
    length: u64,
};

inline fn getLoop(start: u16, map: [65535][2]u16, step: u16, steps: [310]u1) Loop {
    var offset: u64 = 0;
    var loc: u16 = start;
    var count: u32 = 0;
    var hit: bool = false;
    while (true) {
        loc = map[loc][steps[(count % step)]];
        count += 1;
        // const c1: u8 = @intCast((loc >> 10) & 0b11111);
        // const c2: u8 = @intCast((loc >> 5) & 0b11111);
        // const c3: u8 = @intCast(loc & 0b11111);
        // print("Stepped to loc {c}{c}{c}.\n", .{ c1 + 'A', c2 + 'A', c3 + 'A' });
        if (loc & 0b11111 == 25) {
            if (hit) {
                return Loop{ .offset = offset, .length = count - offset };
            } else {
                offset = count;
                hit = true;
            }
        }
    }
}

fn gcd(ai: u64, bi: u64) u64 {
    var a = ai;
    var b = bi;
    while (b != 0) {
        const t = b;
        b = a % b;
        a = t;
    }
    return a;
}

fn lcm(a: u64, b: u64) u64 {
    return (a / gcd(a, b)) * b;
}

inline fn mergeLoops(a: Loop, b: Loop) Loop {
    var aloc = a.offset;
    var bloc = b.offset;
    var offset: u64 = 0;
    while (true) {
        if (aloc == bloc) {
            offset = aloc;
            return Loop{ .offset = offset, .length = lcm(a.length, b.length) };
        }
        if (aloc < bloc) {
            aloc += a.length;
        } else {
            bloc += b.length;
        }
    }
}

inline fn mergeLoopsNoRecurse(a: Loop, b: Loop) u64 {
    var aloc = a.offset;
    var bloc = b.offset;
    while (true) {
        if (aloc == bloc) {
            return aloc;
        }
        if (aloc < bloc) {
            aloc += a.length;
        } else {
            bloc += b.length;
        }
    }
}

fn part2robust(input: []const u8) u64 {
    var timer = std.time.Timer.start() catch unreachable;
    var step: u16 = 0;
    var steps: [310]u1 = undefined;

    while (input[step] != '\n') {
        step += 1;
    }

    if (input[step - 1] == '\r') {
        step -= 1;
    }

    for (input[0..step], 0..) |c, i| {
        steps[i] = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
    }

    var current: u16 = 0;
    var map: [65535][2]u16 = undefined;
    var this: u16 = 0;
    var left: u16 = 0;
    var node: u4 = 0;
    var nodes: [10]u16 = undefined;

    for (input[step + 1 ..]) |c| {
        switch (c) {
            'A'...'Z' => {
                current = (current << 5) | (c - 'A');
            },
            '(' => {
                this = current;
                current = 0;
            },
            ',' => {
                left = current;
                current = 0;
            },
            ')' => {
                map[this][0] = left;
                map[this][1] = current;
                current = 0;
                if (this & 0b11111 == 0) {
                    nodes[node] = this;
                    node += 1;
                }
            },
            else => continue,
        }
    }

    const time = timer.lap();

    var loops: [10]Loop = undefined;
    for (0..node) |i| {
        loops[i] = getLoop(nodes[i], map, step, steps);
        print("Loop {}: offset {}, length {}\n", .{ i, loops[i].offset, loops[i].length });
    }

    const time2 = timer.lap();

    const merge1 = mergeLoops(loops[0], loops[1]);
    const merge2 = mergeLoops(loops[2], loops[3]);
    const merge3 = mergeLoops(loops[4], loops[5]);
    const time3 = timer.lap();
    const merge4 = mergeLoops(merge1, merge2);
    const time4 = timer.lap();
    const merge5 = mergeLoopsNoRecurse(merge3, merge4);
    const time5 = timer.lap();

    print("Time: {}ns\n", .{time});
    print("Time2: {}ns\n", .{time2});
    print("Time3: {}ns\n", .{time3});
    print("Time4: {}ns\n", .{time4});
    print("Time5: {}ns\n", .{time5});

    return merge5;
}

fn getStepsToZ(start: u16, map: [65535][2]u16, step: u16, steps: [310]u1) u32 {
    var loc: u16 = start;
    var count: u32 = 0;
    while (loc & 0b11111 != 25) {
        loc = map[loc][steps[(count % step)]];
        count += 1;
    }
    return count;
}

fn part2(input: []const u8) u64 {
    var step: u16 = 0;
    var steps: [310]u1 = undefined;

    while (input[step] != '\n') {
        step += 1;
    }

    if (input[step - 1] == '\r') {
        step -= 1;
    }

    for (input[0..step], 0..) |c, i| {
        steps[i] = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
    }

    var current: u16 = 0;
    var map: [65535][2]u16 = undefined;
    var this: u16 = 0;
    var left: u16 = 0;
    var node: u4 = 0;
    var nodes: [10]u16 = undefined;

    for (input[step + 1 ..]) |c| {
        switch (c) {
            'A'...'Z' => {
                current = (current << 5) | (c - 'A');
            },
            '(' => {
                this = current;
                current = 0;
            },
            ',' => {
                left = current;
                current = 0;
            },
            ')' => {
                map[this][0] = left;
                map[this][1] = current;
                current = 0;
                if (this & 0b11111 == 0) {
                    nodes[node] = this;
                    node += 1;
                }
            },
            else => continue,
        }
    }

    var lens: [10]u32 = undefined;

    for (0..node) |i| {
        lens[i] = getStepsToZ(nodes[i], map, step, steps);
    }

    const merge1 = lcm(lens[0], lens[1]);
    const merge2 = lcm(lens[2], lens[3]);
    const merge3 = lcm(lens[4], lens[5]);
    const merge4 = lcm(merge1, merge2);
    const merge5 = lcm(merge3, merge4);

    return merge5;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time1});
    print("Part2 took {}ns\n", .{time2});
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
