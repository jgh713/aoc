const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day22.txt");
const testdata = "1,0,1~1,2,1\n0,0,2~2,0,2\n0,2,3~2,2,3\n0,0,4~0,2,4\n2,0,5~2,2,5\n0,1,6~2,1,6\n1,1,8~1,1,9";

test "day22_part1" {
    const res = part1(testdata);
    print("test result: {}\n", .{res});
    assert(res == 5);
}

const Point = struct {
    x: usize,
    y: usize,
    z: usize,
};

const Block = struct {
    id: u16,
    a: Point,
    b: Point,
    //below: [4]?*Block = .{null} ** 4,
    bcount: usize = 0,
    above: [10]?*Block = .{null} ** 10,
    //acount: usize = 0,
};

const Grid = struct {
    xmax: usize,
    ymax: usize,
    zmax: usize,
    blocks: []Block,
    map: []?u16,

    pub fn get(self: *Grid, x: usize, y: usize, z: usize) ?u16 {
        return self.map[x + y * self.xmax + z * self.xmax * self.ymax];
    }

    pub fn set(self: *Grid, x: usize, y: usize, z: usize, v: ?u16) void {
        self.map[x + y * self.xmax + z * self.xmax * self.ymax] = v;
    }

    pub fn deinit(self: *Grid) void {
        gpa.free(self.blocks);
        gpa.free(self.map);
    }

    pub fn blockSupports(self: *Grid, block: *Block) u4 {
        var supports: [4]u16 = undefined;
        var si: u4 = 0;
        for (block.a.x..block.b.x + 1) |x| {
            for (block.a.y..block.b.y + 1) |y| {
                const z = block.a.z - 1;
                const bmap = self.get(x, y, z);
                if (bmap) |bid| {
                    const has: bool = for (supports[0..si]) |s| {
                        if (s == bid) break true;
                    } else false;
                    if (!has) {
                        supports[si] = bid;
                        si += 1;
                    }
                }
            }
        }

        for (supports[0..si]) |sid| {
            const s = &self.blocks[sid];
            const hasparent: bool = for (s.above) |bpo| {
                if (bpo) |bp| {
                    if (bp == block) break true;
                }
            } else false;
            if (!hasparent) {
                infor: for (s.above[0..]) |*bpo| {
                    if (bpo.* == null) {
                        bpo.* = block;
                        break :infor;
                    }
                }
            }
        }
        block.bcount = si;

        return si;
    }

    pub fn shiftDown(self: *Grid, block: *Block) void {
        for (block.a.x..block.b.x + 1) |x| {
            for (block.a.y..block.b.y + 1) |y| {
                self.set(x, y, block.b.z, null);
            }
        }

        block.a.z -= 1;
        block.b.z -= 1;

        for (block.a.x..block.b.x + 1) |x| {
            for (block.a.y..block.b.y + 1) |y| {
                self.set(x, y, block.a.z, block.id);
            }
        }
    }

    pub fn allFall(self: *Grid) void {
        const qlen = self.blocks.len + 1;
        var blockqueue = gpa.alloc(u16, qlen) catch unreachable;
        defer gpa.free(blockqueue);

        var qstart: usize = 0;
        var qend: usize = 0;

        for (self.blocks, 0..) |block, bi| {
            if (block.a.z >= 0) {
                blockqueue[qend] = @intCast(bi);
                qend += 1;
            }
        }

        while (qstart != qend) : (qstart += 1) {
            if (qstart == qlen) qstart = 0;

            var block = &self.blocks[blockqueue[qstart]];
            const support_count = self.blockSupports(block);
            if (support_count == 0) {

                // Handle parent support
                for (block.above[0..]) |*bpo| {
                    if (bpo.*) |bp| {
                        bp.bcount -= 1;
                        if (bp.bcount == 0) {
                            // Queue for falling
                            blockqueue[qend] = bp.id;
                            qend += 1;
                            if (qend == qlen) qend = 0;
                        }
                        // Remove as parent
                        bpo.* = null;
                    }
                }

                var scount: usize = 0;
                while (scount == 0) {
                    self.shiftDown(block);
                    if (block.a.z == 0) break;
                    scount = self.blockSupports(block);
                }
            }
        }
    }

    pub fn countSafe(self: *Grid) usize {
        var count: usize = 0;
        for (self.blocks) |block| {
            const safe: bool = for (block.above[0..]) |bpo| {
                if (bpo) |bp| {
                    if (bp.bcount == 1) break false;
                }
            } else true;
            if (safe) count += 1;
        }
        return count;
    }

    pub fn countFalls(self: *Grid) usize {
        var bcounts = gpa.alloc(usize, self.blocks.len) catch unreachable;
        defer gpa.free(bcounts);
        const qlen = self.blocks.len + 1;
        var delqueue = gpa.alloc(u16, qlen) catch unreachable;
        defer gpa.free(delqueue);
        var total: usize = 0;

        for (0..self.blocks.len) |start_del| {
            var qstart: usize = 0;
            var qend: usize = 1;

            for (self.blocks, 0..) |block, bi| {
                bcounts[bi] = block.bcount;
            }

            delqueue[0] = @intCast(start_del);
            while (qstart != qend) : (qstart += 1) {
                if (qstart == qlen) qstart = 0;

                const block = self.blocks[delqueue[qstart]];
                for (block.above[0..]) |bpo| {
                    if (bpo) |bp| {
                        const bpid = bp.id;
                        bcounts[bpid] -= 1;
                        if (bcounts[bpid] == 0) {
                            delqueue[qend] = bpid;
                            qend += 1;
                            if (qend == qlen) unreachable;
                        }
                    }
                }
            }
            total += (qend - 1);
        }

        return total;
    }
};

fn createGrid(coords: [][2][3]usize, maxes: [3]usize) Grid {
    const gridsize = maxes[0] * maxes[1] * maxes[2];
    var grid = Grid{
        .xmax = maxes[0],
        .ymax = maxes[1],
        .zmax = maxes[2],
        .blocks = gpa.alloc(Block, coords.len) catch unreachable,
        .map = gpa.alloc(?u16, gridsize) catch unreachable,
    };

    errdefer grid.deinit();
    for (0..gridsize) |i| {
        grid.map[i] = null;
    }

    for (coords, 0..) |coord, bi| {
        const apoint: Point = .{ .x = @min(coord[0][0], coord[1][0]), .y = @min(coord[0][1], coord[1][1]), .z = @min(coord[0][2], coord[1][2]) };
        const bpoint: Point = .{ .x = @max(coord[0][0], coord[1][0]), .y = @max(coord[0][1], coord[1][1]), .z = @max(coord[0][2], coord[1][2]) };
        grid.blocks[bi] = Block{
            .id = @as(u16, @truncate(bi)),
            .a = apoint,
            .b = bpoint,
            .bcount = 0,
        };
    }

    for (grid.blocks) |block| {
        for (block.a.x..block.b.x + 1) |x| {
            for (block.a.y..block.b.y + 1) |y| {
                for (block.a.z..block.b.z + 1) |z| {
                    grid.set(x, y, z, block.id);
                }
            }
        }
    }

    return grid;
}

pub fn part1(input: []const u8) usize {
    const rindex = indexOf(u8, input, '\r');
    var lineit = splitSeq(u8, input, if (rindex) |_| "\r\n" else "\n");
    var maxes: [3]usize = .{ 0, 0, 0 };
    var coords: [1500][2][3]usize = undefined;
    var blockcount: usize = 0;

    while (lineit.next()) |line| {
        var cit = splitSca(u8, line, '~');
        var points: [2][3]usize = undefined;

        var pi: u2 = 0;
        while (cit.next()) |coord| {
            var coordit = splitSca(u8, coord, ',');
            var ci: u2 = 0;
            while (coordit.next()) |c| {
                const v = parseInt(usize, c, 10) catch unreachable;
                points[pi][ci] = v;
                maxes[ci] = @max(v, maxes[ci]);
                ci += 1;
            }
            pi += 1;
        }

        coords[blockcount][0] = points[0];
        coords[blockcount][1] = points[1];
        blockcount += 1;
    }

    maxes[0] += 1;
    maxes[1] += 1;
    maxes[2] += 1;

    //print("maxes: {any}\n", .{maxes});
    //print("Blocks: {}\n", .{blockcount});

    var grid = createGrid(coords[0..blockcount], maxes);
    defer grid.deinit();

    grid.allFall();

    return grid.countSafe();
}

test "day22_part2" {
    const res = part2(testdata);
    assert(res == 7);
}

pub fn part2(input: []const u8) usize {
    const rindex = indexOf(u8, input, '\r');
    var lineit = splitSeq(u8, input, if (rindex) |_| "\r\n" else "\n");
    var maxes: [3]usize = .{ 0, 0, 0 };
    var coords: [1500][2][3]usize = undefined;
    var blockcount: usize = 0;

    while (lineit.next()) |line| {
        var cit = splitSca(u8, line, '~');
        var points: [2][3]usize = undefined;

        var pi: u2 = 0;
        while (cit.next()) |coord| {
            var coordit = splitSca(u8, coord, ',');
            var ci: u2 = 0;
            while (coordit.next()) |c| {
                const v = parseInt(usize, c, 10) catch unreachable;
                points[pi][ci] = v;
                maxes[ci] = @max(v, maxes[ci]);
                ci += 1;
            }
            pi += 1;
        }

        coords[blockcount][0] = points[0];
        coords[blockcount][1] = points[1];
        blockcount += 1;
    }

    maxes[0] += 1;
    maxes[1] += 1;
    maxes[2] += 1;

    //print("maxes: {any}\n", .{maxes});
    //print("Blocks: {}\n", .{blockcount});

    var grid = createGrid(coords[0..blockcount], maxes);
    defer grid.deinit();

    grid.allFall();

    return grid.countFalls();
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part2: {}\n", .{res2});
    print("Part1 took {}ns\n", .{time});
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
