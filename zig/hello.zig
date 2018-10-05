const std = @import("std");
const warn = std.debug.warn;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn printing(buf: [*]const u8, len: usize) void {
    var s = buf[0..len];
    warn("Zig: {}\n", s);
}