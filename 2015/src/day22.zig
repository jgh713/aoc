const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day22.txt");
const testdata = "";

test "day22_part1" {
    const res = part1(testdata);
    assert(res == 0);
}

const Spells = enum {
    MagicMissile,
    Drain,
    Shield,
    Poison,
    Recharge,
};

const costs = [_]usize{ 53, 73, 113, 173, 229 };

const Player = struct {
    hp: usize,
    mana: usize,
};

const Boss = struct {
    hp: usize,
    damage: usize,
};

const GameState = struct {
    player: Player,
    boss: Boss,
    mana_spent: usize,
    shield: u8,
    poison: u8,
    recharge: u8,
    //choice: ?Spells,
    //last: ?*GameState,
};
inline fn getInt(line: []const u8) u8 {
    const off = indexOf(u8, line, ':').? + 2;
    return parseInt(u8, line[off..], 10) catch unreachable;
}

pub fn orderGameStates(_: void, a: GameState, b: GameState) std.math.Order {
    if (a.mana_spent < b.mana_spent) {
        return .lt;
    } else if (a.mana_spent > b.mana_spent) {
        return .gt;
    }
    return .eq;
}

pub fn processTurn(state: *GameState, hardmode: bool) void {
    if (hardmode) {
        state.player.hp -|= 1;
        if (state.player.hp == 0) return;
    }
    if (state.shield > 0) {
        state.shield -= 1;
    }
    if (state.poison > 0) {
        state.boss.hp -|= 3;
        state.poison -= 1;
    }
    if (state.recharge > 0) {
        state.player.mana += 101;
        state.recharge -= 1;
    }
    if (state.boss.hp == 0) return;
    const armor: usize = if (state.shield > 0) 7 else 0;
    const damage = @max(1, state.boss.damage -| armor);
    state.player.hp -|= damage;
    if (state.player.hp == 0) return;
    if (state.shield > 0) {
        state.shield -= 1;
    }
    if (state.poison > 0) {
        state.boss.hp -|= 3;
        state.poison -= 1;
    }
    if (state.recharge > 0) {
        state.player.mana += 101;
        state.recharge -= 1;
    }
}

fn castable(state: GameState, spell: Spells) bool {
    if (costs[@intFromEnum(spell)] > state.player.mana) {
        return false;
    }
    switch (spell) {
        Spells.Shield => return state.shield == 0,
        Spells.Poison => return state.poison == 0,
        Spells.Recharge => return state.recharge == 0,
        else => return true,
    }
}

fn spellEffect(state: *GameState, spell: Spells) void {
    const cost = costs[@intFromEnum(spell)];
    state.player.mana -= cost;
    state.mana_spent += cost;
    switch (spell) {
        Spells.MagicMissile => state.boss.hp -|= 4,
        Spells.Drain => {
            state.boss.hp -|= 2;
            state.player.hp += 2;
        },
        Spells.Shield => state.shield = 6,
        Spells.Poison => state.poison = 6,
        Spells.Recharge => state.recharge = 5,
    }
}

// I can't read, apparently.
// Must cast spell each turn.
//fn isWin(instate: GameState) bool {
//    var state = instate;
//    while (state.boss.hp > 0 and state.player.hp > 0 and state.poison > 0) {
//        processTurn(&state);
//    }
//    return (state.boss.hp == 0);
//}

pub fn runGame(input: []const u8, hardmode: bool) usize {
    //var membuffer: [6000000]u8 = undefined;
    //var alloc_impl = std.heap.FixedBufferAllocator.init(&membuffer);
    //const alloc = alloc_impl.allocator();
    //const alloc = gpa;
    var alloc_impl = std.heap.ArenaAllocator.init(gpa);
    const alloc = alloc_impl.allocator();
    defer _ = alloc_impl.reset(.free_all);
    var lines = splitSeq(u8, input, "\r\n");
    const boss = Boss{
        .hp = getInt(lines.next().?),
        .damage = getInt(lines.next().?),
    };
    //print("Boss: {any}\n", .{boss});

    const base_game = GameState{
        .player = Player{ .hp = 50, .mana = 500 },
        .boss = boss,
        .mana_spent = 0,
        .shield = 0,
        .poison = 0,
        .recharge = 0,
        //.choice = null,
        //.last = null,
    };

    var queue = std.PriorityQueue(GameState, void, orderGameStates).init(alloc, {});
    queue.add(base_game) catch unreachable;

    //var minptr = &base_game;

    //var min: usize = std.math.maxInt(usize);
    while (queue.len > 0) {
        const state = queue.remove();
        //if (state.mana_spent > min) {
        //    continue;
        //}
        //print("Lowest state: {any}\n", .{state});
        for (0..5) |spellid| {
            const spell: Spells = @enumFromInt(spellid);
            if (castable(state, spell)) {
                //print("Casting spell: {any}\n", .{spell});
                var newstate = state;
                newstate = state;
                //newstate.choice = spell;
                //newstate.last = state;
                spellEffect(&newstate, spell);
                //if (newstate.mana_spent > min) {
                //    continue;
                //}
                processTurn(&newstate, hardmode);
                //print("New state: {any}\n", .{newstate});
                if (newstate.player.hp == 0) {
                    continue;
                }
                if (newstate.boss.hp == 0) {
                    return newstate.mana_spent;
                }
                queue.add(newstate) catch unreachable;
            }
        }
    }

    //var s: ?*GameState = minptr;
    //while (s) |sv| {
    //    print("State:\n", .{});
    //    print("Choice: {?}\n", .{sv.choice});
    //    print("Mana spent: {}\n", .{sv.mana_spent});
    //    print("Player: {any}\n", .{sv.player});
    //    print("Boss: {any}\n", .{sv.boss});
    //    print("Shield: {}, Poison: {}, Recharge: {}\n\n", .{ sv.shield, sv.poison, sv.recharge });
    //    s = sv.last;
    //}

    return 0;
}

fn part1(input: []const u8) usize {
    return runGame(input, false);
}

test "day22_part2" {
    const res = part2(testdata);
    assert(res == 0);
}

pub fn part2(input: []const u8) usize {
    return runGame(input, true);
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
