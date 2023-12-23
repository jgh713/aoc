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
const cloudzytest = "???#?????? 4,4\n??..#??#??.???? 5,1\n?.?.???????##????? 1,2,8\n.#????.????#?????? 2,1,1,2,1,1\n??????#????...#?... 9,1\n.???.?????. 3,1,1\n??..?..???. 1,1\n??.??.#..?..??###?? 2,1,1,1,6\n????.???## 3,1,3\n???#?###?#?#.??? 1,1,7,1,1\n??.#?#???#.????????? 7,6\n???#?#.??##?????? 3,1,6\n????##???#????#?#?? 6,8,1\n??#????#?? 5,1\n?##?#??#??????##?.#? 10,5,2\n..???..?##???..?? 1,5,1\n.?.#???.??? 3,2\n?????#?#.???.?.?###? 1,4,1,5\n?##.??#..?????????? 3,3,3,1,1\n?#???.#?????##??? 2,1,2,4,1";

test "day12_part1" {
    const res = part1(testdata);
    assert(res == 21);
}

const Step = struct {
    val: u1,
    known: bool,
};

fn calcMatchesOld(linemap: []Step, linelen: u8, valmap: []u4, vals: u4) u32 {
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

fn part1slow(input: []const u8) u32 {
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
                total += calcMatchesOld(&linemap, linelen, &valmap, vals);
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

fn part1(input: []const u8) u128 {
    var line: [150]Marker = undefined;
    var linelen: u8 = 0;
    var total: u128 = 0;
    var blocks: [40]u4 = undefined;
    var blocklen: u8 = 0;
    var current: u4 = 0;

    for (input) |c| {
        switch (c) {
            '#' => {
                line[linelen] = Marker.yes;
                linelen += 1;
            },
            '.' => {
                line[linelen] = Marker.no;
                linelen += 1;
            },
            '?' => {
                line[linelen] = Marker.unknown;
                linelen += 1;
            },
            '0'...'9' => {
                current = @intCast((current * 10) + (c - '0'));
            },
            ',' => {
                blocks[blocklen] = current;
                blocklen += 1;
                current = 0;
            },
            '\n' => {
                blocks[blocklen] = current;
                blocklen += 1;

                total += calcMatchesFast(line[0..linelen], blocks[0..blocklen]);
                linelen = 0;
                blocklen = 0;
                current = 0;
            },
            else => {},
        }
    }
    return total;
}

test "day12_part2" {
    const res = part2(testdata);
    assert(res == 525152);
}

const Marker = enum { yes, no, unknown };

fn walkLine(linemap: []Marker, blockmap: []u4, fitmap: [16][150]bool, walkmap: *[40][150]?usize, offset: u8, block: u8, lastyes: u8) usize {
    if (offset > linemap.len) return 0;
    const nextyes = for (offset..linemap.len) |i| {
        if (linemap[i] == Marker.yes) {
            break i;
        }
    } else linemap.len;
    const width: u4 = blockmap[block];

    var total: usize = 0;

    for (offset..nextyes + 1) |pos| {
        if (!fitmap[width][pos]) continue;

        const nextblock: u8 = block + 1;
        if (nextblock == blockmap.len) {
            const end = pos + width;
            if (end >= lastyes) {
                total += 1;
            }
        } else {
            const nextoffset: u8 = @intCast(pos + width + 1);

            if (walkmap[nextblock][nextoffset]) |walkval| {
                total += walkval;
            } else {
                const walkval = walkLine(linemap, blockmap, fitmap, walkmap, nextoffset, nextblock, lastyes);
                walkmap[nextblock][nextoffset] = walkval;
                total += walkval;
            }
        }
    }

    return total;
}

fn calcMatchesFast(linemap: []Marker, blockmap: []u4) u64 {
    var fitmap: [16][150]bool = .{.{false} ** 150} ** 16;
    var walkmap: [40][150]?usize = .{.{null} ** 150} ** 40;

    var lastyes: u8 = 0;
    for (0..linemap.len) |offset| {
        if (linemap[offset] == Marker.yes) {
            lastyes = @intCast(offset);
        }
    }

    for (0..linemap.len) |offset| {
        if (offset != 0 and linemap[offset - 1] == Marker.yes) continue;

        for (0..15) |width| {
            if (offset + width > linemap.len) break;
            if ((offset + width) < linemap.len and linemap[offset + width] == Marker.no) break;
            const next = offset + width + 1;
            if (next == linemap.len or linemap[next] == Marker.no or linemap[next] == Marker.unknown) {
                fitmap[width + 1][offset] = true;
            }
            if (next == linemap.len) break;
        }
    }

    return walkLine(linemap, blockmap, fitmap, &walkmap, 0, 0, lastyes);
}

fn part2(input: []const u8) u128 {
    var line: [150]Marker = undefined;
    var linelen: u8 = 0;
    var total: u128 = 0;
    var blocks: [40]u4 = undefined;
    var blocklen: u8 = 0;
    var current: u4 = 0;

    for (input) |c| {
        switch (c) {
            '#' => {
                line[linelen] = Marker.yes;
                linelen += 1;
            },
            '.' => {
                line[linelen] = Marker.no;
                linelen += 1;
            },
            '?' => {
                line[linelen] = Marker.unknown;
                linelen += 1;
            },
            ' ' => {
                var i: u8 = linelen;
                for (0..4) |_| {
                    line[i] = Marker.unknown;
                    i += 1;
                    for (0..linelen) |j| {
                        line[i] = line[j];
                        i += 1;
                    }
                }
                linelen = i;
            },
            '0'...'9' => {
                current = @intCast((current * 10) + (c - '0'));
            },
            ',' => {
                blocks[blocklen] = current;
                blocklen += 1;
                current = 0;
            },
            '\n' => {
                blocks[blocklen] = current;
                blocklen += 1;
                var i: u8 = blocklen;
                for (0..4) |_| {
                    for (0..blocklen) |j| {
                        blocks[i] = blocks[j];
                        i += 1;
                    }
                }
                blocklen = i;

                total += calcMatchesFast(line[0..linelen], blocks[0..blocklen]);
                linelen = 0;
                blocklen = 0;
                current = 0;
            },
            else => {},
        }
    }
    return total;
}

fn generate_test_cases(len: u4) !void {
    const cap = std.math.pow(u32, 3, len);
    var i: u32 = 0;
    var buffer: [1000]u8 = undefined;
    const cwd = std.fs.cwd();
    const outfile = try cwd.createFile("day12_examples.txt", .{ .truncate = true });
    defer outfile.close();
    var linemap: [32]Marker = undefined;
    var line: u8 = 0;
    var blockmap: [8]u4 = undefined;
    var block: u4 = 0;

    for (0..3) |bi| {
        blockmap[bi] = 1;
        block += 1;
    }

    while (i < cap) : (i += 1) {
        buffer = std.mem.zeroes([1000]u8);
        var map: u32 = i;
        for (0..len) |j| {
            _ = j;
            const this = map % 3;
            map /= 3;
            switch (this) {
                0 => {
                    _ = try outfile.write("?");
                    linemap[line] = Marker.unknown;
                    line += 1;
                },
                1 => {
                    _ = try outfile.write(".");
                    linemap[line] = Marker.no;
                    line += 1;
                },
                2 => {
                    _ = try outfile.write("#");
                    linemap[line] = Marker.yes;
                    line += 1;
                },
                else => unreachable,
            }
        }
        _ = try outfile.write(" 1,1,1=");
        const res = calcMatchesFast(linemap[0..line], blockmap[0..block]);
        _ = try outfile.write(try bufPrint(&buffer, "{}\n", .{res}));
        const end = std.mem.indexOfScalar(u8, &buffer, @as(u8, 0)) orelse unreachable;
        _ = end;
        line = 0;
    }
}

pub fn main() !void {
    //try generate_test_cases(7);
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time1 = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part 1: {}\n", .{res});
    print("Part 2: {}\n", .{res2});
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
const bufPrint = std.fmt.bufPrint;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
