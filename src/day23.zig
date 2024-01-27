///
/// Learned you can't reliably return slices from functions.
/// Works in debug mode but doesn't work in any release build.
///
const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
//const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day23.txt");
const testdata = "#.#####################\n#.......#########...###\n#######.#########.#.###\n###.....#.>.>.###.#.###\n###v#####.#v#.###.#.###\n###.>...#.#.#.....#...#\n###v###.#.#.#########.#\n###...#.#.#.......#...#\n#####.#.#.#######.#.###\n#.....#.#.#.......#...#\n#.#####.#.#.#########v#\n#.#...#...#...###...>.#\n#.#.#v#######v###.###v#\n#...#.>.#...>.>.#.###.#\n#####v#.#.###v#.#.###.#\n#.....#...#...#.#.#...#\n#.#########.###.#.#.###\n#...###...#...#...#.###\n###.###.#.###v#####v###\n#...#...#.#.>.>.#.>.###\n#.###.###.#.###.#.#v###\n#.....###...###...#...#\n#####################.#";

test "day23_part1" {
    const res = part1(testdata);
    assert(res == 94);
}

const Dirs = enum { Any, Up, Right, Down, Left };

const Tile = struct {
    walkable: bool,
    dir: Dirs = .Any,
    intersection: bool = false,
    visited: bool = false,
    node: ?*Node = null,
};

const dirmods: [4][2]i2 = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};

const Map = struct {
    tiles: [141][141]Tile,
    startx: usize,
    starty: usize,
    endx: usize,
    endy: usize,
    maxx: usize,
    maxy: usize,
    nodes: [1000]Node,
    nodecount: usize = 0,
    ignore_slopes: bool = false,

    pub fn build(self: *Map, input: []const u8) void {
        var x: usize = 0;
        var y: usize = 0;

        self.nodecount = 0;

        for (input) |c| {
            switch (c) {
                '\r' => {},
                '\n' => {
                    x = 0;
                    y += 1;
                },
                '#' => {
                    self.tiles[y][x] = .{ .walkable = false };
                    x += 1;
                },
                '.' => {
                    self.tiles[y][x] = .{ .walkable = true };
                    if (y == 0) {
                        self.startx = x;
                        self.starty = y;
                    }
                    x += 1;
                },
                '^' => {
                    self.tiles[y][x] = .{ .walkable = true, .dir = .Up };
                    x += 1;
                },
                '>' => {
                    self.tiles[y][x] = .{ .walkable = true, .dir = .Right };
                    x += 1;
                },
                'v' => {
                    self.tiles[y][x] = .{ .walkable = true, .dir = .Down };
                    x += 1;
                },
                '<' => {
                    self.tiles[y][x] = .{ .walkable = true, .dir = .Left };
                    x += 1;
                },
                else => unreachable,
            }
        }

        self.maxx = x;
        self.maxy = y + 1;
        self.endy = self.maxy - 1;
        self.endx = for (self.tiles[self.maxy - 1], 0..) |tile, ix| {
            if (tile.walkable) {
                break ix;
            }
        } else unreachable;

        //self.buildNodes();
    }

    fn neighbors(self: *Map, x: u8, y: u8) [][2]u8 {
        var out: [4][2]u8 = undefined;
        var oc: u8 = 0;

        for (dirmods) |mod| {
            const inx = @as(i16, x) + mod[0];
            const iny = @as(i16, y) + mod[1];

            if (inx < 0 or iny < 0 or inx >= self.maxx or iny >= self.maxy) {
                continue;
            }

            const nx: u8 = @intCast(inx);
            const ny: u8 = @intCast(iny);

            if (self.tiles[ny][nx].walkable) {
                out[oc] = .{ nx, ny };
                oc += 1;
            }
        }

        return out[0..oc];
    }

    fn neighborsUnvisited(self: *Map, x: u8, y: u8) [][2]u8 {
        var out: [4][2]u8 = undefined;
        var oc: u8 = 0;

        //print("Neighbors of ({}, {})\n", .{ x, y });
        for (dirmods) |mod| {
            const inx = @as(i16, x) + mod[0];
            const iny = @as(i16, y) + mod[1];
            //print("Neighbor ({}, {})\n", .{ inx, iny });

            if (inx < 0 or iny < 0 or inx >= self.maxx or iny >= self.maxy) {
                continue;
            }

            //print("Neighbor ({}, {}) in bounds\n", .{ inx, iny });
            const nx: u8 = @intCast(inx);
            const ny: u8 = @intCast(iny);

            if (!self.tiles[ny][nx].walkable) continue;
            if (self.tiles[ny][nx].visited) continue;
            if (!self.ignore_slopes) {
                switch (self.tiles[y][x].dir) {
                    .Any => {},
                    .Up => if (mod[1] == 1) continue,
                    .Right => if (mod[0] == -1) continue,
                    .Down => if (mod[1] == -1) continue,
                    .Left => if (mod[0] == 1) continue,
                }
            }

            out[oc] = .{ nx, ny };
            oc += 1;
        }

        return out[0..oc];
    }

    fn neighborsSkipLast(self: *Map, x: u8, y: u8, lx: u8, ly: u8) [][2]u8 {
        var out: [4][2]u8 = undefined;
        var oc: u8 = 0;

        for (dirmods) |mod| {
            var inx: i16 = @intCast(x);
            var iny: i16 = @intCast(y);
            inx += mod[0];
            iny += mod[1];

            if (inx < 0 or iny < 0 or inx >= self.maxx or iny >= self.maxy) {
                continue;
            }

            const nx: u8 = @intCast(inx);
            const ny: u8 = @intCast(iny);

            //print("Neighbor ({}, {}) in bounds ({}, {})\n", .{ inx, iny, nx, ny });
            //print("Last is ({}, {})\n", .{ lx, ly });

            if (nx == lx and ny == ly) {
                continue;
            }

            if (self.tiles[ny][nx].walkable) {
                //print("Neighbor ({}, {}) is walkable\n", .{ nx, ny });
                out[oc] = .{ nx, ny };
                oc += 1;
            }
        }

        return out[0..oc];
    }

    fn walkFrom(self: *Map, steps: *[141 * 141][2]u8, start_count: usize, start_x: u8, start_y: u8) usize {
        var sc = start_count;
        var x: u8 = start_x;
        var y: u8 = start_y;
        const tiles = &self.tiles;
        //print("Walking from ({}, {})\n", .{ x, y });

        while (true) {
            steps[sc] = .{ x, y };
            tiles[y][x].visited = true;
            sc += 1;
            const ns = self.neighborsUnvisited(x, y);

            //print("Ns len {}\n", .{ns.len});
            // Dead end
            if (ns.len == 0) {
                if (y == self.endy and x == self.endx) {
                    //print("Found path of length {}\n", .{sc});
                    //for (0..sc) |i| {
                    //    const step = steps[i];
                    //    print("({}, {})\n", .{ step[0], step[1] });
                    //}
                    for (start_count..sc) |i| {
                        const step = steps[i];
                        tiles[step[1]][step[0]].visited = false;
                    }
                    return sc;
                } else {
                    for (start_count..sc) |i| {
                        const step = steps[i];
                        tiles[step[1]][step[0]].visited = false;
                    }
                    //print("Dead end at ({}, {})\n", .{ x, y });
                    return 0;
                }
            }

            // Split here
            if (ns.len > 1) {
                var res: usize = 0;
                for (ns) |n| {
                    res = @max(res, self.walkFrom(steps, sc, n[0], n[1]));
                }
                for (start_count..sc) |i| {
                    const step = steps[i];
                    tiles[step[1]][step[0]].visited = false;
                }
                return res;
            }

            x = ns[0][0];
            y = ns[0][1];
            //print("Stepped to ({}, {})\n", .{ x, y });
        }
    }

    pub fn rawWalk(self: *Map) usize {
        var steps: [141 * 141][2]u8 = comptime std.mem.zeroes([141 * 141][2]u8);
        const sx = @as(u8, @truncate(self.startx));
        const sy = @as(u8, @truncate(self.starty));
        steps[0] = .{ sx, sy };
        const res = self.walkFrom(&steps, 0, sx, sy);
        if (res == 0) {
            //print("No path found\n", .{});
            return 0;
        }
        return res - 1;
    }

    inline fn makeNode(self: *Map, node: Node) *Node {
        self.nodes[self.nodecount] = node;
        self.nodecount += 1;
        return &self.nodes[self.nodecount - 1];
    }

    fn walkBuildNode(self: *Map, startnode: *Node) void {
        //print("Walkbuildinging from ({}, {})\n", .{ startnode.x, startnode.y });
        const sx: u8 = startnode.x;
        const sy: u8 = startnode.y;
        var pts: [4][2]u8 = undefined;
        var ptc: usize = 0;
        const start_neighbors = self.neighborsUnvisited(sx, sy);
        for (start_neighbors) |n| {
            pts[ptc] = n;
            ptc += 1;
        }
        var tiles = &self.tiles;

        outerfor: for (pts[0..ptc]) |starts| {
            var steps: u16 = 1;
            var lx: u8 = sx;
            var ly: u8 = sy;
            var nx: u8 = starts[0];
            var ny: u8 = starts[1];
            //print("Starting at ({}, {})\n", .{ nx, ny });
            //print("SLX: {}, SLY: {}, NX: {}, NY: {}\n", .{ lx, ly, nx, ny });

            while (true) {
                //print("Walking from ({}, {}) to ({}, {})\n", .{ lx, ly, nx, ny });
                tiles[ny][nx].visited = true;
                const ns = self.neighborsSkipLast(nx, ny, lx, ly);
                if (ns.len != 1) {
                    var oendnode: ?*Node = null;
                    if (tiles[ny][nx].node) |inode| {
                        oendnode = inode;
                    } else {
                        tiles[ny][nx].node = self.makeNode(.{ .x = nx, .y = ny });
                        tiles[ny][nx].intersection = true;
                        oendnode = tiles[ny][nx].node;
                    }
                    const endnode = oendnode orelse unreachable;
                    //print("Connecting ({}, {}) to ({}, {}) with weight {}\n", .{ startnode.x, startnode.y, endnode.x, endnode.y, steps });
                    startnode.steps[startnode.stepcount] = .{ .weight = steps, .end = tiles[ny][nx].node orelse unreachable };
                    startnode.stepcount += 1;
                    endnode.steps[endnode.stepcount] = .{ .weight = steps, .end = startnode };
                    endnode.stepcount += 1;
                    continue :outerfor;
                }
                lx = nx;
                ly = ny;
                nx = ns[0][0];
                ny = ns[0][1];
                //print("Stepped to ({}, {})\n", .{ nx, ny });
                steps += 1;
            }
        }
    }

    fn buildNodes(self: *Map) void {
        //print("STarts at ({}, {})\n", .{ self.startx, self.starty });
        self.tiles[self.starty][self.startx].visited = true;
        self.tiles[self.starty][self.startx].node = self.makeNode(.{ .x = @intCast(self.startx), .y = @intCast(self.starty) });
        var n: usize = 0;
        while (n < self.nodecount) : (n += 1) {
            self.walkBuildNode(&self.nodes[n]);
        }
    }

    fn walkFromNode(self: *Map, steps: *[1000]*Node, sc: usize, stepcount: usize) usize {
        var node = steps[sc];
        if (node.x == self.endx and node.y == self.endy) {
            return stepcount;
        }

        node.visited = true;

        var longest: usize = 0;

        for (node.steps[0..node.stepcount]) |step| {
            if (step.end.visited) continue;
            const end = step.end;
            steps[sc + 1] = end;
            const res = self.walkFromNode(steps, sc + 1, stepcount + step.weight);
            longest = @max(longest, res);
        }

        node.visited = false;
        return longest;
    }

    pub fn rawWalkNodes(self: *Map) usize {
        var steps: [1000]*Node = undefined;

        const sx = @as(u8, @truncate(self.startx));
        const sy = @as(u8, @truncate(self.starty));
        steps[0] = self.tiles[sy][sx].node orelse unreachable;
        const res = self.walkFromNode(&steps, 0, 0);
        if (res == 0) {
            //print("No path found\n", .{});
            return 0;
        }
        return res;
    }
};

const Step = struct {
    weight: u16,
    end: *Node,
};

const Node = struct {
    visited: bool = false,
    steps: [4]Step = undefined,
    stepcount: u8 = 0,
    x: u8,
    y: u8,
};

pub fn part1(input: []const u8) usize {
    var map: Map = undefined;

    map.build(input);

    //print("start: ({}, {})\n", .{ map.startx, map.starty });
    //print("end: ({}, {})\n", .{ map.endx, map.endy });

    const res = map.rawWalk();

    return res;
}

test "day23_part2" {
    const res = part2(testdata);
    assert(res == 154);
}

pub fn part2(input: []const u8) usize {
    var map: Map = undefined;

    map.build(input);

    //print("start: ({}, {})\n", .{ map.startx, map.starty });
    //print("end: ({}, {})\n", .{ map.endx, map.endy });

    map.buildNodes();
    const res = map.rawWalkNodes();

    return res;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Part 1: {}\n", .{res});
    print("Part 2: {}\n", .{res2});
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
