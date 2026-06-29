const std = @import("std");

// ============================================================
// Arithmetic
// ============================================================

/// Add two 32-bit integers.
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// Multiply two 32-bit integers.
export fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

// ============================================================
// Fibonacci
// ============================================================

/// Compute the n-th Fibonacci number iteratively.
/// Returns -1 for negative inputs.
export fn fibonacci(n: i32) i64 {
    if (n < 0) return -1;
    if (n <= 1) return @intCast(n);

    var a: i64 = 0;
    var b: i64 = 1;
    var i: i32 = 2;
    while (i <= n) : (i += 1) {
        const tmp = a + b;
        a = b;
        b = tmp;
    }
    return b;
}

// ============================================================
// String processing
// ============================================================

/// Reverse a UTF-8 string by codepoint.
///
/// Accepts a pointer and byte length. Returns a newly allocated
/// null-terminated reversed string, or null on allocation failure.
/// The caller MUST free the returned pointer with `free_string`.
export fn reverse_string(input: [*c]const u8, len: u32) ?[*:0]u8 {
    const allocator = std.heap.c_allocator;
    const byte_len: usize = @intCast(len);
    const slice = input[0..byte_len];

    // First pass: count codepoints and collect their byte offsets.
    // We store each codepoint's start offset and byte length.
    const Cp = struct { start: usize, cp_len: usize };

    // Allocate a temporary array for codepoint info.
    // Max possible codepoints == byte_len (all ASCII).
    const cp_info = allocator.alloc(Cp, byte_len) catch return null;
    defer allocator.free(cp_info);

    var cp_count: usize = 0;
    var offset: usize = 0;
    while (offset < byte_len) {
        const cp_byte_len = std.unicode.utf8ByteSequenceLength(slice[offset]) catch 1;
        cp_info[cp_count] = .{ .start = offset, .cp_len = cp_byte_len };
        cp_count += 1;
        offset += cp_byte_len;
    }

    // Allocate output buffer (same byte length + null terminator).
    const buf = allocator.alloc(u8, byte_len + 1) catch return null;

    // Write codepoints in reverse order.
    var pos: usize = 0;
    var idx: usize = cp_count;
    while (idx > 0) {
        idx -= 1;
        const info = cp_info[idx];
        @memcpy(buf[pos .. pos + info.cp_len], slice[info.start .. info.start + info.cp_len]);
        pos += info.cp_len;
    }
    buf[byte_len] = 0;

    return buf[0..byte_len :0];
}

/// Free a string previously returned by `reverse_string`.
export fn free_string(ptr: ?[*:0]u8) void {
    if (ptr) |p| {
        const len = std.mem.len(p);
        const allocator = std.heap.c_allocator;
        allocator.free(p[0 .. len + 1]);
    }
}

// ============================================================
// Tests
// ============================================================

test "add" {
    try std.testing.expectEqual(@as(i32, 5), add(2, 3));
    try std.testing.expectEqual(@as(i32, 0), add(-1, 1));
    try std.testing.expectEqual(@as(i32, -4), add(-2, -2));
}

test "add i32 boundaries" {
    try std.testing.expectEqual(@as(i32, 2147483647), add(2147483646, 1));
    try std.testing.expectEqual(@as(i32, -2147483648), add(-2147483647, -1));
}

test "multiply" {
    try std.testing.expectEqual(@as(i32, 6), multiply(2, 3));
    try std.testing.expectEqual(@as(i32, 0), multiply(0, 42));
    try std.testing.expectEqual(@as(i32, 4), multiply(-2, -2));
}

test "fibonacci" {
    try std.testing.expectEqual(@as(i64, 0), fibonacci(0));
    try std.testing.expectEqual(@as(i64, 1), fibonacci(1));
    try std.testing.expectEqual(@as(i64, 55), fibonacci(10));
    try std.testing.expectEqual(@as(i64, 6765), fibonacci(20));
    try std.testing.expectEqual(@as(i64, -1), fibonacci(-1));
}

test "fibonacci large" {
    try std.testing.expectEqual(@as(i64, 12586269025), fibonacci(50));
    // fib(92) is the largest that fits in i64
    try std.testing.expectEqual(@as(i64, 7540113804746346429), fibonacci(92));
}

test "reverse_string ASCII" {
    const input = "hello";
    const result = reverse_string(input.ptr, input.len) orelse unreachable;
    defer free_string(result);
    const slice = std.mem.span(result);
    try std.testing.expectEqualStrings("olleh", slice);
}

test "reverse_string multi-byte UTF-8" {
    const input = "café";
    const result = reverse_string(input.ptr, input.len) orelse unreachable;
    defer free_string(result);
    const slice = std.mem.span(result);
    try std.testing.expectEqualStrings("éfac", slice);
}

test "reverse_string CJK" {
    const input = "\u{4f60}\u{597d}"; // 你好
    const result = reverse_string(input.ptr, input.len) orelse unreachable;
    defer free_string(result);
    const slice = std.mem.span(result);
    try std.testing.expectEqualStrings("\u{597d}\u{4f60}", slice); // 好你
}

test "reverse_string empty" {
    const input = "";
    const result = reverse_string(input.ptr, 0);
    if (result) |r| {
        defer free_string(r);
        const slice = std.mem.span(r);
        try std.testing.expectEqualStrings("", slice);
    }
    // null is also acceptable for empty input
}

test "reverse_string single char" {
    const input = "x";
    const result = reverse_string(input.ptr, input.len) orelse unreachable;
    defer free_string(result);
    const slice = std.mem.span(result);
    try std.testing.expectEqualStrings("x", slice);
}

