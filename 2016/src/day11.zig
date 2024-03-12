const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day11.txt");
const testdata = "The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.\r\nThe second floor contains a hydrogen generator.\r\nThe third floor contains a lithium generator.\r\nThe fourth floor contains nothing relevant.";

const elements = std.ComptimeStringMap(u8, .{
    .{ "hydrogen", 0 },
    .{ "lithium", 1 },
    .{ "thulium", 0 },
    .{ "plutonium", 1 },
    .{ "strontium", 2 },
    .{ "promethium", 3 },
    .{ "ruthenium", 4 },
    //.{ "elerium", 5 },
    //.{ "dilithium", 6 },
});

test "day11_part1" {
    const res = part1(testdata);
    print("Test result: {}\n", .{res});
    assert(res == 11);
}

const typecount = if (builtin.is_test) 2 else 5;
const extracount = typecount + 2;

fn State(tc: usize) type {
    return struct {
        elev: u3,
        chips: [tc]u3,
        gens: [tc]u3,
    };
}

//const State = struct {
//    elev: u3,
//    chips: [typecount]u3,
//    gens: [typecount]u3,
//};

const Action = enum { Queue, Skip, Win };

fn checkState(state: anytype, map: *Map(@TypeOf(state), void)) Action {
    const e = map.getOrPut(state) catch unreachable;
    if (e.found_existing) return .Skip;
    for (0..typecount) |i| {
        if (state.chips[i] != state.gens[i]) {
            const j = indexOf(u3, &state.gens, state.chips[i]);
            if (j != null) return .Skip;
        }
    }
    var win: bool = true;
    for (0..typecount) |i| {
        if (state.chips[i] != 3) win = false;
        if (state.gens[i] != 3) win = false;
    }
    if (win) return .Win;
    return .Queue;
}

fn sortPair(_: void, a: [2]u3, b: [2]u3) bool {
    if (a[0] != b[0]) return a[0] < b[0];
    return a[1] < b[1];
}

fn sortState(state: anytype) @TypeOf(state) {
    var pairs: [typecount][2]u3 = undefined;
    for (0..typecount) |i| {
        pairs[i] = .{ state.chips[i], state.gens[i] };
    }
    sort([2]u3, &pairs, {}, sortPair);

    var newstate = @TypeOf(state){ .elev = state.elev, .chips = undefined, .gens = undefined };
    for (0..typecount) |i| {
        newstate.chips[i] = pairs[i][0];
        newstate.gens[i] = pairs[i][1];
    }

    return newstate;
}

pub fn part1(input: []const u8) usize {
    //var membuffer: [6000000]u8 = undefined;
    //var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    //const alloc = alloc_impl.allocator();
    const alloc = gpa;
    var lines = splitSeq(u8, input, "\r\n");
    var state: State(typecount) = .{ .elev = 0, .chips = undefined, .gens = undefined };
    for (0..3) |floor| {
        const line = lines.next().?;
        var words = splitSca(u8, line, ' ');
        var last: []const u8 = line[0..1];
        while (words.next()) |word| {
            const cword = if (word[word.len - 1] == ',' or word[word.len - 1] == '.') word[0 .. word.len - 1] else word;
            if (std.mem.eql(u8, cword, "microchip")) {
                //print("Found microchip: {s}\n", .{last});
                const dash = indexOf(u8, last, '-').?;
                const element = last[0..dash];
                print("Element: {s}\n", .{element});
                const eid = elements.get(element).?;
                state.chips[eid] = @intCast(floor);
            } else if (std.mem.eql(u8, cword, "generator")) {
                //print("Found generator: {s}\n", .{last});
                const element = last;
                print("Element: {s}\n", .{element});
                const eid = elements.get(element).?;
                state.gens[eid] = @intCast(floor);
            }
            last = word;
        }
    }
    print("{any}, {any}, {}\n", .{ state.chips, state.gens, state.elev });

    var map = Map(State(typecount), void).init(alloc);
    var queue: [50000]State(typecount) = undefined;
    var qstart: usize = 0;
    var qend: usize = 0;

    map.put(state, {}) catch unreachable;
    queue[qend] = state;
    qend += 1;
    var steps: usize = 1;
    var nextstep: usize = 1;
    while (qstart != qend) : (qstart += 1) {
        if (qstart == nextstep) {
            steps += 1;
            print("Checking step {}\n", .{steps});
            nextstep = qend;
        }
        if (qstart == queue.len) qstart = 0;
        const current = queue[qstart];
        var nbuffer: [2]u3 = undefined;
        const neighbor_floors: []u3 = blk: {
            if (current.elev == 0) {
                nbuffer[0] = 1;
                break :blk nbuffer[0..1];
            } else if (current.elev == 3) {
                nbuffer[0] = 2;
                break :blk nbuffer[0..1];
            } else {
                nbuffer[0] = current.elev - 1;
                nbuffer[1] = current.elev + 1;
                break :blk nbuffer[0..2];
            }
        };
        const valarr: *const [1 + (2 * typecount)]u3 = @ptrCast(&current);
        for (neighbor_floors) |nfloor| {
            for (1..valarr.len) |i| {
                if (valarr[i] != current.elev) continue;
                {
                    var newstate = current;
                    newstate.elev = nfloor;
                    const newarr: *[1 + (2 * typecount)]u3 = @ptrCast(&newstate);
                    newarr[i] = nfloor;
                    newstate = sortState(newstate);
                    switch (checkState(newstate, &map)) {
                        .Win => return steps,
                        .Skip => {},
                        .Queue => {
                            //print("Queueing: {any} -> {any}\n", .{ current, newstate });
                            queue[qend] = newstate;
                            qend += 1;
                            if (qend == queue.len) qend = 0;
                            if (qend == qstart) {
                                print("Queue full\n", .{});
                                unreachable;
                            }
                        },
                    }
                }
                for (i + 1..valarr.len) |j| {
                    if (valarr[j] != current.elev) continue;
                    var newstate = current;
                    newstate.elev = nfloor;
                    const newarr: *[1 + (2 * typecount)]u3 = @ptrCast(&newstate);
                    newarr[i] = nfloor;
                    newarr[j] = nfloor;
                    newstate = sortState(newstate);
                    switch (checkState(newstate, &map)) {
                        .Win => return steps,
                        .Skip => {},
                        .Queue => {
                            //print("Queueing: {any} -> {any}\n", .{ current, newstate });
                            queue[qend] = newstate;
                            qend += 1;
                            if (qend == queue.len) qend = 0;
                            if (qend == qstart) {
                                print("Queue full\n", .{});
                                unreachable;
                            }
                        },
                    }
                }
            }
        }
    }
    unreachable;
}

test "day11_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    // Can safely ignore the extra inputs,
    // then just add 24 to the result of part1,
    // since the two pairs of elements are on the first floor.
    return part1(input) + 24;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 11:\n", .{});
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
