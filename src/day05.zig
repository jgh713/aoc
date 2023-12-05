const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const itype = u64;

const data = @embedFile("data/day05.txt");
const testdata = "seeds: 79 14 55 13\n\nseed-to-soil map:\n50 98 2\n52 50 48\n\nsoil-to-fertilizer map:\n0 15 37\n37 52 2\n39 0 15\n\nfertilizer-to-water map:\n49 53 8\n0 11 42\n42 0 7\n57 7 4\n\nwater-to-light map:\n88 18 7\n18 25 70\n\nlight-to-temperature map:\n45 77 23\n81 45 19\n68 64 13\n\ntemperature-to-humidity map:\n0 69 1\n1 0 69\n\nhumidity-to-location map:\n60 56 37\n56 93 4\n";

test "day5_test1" {
    const res = part1(testdata);
    assert(res == 35);
}

const Seed = struct {
    value: itype = 0,
    step: u8 = 0,
};

inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn part1(input: []const u8) itype {
    var seed: u8 = 0;
    var seeds = [_]Seed{.{ .value = 0, .step = 0 }} ** 20;
    var step: i16 = -1;
    var indigit: bool = false;
    var current: itype = 0;
    var map = [_]itype{0} ** 3;
    var mapi: u8 = 0;

    for (input) |c| {
        if (c == ':') {
            step += 1;
            continue;
        }

        if (isDigit(c)) {
            indigit = true;
            current = current * 10 + (c - '0');
            continue;
        } else if (indigit) {
            indigit = false;
            if (step == 0) {
                seeds[seed].value = current;
                seed += 1;
                current = 0;
            } else {
                map[mapi] = current;
                mapi += 1;
                current = 0;
            }
        }

        if (c == '\n') {
            if (mapi == 3) {
                const dest = map[0];
                const min = map[1];
                const max = map[1] + map[2] - 1;
                for (seeds[0..seed]) |*s| {
                    if (s.value >= min and s.value <= max and s.step < step) {
                        s.step = @intCast(step);
                        s.value = dest + (s.value - min);
                    }
                }
            }
            mapi = 0;
            continue;
        }
    }

    var lowest = seeds[0].value;
    for (seeds[0..seed]) |s| {
        if (s.value < lowest) {
            lowest = s.value;
        }
    }
    return lowest;
}

test "day5_part2" {
    const res = part2(testdata);
    assert(res == 46);
}

const Range = struct {
    min: itype = 0,
    max: itype = 0,
};

const MapRange = struct {
    dest: itype = 0,
    min: itype = 0,
    max: itype = 0,
};

inline fn compSeed(s: itype, maps: [10][100]MapRange, mapcounts: [10]u16) itype {
    var value = s;
    for (0..10) |i| {
        const mapid = mapcounts[i];
        for (maps[i][0..mapid]) |m| {
            if (value >= m.min and value <= m.max) {
                value = m.dest + (value - m.min);
                break;
            }
        }
    }
    return value;
}

fn part2slowbruteforce(input: []const u8) itype {
    var seed: u8 = 0;
    var seeds: [20]Range = undefined;
    var step: i16 = -1;
    var indigit: bool = false;
    var current: itype = 0;
    var map = [_]itype{0} ** 3;
    var mapi: u8 = 0;
    var mapcounts = [_]u16{0} ** 10;
    var maps: [10][100]MapRange = undefined;
    var hold: itype = 0;

    for (input) |c| {
        if (c == ':') {
            step += 1;
            continue;
        }

        if (isDigit(c)) {
            indigit = true;
            current = current * 10 + (c - '0');
            continue;
        } else if (indigit) {
            indigit = false;
            if (step == 0) {
                if (hold == 0) {
                    hold = current;
                    current = 0;
                } else {
                    seeds[seed] = Range{ .min = hold, .max = hold + current };
                    seed += 1;
                    current = 0;
                    hold = 0;
                }
            } else {
                map[mapi] = current;
                mapi += 1;
                current = 0;
            }
        }

        if (c == '\n') {
            if (mapi == 3) {
                const istep: usize = @intCast(step);
                const mapid = mapcounts[istep];
                maps[istep][mapid] = MapRange{ .dest = map[0], .min = map[1], .max = map[1] + map[2] - 1 };
                mapcounts[istep] += 1;
            }
            mapi = 0;
            continue;
        }
    }

    var lowest: itype = std.math.maxInt(itype);
    var i: itype = 0;
    var total: itype = 0;
    for (seeds[0..seed]) |range| {
        total += range.max - range.min;
    }
    print("Total: {}\n", .{total});
    const stepsize = total / 100;
    for (seeds[0..seed]) |range| {
        for (range.min..range.max) |s| {
            const value = compSeed(s, maps, mapcounts);
            if (value < lowest) {
                lowest = value;
            }
            i += 1;
            if (i % stepsize == 0) {
                print("Progress: {}%\n", .{(((i + 1) * 100) / total)});
            }
        }
    }
    return lowest;
}

fn compSeedRange(min: itype, max: itype, maps: [10][100]MapRange, mapcounts: [10]u16, step: u8) itype {
    const mapid = mapcounts[step];
    if (step >= 9) {
        return min;
    }
    for (maps[step][0..mapid]) |m| {
        if (m.min <= min and m.max >= max) {
            const xmin = m.dest + (min - m.min);
            const xmax = xmin + (max - min);
            return compSeedRange(xmin, xmax, maps, mapcounts, step + 1);
        } else if (m.min >= min and m.min <= max) {
            const xmin = m.min;
            const xmax = @min(m.max, max);
            const ymin = m.dest;
            const ymax = ymin + (xmax - xmin);
            var calced: itype = 0;
            var lowest = compSeedRange(ymin, ymax, maps, mapcounts, step + 1);
            calced += ymax - ymin + 1;
            if (min < xmin) {
                lowest = @min(lowest, compSeedRange(min, xmin - 1, maps, mapcounts, step));
                calced += xmin - min;
            }
            if (max > xmax) {
                lowest = @min(lowest, compSeedRange(xmax + 1, max, maps, mapcounts, step));
                calced += max - xmax;
            }
            return lowest;
        } else if (m.max >= min and m.max <= max) {
            const xmin = @max(m.min, min);
            const xmax = m.max;
            const ymax = m.dest + (m.max - m.min);
            const ymin = ymax - (xmax - xmin);
            var calced: itype = 0;
            var lowest = compSeedRange(ymin, ymax, maps, mapcounts, step + 1);
            calced += ymax - ymin + 1;
            if (min < xmin) {
                lowest = @min(lowest, compSeedRange(min, xmin - 1, maps, mapcounts, step));
                calced += xmin - min;
            }
            if (max > xmax) {
                lowest = @min(lowest, compSeedRange(xmax + 1, max, maps, mapcounts, step));
                calced += max - xmax;
            }
            return lowest;
        }
    }
    return compSeedRange(min, max, maps, mapcounts, step + 1);
}

fn part2(input: []const u8) itype {
    var seed: u8 = 0;
    var seeds: [20]Range = undefined;
    var step: i16 = -1;
    var indigit: bool = false;
    var current: itype = 0;
    var map = [_]itype{0} ** 3;
    var mapi: u8 = 0;
    var mapcounts = [_]u16{0} ** 10;
    var maps: [10][100]MapRange = undefined;
    var hold: itype = 0;

    for (input) |c| {
        if (c == ':') {
            step += 1;
            continue;
        }

        if (isDigit(c)) {
            indigit = true;
            current = current * 10 + (c - '0');
            continue;
        } else if (indigit) {
            indigit = false;
            if (step == 0) {
                if (hold == 0) {
                    hold = current;
                    current = 0;
                } else {
                    seeds[seed] = Range{ .min = hold, .max = hold + current - 1 };
                    seed += 1;
                    current = 0;
                    hold = 0;
                }
            } else {
                map[mapi] = current;
                mapi += 1;
                current = 0;
            }
        }

        if (c == '\n') {
            if (mapi == 3) {
                const istep: usize = @intCast(step);
                const mapid = mapcounts[istep];
                maps[istep][mapid] = MapRange{ .dest = map[0], .min = map[1], .max = map[1] + map[2] - 1 };
                mapcounts[istep] += 1;
            }
            mapi = 0;
            continue;
        }
    }

    var lowest: itype = std.math.maxInt(itype);
    for (seeds[0..seed], 0..) |range, i| {
        _ = i;
        lowest = @min(lowest, compSeedRange(range.min, range.max, maps, mapcounts, 0));
    }
    return lowest;
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
