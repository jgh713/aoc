const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day25.txt");
const testinput = "jqt: rhn xhk nvd\nrsh: frs pzl lsr\nxhk: hfx\ncmg: qnr nvd lhk bvb\nrhn: xhk bvb hfx\nbvb: xhk hfx\npzl: lsr hfx nvd\nqnr: nvd\nntq: jqt hfx bvb xhk\nnvd: lhk\nlsr: lhk\nrzs: qnr cmg lsr rsh\nfrs: qnr lhk lsr";

test "day25_part1" {
    const res = part1(testinput);
    print("Test result: {d}\n", .{res});
    assert(res == 54);
}

const Component = struct {
    targets: [16]?*Component = undefined,
    tcount: u4 = 0,
    id: u16 = 0,

    pub fn format(self: @This(), comptime f: []const u8, options: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        _ = options;
        _ = f;
        const id = idcomp(self.id);
        try std.fmt.format(writer, "{s} -> ", .{id});
        if (self.tcount == 0) {
            try std.fmt.format(writer, "null", .{});
            return;
        }
        for (0..self.tcount) |i| {
            const tid = idcomp(self.targets[i].?.id);
            try std.fmt.format(writer, "{s}", .{tid});
            if (i != self.tcount - 1) {
                try std.fmt.format(writer, " | ", .{});
            }
        }
    }
};

fn compid(str: []const u8) u16 {
    return (@as(u16, str[0] - 'a') << 10) | (@as(u16, str[1] - 'a') << 5) | (str[2] - 'a');
}

fn idcomp(id: u16) [3]u8 {
    return .{ @truncate((id >> 10) + 'a'), @truncate(((id >> 5) & 0b11111) + 'a'), @truncate((id & 0b11111) + 'a') };
}

fn shortestPath(start: *Component, end: *Component) [1000]u16 {
    //print("Finding shortest path from {s} to {s}\n", .{ idcomp(start.id), idcomp(end.id) });
    // Calc shortest path and return the list nodes along the shortest path
    var prevnodes: [32768]u16 = undefined;
    var queue: [2500]*Component = undefined;
    var visited: [32768]bool = std.mem.zeroes([32768]bool);

    var qstart: usize = 0;
    var qend: usize = 1;

    queue[0] = start;
    visited[start.id] = true;

    while (qstart != qend) : (qstart += 1) {
        const node = queue[qstart];
        //print("Visiting {s}\n", .{idcomp(node.id)});

        if (node == end) {
            // Found the end node
            var path: [1000]u16 = std.mem.zeroes([1000]u16);
            var pathlen: usize = 1;
            var cur = end.id;
            const sid = start.id;
            while (cur != sid) {
                path[pathlen] = cur;
                pathlen += 1;
                cur = prevnodes[cur];
            }
            path[pathlen] = sid;
            path[0] = @truncate(pathlen);
            return path;
        }

        for (0..node.tcount) |i| {
            const target = node.targets[i].?;
            if (visited[target.id]) {
                //print("  Already visited {s}\n", .{idcomp(target.id)});
                continue;
            }
            //print("  Target: {s}\n", .{idcomp(target.id)});
            visited[target.id] = true;
            prevnodes[target.id] = node.id;
            queue[qend] = target;
            qend += 1;
        }
    }

    unreachable;
}

fn countSort(_: @TypeOf(.{}), a: [2]u32, b: [2]u32) bool {
    return a[1] > b[1];
}

fn skiplist(cuts: [3]u32) [6]u32 {
    var toskip = [6]u32{ 0, 0, 0, 0, 0, 0 };
    for (0..3) |i| {
        const key = cuts[i];
        const id1: u16 = @truncate(key >> 16);
        const id2: u16 = @truncate(key & 0xFFFF);
        toskip[i * 2] = key;
        toskip[i * 2 + 1] = @as(u32, id2) << 16 | id1;
    }
    return toskip;
}

fn printcut(cut: u32) void {
    const id1: u16 = @truncate(cut >> 16);
    const id2: u16 = @truncate(cut & 0xFFFF);
    print("{s} -> {s}", .{ idcomp(id1), idcomp(id2) });
}

fn testCuts(compmap: []*Component, cuts: [3]u32) ?usize {
    //print("Testing cuts:\n", .{});
    //for (0..3) |i| {
    //    printcut(cuts[i]);
    //    if (i != 2) {
    //        print(", ", .{});
    //    } else {
    //        print("\n", .{});
    //    }
    //}
    const toskip = skiplist(cuts);
    var step: usize = 0;
    var queue: [2500]*Component = undefined;
    var visited: [32768]bool = std.mem.zeroes([32768]bool);
    var qstart: usize = 0;
    var qend: usize = 0;
    var sizes: [2]usize = .{0} ** 2;
    var size: usize = 0;

    while (true) {
        if (qstart == qend) {
            if (step == 2 and size == 1) {
                print("Lone component: {s}\n", .{idcomp(queue[qend - 1].id)});
            }
            if (step > 0) {
                print("Step {d}: {d}\n", .{ step, size });
                sizes[step - 1] = size;
                size = 0;
            }
            const next = for (compmap) |comp| {
                if (visited[comp.id]) {
                    continue;
                }
                break comp;
            } else {
                if (step == 2) {
                    return sizes[0] * sizes[1];
                } else {
                    return null;
                }
            };

            step += 1;
            if (step > 2) return null;
            queue[qend] = next;
            qend += 1;
            visited[next.id] = true;
            size += 1;
            continue;
        }

        const node = queue[qstart];
        qstart += 1;
        for (0..node.tcount) |i| {
            const target = node.targets[i].?;
            if (visited[target.id]) {
                continue;
            }
            const key = (@as(u32, node.id) << 16) | target.id;
            if (std.mem.indexOf(u32, &toskip, &[1]u32{key})) |_| {
                continue;
            }
            visited[target.id] = true;
            queue[qend] = target;
            qend += 1;
            size += 1;
        }
    }
}

fn part1(input: []const u8) usize {
    var line_iter = if (indexOf(u8, input, '\r')) |_| std.mem.splitSequence(u8, input, "\n") else std.mem.splitSequence(u8, input, "\n");
    var components: [32768]Component = std.mem.zeroes([32768]Component);
    var compmap: [2500]*Component = undefined;
    while (line_iter.next()) |line| {
        const id_str = line[0..3];
        const id = compid(id_str);
        const targetcount = (line.len - 4) / 4;
        components[id].id = id;
        for (0..targetcount) |tid| {
            const start = 4 + tid * 4 + 1;
            const target_str = line[start .. start + 3];
            const target = compid(target_str);

            components[id].targets[components[id].tcount] = &components[target];
            components[id].tcount += 1;
            components[target].id = target;
            components[target].targets[components[target].tcount] = &components[id];
            components[target].tcount += 1;
            //print("{s} -> {s}\n", .{ id_str, target_str });
        }
    }

    var cid: usize = 0;
    for (&components) |*comp| {
        if (comp.tcount == 0) {
            continue;
        }
        compmap[cid] = comp;
        cid += 1;
    }

    //for (compmap[0..cid]) |comp| {
    //    print("{any}\n", .{comp});
    //}

    var rnd = std.rand.DefaultPrng.init(0);
    //_ = rnd;
    //_ = rnd.random().int(u32);

    var compcounts = Map(u32, u16).init(gpa);
    defer compcounts.deinit();

    for (0..200) |_| {
        const start = rnd.random().int(u32) % cid;
        const end = rnd.random().int(u32) % cid;
        //print("Finding shortest path from {s} to {s}\n", .{ idcomp(compmap[start].id), idcomp(compmap[end].id) });
        const path = shortestPath(compmap[start], compmap[end]);
        //print("Shortest path from {s} to {s} is {any}\n", .{ idcomp(compmap[start].id), idcomp(compmap[end].id), path });
        for (1..path[0]) |i| {
            var id1 = path[i];
            var id2 = path[i + 1];
            //print("{s} -> {s}\n", .{ idcomp(id1), idcomp(id2) });
            if (id1 > id2) {
                const tmp = id1;
                id1 = id2;
                id2 = tmp;
            }
            const key = (@as(u32, id1) << 16) | id2;
            const entry = compcounts.getOrPut(key) catch unreachable;
            if (entry.found_existing) {
                entry.value_ptr.* += 1;
            } else {
                entry.value_ptr.* = 1;
            }
        }
    }

    const edgecount = compcounts.count();
    var countiter = compcounts.iterator();
    var counts: [][2]u32 = gpa.alloc([2]u32, edgecount) catch unreachable;
    defer gpa.free(counts);

    var countidx: usize = 0;

    while (countiter.next()) |entry| {
        const key = entry.key_ptr.*;
        const count = entry.value_ptr.*;
        counts[countidx][0] = key;
        counts[countidx][1] = count;
        countidx += 1;
    }

    sort([2]u32, counts, .{}, countSort);

    for (counts[0..countidx]) |count| {
        const key = count[0];
        const id1: u16 = @truncate(key >> 16);
        _ = id1;
        const id2: u16 = @truncate(key & 0xFFFF);
        _ = id2;
        const countx = count[1];
        _ = countx;
        //print("{s} -> {s}: {d}\n", .{ idcomp(id1), idcomp(id2), countx });
    }

    const totry = 10;

    for (0..totry - 2) |i| {
        for (i + 1..totry - 1) |j| {
            for (j + 1..totry) |k| {
                if (testCuts(compmap[0..cid], .{ counts[i][0], counts[j][0], counts[k][0] })) |val| {
                    return val;
                }
            }
        }
    }

    return 0;
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time1 = timer.lap();
    print("Part1: {}\n", .{res});
    print("Part1 took {}ns\n", .{time1});
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
