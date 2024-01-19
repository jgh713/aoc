const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day24.txt");
const testdata = "19, 13, 30 @ -2, 1, -2\n18, 19, 22 @ -1, -1, -2\n20, 25, 34 @ -2, -2, -4\n12, 31, 28 @ -1, -2, -1\n20, 19, 15 @ 1, -5, -3";

test "day24_part1" {
    const res = part1(testdata, 7, 27);
    assert(res == 2);
}

const XYZ = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn format(self: @This(), comptime f: []const u8, options: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        _ = options;
        _ = f;
        try std.fmt.format(writer, "({d},{d},{d})", .{ self.x, self.y, self.z });
    }
};

const Vector = [2]XYZ;

fn parsePoint(input: []const u8) XYZ {
    var it = splitSeq(u8, input, ", ");
    var res: XYZ = undefined;
    res.x = parseFloat(f64, it.next().?) catch unreachable;
    res.y = parseFloat(f64, it.next().?) catch unreachable;
    res.z = parseFloat(f64, it.next().?) catch unreachable;
    return res;
}

fn intersection_2d(in_a: Vector, in_b: Vector) ?[4]f64 {
    const ap = in_a[0];
    const av = in_a[1];
    const bp = in_b[0];
    const bv = in_b[1];

    const den = bv.x * av.y - bv.y * av.x;
    if (den == 0.0) return null;

    const num = bv.y * (ap.x - bp.x) - bv.x * (ap.y - bp.y);
    const t1 = num / den;
    const t2 = ((ap.x - bp.x) + av.x * t1) / bv.x;

    if (bv.x == 0) {
        if (av.x == 0) return null;
        const swap = intersection_2d(in_b, in_a);
        if (swap) |res| {
            return .{ res[0], res[1], res[3], res[2] };
        }
        return null;
    }

    const x = ap.x + av.x * t1;
    const y = ap.y + av.y * t1;
    // Maybe needed for part 2?
    //const z = ap[2] + av[2] * t1;

    return .{ x, y, t1, t2 };
}

fn intersection_2dz(in_a: Vector, in_b: Vector) ?[4]f64 {
    const ap = in_a[0];
    const av = in_a[1];
    const bp = in_b[0];
    const bv = in_b[1];

    const den = bv.x * av.z - bv.z * av.x;
    if (den == 0.0) return null;

    const num = bv.z * (ap.x - bp.x) - bv.x * (ap.z - bp.z);
    const t1 = num / den;
    const t2 = ((ap.x - bp.x) + av.x * t1) / bv.x;

    if (bv.x == 0) {
        if (av.x == 0) return null;
        const swap = intersection_2dz(in_b, in_a);
        if (swap) |res| {
            return .{ res[0], res[1], res[3], res[2] };
        }
        return null;
    }

    const x = ap.x + av.x * t1;
    const y = ap.z + av.z * t1;
    // Maybe needed for part 2?
    //const z = ap[2] + av[2] * t1;

    return .{ x, y, t1, t2 };
}

fn part1(input: []const u8, min: usize, max: usize) usize {
    const ri = indexOf(u8, input, '\r');
    var lineit = splitSeq(u8, input, if (ri) |_| "\r\n" else "\n");
    var points: [300]Vector = undefined;
    var ptc: usize = 0;

    while (lineit.next()) |line| {
        var it = splitSeq(u8, line, " @ ");
        const pt1 = parsePoint(it.next().?);
        const mods = parsePoint(it.next().?);
        points[ptc][0] = pt1;
        points[ptc][1] = mods;
        ptc += 1;
    }

    var total: usize = 0;
    const fmin: f64 = @floatFromInt(min);
    const fmax: f64 = @floatFromInt(max);

    for (0..ptc - 1) |i| {
        for (i + 1..ptc) |j| {
            const optres = intersection_2d(points[i], points[j]);
            if (optres) |res| {
                if (res[0] >= fmin and res[0] <= fmax and res[1] >= fmin and res[1] <= fmax and res[2] >= 0.0 and res[3] >= 0.0) {
                    //print("Intersection at {any}\n", .{res});
                    total += 1;
                }
            }
        }
    }

    //print("Total: {d}\n", .{total});
    return total;
}

test "day24_part2" {
    const ta: Vector = .{ .{ .x = 20, .y = 19, .z = 15 }, .{ .x = 1, .y = -5, .z = -3 } };
    const tb: Vector = .{ .{ .x = 12, .y = 31, .z = 28 }, .{ .x = -1, .y = -2, .z = -1 } };
    print("Teststone: {any}\n", .{calcNewStone(ta, tb)});
    const res = part2(testdata);
    assert(res == 47);
}

fn calcNewStone(in_a: Vector, in_b: Vector) Vector {
    var pt1 = in_a[0];
    pt1.x += in_a[1].x;
    pt1.y += in_a[1].y;
    pt1.z += in_a[1].z;

    var pt2 = in_b[0];
    pt2.x += in_b[1].x * 2;
    pt2.y += in_b[1].y * 2;
    pt2.z += in_b[1].z * 2;

    var mods: XYZ = undefined;
    mods.x = pt2.x - pt1.x;
    mods.y = pt2.y - pt1.y;
    mods.z = pt2.z - pt1.z;

    var start: XYZ = undefined;
    start.x = pt1.x - mods.x;
    start.y = pt1.y - mods.y;
    start.z = pt1.z - mods.z;

    return .{ start, mods };
}

fn isInt(f: f64) bool {
    return @abs(f - std.math.round(f)) < 0.05;
}

fn part2(input: []const u8) usize {
    const ri = indexOf(u8, input, '\r');
    var lineit = splitSeq(u8, input, if (ri) |_| "\r\n" else "\n");
    var points: [300]Vector = undefined;
    var ptc: usize = 0;

    while (lineit.next()) |line| {
        var it = splitSeq(u8, line, " @ ");
        const pt1 = parsePoint(it.next().?);
        const mods = parsePoint(it.next().?);
        points[ptc][0] = pt1;
        points[ptc][1] = mods;
        ptc += 1;
    }

    const s0 = points[0];
    const s1 = points[1];
    const s2 = points[2];
    const ap = s0[0];
    const av = s0[1];
    const bp = s1[0];
    const bv = s1[1];

    for (0..1001) |uxv| {
        const xv: f64 = 501.0 - @as(f64, @floatFromInt(uxv));
        for (0..1001) |uyv| {
            const yv: f64 = 501.0 - @as(f64, @floatFromInt(uyv));

            const num = (bp.y - ap.y) * (xv - av.x) - (bp.x - ap.x) * (yv - av.y);
            const den = (yv - bv.y) * (xv - av.x) - (xv - bv.x) * (yv - av.y);
            const t2 = num / den;
            const t1 = ((yv - bv.y) * t2 - (bp.y - ap.y)) / (yv - av.y);

            const px = ap.x + (av.x - xv) * t1;
            const py = ap.y + (av.y - yv) * t1;

            const z1 = ap.z + t1 * av.z;
            const z2 = bp.z + t2 * bv.z;
            const zv = (z2 - z1) / (t2 - t1);
            const pz = ap.z + (av.z - zv) * t1;

            if (isInt(t1) and isInt(t2) and isInt(zv)) {
                const newstone: Vector = .{ .{ .x = px, .y = py, .z = pz }, .{ .x = xv, .y = yv, .z = zv } };
                if (intersection_2d(newstone, s2)) |int| {
                    const tdiff = @abs(int[2] - int[3]);
                    if (tdiff < 0.05) {
                        const newz = s2[0].z + int[2] * s2[1].z;
                        const stonez = newstone[0].z + int[2] * newstone[1].z;
                        const zdiff = @abs(newz - stonez);
                        if (zdiff < 0.05) {
                            return @intFromFloat(px + py + pz);
                        }
                    }
                }
            }
        }
    }

    return 0;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data, 200000000000000, 400000000000000);
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
