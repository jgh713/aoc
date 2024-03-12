const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day07.txt");
const testdata = "";

test "day07_part1" {
    assert(supportsTLS("abba[mnop]qrst"));
    assert(!supportsTLS("abcd[bddb]xyyx"));
    assert(!supportsTLS("aaaa[qwer]tyui"));
    assert(supportsTLS("ioxxoj[asdfgh]zxcvbn"));
    assert(!supportsTLS("ioxxoj[asdfgh]zxcvbn[abba]"));
}

fn supportsTLS(ip: []const u8) bool {
    var in_brackets: bool = false;
    var pieces = splitAny(u8, ip, &[2]u8{ '[', ']' });
    var found: bool = false;

    while (pieces.next()) |piece| {
        if (in_brackets or !found) {
            for (0..piece.len - 3) |i| {
                if (piece[i] == piece[i + 3] and piece[i + 1] == piece[i + 2] and piece[i] != piece[i + 1]) {
                    if (in_brackets) {
                        return false;
                    }
                    found = true;
                }
            }
        }
        in_brackets = !in_brackets;
    }

    return found;
}

pub fn part1(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;

    while (lines.next()) |line| {
        if (supportsTLS(line)) {
            count += 1;
        }
    }
    return count;
}

test "day07_part2" {
    assert(supportsSSL("aba[bab]xyz"));
    assert(!supportsSSL("xyx[xyx]xyx"));
    assert(supportsSSL("aaa[kek]eke"));
    assert(supportsSSL("zazbz[bzb]cdb"));
}

fn supportsSSL(ip: []const u8) bool {
    var inbuffer: [128]u8 = undefined;
    var ibi: u8 = 0;
    var outbuffer: [128]u8 = undefined;
    var obi: u8 = 0;

    var in_brackets: bool = false;
    var pieces = splitAny(u8, ip, &[2]u8{ '[', ']' });

    while (pieces.next()) |piece| {
        if (in_brackets) {
            @memcpy(inbuffer[ibi .. ibi + piece.len], piece);
            inbuffer[ibi + piece.len] = ' ';
            ibi += @intCast(piece.len + 1);
        } else {
            @memcpy(outbuffer[obi .. obi + piece.len], piece);
            outbuffer[obi + piece.len] = ' ';
            obi += @intCast(piece.len + 1);
        }
        in_brackets = !in_brackets;
    }

    for (0..ibi - 2) |i| {
        if (inbuffer[i] == inbuffer[i + 2] and inbuffer[i] != inbuffer[i + 1]) {
            const aba = inbuffer[i .. i + 3];
            if (indexOf(u8, aba, ' ') != null) continue;
            const bab: [3]u8 = .{ aba[1], aba[0], aba[1] };
            if (indexOfStr(u8, outbuffer[0..obi], 0, &bab) != null) {
                return true;
            }
        }
    }

    return false;
}

pub fn part2(input: []const u8) usize {
    var lines = splitSeq(u8, input, "\r\n");
    var count: usize = 0;

    while (lines.next()) |line| {
        if (supportsSSL(line)) {
            count += 1;
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
    print("Day 07:\n", .{});
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
