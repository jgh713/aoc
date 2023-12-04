const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");
const testdata = "467..114..\n...*......\n..35..633.\n......#...\n617*......\n.....+.58.\n..592.....\n......755.\n...$.*....\n.664.598..";

test "day3_part1" {
    const result = part1(testdata);
    assert(result == 4361);
}

inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

inline fn gridIndex(x: usize, y: usize, width: usize) usize {
    return y * width + x;
}

fn part1(input: []const u8) usize {
    const gridwidth = indexOf(u8, input, '\n').?;
    const width = gridwidth + 1;
    const gridheight = (input.len / width);
    var sum: usize = 0;
    var indigit: bool = false;
    var current: usize = 0;
    var startx: usize = 0;

    for (input, 0..) |char, i| {
        if (!isDigit(char)) {
            if (!indigit) {
                continue;
            }

            const x = (i - 1) % width;
            const y = (i - 1) / width;

            const minx = @max(startx -| 1, 0);
            const maxx = @min(x + 1, gridwidth);
            const miny = @max(y -| 1, 0);
            const maxy = @min(y + 1, gridheight);

            sum += sumfor: for (miny..maxy + 1) |iy| {
                for (minx..maxx + 1) |ix| {
                    const index = gridIndex(ix, iy, width);
                    const ichar = input[index];
                    if (!isDigit(ichar) and ichar != '.' and ichar != '\n' and ichar != '\r') {
                        break :sumfor current;
                    }
                }
            } else 0;
            indigit = false;
            continue;
        }

        if (!indigit) {
            indigit = true;
            current = input[i] - '0';
            startx = i % width;
        } else {
            current = current * 10 + (input[i] - '0');
        }
    }
    return sum;
}

test "day3_part2" {
    const result = try part2(testdata);
    assert(result == 467835);
}

const symbol = struct {
    count: usize,
    val: usize,
};

fn part2hash(input: []const u8) !usize {
    var gears = std.AutoHashMap(usize, symbol).init(gpa);
    defer gears.deinit();
    const gridwidth = indexOf(u8, input, '\n').?;
    const width = gridwidth + 1;
    const gridheight = (input.len / width);
    var sum: usize = 0;
    var indigit: bool = false;
    var current: usize = 0;
    var startx: usize = 0;

    for (input, 0..) |char, i| {
        if (!isDigit(char)) {
            if (!indigit) {
                continue;
            }

            const x = (i - 1) % width;
            const y = (i - 1) / width;

            const minx = @max(startx -| 1, 0);
            const maxx = @min(x + 1, gridwidth);
            const miny = @max(y -| 1, 0);
            const maxy = @min(y + 1, gridheight);

            for (miny..maxy + 1) |iy| {
                for (minx..maxx + 1) |ix| {
                    const index = gridIndex(ix, iy, width);
                    const ichar = input[index];
                    if (!isDigit(ichar) and ichar != '.' and ichar != '\n' and ichar != '\r') {
                        const v = try gears.getOrPut(index);
                        if (!v.found_existing) {
                            v.value_ptr.* = symbol{ .count = 1, .val = current };
                        } else {
                            var gear = v.value_ptr;
                            gear.count += 1;
                            gear.val *= current;
                        }
                    }
                }
            }
            indigit = false;
            continue;
        }

        if (!indigit) {
            indigit = true;
            current = input[i] - '0';
            startx = i % width;
        } else {
            current = current * 10 + (input[i] - '0');
        }
    }

    var it = gears.valueIterator();
    while (it.next()) |gear| {
        if (gear.count == 2) {
            sum += gear.val;
        }
    }

    return sum;
}

fn part2(input: []const u8) !usize {
    var gears: [20000]symbol = undefined;
    for (&gears) |*gear| {
        gear.count = 0;
        gear.val = 1;
    }
    const gridwidth = indexOf(u8, input, '\n').?;
    const width = gridwidth + 1;
    const gridheight = (input.len / width);
    var sum: usize = 0;
    var indigit: bool = false;
    var current: usize = 0;
    var startx: usize = 0;

    for (input, 0..) |char, i| {
        if (!isDigit(char)) {
            if (!indigit) {
                continue;
            }

            const x = (i - 1) % width;
            const y = (i - 1) / width;

            const minx = @max(startx -| 1, 0);
            const maxx = @min(x + 1, gridwidth);
            const miny = @max(y -| 1, 0);
            const maxy = @min(y + 1, gridheight);

            for (miny..maxy + 1) |iy| {
                for (minx..maxx + 1) |ix| {
                    const index = gridIndex(ix, iy, width);
                    const ichar = input[index];
                    if (!isDigit(ichar) and ichar != '.' and ichar != '\n' and ichar != '\r') {
                        gears[index].count += 1;
                        gears[index].val *= current;
                    }
                }
            }
            indigit = false;
            continue;
        }

        if (!indigit) {
            indigit = true;
            current = input[i] - '0';
            startx = i % width;
        } else {
            current = current * 10 + (input[i] - '0');
        }
    }

    for (0..input.len) |i| {
        if (gears[i].count == 2) {
            sum += gears[i].val;
        }
    }

    return sum;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = try part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took: {}ns\n", .{time1});
    print("Part2 took: {}ns\n", .{time2});
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
