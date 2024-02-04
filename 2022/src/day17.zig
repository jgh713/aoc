const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day17.txt");
const testdata = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>";

test "day17_part1" {
    const res = part1(testdata);
    assert(res == 3068);
}

const Blocks = enum {
    Flat,
    Cross,
    L,
    Pole,
    Square,
};

const Dirs = enum {
    Left,
    Right,
    Down,
};

const linebuffer = 100;

const Blockers = struct {
    blocks: [4][2]i8,
    count: u8,
};

const State = struct {
    block: Blocks,
    blocks: [40][8]bool,
};

const Cache = struct {
    blockstep: usize = 0,
    maxy: usize = 0,
};

const Tunnel = struct {
    blocks: [linebuffer][8]bool = std.mem.zeroes([linebuffer][8]bool),
    winds: [11000]bool,
    floor: usize = 0,
    ceiling: usize = 40,
    maxy: usize = 0,
    windcount: u16,
    windstep: u16 = 0,
    blockstep: usize = 0,
    block: Blocks = undefined,
    x: usize = undefined,
    y: usize = undefined,
    target: usize = 0,
    cachemap: Map(State, Cache) = undefined,
    skipped: bool = false,

    pub fn init(input: []const u8) Tunnel {
        var windcount: u16 = 0;
        var winds: [11000]bool = undefined;
        for (input) |c| {
            switch (c) {
                '<' => {
                    winds[windcount] = false;
                    windcount += 1;
                },
                '>' => {
                    winds[windcount] = true;
                    windcount += 1;
                },
                else => unreachable,
            }
        }

        return Tunnel{
            .winds = winds,
            .windcount = windcount,
            .cachemap = Map(State, Cache).init(gpa),
        };
    }

    fn nextblock(this: *@This()) void {
        this.block = @enumFromInt(this.blockstep % 5);
        this.blockstep += 1;
    }

    fn nextwind(this: *@This()) Dirs {
        const wind = this.winds[this.windstep];
        this.windstep = (this.windstep + 1) % this.windcount;
        if (!this.skipped and this.windstep == 0 and this.target > 0 and this.blockstep > 200) {
            var blocks: [40][8]bool = comptime std.mem.zeroes([40][8]bool);
            for (this.ceiling - 40..this.ceiling, 0..) |i, bi| {
                blocks[bi] = this.blocks[i % linebuffer];
            }
            const state = State{ .block = this.block, .blocks = blocks };
            const entry = this.cachemap.getOrPut(state) catch unreachable;
            if (entry.found_existing) {
                const clen = this.blockstep - entry.value_ptr.blockstep;
                const cheight = this.maxy - entry.value_ptr.maxy;
                //print("Cycle found: {} by {}\n", .{ clen, cheight });
                const stepsleft = this.target - this.blockstep;
                const cyclesleft = stepsleft / clen;
                const hoffset = cyclesleft * cheight;
                this.maxy += hoffset;
                this.y += hoffset;
                this.ceiling += hoffset;
                this.floor = this.ceiling - 40;
                this.blockstep += cyclesleft * clen;
                for (this.floor..this.ceiling, 0..) |it, bit| {
                    this.blocks[it % linebuffer] = blocks[bit];
                }
                this.skipped = true;
            } else {
                entry.value_ptr.* = Cache{ .blockstep = this.blockstep, .maxy = this.maxy };
            }
        }
        return if (wind) Dirs.Right else Dirs.Left;
    }

    fn blockHeight(this: *@This()) u8 {
        switch (this.block) {
            .Flat => return 1,
            .Cross => return 3,
            .L => return 3,
            .Pole => return 4,
            .Square => return 2,
        }
    }

    fn marksolids(this: *@This()) void {
        switch (this.block) {
            .Flat => {
                for ([_][2]i8{ .{ 0, 0 }, .{ 1, 0 }, .{ 2, 0 }, .{ 3, 0 } }) |coords| {
                    const ibx = @as(i65, @intCast(this.x)) + coords[0];
                    const iby = @as(i65, @intCast(this.y)) + coords[1];
                    const bx: usize = @as(usize, @intCast(ibx));
                    const by: usize = @as(usize, @intCast(iby));
                    this.blocks[by % linebuffer][bx % linebuffer] = true;
                }
            },
            .Cross => {
                for ([_][2]i8{ .{ 1, 0 }, .{ 0, 1 }, .{ 1, 1 }, .{ 1, 2 }, .{ 2, 1 } }) |coords| {
                    const ibx = @as(i65, @intCast(this.x)) + coords[0];
                    const iby = @as(i65, @intCast(this.y)) + coords[1];
                    const bx: usize = @as(usize, @intCast(ibx));
                    const by: usize = @as(usize, @intCast(iby));
                    this.blocks[by % linebuffer][bx % linebuffer] = true;
                }
            },
            .L => {
                for ([_][2]i8{ .{ 0, 0 }, .{ 1, 0 }, .{ 2, 0 }, .{ 2, 1 }, .{ 2, 2 } }) |coords| {
                    const ibx = @as(i65, @intCast(this.x)) + coords[0];
                    const iby = @as(i65, @intCast(this.y)) + coords[1];
                    const bx: usize = @as(usize, @intCast(ibx));
                    const by: usize = @as(usize, @intCast(iby));
                    this.blocks[by % linebuffer][bx % linebuffer] = true;
                }
            },
            .Pole => {
                for ([_][2]i8{ .{ 0, 0 }, .{ 0, 1 }, .{ 0, 2 }, .{ 0, 3 } }) |coords| {
                    const ibx = @as(i65, @intCast(this.x)) + coords[0];
                    const iby = @as(i65, @intCast(this.y)) + coords[1];
                    const bx: usize = @as(usize, @intCast(ibx));
                    const by: usize = @as(usize, @intCast(iby));
                    this.blocks[by % linebuffer][bx % linebuffer] = true;
                }
            },
            .Square => {
                for ([_][2]i8{ .{ 0, 0 }, .{ 1, 0 }, .{ 0, 1 }, .{ 1, 1 } }) |coords| {
                    const ibx = @as(i65, @intCast(this.x)) + coords[0];
                    const iby = @as(i65, @intCast(this.y)) + coords[1];
                    const bx: usize = @as(usize, @intCast(ibx));
                    const by: usize = @as(usize, @intCast(iby));
                    this.blocks[by % linebuffer][bx % linebuffer] = true;
                }
            },
        }
    }

    fn blockers(this: *@This(), dir: Dirs) Blockers {
        var out: [4][2]i8 = comptime std.mem.zeroes([4][2]i8);
        var count: u8 = 0;
        switch (this.block) {
            // ####
            .Flat => {
                switch (dir) {
                    .Left => {
                        out[0] = .{ -1, 0 };
                        count = 1;
                    },
                    .Right => {
                        out[0] = .{ 4, 0 };
                        count = 1;
                    },
                    .Down => {
                        out = .{ .{ 0, -1 }, .{ 1, -1 }, .{ 2, -1 }, .{ 3, -1 } };
                        count = 4;
                    },
                }
            },
            // .#.
            // ###
            // .#.
            .Cross => {
                switch (dir) {
                    .Left => {
                        out[0] = .{ 0, 0 };
                        out[1] = .{ -1, 1 };
                        out[2] = .{ 0, 2 };
                        count = 3;
                    },
                    .Right => {
                        out[0] = .{ 2, 0 };
                        out[1] = .{ 3, 1 };
                        out[2] = .{ 2, 2 };
                        count = 3;
                    },
                    .Down => {
                        out[0] = .{ 0, 0 };
                        out[1] = .{ 1, -1 };
                        out[2] = .{ 2, 0 };
                        count = 3;
                    },
                }
            },
            // ..#
            // ..#
            // ###
            .L => {
                switch (dir) {
                    .Left => {
                        out[0] = .{ -1, 0 };
                        out[1] = .{ 1, 1 };
                        out[2] = .{ 1, 2 };
                        count = 3;
                    },
                    .Right => {
                        out[0] = .{ 3, 0 };
                        out[1] = .{ 3, 1 };
                        out[2] = .{ 3, 2 };
                        count = 3;
                    },
                    .Down => {
                        out[0] = .{ 0, -1 };
                        out[1] = .{ 1, -1 };
                        out[2] = .{ 2, -1 };
                        count = 3;
                    },
                }
            },
            // #
            // #
            // #
            // #
            .Pole => {
                switch (dir) {
                    .Left => {
                        out[0] = .{ -1, 0 };
                        out[1] = .{ -1, 1 };
                        out[2] = .{ -1, 2 };
                        out[3] = .{ -1, 3 };
                        count = 4;
                    },
                    .Right => {
                        out[0] = .{ 1, 0 };
                        out[1] = .{ 1, 1 };
                        out[2] = .{ 1, 2 };
                        out[3] = .{ 1, 3 };
                        count = 4;
                    },
                    .Down => {
                        out[0] = .{ 0, -1 };
                        count = 1;
                    },
                }
            },
            // ##
            // ##
            .Square => {
                switch (dir) {
                    .Left => {
                        out[0] = .{ -1, 0 };
                        out[1] = .{ -1, 1 };
                        count = 2;
                    },
                    .Right => {
                        out[0] = .{ 2, 0 };
                        out[1] = .{ 2, 1 };
                        count = 2;
                    },
                    .Down => {
                        out[0] = .{ 0, -1 };
                        out[1] = .{ 1, -1 };
                        count = 2;
                    },
                }
            },
        }

        return Blockers{ .blocks = out, .count = count };
    }

    fn isBlocked(this: *@This(), dir: Dirs) bool {
        const blocks = this.blockers(dir);
        for (0..blocks.count) |i| {
            const ibx = @as(i65, @intCast(this.x)) + blocks.blocks[i][0];
            const iby = @as(i65, @intCast(this.y)) + blocks.blocks[i][1];
            const bx: usize = @as(usize, @intCast(ibx));
            const by: usize = @as(usize, @intCast(iby));
            if (bx == 0 or bx == 8 or by == 0) return true;
            if (this.blocks[by % linebuffer][bx % linebuffer]) return true;
        }
        return false;
    }

    pub fn clearCacheTo(this: *@This(), newceil: usize) void {
        if (newceil > this.ceiling) {
            for (this.ceiling..newceil) |i| {
                this.blocks[i % linebuffer] = comptime std.mem.zeroes([8]bool);
            }
        }
        this.ceiling = newceil;
        if (this.ceiling >= linebuffer) {
            this.floor = this.ceiling - (linebuffer - 1);
        }
    }

    pub fn dropBlock(this: *@This()) void {
        this.nextblock();

        //print("Dropping {}\n", .{this.block});

        // These could probably be local vars but I didn't want to pass them everywhere
        // so instead they're part of the struct
        // I'll probably regret this later in part 2
        this.x = 3;
        this.y = this.maxy + 4;
        this.clearCacheTo(this.y + this.blockHeight());

        while (true) {
            const winddir = this.nextwind();
            if (!this.isBlocked(winddir)) {
                if (winddir == Dirs.Right) {
                    this.x += 1;
                } else {
                    this.x -= 1;
                }
            }
            if (this.isBlocked(Dirs.Down)) {
                this.maxy = @max(this.maxy, this.y + this.blockHeight() - 1);
                this.marksolids();
                return;
            }
            this.y -= 1;
            if (this.y <= this.floor) {
                print("Reached floor\n", .{});
                print("Maxy: {}\n", .{this.maxy});
                print("Y: {}\n", .{this.y});
                print("Floor: {}\n", .{this.floor});
                print("Ceiling: {}\n", .{this.ceiling});
                unreachable;
            }
        }
        unreachable;
    }

    pub fn dropUntil(this: *@This(), dropcount: usize) void {
        this.target = dropcount;
        while (this.blockstep < dropcount) {
            this.dropBlock();
            //print("Blockstep: {}\n", .{this.blockstep});
            //print("Maxy: {}\n", .{this.maxy});
        }
    }
};

pub fn part1(input: []const u8) usize {
    var map = Tunnel.init(input);

    map.dropUntil(2022);

    return map.maxy;
}

test "day17_part2" {
    const res = part2(testdata);
    assert(res == 1514285714288);
}

pub fn part2(input: []const u8) usize {
    var map = Tunnel.init(input);

    map.dropUntil(1000000000000);

    return map.maxy;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 17:\n", .{});
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
