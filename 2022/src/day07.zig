const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day07.txt");
const testdata = "$ cd /\r\n$ ls\r\ndir a\r\n14848514 b.txt\r\n8504156 c.dat\r\ndir d\r\n$ cd a\r\n$ ls\r\ndir e\r\n29116 f\r\n2557 g\r\n62596 h.lst\r\n$ cd e\r\n$ ls\r\n584 i\r\n$ cd ..\r\n$ cd ..\r\n$ cd d\r\n$ ls\r\n4060174 j\r\n8033020 d.log\r\n5626152 d.ext\r\n7214296 k";

test "day07_part1" {
    const res = part1(testdata);
    assert(res == 95437);
}

const Directory = struct {
    name: []u8,
    parent: ?*Directory,
    subdirs: ?*SubNode,
    selfsize: usize,
    totalsize: usize,

    pub fn getSubDir(self: *Directory, name: []const u8) ?*Directory {
        var node = self.subdirs;
        while (node) |n| {
            if (std.mem.eql(u8, n.dir.name, name)) {
                return n.dir;
            }
            node = n.next;
        }
        return null;
    }

    pub fn makeSubDir(self: *Directory, name: []const u8, newdir: *Directory) *Directory {
        var newnode = gpa.alloc(SubNode, 1) catch unreachable;
        newnode[0] = SubNode{ .dir = newdir, .next = self.subdirs };
        self.subdirs = &newnode[0];

        const nameptr = gpa.alloc(u8, name.len) catch unreachable;
        @memcpy(nameptr, name.ptr);
        newdir.* = Directory{ .name = nameptr, .parent = self, .subdirs = null, .selfsize = 0, .totalsize = 0 };
        return newdir;
    }
};
const SubNode = struct { dir: *Directory, next: ?*SubNode };

pub fn part1(input: []const u8) usize {
    var dirs: [370]Directory = undefined;
    var dircount: usize = 0;

    const rptr = gpa.alloc(u8, 1) catch unreachable;
    rptr[0] = '/';
    dirs[0] = Directory{ .name = rptr, .parent = null, .subdirs = null, .selfsize = 0, .totalsize = 0 };
    dircount += 1;

    var lines = splitSeq(u8, input, "\r\n");
    var current_dir = &dirs[0];

    while (lines.next()) |line| {
        var words = splitSeq(u8, line, " ");
        const w1 = words.next().?;
        if (std.mem.eql(u8, w1, "$")) {
            const cmd = words.next().?;
            if (std.mem.eql(u8, cmd, "cd")) {
                const todir = words.next().?;
                if (std.mem.eql(u8, todir, "/")) {
                    current_dir = &dirs[0];
                } else if (std.mem.eql(u8, todir, "..")) {
                    current_dir = if (current_dir.parent) |parent| parent else unreachable;
                } else {
                    if (current_dir.getSubDir(todir)) |dir| {
                        current_dir = dir;
                    } else {
                        const newdir = current_dir.makeSubDir(todir, &dirs[dircount]);
                        dircount += 1;
                        current_dir = newdir;
                    }
                }
            }
        } else if (std.mem.eql(u8, w1, "dir")) {
            // Don't think we need to do anything here (yet)
        } else {
            const size = parseInt(usize, w1, 10) catch unreachable;
            current_dir.selfsize += size;
        }
    }

    for (dirs[0..dircount]) |*startdir| {
        var dir: ?*Directory = startdir;
        const size = startdir.selfsize;
        while (dir) |d| {
            d.totalsize += size;
            dir = d.parent;
        }
    }

    var total: usize = 0;
    for (dirs[0..dircount]) |dir| {
        //print("{s}: {}\n", .{ dir.name, dir.totalsize });
        if (dir.totalsize < 100000) {
            total += dir.totalsize;
        }
    }
    return total;
}

test "day07_part2" {
    const res = part2(testdata);
    assert(res == 24933642);
}

fn compareDirs(_: @TypeOf(.{}), a: Directory, b: Directory) bool {
    return (a.totalsize > b.totalsize);
}

pub fn part2(input: []const u8) usize {
    var dirs: [370]Directory = comptime std.mem.zeroes([370]Directory);
    var dircount: usize = 0;

    const rptr = gpa.alloc(u8, 1) catch unreachable;
    rptr[0] = '/';
    dirs[0] = Directory{ .name = rptr, .parent = null, .subdirs = null, .selfsize = 0, .totalsize = 0 };
    dircount += 1;

    var lines = splitSeq(u8, input, "\r\n");
    var current_dir = &dirs[0];

    while (lines.next()) |line| {
        var words = splitSeq(u8, line, " ");
        const w1 = words.next().?;
        if (std.mem.eql(u8, w1, "$")) {
            const cmd = words.next().?;
            if (std.mem.eql(u8, cmd, "cd")) {
                const todir = words.next().?;
                if (std.mem.eql(u8, todir, "/")) {
                    current_dir = &dirs[0];
                } else if (std.mem.eql(u8, todir, "..")) {
                    current_dir = if (current_dir.parent) |parent| parent else unreachable;
                } else {
                    if (current_dir.getSubDir(todir)) |dir| {
                        current_dir = dir;
                    } else {
                        const newdir = current_dir.makeSubDir(todir, &dirs[dircount]);
                        dircount += 1;
                        current_dir = newdir;
                    }
                }
            }
        } else if (std.mem.eql(u8, w1, "dir")) {
            // Don't think we need to do anything here (yet)
        } else {
            const size = parseInt(usize, w1, 10) catch unreachable;
            current_dir.selfsize += size;
        }
    }

    for (dirs[0..dircount]) |*startdir| {
        var dir: ?*Directory = startdir;
        const size = startdir.selfsize;
        while (dir) |d| {
            d.totalsize += size;
            dir = d.parent;
        }
    }

    const total = 70000000;
    const total_needed = 30000000;

    const free = total - dirs[0].totalsize;
    const needed = total_needed - free;

    std.mem.sort(Directory, &dirs, .{}, compareDirs);

    var i: usize = dircount - 1;
    while (dirs[i].totalsize < needed) {
        i -= 1;
    }

    return dirs[i].totalsize;
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
