const std = @import("std");

const parser = @import("core/parser.zig");

pub fn main() !void {
    var argsIter = std.process.args();
    defer argsIter.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const cmd = try parser.parseArgs(allocator, &argsIter);
    switch (cmd) {
        .Commit => {
            std.debug.print("Commit detected", .{});
        },
        .Unknown => {
            std.debug.print("Unknown command detected", .{});
        },
    }
}
