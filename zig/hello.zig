const std = @import("std");
const warn = std.debug.warn;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn printing(buf: [*]const u8, len: usize) void {
    var s = buf[0..len];
    warn("Zig: {}\n", s);
}

fn itoa(comptime N: type, n: N, buff: []u8) void {
    comptime var UNROLL_MAX: usize = 4;

    var num = n;
    var len = buff.len;

    var qs: [UNROLL_MAX]N = []N{0} ** UNROLL_MAX;
    var partial_result: [UNROLL_MAX]u8 = []u8{0} ** UNROLL_MAX;
    
    while(len >= 4): ({len -= 4; num = @divTrunc(num, 10000);}) {
        
        comptime var CURRENT: usize = 3;
        
        comptime var DIV_CONST: N = 1;
        
        inline while(CURRENT != @maxValue(usize)): ({CURRENT -%= 1; DIV_CONST *= 10;}) {
            qs[CURRENT] = @divTrunc(num, DIV_CONST);

        }

        CURRENT = 3;

        inline while(CURRENT != @maxValue(usize)): ({CURRENT -%= 1;}) {
            partial_result[CURRENT] = @intCast(u8, @rem(qs[CURRENT], 10)) + 48;
        }

        var slice = buff[len - 4..len];
        @memcpy(slice.ptr, &partial_result, UNROLL_MAX);
    }

    len -= 1;

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