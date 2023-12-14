const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");
const testdata = "???.### 1,1,3\n.??..??...?##. 1,1,3\n?#?#?#?#?#?#?#? 1,3,1,6\n????.#...#... 4,1,1\n????.######..#####. 1,6,5\n?###???????? 3,2,1\n";

test "day12_part1" {
    const res = part1(testdata);
    assert(res == 21);
}

const Step = struct {
    val: u1,
    known: bool,
};

fn calcMatches(linemap: []Step, linelen: u8, valmap: []u4, vals: u4) u32 {
    var matches: u32 = 0;
    var testmap: [32]u1 = undefined;
    var spacemap: u40 = 0;
    const spacecap: u40 = @as(u40, 1) << (@as(u6, vals) * 5);
    var spaces: u8 = linelen - vals + 1;

    for (valmap[0..vals]) |val| {
        spaces -= val;
    }

    steploop: while (spacemap < spacecap) : (spacemap += 1) {
        var spacecount: u16 = 0;
        for (0..vals) |i| {
            const width: u8 = @intCast((spacemap >> @intCast(i * 5)) & 0b11111);
            spacecount += width;
        }
        if (spacecount > spaces) continue;

        var step: u8 = 0;
        for (0..vals) |i| {
            var width: u5 = @intCast((spacemap >> @intCast(i * 5)) & 0b11111);
            if (i != 0) {
                width += 1;
            }
            for (0..width) |j| {
                _ = j;
                testmap[step] = 0;
                step += 1;
            }
            for (0..valmap[i]) |j| {
                _ = j;
                testmap[step] = 1;
                step += 1;
            }
        }
        for (step..linelen) |i| {
            testmap[i] = 0;
        }
        for (0..linelen) |i| {
            if (linemap[i].known and linemap[i].val != testmap[i]) {
                continue :steploop;
            }
        }
        matches += 1;
    }

    return matches;
}

// fn calcMatches( linemap: []Step, linelen: u8, valmap: []u4, vals: u4 ) u32 {
//     var matches: u32 = 0;
//     var linemapCopy: [32]Step = undefined;
//     for (valmap) |val| {
//         for (linemap) |

fn part1(input: []const u8) u32 {
    var linemap: [32]Step = undefined;
    var linelen: u8 = 0;
    var current: u4 = 0;
    var valmap: [8]u4 = undefined;
    var vals: u4 = 0;
    var total: u32 = 0;
    var line: u16 = 0;

    for (input) |c| {
        switch (c) {
            '#' => {
                linemap[linelen] = Step{ .val = 1, .known = true };
                linelen += 1;
            },
            '.' => {
                linemap[linelen] = Step{ .val = 0, .known = true };
                linelen += 1;
            },
            '?' => {
                linemap[linelen] = Step{ .val = 0, .known = false };
                linelen += 1;
            },
            '0'...'9' => {
                current = @intCast((current * 10) + (c - '0'));
            },
            ',' => {
                valmap[vals] = current;
                vals += 1;
                current = 0;
            },
            '\n' => {
                valmap[vals] = current;
                vals += 1;
                current = 0;
                total += calcMatches(&linemap, linelen, &valmap, vals);
                line += 1;
                print("{} lines processed.\n", .{line});
                linelen = 0;
                vals = 0;
            },
            else => {},
        }
    }

    return total;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    print("Part 1: {}\n", .{res});
    print("Part1 took {}ns\n", .{time1});
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
