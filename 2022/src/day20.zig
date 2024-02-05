const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day20.txt");
const testdata = "1\r\n2\r\n-3\r\n3\r\n-2\r\n0\r\n4";
const testdata2 = "1\r\n2\r\n-3\r\n3\r\n-2\r\n0\r\n8";

test "day20_part1" {
    const res = part1(testdata);
    assert(res == 3);
    const res2 = part1(testdata2);
    assert(res2 == 7);
}

const Number = struct {
    value: isize,
    index: usize,
};

pub fn part1(input: []const u8) isize {
    var nums: [5000]Number = undefined;
    var ncount: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        const num = parseInt(isize, line, 10) catch unreachable;
        nums[ncount] = Number{ .value = num, .index = ncount };
        ncount += 1;
    }

    var current: [5000]Number = nums;
    var hold: [5000]Number = undefined;

    for (0..ncount) |ni| {
        const num = nums[ni];
        const index: usize = for (current[0..ncount], 0..) |n, i| {
            if (n.index == num.index) {
                break i;
            }
        } else unreachable;
        const newindex: usize = @abs(@mod(@as(isize, @intCast(index)) + num.value, @as(isize, @intCast(ncount - 1))));
        if (newindex == index) {
            continue;
        }
        //print("Index: {}, NewIndex: {}\n", .{ index, newindex });
        var slices: [3][]Number = undefined;
        if (newindex > index) {
            slices[0] = current[newindex + 1 .. ncount];
            slices[1] = current[0..index];
            slices[2] = current[index + 1 .. newindex + 1];
        } else {
            slices[0] = current[newindex..index];
            slices[1] = current[index + 1 .. ncount];
            slices[2] = current[0..newindex];
        }
        //print("First: {any}\n", .{slices[0]});
        //print("Second: {any}\n", .{slices[1]});
        //print("Third: {any}\n", .{slices[2]});
        hold[0] = num;
        var end: usize = 1;
        for (slices) |slice| {
            if (slice.len > 0) {
                @memcpy(hold[end .. end + slice.len], slice);
                end += slice.len;
            }
        }
        //print("Post-shift array is now: ", .{});
        //for (hold[0..ncount]) |n| {
        //    print("{}, ", .{n.value});
        //}
        //print("\n", .{});
        current = hold;
    }

    const zeroIndex: usize = for (current[0..ncount], 0..) |n, i| {
        if (n.value == 0) {
            break i;
        }
    } else unreachable;

    const vi1 = (zeroIndex + 1000) % ncount;
    const vi2 = (zeroIndex + 2000) % ncount;
    const vi3 = (zeroIndex + 3000) % ncount;

    const v1 = current[vi1].value;
    const v2 = current[vi2].value;
    const v3 = current[vi3].value;

    //print("Values: {}, {}, {}\n", .{ v1, v2, v3 });

    return v1 + v2 + v3;
}

test "day20_part2" {
    const res = part2(testdata);
    assert(res == 1623178306);
}

pub fn part2(input: []const u8) isize {
    var nums: [5000]Number = undefined;
    var ncount: usize = 0;
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        const num = parseInt(isize, line, 10) catch unreachable;
        nums[ncount] = Number{ .value = num * 811589153, .index = ncount };
        ncount += 1;
    }

    var current: [5000]Number = nums;
    var hold: [5000]Number = undefined;

    for (0..10) |_| {
        for (0..ncount) |ni| {
            const num = nums[ni];
            const index: usize = for (current[0..ncount], 0..) |n, i| {
                if (n.index == num.index) {
                    break i;
                }
            } else unreachable;
            const newindex: usize = @abs(@mod(@as(isize, @intCast(index)) + num.value, @as(isize, @intCast(ncount - 1))));
            if (newindex == index) {
                continue;
            }
            var slices: [3][]Number = undefined;
            if (newindex > index) {
                slices[0] = current[newindex + 1 .. ncount];
                slices[1] = current[0..index];
                slices[2] = current[index + 1 .. newindex + 1];
            } else {
                slices[0] = current[newindex..index];
                slices[1] = current[index + 1 .. ncount];
                slices[2] = current[0..newindex];
            }
            hold[0] = num;
            var end: usize = 1;
            for (slices) |slice| {
                if (slice.len > 0) {
                    @memcpy(hold[end .. end + slice.len], slice);
                    end += slice.len;
                }
            }
            current = hold;
        }
    }

    const zeroIndex: usize = for (current[0..ncount], 0..) |n, i| {
        if (n.value == 0) {
            break i;
        }
    } else unreachable;

    const vi1 = (zeroIndex + 1000) % ncount;
    const vi2 = (zeroIndex + 2000) % ncount;
    const vi3 = (zeroIndex + 3000) % ncount;

    const v1 = current[vi1].value;
    const v2 = current[vi2].value;
    const v3 = current[vi3].value;

    return v1 + v2 + v3;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 20:\n", .{});
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
