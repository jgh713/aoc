const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day12.txt");
const testdata = "start-A\r\nstart-b\r\nA-c\r\nA-b\r\nb-d\r\nA-end\r\nb-end";
const testdata2 = "dc-end\r\nHN-start\r\nstart-kj\r\ndc-start\r\ndc-HN\r\nLN-dc\r\nHN-end\r\nkj-sa\r\nkj-HN\r\nkj-dc";
const testdata3 = "fs-end\r\nhe-DX\r\nfs-he\r\nstart-DX\r\npj-DX\r\nend-zg\r\nzg-sl\r\nzg-pj\r\npj-he\r\nRW-he\r\nfs-DX\r\npj-RW\r\nzg-RW\r\nstart-pj\r\nhe-WI\r\nzg-he\r\npj-fs\r\nstart-RW";

test "day12_part1" {
    const res = part1(testdata);
    assert(res == 10);
    const res2 = part1(testdata2);
    assert(res2 == 19);
    const res3 = part1(testdata3);
    assert(res3 == 226);
}

const Node = struct {
    visited: bool = false,
    edges: [10]?[]const u8 = .{null} ** 10,
    ecount: u8 = 0,
};

fn countPossibilities(map: StrMap(Node), nid: []const u8, extras_in: u8) usize {
    //for (0..depth) |_| print(" ", .{});
    //print("Counting: {s}\n", .{nid});
    const node = map.getPtr(nid).?;
    if (std.mem.eql(u8, nid, "end")) {
        //for (0..depth) |_| print(" ", .{});
        //print("End\n", .{});
        return 1;
    }
    var extras = extras_in;
    var is_extra: bool = false;
    if (node.visited) {
        if (extras > 0 and !std.mem.eql(u8, nid, "start")) {
            extras -= 1;
            is_extra = true;
        } else {
            //for (0..depth) |_| print(" ", .{});
            //print("Visited\n", .{});
            return 0;
        }
    }
    if (nid[0] < 'A' or nid[0] > 'Z') node.visited = true;
    var count: usize = 0;
    for (node.edges[0..node.ecount]) |edge| {
        count += countPossibilities(map, edge.?, extras);
    }
    if (!is_extra) node.visited = false;

    return count;
}

pub fn part1(input: []const u8) usize {
    var map = StrMap(Node).init(gpa);
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var parts = splitSca(u8, line, '-');
        const left = parts.next().?;
        const right = parts.next().?;
        const lnode = map.getOrPut(left) catch unreachable;
        if (!lnode.found_existing) {
            lnode.value_ptr.* = Node{};
        }
        lnode.value_ptr.edges[lnode.value_ptr.ecount] = right;
        lnode.value_ptr.ecount += 1;
        const rnode = map.getOrPut(right) catch unreachable;
        if (!rnode.found_existing) {
            rnode.value_ptr.* = Node{};
        }
        rnode.value_ptr.edges[rnode.value_ptr.ecount] = left;
        rnode.value_ptr.ecount += 1;
    }

    const res = countPossibilities(map, "start", 0);

    //print("Res: {}\n", .{res});
    return res;
}

test "day12_part2" {
    const res = part2(testdata);
    assert(res == 36);
    const res2 = part2(testdata2);
    assert(res2 == 103);
    const res3 = part2(testdata3);
    assert(res3 == 3509);
}

pub fn part2(input: []const u8) usize {
    var map = StrMap(Node).init(gpa);
    var lines = splitSeq(u8, input, "\r\n");

    while (lines.next()) |line| {
        var parts = splitSca(u8, line, '-');
        const left = parts.next().?;
        const right = parts.next().?;
        const lnode = map.getOrPut(left) catch unreachable;
        if (!lnode.found_existing) {
            lnode.value_ptr.* = Node{};
        }
        lnode.value_ptr.edges[lnode.value_ptr.ecount] = right;
        lnode.value_ptr.ecount += 1;
        const rnode = map.getOrPut(right) catch unreachable;
        if (!rnode.found_existing) {
            rnode.value_ptr.* = Node{};
        }
        rnode.value_ptr.edges[rnode.value_ptr.ecount] = left;
        rnode.value_ptr.ecount += 1;
    }

    const res = countPossibilities(map, "start", 1);

    //print("Res: {}\n", .{res});
    return res;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 12:\n", .{});
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
