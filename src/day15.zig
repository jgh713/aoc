const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day15.txt");
const testdata = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";

test "day15_part1" {
    const hashres = part1("HASH");
    assert(hashres == 52);
    const res = part1(testdata);
    assert(res == 1320);
}

fn part1(input: []const u8) usize {
    var total: usize = 0;
    var current: usize = 0;
    for (input) |c| {
        if (c == ',') {
            total += current;
            current = 0;
            continue;
        }

        current += c;
        current *= 17;
        current %= 256;
    }
    total += current;

    return total;
}

test "day15_part2" {
    const res = part2(testdata);
    assert(res == 145);
}

const Lens = struct {
    label: [8]u8,
    focal: u4,
};

const Box = struct {
    lenses: [10]Lens,
    size: u4,
};

fn part2(input: []const u8) usize {
    var total: usize = 0;
    var current: usize = 0;
    var boxes: [256]Box = undefined;
    var label: [8]u8 = .{0} ** 8;
    var l: u4 = 0;
    boxes = std.mem.zeroes(@TypeOf(boxes));

    for (input, 0..) |c, i| {
        switch (c) {
            ',' => {
                current = 0;
                label = .{0} ** 8;
                l = 0;
                continue;
            },
            '=' => {
                const focal: u4 = @intCast(input[i + 1] - '0');
                const box = &boxes[current];
                const lens: u4 = inner: for (0..box.size) |b| {
                    if (std.mem.eql(u8, box.lenses[b].label[0..8], label[0..8])) {
                        break :inner @intCast(b);
                    }
                } else {
                    box.size += 1;
                    break :inner box.size - 1;
                };
                box.lenses[lens] = Lens{ .label = label, .focal = focal };
            },
            '-' => {
                const box = &boxes[current];
                const lens: ?u4 = for (0..box.size) |b| {
                    if (std.mem.eql(u8, box.lenses[b].label[0..8], label[0..8])) {
                        break @intCast(b);
                    }
                } else null;
                if (lens) |li| {
                    box.size -= 1;
                    for (li..box.size) |b| {
                        box.lenses[b] = box.lenses[b + 1];
                    }
                }
            },
            else => {
                label[l] = c;
                l += 1;
                current += c;
                current *= 17;
                current %= 256;
            },
        }
    }

    for (boxes, 1..) |box, bi| {
        for (box.lenses[0..box.size], 1..) |lens, li| {
            total += bi * li * lens.focal;
        }
    }

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time});
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
