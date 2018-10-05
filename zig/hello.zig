const std = @import("std");
const warn = std.debug.warn;

fn pow(base: usize, exp: usize) usize {
    var x: usize = base;
    var i: usize = 0;
    while (i < exp) : (i += 1) {
        x *= exp;
    }
    return x;
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn printing(buf: [*]const u8, len: usize) void {
    var s = buf[0..len];
    warn("Zig: {}\n", s);
}

fn itoa(comptime N: type, n: N, buff: []u8) void {
    comptime var UNROLL_MAX: usize = 4;
    comptime var DIV_CONST: usize = 10000; // <-- replace with 10 to the power of 4

    var num = n;
    var len = buff.len - 1;

    while(num >= DIV_CONST): ({num = @divTrunc(num, DIV_CONST);}) {
        comptime var DIV10: N = 1;
        comptime var CURRENT: usize = 0;
        
        // Write digits backwards into the buffer
        inline while(CURRENT != UNROLL_MAX): ({CURRENT += 1; DIV10 *= 10;}) {
            var q = @divTrunc(num, DIV10);
            var r = @intCast(u8, @rem(q, 10)) + 48;
            buff[len - CURRENT] = r;
        }

        len -= 4;
    }

    while(len != @maxValue(usize)): ({len -%= 1;}) {
        var q: N = @divTrunc(num, 10);
        var r: u8 = @intCast(u8, @rem(num, 10)) + 48;
        buff[len] = r;
        num = q;
    }
}

export fn itoa_u64(n: u64, noalias buff: [*] u8, len: usize) void {

    var slice = buff[0..len];

    itoa(u64, n, slice);
}

test "test" {
    const assert = @import("std").debug.assert;

    comptime var small_buff = []u8{10} ** 3;

    comptime var small: u64 = 100;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    comptime itoa_u64(small, &small_buff, small_buff.len);
    
    
    assert(small_buff[0] == 1 + 48);
    assert(small_buff[1] == 0 + 48);
    assert(small_buff[2] == 0 + 48);

    comptime var big_buff = []u8{0} ** 10;

    comptime var big: u64 = 1234123412;

    comptime itoa_u64(big, &big_buff, big_buff.len);

    assert(big_buff[0] == 1 + 48);
    assert(big_buff[1] == 2 + 48);
    assert(big_buff[2] == 3 + 48);
    assert(big_buff[3] == 4 + 48);
    assert(big_buff[4] == 1 + 48);
    assert(big_buff[5] == 2 + 48);
    assert(big_buff[6] == 3 + 48);
    assert(big_buff[7] == 4 + 48);
    assert(big_buff[8] == 1 + 48);
    assert(big_buff[9] == 2 + 48);
}