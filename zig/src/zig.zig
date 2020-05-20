const std = @import("std");
const warn = std.debug.warn;

fn pow(base: usize, exp: usize) usize {
    var x: usize = base;
    var i: usize = 1;

    while (i < exp) : (i += 1) {
        x *= base;
    }
    return x;
}

export fn add(a: i32, b: i32) callconv(.C) i32 {
    return a + b;
}

export fn printing(buf: [*]const u8, len: usize) callconv(.C) void {
    var s = buf[0..len];
    warn("Zig says: {}\n", .{s});
}

fn itoa(comptime N: type, n: N, buff: []u8) void {
    comptime var UNROLL_MAX: usize = 4;
    comptime var DIV_CONST: usize = comptime pow(10, UNROLL_MAX);

    var num = n;
    var len = buff.len;

    while (len >= UNROLL_MAX) : (num = @divTrunc(num, DIV_CONST)) {
        comptime var DIV10: N = 1;
        comptime var CURRENT: usize = 0;

        // Write digits backwards into the buffer
        inline while (CURRENT != UNROLL_MAX) : ({
            CURRENT += 1;
            DIV10 *= 10;
        }) {
            var q = @divTrunc(num, DIV10);
            var r = @intCast(u8, @rem(q, 10)) + 48;
            buff[len - CURRENT - 1] = r;
        }

        len -= UNROLL_MAX;
    }

    // On an empty buffer, this will wrapparoo to 0xfffff
    len -%= 1;

    // Stops at 0xfffff
    while (len != std.math.maxInt(usize)) : (len -%= 1) {
        var q: N = @divTrunc(num, 10);
        var r: u8 = @intCast(u8, @rem(num, 10)) + 48;
        buff[len] = r;
        num = q;
    }
}

export fn itoa_u64(n: u64, noalias buff: [*]u8, len: usize) callconv(.C) void {
    var slice = buff[0..len];

    itoa(u64, n, slice);
}

test "empty buff" {
    var small_buff: []u8 = &[_]u8{};

    var small: u64 = 100;

    _ = itoa_u64(small, small_buff.ptr, small_buff.len);
}

test "small buff" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var small_buff = [_]u8{10} ** 3;

    comptime var small: u64 = 100;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    comptime itoa_u64(small, &small_buff, small_buff.len);

    assert(mem.eql(u8, &small_buff, "100"));
}

test "big buff" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var big_buff = [_]u8{0} ** 10;

    comptime var big: u64 = 1234123412;

    comptime itoa_u64(big, &big_buff, big_buff.len);

    assert(mem.eql(u8, &big_buff, "1234123412"));
}

test "unroll count buf" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var small_buff = [_]u8{10} ** 4;

    comptime var small: u64 = 1000;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    comptime itoa_u64(small, &small_buff, small_buff.len);

    assert(mem.eql(u8, &small_buff, "1000"));
}
