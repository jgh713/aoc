const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day04.txt");
const testdata = "aaaaa-bbb-z-y-x-123[abxyz]\r\na-b-c-d-e-f-g-h-987[abcde]\r\nnot-a-real-room-404[oarel]\r\ntotally-real-room-200[decoy]";

test "day04_part1" {
    const res = part1(testdata);
    assert(res == 1514);
}

const Letter = struct {
    letter: u8 = 0,
    freq: u8 = 0,
    fpos: u8 = 0,
};

fn letterSort(_: void, a: Letter, b: Letter) bool {
    if (a.freq > b.freq) {
        return true;
    } else if (a.freq < b.freq) {
        return false;
        //} else if (a.fpos < b.fpos) {
        //    return true;
        //} else if (a.fpos > b.fpos) {
        //    return false;
    } else {
        // This is just to prevent errors on the sort
        // for zero-freqency letters being unsortable
        return a.letter < b.letter;
    }
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;

    while (lines.next()) |line| {
        var letters: [26]Letter = undefined;
        for (0..26) |i| {
            letters[i] = Letter{ .letter = 'a' + @as(u8, @intCast(i)), .freq = 0, .fpos = 0 };
        }
        const bracket = indexOf(u8, line, '[').?;
        const left = line[0 .. bracket - 4];
        const sector = parseInt(usize, line[bracket - 3 .. bracket], 10) catch unreachable;
        const checksum = line[bracket + 1 .. bracket + 6];
        for (left, 0..) |c, pos| {
            switch (c) {
                'a'...'z' => {
                    letters[c - 'a'].freq += 1;
                    if (letters[c - 'a'].freq == 1) {
                        letters[c - 'a'].fpos = @intCast(pos);
                    }
                },
                '-' => {},
                else => unreachable,
            }
        }
        sort(Letter, &letters, {}, letterSort);
        const valid = for (0..5) |i| {
            if (letters[i].letter != checksum[i]) {
                break false;
            }
        } else true;
        //print("{s}: {}\n", .{ line, valid });
        if (valid) {
            count += sector;
        }
    }
    return count;
}

test "day04_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;

    while (lines.next()) |line| {
        var letters: [26]Letter = undefined;
        for (0..26) |i| {
            letters[i] = Letter{ .letter = 'a' + @as(u8, @intCast(i)), .freq = 0, .fpos = 0 };
        }
        const bracket = indexOf(u8, line, '[').?;
        const left = line[0 .. bracket - 4];
        const sector = parseInt(usize, line[bracket - 3 .. bracket], 10) catch unreachable;
        const checksum = line[bracket + 1 .. bracket + 6];
        for (left, 0..) |c, pos| {
            switch (c) {
                'a'...'z' => {
                    letters[c - 'a'].freq += 1;
                    if (letters[c - 'a'].freq == 1) {
                        letters[c - 'a'].fpos = @intCast(pos);
                    }
                },
                '-' => {},
                else => unreachable,
            }
        }
        sort(Letter, &letters, {}, letterSort);
        const valid = for (0..5) |i| {
            if (letters[i].letter != checksum[i]) {
                break false;
            }
        } else true;
        //print("{s}: {}\n", .{ line, valid });
        if (valid) {
            count += sector;
        }
        var linebuffer: [128]u8 = undefined;
        @memcpy(linebuffer[0..left.len], left);
        for (0..left.len) |ci| {
            switch (linebuffer[ci]) {
                'a'...'z' => {
                    linebuffer[ci] = @as(u8, @intCast((@as(usize, linebuffer[ci] - 'a') + sector) % 26)) + 'a';
                },
                '-' => {
                    linebuffer[ci] = ' ';
                },
                else => unreachable,
            }
        }
        if (std.mem.indexOf(u8, &linebuffer, "northpole") != null) {
            //print("{}: {s}\n", .{ sector, linebuffer[0..left.len] });
            return sector;
        }
    }
    unreachable;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 04:\n", .{});
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
