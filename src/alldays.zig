const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");
const day4 = @import("day04.zig");
const day5 = @import("day05.zig");
const day6 = @import("day06.zig");
const day7 = @import("day07.zig");
const day8 = @import("day08.zig");
const day9 = @import("day09.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");
const day13 = @import("day13.zig");
const day14 = @import("day14.zig");
const day15 = @import("day15.zig");
const day16 = @import("day16.zig");
const day17 = @import("day17.zig");
const day18 = @import("day18.zig");
const day19 = @import("day19.zig");
const day20 = @import("day20.zig");
const day21 = @import("day21.zig");
const day22 = @import("day22.zig");
const day23 = @import("day23.zig");
const day24 = @import("day24.zig");
const day25 = @import("day25.zig");

const Time = struct {
    time: usize,

    pub fn format(self: @This(), comptime f: []const u8, options: std.fmt.FormatOptions, writer: std.fs.File.Writer) !void {
        _ = options;
        _ = f;
        const secs = self.time / 1000000000;
        const decimal = self.time % 1000000000;
        //if (secs == 0 and decimal < 1000000) {
        //    try std.fmt.format(writer, "{}ns", .{ decimal });
        //    return;
        //}
        //else if (secs == 0) {
        //    const msecs = decimal / 1000000;
        //    const mdecimal = decimal % 1000000;
        //    try std.fmt.format(writer, "{}.{}ms", .{ msecs, mdecimal });
        //    return;
        //}
        try std.fmt.format(writer, "{}.{:0>9}s", .{ secs, decimal });
    }
};

fn totime(nanos: usize) Time {
    return Time{ .time = nanos };
}

pub fn main() !void {
    var res: [25][2]i128 = comptime std.mem.zeroes([25][2]i128);
    var times: [25]usize = comptime std.mem.zeroes([25]usize);
    var timer = std.time.Timer.start() catch unreachable;

    res[0][0] = @intCast(day1.part1(day1.data));
    res[0][1] = @intCast(day1.part2(day1.data) catch unreachable);
    times[0] = timer.lap();

    res[1][0] = @intCast(day2.part1(day2.data) catch unreachable);
    res[1][1] = @intCast(day2.part2(day2.data) catch unreachable);
    times[1] = timer.lap();

    res[2][0] = @intCast(day3.part1(day3.data));
    res[2][1] = @intCast(day3.part2(day3.data) catch unreachable);
    times[2] = timer.lap();

    res[3][0] = @intCast(day4.part1(day4.data));
    res[3][1] = @intCast(day4.part2(day4.data));
    times[3] = timer.lap();

    res[4][0] = @intCast(day5.part1(day5.data));
    res[4][1] = @intCast(day5.part2(day5.data));
    times[4] = timer.lap();

    res[5][0] = @intCast(day6.part1(day6.data));
    res[5][1] = @intCast(day6.part2(day6.data));
    times[5] = timer.lap();

    res[6][0] = @intCast(day7.part1(day7.data));
    res[6][1] = @intCast(day7.part2(day7.data));
    times[6] = timer.lap();

    res[7][0] = @intCast(day8.part1(day8.data));
    res[7][1] = @intCast(day8.part2(day8.data));
    times[7] = timer.lap();

    res[8][0] = @intCast(day9.part1(day9.data, true));
    res[8][1] = @intCast(day9.part2(day9.data, true));
    times[8] = timer.lap();

    res[9][0] = @intCast(day10.part1(day10.data));
    res[9][1] = @intCast(day10.part2(day10.data));
    times[9] = timer.lap();

    const day11gal = day11.parseInput(day11.data);
    res[10][0] = @intCast(day11.day11(day11gal, 2));
    res[10][1] = @intCast(day11.day11(day11gal, 1000000));
    times[10] = timer.lap();

    res[11][0] = @intCast(day12.part1(day12.data));
    res[11][1] = @intCast(day12.part2(day12.data));
    times[11] = timer.lap();

    res[12][0] = @intCast(day13.part1(day13.data));
    res[12][1] = @intCast(day13.part2(day13.data));
    times[12] = timer.lap();

    res[13][0] = @intCast(day14.part1(day14.data, 100));
    res[13][1] = @intCast(day14.part2(day14.data, 100) catch unreachable);
    times[13] = timer.lap();

    res[14][0] = @intCast(day15.part1(day15.data));
    res[14][1] = @intCast(day15.part2(day15.data));
    times[14] = timer.lap();

    res[15][0] = @intCast(day16.part1(day16.data, 110));
    res[15][1] = @intCast(day16.part2(day16.data, 110));
    times[15] = timer.lap();

    res[16][0] = @intCast(day17.part1(day17.data));
    res[16][1] = @intCast(day17.part2(day17.data));
    times[16] = timer.lap();

    res[17][0] = @intCast(day18.part1(day18.data));
    res[17][1] = @intCast(day18.part2(day18.data));
    times[17] = timer.lap();

    res[18][0] = @intCast(day19.part1(day19.data));
    res[18][1] = @intCast(day19.part2(day19.data));
    times[18] = timer.lap();

    res[19][0] = @intCast(day20.part1(day20.data));
    res[19][1] = @intCast(day20.part2(day20.data));
    times[19] = timer.lap();

    res[20][0] = @intCast(day21.part1(day21.data, 64));
    res[20][1] = @intCast(day21.part2(day21.data));
    times[20] = timer.lap();

    res[21][0] = @intCast(day22.part1(day22.data));
    res[21][1] = @intCast(day22.part2(day22.data));
    times[21] = timer.lap();

    res[22][0] = @intCast(day23.part1(day23.data));
    res[22][1] = @intCast(day23.part2(day23.data));
    times[22] = timer.lap();

    res[23][0] = @intCast(day24.part1(day24.data, 200000000000000, 400000000000000));
    res[23][1] = @intCast(day24.part2(day24.data));
    times[23] = timer.lap();

    res[24][0] = @intCast(day25.part1(day25.data));
    times[24] = timer.lap();

    assert(res[0][0] == 54390);
    assert(res[0][1] == 54277);

    assert(res[1][0] == 2268);
    assert(res[1][1] == 63542);

    assert(res[2][0] == 553079);
    assert(res[2][1] == 84363105);

    assert(res[3][0] == 22488);
    assert(res[3][1] == 7013204);

    assert(res[4][0] == 57075758);
    assert(res[4][1] == 31161857);

    assert(res[5][0] == 840336);
    assert(res[5][1] == 41382569);

    assert(res[6][0] == 256448566);
    assert(res[6][1] == 254412181);

    assert(res[7][0] == 18113);
    assert(res[7][1] == 12315788159977);

    assert(res[8][0] == 1939607039);
    assert(res[8][1] == 1041);

    assert(res[9][0] == 6890);
    assert(res[9][1] == 453);

    assert(res[10][0] == 9965032);
    assert(res[10][1] == 550358864332);

    assert(res[11][0] == 7361);
    assert(res[11][1] == 83317216247365);

    assert(res[12][0] == 28895);
    assert(res[12][1] == 31603);

    assert(res[13][0] == 105249);
    assert(res[13][1] == 88680);

    assert(res[14][0] == 503487);
    assert(res[14][1] == 261505);

    assert(res[15][0] == 7477);
    assert(res[15][1] == 7853);

    assert(res[16][0] == 1260);
    assert(res[16][1] == 1416);

    assert(res[17][0] == 62500);
    assert(res[17][1] == 122109860712709);

    assert(res[18][0] == 420739);
    assert(res[18][1] == 130251901420382);

    assert(res[19][0] == 807069600);
    assert(res[19][1] == 221453937522197);

    assert(res[20][0] == 3820);
    assert(res[20][1] == 632421652138917);

    assert(res[21][0] == 524);
    assert(res[21][1] == 77070);

    assert(res[22][0] == 2442);
    assert(res[22][1] == 6898);

    assert(res[23][0] == 28174);
    assert(res[23][1] == 568386357876600);

    assert(res[24][0] == 583338);

    var totaltime: usize = 0;
    print("Timings:\n", .{});
    for (0..25) |day| {
        print("Day {}: {any}\n", .{ day + 1, totime(times[day]) });
        print("Day {} ns: {}\n", .{ day + 1, times[day] });
        totaltime += times[day];
    }
    print("Total: {any}\n", .{totime(totaltime)});
    print("Total ns: {}\n", .{totaltime});
}
