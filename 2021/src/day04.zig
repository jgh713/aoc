const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day04.txt");
const testdata = "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\r\n\r\n22 13 17 11  0\r\n 8  2 23  4 24\r\n21  9 14 16  7\r\n 6 10  3 18  5\r\n 1 12 20 15 19\r\n\r\n 3 15  0  2 22\r\n 9 18 13 17  5\r\n19  8  7 25 23\r\n20 11 10 24  4\r\n14 21 16 12  6\r\n\r\n14 21 17 24  4\r\n10 16 15  9 19\r\n18  8 23 26 20\r\n22 11 13  6  5\r\n 2  0 12  3  7";

const Board = struct {
    id: u8,
    wins: [10]u100,
    won: bool = false,
};

test "day04_part1" {
    const res = part1(testdata);
    assert(res == 4512);
}

pub fn part1(input: []const u8) usize {
    var boards: [100]Board = undefined;
    var bi: u8 = 0;

    var boardlines = splitSeq(u8, input, "\r\n\r\n");
    var numbers = splitSca(u8, boardlines.first(), ',');

    while (boardlines.next()) |boardline| {
        var board: [5][5]u8 = undefined;
        var lines = splitSeq(u8, boardline, "\r\n");
        for (0..5) |y| {
            const line = lines.next().?;
            for (0..5) |x| {
                var val: u8 = 0;
                const offset = x * 3;
                if (line[offset] == ' ') {
                    val = line[offset + 1] - '0';
                } else {
                    val = (line[offset] - '0') * 10 + (line[offset + 1] - '0');
                }
                board[y][x] = val;
            }
        }

        var wins: [10]u100 = undefined;
        for (0..5) |i| {
            var x: u100 = 0;
            var y: u100 = 0;
            for (0..5) |j| {
                x |= @as(u100, 1) << @truncate(board[i][j]);
                y |= @as(u100, 1) << @truncate(board[j][i]);
            }
            wins[i] = x;
            wins[i + 5] = y;
        }

        boards[bi] = Board{ .id = bi + 1, .wins = wins };
        bi += 1;
    }

    var called: u100 = 0;

    for (0..4) |_| {
        const num = parseInt(u7, numbers.next().?, 10) catch unreachable;
        called |= @as(u100, 1) << num;
    }

    while (numbers.next()) |numline| {
        const num = parseInt(u7, numline, 10) catch unreachable;
        called |= @as(u100, 1) << num;

        for (boards[0..bi]) |board| {
            for (board.wins) |win| {
                if (win & called == win) {
                    //print("Board {} wins!\n", .{board.id});
                    var nums: u100 = 0;
                    for (board.wins) |w| {
                        nums |= w;
                    }
                    nums &= ~called;
                    var total: usize = 0;
                    for (0..100) |i| {
                        if (nums & (@as(u100, 1) << @truncate(i)) != 0) {
                            //print("{} ", .{i});
                            total += i;
                        }
                    }
                    //print("\ntotal: {}\n", .{total});
                    return total * num;
                }
            }
        }
    }

    return 0;
}

test "day04_part2" {
    const res = part2(testdata);
    assert(res == 1924);
}

pub fn part2(input: []const u8) usize {
    var boards: [100]Board = undefined;
    var bi: u8 = 0;

    var boardlines = splitSeq(u8, input, "\r\n\r\n");
    var numbers = splitSca(u8, boardlines.first(), ',');

    while (boardlines.next()) |boardline| {
        var board: [5][5]u8 = undefined;
        var lines = splitSeq(u8, boardline, "\r\n");
        for (0..5) |y| {
            const line = lines.next().?;
            for (0..5) |x| {
                var val: u8 = 0;
                const offset = x * 3;
                if (line[offset] == ' ') {
                    val = line[offset + 1] - '0';
                } else {
                    val = (line[offset] - '0') * 10 + (line[offset + 1] - '0');
                }
                board[y][x] = val;
            }
        }

        var wins: [10]u100 = undefined;
        for (0..5) |i| {
            var x: u100 = 0;
            var y: u100 = 0;
            for (0..5) |j| {
                x |= @as(u100, 1) << @truncate(board[i][j]);
                y |= @as(u100, 1) << @truncate(board[j][i]);
            }
            wins[i] = x;
            wins[i + 5] = y;
        }

        boards[bi] = Board{ .id = bi + 1, .wins = wins };
        bi += 1;
    }

    var called: u100 = 0;
    var wins: usize = bi;

    for (0..4) |_| {
        const num = parseInt(u7, numbers.next().?, 10) catch unreachable;
        called |= @as(u100, 1) << num;
    }

    while (numbers.next()) |numline| {
        const num = parseInt(u7, numline, 10) catch unreachable;
        called |= @as(u100, 1) << num;

        for (boards[0..bi]) |*board| {
            if (board.won) continue;
            winfor: for (board.wins) |win| {
                if (win & called == win) {
                    //print("Board {} has bingo with number {}\n", .{ board.id, num });
                    wins -= 1;
                    board.won = true;
                    if (wins == 0) {
                        //print("Board {} wins!\n", .{board.id});
                        var nums: u100 = 0;
                        for (board.wins) |w| {
                            nums |= w;
                        }
                        nums &= ~called;
                        var total: usize = 0;
                        for (0..100) |i| {
                            if (nums & (@as(u100, 1) << @truncate(i)) != 0) {
                                //print("{} ", .{i});
                                total += i;
                            }
                        }
                        //print("\ntotal: {}\n", .{total});
                        //print("Last number: {}\n", .{num});
                        return total * num;
                    }
                    break :winfor;
                }
            }
        }
    }

    return 0;
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
