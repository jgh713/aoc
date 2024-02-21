const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub const data = @embedFile("data/day16.txt");
const testdata = "";

test "day16_part1" {
    assert(part1("8A004A801A8002F478") == 16);
    assert(part1("620080001611562C8802118E34") == 12);
    assert(part1("C0015000016115A2E0802F182340") == 23);
    assert(part1("A0016C880162017C3686B18A3D4780") == 31);
}

fn packetType(n: usize) type {
    return @Type(std.builtin.Type{ .Int = std.builtin.Type.Int{ .signedness = .unsigned, .bits = n } });
}

const PacketType = enum(u3) {
    Sum = 0,
    Product = 1,
    Min = 2,
    Max = 3,
    Literal = 4,
    GT = 5,
    LT = 6,
    EQ = 7,
};

const Packet = struct {
    str: []const u8,
    bit: usize,

    pub fn init(str: []const u8) Packet {
        return Packet{ .str = str, .bit = 0 };
    }

    pub fn next(self: *@This(), comptime n: usize) packetType(n) {
        const btype = packetType(n);
        var bits: btype = 0;
        var cval: u4 = parseInt(u4, self.str[(self.bit / 4) .. (self.bit / 4) + 1], 16) catch unreachable;
        var ni: usize = n;
        while (true) {
            ni -= 1;
            const bit: u1 = @intCast((cval >> @intCast(3 - (self.bit % 4))) & 1);
            bits |= @as(btype, bit) << @intCast(ni);
            self.bit += 1;
            if (self.bit % 4 == 0 and ni > 0) {
                cval = parseInt(u4, self.str[(self.bit / 4) .. (self.bit / 4) + 1], 16) catch unreachable;
            }
            if (ni == 0) {
                return bits;
            }
        }
        unreachable;
    }

    pub fn unext(self: *@This(), comptime n: usize) usize {
        var bits: usize = 0;
        var cval = parseInt(u4, self.str[(self.bit / 4) .. (self.bit / 4) + 1], 16) catch unreachable;
        var ni: usize = n;
        while (true) {
            ni -= 1;
            const bit: u1 = @intCast((cval >> @intCast(3 - (self.bit % 4))) & 1);
            bits |= @as(usize, bit) << @intCast(ni);
            self.bit += 1;
            if (self.bit % 4 == 0 and ni > 0) {
                cval = parseInt(u4, self.str[(self.bit / 4) .. (self.bit / 4) + 1], 16) catch unreachable;
            }
            if (ni == 0) {
                return bits;
            }
        }
        unreachable;
    }

    const IteratorType = enum { Size, Count };

    const Iterator = struct {
        packet: *Packet,
        itype: IteratorType,
        startbit: usize,
        count: usize,

        pub fn next(self: *@This()) bool {
            switch (self.itype) {
                IteratorType.Size => {
                    return (self.packet.bit - self.startbit) < self.count;
                },
                IteratorType.Count => {
                    if (self.count == 0) return false;
                    self.count -= 1;
                    return true;
                },
            }
        }
    };

    pub fn iterator(self: *@This()) Iterator {
        const itype: IteratorType = @enumFromInt(self.next(1));
        switch (itype) {
            IteratorType.Size => {
                const size = self.next(15);
                return Iterator{ .packet = self, .itype = itype, .startbit = self.bit, .count = size };
            },
            IteratorType.Count => {
                const count = self.next(11);
                return Iterator{ .packet = self, .itype = itype, .startbit = self.bit, .count = count };
            },
        }
    }

    pub fn parseVersions(self: *@This()) usize {
        const version: u3 = self.next(3);
        const ptype: u3 = self.next(3);
        switch (ptype) {
            4 => {
                var is_end: bool = false;
                while (!is_end) {
                    is_end = (self.next(1) == 0);
                    _ = self.next(4);
                }
                return version;
            },
            else => {
                const ltype: u1 = self.next(1);
                switch (ltype) {
                    0 => {
                        var total: usize = 0;
                        const len = self.next(15);
                        const startbit = self.bit;
                        while ((self.bit - startbit) < len) {
                            total += self.parseVersions();
                        }
                        return total + version;
                    },
                    1 => {
                        const len = self.next(11);
                        var total: usize = 0;
                        for (0..len) |_| {
                            total += self.parseVersions();
                        }
                        return total + version;
                    },
                }
            },
        }
    }

    pub fn parseValue(self: *@This()) usize {
        _ = self.next(3);
        //print("version: {}\n", .{version});
        const ptype: PacketType = @enumFromInt(self.next(3));
        //print("ptype: {}\n", .{ptype});
        //print("bit: {}\n", .{self.bit});
        switch (ptype) {
            .Literal => {
                var is_end: bool = false;
                var value: usize = 0;
                while (!is_end) {
                    is_end = (self.next(1) == 0);
                    value <<= 4;
                    value |= self.next(4);
                }
                return value;
            },
            .Sum => {
                var it = self.iterator();
                var total: usize = 0;
                while (it.next()) {
                    total += self.parseValue();
                }
                return total;
            },
            .Product => {
                var it = self.iterator();
                var total: usize = 1;
                while (it.next()) {
                    total *= self.parseValue();
                }
                return total;
            },
            .Min => {
                var it = self.iterator();
                var total: usize = std.math.maxInt(usize);
                while (it.next()) {
                    total = @min(total, self.parseValue());
                }
                return total;
            },
            .Max => {
                var it = self.iterator();
                var total: usize = 0;
                while (it.next()) {
                    total = @max(total, self.parseValue());
                }
                return total;
            },
            .GT => {
                _ = self.iterator();
                const left: usize = self.parseValue();
                const right: usize = self.parseValue();
                return if (left > right) 1 else 0;
            },
            .LT => {
                _ = self.iterator();
                const left: usize = self.parseValue();
                const right: usize = self.parseValue();
                return if (left < right) 1 else 0;
            },
            .EQ => {
                _ = self.iterator();
                const left: usize = self.parseValue();
                const right: usize = self.parseValue();
                return if (left == right) 1 else 0;
            },
        }
    }
};

pub fn part1(input: []const u8) usize {
    var packet = Packet.init(input);

    //print("{b}\n", .{packet.next(4)});

    return packet.parseVersions();
}

test "day16_part2" {
    assert(part2("C200B40A82") == 3);
    assert(part2("04005AC33890") == 54);
    assert(part2("880086C3E88112") == 7);
    assert(part2("CE00C43D881120") == 9);
    assert(part2("D8005AC2A8F0") == 1);
    assert(part2("F600BC2D8F") == 0);
    assert(part2("9C005AC2F8F0") == 0);
    assert(part2("9C0141080250320F1802104A08") == 1);
}

pub fn part2(input: []const u8) usize {
    var packet = Packet.init(input);

    //print("{b}\n", .{packet.next(4)});

    return packet.parseValue();
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    const res = part1(data);
    const time = timer.lap();
    const res2 = part2(data);
    const time2 = timer.lap();
    print("Day 16:\n", .{});
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
