const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day19.txt");
const testdata = "px{a<2006:qkq,m>2090:A,rfg}\npv{a>1716:R,A}\nlnx{m>1548:A,A}\nrfg{s<537:gd,x>2440:R,A}\nqs{s>3448:A,lnx}\nqkq{x<1416:A,crn}\ncrn{x>2662:A,R}\nin{s<1351:px,qqz}\nqqz{s>2770:qs,m<1801:hdj,R}\ngd{a>3333:R,R}\nhdj{m>838:A,pv}\n\n{x=787,m=2655,a=1222,s=2876}\n{x=1679,m=44,a=2067,s=496}\n{x=2036,m=264,a=79,s=2244}\n{x=2461,m=1339,a=466,s=291}\n{x=2127,m=1623,a=2188,s=1013}";
test "day19_part1" {
    const res = part1(testdata);
    assert(res == 19114);
}

const Condition = enum { LT, GT };

const Rule = struct {
    condition: ?Condition,
    valueid: u2 = undefined,
    limit: u16 = undefined,
    destination: u16,
};

const Ruleset = [5]Rule;

fn ruleid(str: []const u8) u16 {
    switch (str[0]) {
        'A' => return 0,
        'R' => return 1,
        else => {
            var id: u16 = 0;
            for (str) |c| {
                id <<= 5;
                id |= c - 'a';
            }
            return id;
        },
    }
}

inline fn valueid(c: u8) u2 {
    return switch (c) {
        'x' => 0,
        'm' => 1,
        'a' => 2,
        's' => 3,
        else => unreachable,
    };
}

pub fn part1(input: []const u8) usize {
    var lines = splitSca(u8, input, '\n');
    var rulesets: [65536]Ruleset = undefined;

    while (lines.next()) |line| {
        if (line.len < 2) break;
        const start: usize = indexOf(u8, line, '{').?;
        const end: usize = indexOf(u8, line, '}').?;
        const rule_id = ruleid(line[0..start]);
        var ruleit = splitSca(u8, line[start + 1 .. end], ',');
        var ruleset: Ruleset = undefined;
        var ri: u3 = 0;
        while (ruleit.next()) |rulestr| {
            const rule: Rule = switch (rulestr[0]) {
                'A' => Rule{ .condition = null, .destination = 0 },
                'R' => Rule{ .condition = null, .destination = 1 },
                else => blk: {
                    const colonpos = indexOf(u8, rulestr, ':');
                    if (colonpos) |colon| {
                        const value_id: u2 = valueid(rulestr[0]);
                        const cond: Condition = switch (rulestr[1]) {
                            '>' => Condition.GT,
                            '<' => Condition.LT,
                            else => unreachable,
                        };
                        const limit: u16 = parseInt(u16, rulestr[2..colon], 10) catch unreachable;
                        const dest = ruleid(rulestr[colon + 1 .. rulestr.len]);
                        break :blk Rule{ .condition = cond, .valueid = value_id, .limit = limit, .destination = dest };
                    } else {
                        const dest = ruleid(rulestr);
                        break :blk Rule{ .condition = null, .destination = dest };
                    }
                },
            };
            ruleset[ri] = rule;
            ri += 1;
        }
        //print("Created ruleset for id: {}, rules:\n", .{rule_id});
        //for (ruleset[0..ri]) |rule| {
        //    var cond = "ALL";
        //    if (rule.condition) |c| {
        //        cond = switch (c) {
        //            Condition.LT => "LT<",
        //            Condition.GT => "GT>",
        //        };
        //    }
        //    print("{s} {} {} {}\n", .{ cond, rule.valueid, rule.limit, rule.destination });
        //}
        rulesets[rule_id] = ruleset;
    }

    const start = ruleid("in");

    var total: usize = 0;
    while (lines.next()) |line| {
        var values: [4]u16 = undefined;
        const end = indexOf(u8, line, '}').?;
        var valueit = splitSca(u8, line[1..end], ',');
        for (0..4) |i| {
            const this = valueit.next().?;
            values[i] = parseInt(u16, this[2..], 10) catch unreachable;
        }
        var current: u16 = start;
        while (current > 1) {
            const ruleset = rulesets[current];
            for (ruleset) |rule| {
                if (rule.condition) |cond| {
                    const value = values[rule.valueid];
                    const limit = rule.limit;
                    const match: bool = switch (cond) {
                        Condition.LT => (value < limit),
                        Condition.GT => (value > limit),
                    };
                    if (match) {
                        current = rule.destination;
                        break;
                    }
                } else {
                    current = rule.destination;
                    break;
                }
            }
        }
        if (current == 0) {
            for (values) |v| {
                total += v;
            }
        }
    }
    return total;
}

test "day19_part2" {
    const res = part2(testdata);
    assert(res == 167409079868000);
}

const Range = struct {
    min: u16,
    max: u16,
};

const Rangeset = [4]Range;

fn walkRule(rulesets: [65536]Ruleset, current: u16, inset: Rangeset) usize {
    if (current == 0) {
        var total: usize = 1;
        for (inset) |range| {
            total *= (range.max - range.min + 1);
        }
        return total;
    }
    if (current == 1) {
        return 0;
    }
    var rangeset: Rangeset = inset;
    var total: usize = 0;
    for (rulesets[current]) |rule| {
        if (rule.condition) |cond| {
            const limit = rule.limit;
            const vid: u2 = rule.valueid;
            const value = rangeset[vid];
            switch (cond) {
                Condition.LT => {
                    if (value.min < limit) {
                        var newset: Rangeset = rangeset;
                        newset[vid].max = @min(limit - 1, value.max);
                        total += walkRule(rulesets, rule.destination, newset);
                        const newmin = newset[vid].max + 1;
                        if (newmin > rangeset[vid].max) {
                            return total;
                        }
                        rangeset[vid].min = newmin;
                    }
                },
                Condition.GT => {
                    if (value.max > limit) {
                        var newset: Rangeset = rangeset;
                        newset[vid].min = @max(limit + 1, value.min);
                        total += walkRule(rulesets, rule.destination, newset);
                        const newmax = newset[vid].min - 1;
                        if (newmax < rangeset[vid].min) {
                            return total;
                        }
                        rangeset[vid].max = newmax;
                    }
                },
            }
        } else {
            return total + walkRule(rulesets, rule.destination, rangeset);
        }
    }
    unreachable;
}

pub fn part2(input: []const u8) usize {
    var lines = splitSca(u8, input, '\n');
    var rulesets: [65536]Ruleset = undefined;

    while (lines.next()) |line| {
        if (line.len < 2) break;
        const start: usize = indexOf(u8, line, '{').?;
        const end: usize = indexOf(u8, line, '}').?;
        const rule_id = ruleid(line[0..start]);
        var ruleit = splitSca(u8, line[start + 1 .. end], ',');
        var ruleset: Ruleset = undefined;
        var ri: u3 = 0;
        while (ruleit.next()) |rulestr| {
            const rule: Rule = switch (rulestr[0]) {
                'A' => Rule{ .condition = null, .destination = 0 },
                'R' => Rule{ .condition = null, .destination = 1 },
                else => blk: {
                    const colonpos = indexOf(u8, rulestr, ':');
                    if (colonpos) |colon| {
                        const value_id: u2 = valueid(rulestr[0]);
                        const cond: Condition = switch (rulestr[1]) {
                            '>' => Condition.GT,
                            '<' => Condition.LT,
                            else => unreachable,
                        };
                        const limit: u16 = parseInt(u16, rulestr[2..colon], 10) catch unreachable;
                        const dest = ruleid(rulestr[colon + 1 .. rulestr.len]);
                        break :blk Rule{ .condition = cond, .valueid = value_id, .limit = limit, .destination = dest };
                    } else {
                        const dest = ruleid(rulestr);
                        break :blk Rule{ .condition = null, .destination = dest };
                    }
                },
            };
            ruleset[ri] = rule;
            ri += 1;
        }
        //print("Created ruleset for id: {}, rules:\n", .{rule_id});
        //for (ruleset[0..ri]) |rule| {
        //    var cond = "ALL";
        //    if (rule.condition) |c| {
        //        cond = switch (c) {
        //            Condition.LT => "LT<",
        //            Condition.GT => "GT>",
        //        };
        //    }
        //    print("{s} {} {} {}\n", .{ cond, rule.valueid, rule.limit, rule.destination });
        //}
        rulesets[rule_id] = ruleset;
    }

    var range: [4]Range = undefined;
    for (0..4) |i| {
        range[i] = .{ .min = 1, .max = 4000 };
    }

    const res = walkRule(rulesets, ruleid("in"), range);
    return res;
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
