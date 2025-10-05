const std = @import("std");

pub fn stringEquals(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub fn stringStartsWith(word: []const u8, pattern: []const u8) bool {
    return std.mem.startsWith(u8, word, pattern);
}
