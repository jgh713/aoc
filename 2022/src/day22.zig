const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day22.txt");
const testdata = "        ...#\r\n        .#..\r\n        #...\r\n        ....\r\n...#.......#\r\n........#...\r\n..#....#....\r\n..........#.\r\n        ...#....\r\n        .....#..\r\n        .#......\r\n        ......#.\r\n\r\n10R5L5R10L4R5L5";

test "day22_part1" {
    const res = part1(testdata);
    assert(res == 6032);
}

const Tile = enum {
    Edge,
    Wall,
    Open,
};

const Dirs = enum { Right, Down, Left, Up };

const FlatMap = struct {
    map: [201][151]Tile,
    rowmin: [200]usize,
    rowmax: [200]usize,
    colmin: [150]usize,
    colmax: [150]usize,
    startx: usize,
    starty: usize,
    x: usize,
    y: usize,
    dir: u2,

    pub fn init(mapchars: []const u8) FlatMap {
        var map: [201][151]Tile = comptime std.mem.zeroes([201][151]Tile);

        var x: u32 = 0;
        var y: u32 = 0;

        const starty = 0;
        const startx = indexOf(u8, mapchars, '.').?;
        var rowmin: [200]usize = [_]usize{std.math.maxInt(usize)} ** 200;
        var rowmax: [200]usize = comptime std.mem.zeroes([200]usize);
        var colmin: [150]usize = [_]usize{std.math.maxInt(usize)} ** 150;
        var colmax: [150]usize = comptime std.mem.zeroes([150]usize);

        for (mapchars) |c| {
            switch (c) {
                ' ' => {},
                '#' => {
                    map[y][x] = Tile.Wall;
                    colmin[x] = @min(colmin[x], y);
                    colmax[x] = @max(colmax[x], y);
                    rowmin[y] = @min(rowmin[y], x);
                    rowmax[y] = @max(rowmax[y], x);
                },
                '.' => {
                    map[y][x] = Tile.Open;
                    colmin[x] = @min(colmin[x], y);
                    colmax[x] = @max(colmax[x], y);
                    rowmin[y] = @min(rowmin[y], x);
                    rowmax[y] = @max(rowmax[y], x);
                },
                '\r' => {},
                '\n' => {
                    y += 1;
                    x = 0;
                    continue;
                },
                else => unreachable,
            }
            x += 1;
        }
        return FlatMap{
            .map = map,
            .rowmin = rowmin,
            .rowmax = rowmax,
            .colmin = colmin,
            .colmax = colmax,
            .startx = startx,
            .starty = starty,
            .dir = 0,
            .x = startx,
            .y = starty,
        };
    }

    pub fn walkSteps(self: *@This(), dist: usize, dir: Dirs) void {
        switch (dir) {
            Dirs.Right => {
                for (0..dist) |_| {
                    var nx = self.x + 1;
                    if (self.map[self.y][nx] == Tile.Edge) {
                        nx = self.rowmin[self.y];
                    }
                    self.x = switch (self.map[self.y][nx]) {
                        Tile.Wall => return,
                        Tile.Open => nx,
                        Tile.Edge => unreachable,
                    };
                    //print("Stepped to x: {}, y: {}\n", .{ self.x, self.y });
                }
            },
            Dirs.Down => {
                for (0..dist) |_| {
                    var ny = self.y + 1;
                    if (self.map[ny][self.x] == Tile.Edge) {
                        ny = self.colmin[self.x];
                    }
                    self.y = switch (self.map[ny][self.x]) {
                        Tile.Wall => return,
                        Tile.Open => ny,
                        Tile.Edge => unreachable,
                    };
                    //print("Stepped to x: {}, y: {}\n", .{ self.x, self.y });
                }
            },
            Dirs.Left => {
                for (0..dist) |_| {
                    var nx = if (self.x == 0) self.rowmax[self.y] else self.x - 1;
                    if (self.map[self.y][nx] == Tile.Edge) {
                        nx = self.rowmax[self.y];
                    }
                    self.x = switch (self.map[self.y][nx]) {
                        Tile.Wall => return,
                        Tile.Open => nx,
                        Tile.Edge => self.rowmax[self.y],
                    };
                    //print("Stepped to x: {}, y: {}\n", .{ self.x, self.y });
                }
            },
            Dirs.Up => {
                for (0..dist) |_| {
                    var ny = if (self.y == 0) self.colmax[self.x] else self.y - 1;
                    if (self.map[ny][self.x] == Tile.Edge) {
                        ny = self.colmax[self.x];
                    }
                    self.y = switch (self.map[ny][self.x]) {
                        Tile.Wall => return,
                        Tile.Open => ny,
                        Tile.Edge => self.colmax[self.x],
                    };
                    //print("Stepped to x: {}, y: {}\n", .{ self.x, self.y });
                }
            },
        }
    }

    pub fn walkDirs(self: *@This(), directions: []const u8) void {
        var current: usize = 0;
        for (directions) |c| {
            switch (c) {
                '0'...'9' => {
                    current = current * 10 + (c - '0');
                },
                'R' => {
                    self.walkSteps(current, @enumFromInt(self.dir));
                    self.dir = if (self.dir == 3) 0 else self.dir + 1;
                    current = 0;
                },
                'L' => {
                    self.walkSteps(current, @enumFromInt(self.dir));
                    self.dir = if (self.dir == 0) 3 else self.dir - 1;
                    current = 0;
                },
                else => unreachable,
            }
        }
        if (current > 0) {
            self.walkSteps(current, @enumFromInt(self.dir));
        }
    }
};

pub fn part1(input: []const u8) usize {
    var split = splitSeq(u8, input, "\r\n\r\n");

    const mapchars = split.next().?;
    const directions = split.next().?;

    var map = FlatMap.init(mapchars);

    map.walkDirs(directions);

    //print("x: {}, y: {}, dir: {}\n", .{ map.x, map.y, map.dir });

    return (1000 * (map.y + 1)) + (4 * (map.x + 1)) + map.dir;
}

test "day22_part2" {
    const res = part2(testdata);
    assert(res == 5031);
}

const Net = struct {
    map: [50][50]bool,
    size: u8,
    // 0 = topleft, 1 = topright, 2 = bottomright, 3 = bottomleft
    // Ordering is important
    corners: [4]Corners,
    xoff: u8,
    yoff: u8,
};

//   e------f
//  /|     /|
// a------b |
// | g----|-h
// |/     |/ Roll around a cube *underneath* a cube net and
// c------d  store fronting face's top-left coordinates and edges.
//

const Corners = enum {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
};

fn buildCornerMap() [2][2][2]Corners {
    var corners: [2][2][2]Corners = undefined;
    for (0..8) |i| {
        const x = i & 1;
        const y = (i >> 1) & 1;
        const z = (i >> 2) & 1;
        corners[x][y][z] = @enumFromInt(i);
    }
    return corners;
}

const cornermap = buildCornerMap();

const facemap: [6][7]Corners = .{
    .{ .A, .B, .D, .C, .A, .B, .D },
    .{ .G, .H, .F, .E, .G, .H, .F },
    .{ .B, .A, .E, .F, .B, .A, .E },
    .{ .C, .D, .H, .G, .C, .D, .H },
    .{ .B, .F, .H, .D, .B, .F, .H },
    .{ .A, .C, .G, .E, .A, .C, .G },
};

const Step = struct {
    net: u8,
    x: usize,
    y: usize,
    dir: u2,
};

fn nextface(start: [2]Corners) [2]Corners {
    for (facemap) |face| {
        const index = std.mem.indexOfPos(Corners, &face, 0, &start);
        if (index) |i| {
            return .{ face[i + 2], face[i + 3] };
        }
    }
    unreachable;
}

const NetMapBlock = union(enum) {
    unvisited: void,
    net: *Net,
};

// 50, 25 -> 25, 50 -> 0, 25 -> 25, 0

test "rotation" {
    var x: usize = 50;
    var y: usize = 25;
    rotate_clockwise(&x, &y, 1, 51);
    assert(x == 25);
    assert(y == 50);
    rotate_clockwise(&x, &y, 1, 51);
    assert(x == 0);
    assert(y == 25);
    rotate_clockwise(&x, &y, 1, 51);
    assert(x == 25);
    assert(y == 0);
    rotate_clockwise(&x, &y, 1, 51);
    assert(x == 50);
    assert(y == 25);
}

fn rotate_clockwise(x: *usize, y: *usize, rotations: u8, size: u8) void {
    for (0..rotations) |_| {
        const nx = size - 1 - y.*;
        const ny = x.*;
        x.* = nx;
        y.* = ny;
    }
}

const NetMap = struct {
    map: [6]Net,
    net: u8,
    x: usize,
    y: usize,
    dir: u2,

    pub fn init(mapchars: []const u8) NetMap {
        var map: [201][151]Tile = comptime std.mem.zeroes([201][151]Tile);

        var x: u32 = 0;
        var y: u32 = 0;

        const startx: u8 = @truncate(indexOf(u8, mapchars, '.').?);
        var tiles: u16 = 0;

        for (mapchars) |c| {
            switch (c) {
                ' ' => {},
                '#' => {
                    map[y][x] = Tile.Wall;
                    tiles += 1;
                },
                '.' => {
                    map[y][x] = Tile.Open;
                    tiles += 1;
                },
                '\r' => {},
                '\n' => {
                    y += 1;
                    x = 0;
                    continue;
                },
                else => unreachable,
            }
            x += 1;
        }

        const netarea: u16 = tiles / 6;
        const netsize: u8 = std.math.sqrt(netarea);

        const startnetx: u8 = @divExact(startx, netsize);

        var nets: [6]Net = comptime std.mem.zeroes([6]Net);
        var netmap: [6][6]NetMapBlock = undefined;
        for (0..6) |ny| {
            for (0..6) |nx| {
                netmap[ny][nx] = NetMapBlock{
                    .unvisited = {},
                };
            }
        }
        var ni: u8 = 1;

        var holdmap: [50][50]bool = undefined;
        var xoff: u8 = 0;
        var yoff: u8 = 0;

        xoff = startnetx * netsize;
        for (0..netsize) |ny| {
            for (0..netsize) |nx| {
                holdmap[ny][nx] = switch (map[ny + yoff][nx + xoff]) {
                    Tile.Wall => true,
                    Tile.Open => false,
                    Tile.Edge => unreachable,
                };
            }
        }

        var netqueue: [6][2]u8 = undefined;
        var qstart: u8 = 0;
        var qend: u8 = 1;

        netqueue[0] = .{ startnetx, 0 };

        nets[0] = Net{
            .map = holdmap,
            .size = netsize,
            .corners = .{ .A, .B, .D, .C },
            .xoff = xoff,
            .yoff = yoff,
        };

        netmap[0][startnetx] = NetMapBlock{
            .net = &nets[0],
        };

        while (qstart < qend) : (qstart += 1) {
            const coords = netqueue[qstart];
            const net = netmap[coords[1]][coords[0]].net;
            const netx = coords[0];
            const nety = coords[1];
            for (0..3) |dir| {
                var nx: u8 = netx;
                var ny: u8 = nety;
                switch (dir) {
                    0 => {
                        if (nx == 5) {
                            continue;
                        }
                        nx += 1;
                    },
                    1 => {
                        if (ny == 5) {
                            continue;
                        }
                        ny += 1;
                    },
                    2 => {
                        if (nx == 0) {
                            continue;
                        }
                        nx -= 1;
                    },
                    else => unreachable,
                }
                switch (netmap[ny][nx]) {
                    .net => continue,
                    else => {},
                }
                xoff = nx * netsize;
                yoff = ny * netsize;
                if (map[yoff][xoff] == Tile.Edge) {
                    continue;
                }
                //print("nx: {}, ny: {}\n", .{ nx, ny });
                //print("xoff: {}, yoff: {}\n", .{ xoff, yoff });
                for (0..netsize) |nny| {
                    for (0..netsize) |nnx| {
                        holdmap[nny][nnx] = switch (map[nny + yoff][nnx + xoff]) {
                            Tile.Wall => true,
                            Tile.Open => false,
                            Tile.Edge => unreachable,
                        };
                    }
                }
                const shared: [2]Corners = switch (dir) {
                    0 => .{ net.corners[2], net.corners[1] },
                    1 => .{ net.corners[3], net.corners[2] },
                    2 => .{ net.corners[0], net.corners[3] },
                    else => unreachable,
                };
                const next = nextface(shared);
                const newcorners: [4]Corners = switch (dir) {
                    0 => .{ shared[1], next[0], next[1], shared[0] },
                    1 => .{ shared[0], shared[1], next[0], next[1] },
                    2 => .{ next[1], shared[0], shared[1], next[0] },
                    else => unreachable,
                };
                //print("X: {}, Y: {}\n", .{ netx, nety });
                //print("NX: {}, NY: {}\n", .{ nx, ny });
                //print("Current corners are {any}\n", .{net.corners});
                //print("Shared corners are {any}\n", .{shared});
                //print("Next corners are {any}\n", .{next});
                //print("New corners are {any}\n", .{newcorners});
                nets[ni] = Net{
                    .map = holdmap,
                    .size = netsize,
                    .corners = newcorners,
                    .xoff = xoff,
                    .yoff = yoff,
                };
                netmap[ny][nx] = NetMapBlock{
                    .net = &nets[ni],
                };
                netqueue[qend] = .{ nx, ny };
                qend += 1;
                ni += 1;
            }
        }

        return NetMap{
            .map = nets,
            .net = 0,
            .x = 0,
            .y = 0,
            .dir = 0,
        };
    }

    pub fn findface(self: *@This(), shared: [2]Corners) u8 {
        //print("Finding face {any}\n", .{shared});
        for (0..6) |ni| {
            //print("Checking net {}\n", .{ni});
            const net = self.map[ni];
            //print("Corners are {any}\n", .{net.corners});
            for (0..4) |i| {
                if (net.corners[i] == shared[0] and net.corners[(i + 1) % 4] == shared[1]) {
                    return @truncate(ni);
                }
            }
        }
        unreachable;
    }

    pub fn nextStep(self: *@This()) Step {
        const net = self.map[self.net];
        var step = Step{
            .net = self.net,
            .dir = self.dir,
            .x = self.x,
            .y = self.y,
        };
        const mods: [2]i65 = switch (self.dir) {
            0 => .{ 1, 0 },
            1 => .{ 0, 1 },
            2 => .{ -1, 0 },
            3 => .{ 0, -1 },
        };
        var inx = mods[0] + step.x;
        var iny = mods[1] + step.y;
        if (inx >= 0 and inx < net.size and iny >= 0 and iny < net.size) {
            step.x = @truncate(@abs(inx));
            step.y = @truncate(@abs(iny));
            return step;
        }
        const shared: [2]Corners = switch (self.dir) {
            0 => .{ net.corners[2], net.corners[1] },
            1 => .{ net.corners[3], net.corners[2] },
            2 => .{ net.corners[0], net.corners[3] },
            3 => .{ net.corners[1], net.corners[0] },
        };
        const next = self.findface(shared);
        const nextnet = self.map[next];
        const expected_index: u8 = switch (self.dir) {
            0 => 3,
            1 => 0,
            2 => 1,
            3 => 2,
        };
        //print("Current net corners: {any}\n", .{net.corners});
        //print("Expected index: {}, Shared: {any}\n", .{ expected_index, shared });
        //print("Next net corners: {any}\n", .{nextnet.corners});

        const actual_index = indexOf(Corners, &nextnet.corners, shared[0]).?;
        //print("Actual index: {}\n", .{actual_index});
        const rotations_needed: u8 = @truncate((4 + actual_index - expected_index) % 4);
        //print("Rotations needed: {}\n", .{rotations_needed});
        const newdir: u2 = @truncate((self.dir + rotations_needed) % 4);
        if (inx < 0) {
            inx += nextnet.size;
        } else if (inx >= nextnet.size) {
            inx -= nextnet.size;
        }
        if (iny < 0) {
            iny += nextnet.size;
        } else if (iny >= nextnet.size) {
            iny -= nextnet.size;
        }
        var nx: usize = @truncate(@abs(inx));
        var ny: usize = @truncate(@abs(iny));
        rotate_clockwise(&nx, &ny, rotations_needed, nextnet.size);
        return Step{
            .net = next,
            .x = nx,
            .y = ny,
            .dir = newdir,
        };
    }

    pub fn walkSteps(self: *@This(), dist: usize) void {
        for (0..dist) |_| {
            //print("Stepped from net: {}, x: {}, y: {}, dir: {}\n", .{ self.net, self.x, self.y, @as(Dirs, @enumFromInt(self.dir)) });
            const next = self.nextStep();
            //print("Stepped to net: {}, x: {}, y: {}, dir: {}\n", .{ next.net, next.x, next.y, @as(Dirs, @enumFromInt(next.dir)) });
            if (self.map[next.net].map[next.y][next.x]) {
                //print("Hit wall, backing out.\n", .{});
                return;
            }
            self.x = next.x;
            self.y = next.y;
            self.dir = next.dir;
            self.net = next.net;
        }
    }

    pub fn walkDirs(self: *@This(), directions: []const u8) void {
        var current: usize = 0;
        for (directions) |c| {
            switch (c) {
                '0'...'9' => {
                    current = current * 10 + (c - '0');
                },
                'R' => {
                    self.walkSteps(current);
                    //print("Stepped {} times to net: {}, x: {}, y: {}, dir: {}\n", .{ current, self.net, self.x, self.y, self.dir });
                    self.dir = if (self.dir == 3) 0 else self.dir + 1;
                    current = 0;
                },
                'L' => {
                    self.walkSteps(current);
                    //print("Stepped {} times to net: {}, x: {}, y: {}, dir: {}\n", .{ current, self.net, self.x, self.y, self.dir });
                    self.dir = if (self.dir == 0) 3 else self.dir - 1;
                    current = 0;
                },
                else => unreachable,
            }
        }
        if (current > 0) {
            self.walkSteps(current);
        }
    }
};

pub fn part2(input: []const u8) usize {
    var split = splitSeq(u8, input, "\r\n\r\n");

    const mapchars = split.next().?;
    const directions = split.next().?;

    var map = NetMap.init(mapchars);
    map.walkDirs(directions);

    //for (map.map, 0..) |net, ni| {
    //    print("Net: {}\n", .{ni});
    //    for (0..net.size) |y| {
    //        for (0..net.size) |x| {
    //            if (net.map[y][x]) {
    //                print("#", .{});
    //            } else {
    //                print(".", .{});
    //            }
    //        }
    //        print("\n", .{});
    //    }
    //    print("\n", .{});
    //}

    const mx = map.x + map.map[map.net].xoff + 1;
    const my = map.y + map.map[map.net].yoff + 1;

    //print("x: {}, y: {}, dir: {}\n", .{ mx, my, map.dir });

    return (1000 * (my)) + (4 * (mx)) + map.dir;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 22:\n", .{});
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
