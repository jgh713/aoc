const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day02.txt");
const testinput = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\nGame 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\nGame 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\nGame 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\nGame 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green";

test "day2_part1" {
    const x = try part1(testinput);
    assert(x == 8);
}

pub fn part1(input: []const u8) !usize {
    var it_line = splitSca(u8, input, '\n');
    var total: usize = 0;
    while (it_line.next()) |line| {
        var it_game = splitSca(u8, line, ':');
        const game_header = it_game.next().?;
        const game_id = try parseInt(u32, game_header[5..], 10);
        var it_round = splitSca(u8, (it_game.next() orelse unreachable), ';');
        const valid = valid_loop: while (it_round.next()) |round| {
            var it_grab = splitSeq(u8, round[1..], ", ");
            while (it_grab.next()) |grab| {
                var it_dice = splitSca(u8, grab, ' ');
                const count = try parseInt(u32, it_dice.next() orelse unreachable, 10);
                const color = it_dice.next() orelse unreachable;
                const max: u8 = switch (color[0]) {
                    'r' => 12,
                    'g' => 13,
                    'b' => 14,
                    else => unreachable,
                };
                if (count > max) {
                    break :valid_loop false;
                }
            }
        } else {
            break :valid_loop true;
        };
        if (valid) {
            total += game_id;
        }
    }
    return total;
}

pub fn part2(input: []const u8) !usize {
    var it_line = splitSca(u8, input, '\n');
    var total: usize = 0;
    while (it_line.next()) |line| {
        var counts = [_]u32{ 0, 0, 0 };
        var it_game = splitSca(u8, line, ':');
        const game_header = it_game.next().?;
        _ = game_header;
        var it_round = splitSca(u8, (it_game.next() orelse unreachable), ';');
        while (it_round.next()) |round| {
            var it_grab = splitSeq(u8, round[1..], ", ");
            while (it_grab.next()) |grab| {
                var it_dice = splitSca(u8, grab, ' ');
                const count = try parseInt(u32, it_dice.next() orelse unreachable, 10);
                const color = it_dice.next() orelse unreachable;
                const index: u8 = switch (color[0]) {
                    'r' => 0,
                    'g' => 1,
                    'b' => 2,
                    else => unreachable,
                };
                if (counts[index] < count) {
                    counts[index] = count;
                }
            }
        }
        const power = counts[0] * counts[1] * counts[2];
        total += power;
    }
    return total;
}

test "day2_part2" {
    const x = try part2(testinput);
    assert(x == 2286);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res1 = try part1(data);
    const time1 = timer.lap();
    const res2 = try part2(data);
    const time2 = timer.lap();
    print("Part 1: {d}\n", .{res1});
    print("Part 2: {d}\n", .{res2});
    print("Part1 time: {d}ns\n", .{time1});
    print("Part2 time: {d}ns\n", .{time2});
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
