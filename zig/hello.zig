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
    var len = buff.len - 1;

    var qs: [UNROLL_MAX]N = []N{0} ** UNROLL_MAX;
    var rs: [UNROLL_MAX]u8 = []u8{0} ** UNROLL_MAX;
    
    while(len >= 4): ({len -= 4; num = @divExact(num, 10000);}) {
        
        comptime var CURRENT: usize = 0;
        
        comptime var DIV_CONST: N = 1;
        
        inline while(CURRENT < UNROLL_MAX): ({CURRENT += 1; DIV_CONST *= 10;}) {
            qs[CURRENT] = @divExact(num, DIV_CONST);

        }

        CURRENT = 0;

        inline while(CURRENT < UNROLL_MAX): ({CURRENT += 1;}) {
            rs[CURRENT] = @intCast(u8, @rem(qs[CURRENT], 10)) + 48;
        }

        @memcpy(buff[len - UNROLL_MAX..len].ptr, rs[0..].ptr, UNROLL_MAX);
    }


    while(len != 0): ({len -= 1;}) {
        var q: N = @divTrunc(num, 10);

        var r: u8 = @intCast(u8, @rem(q, 10)) + 48;

        buff[len] = r;

        if (q == 0) {
            return;
        }

        num = q;
    }
}

export fn itoa_u64(n: i64, noalias buff: [*] u8, len: usize) void {
    var slice = buff[0..len];

    itoa(i64, n, slice);
}

test "test" {
    const assert = @import("std").debug.assert;

    var buf = []u8{0} ** 3;

    var n: i64 = 100;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    _ = itoa_u64(n, buf[0..].ptr, 3);
    

    assert(buf[0] == 1);
    assert(buf[1] == 0);
    assert(buf[2] == 0);

    // var buff = []u8{0} ** 10;

    // var n2: i64 = 1234567890;

    // _ = itoa_u64(n, buff[0..].ptr, 10);
}