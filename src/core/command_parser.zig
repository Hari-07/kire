const std = @import("std");
const str = @import("../utils/string.zig");

pub const Command = union(enum) {
    Commit: []const []const u8,
    Unknown: []const u8,
};

pub fn parseArgs(allocator: std.mem.Allocator, argsIter: *std.process.ArgIterator) !Command {
    _ = argsIter.next();

    const command = argsIter.next() orelse {
        return Command{ .Unknown = "" };
    };

    if (str.stringEquals(command, "commit")) {
        var args = std.ArrayList([]const u8).init(allocator);
        defer args.deinit();

        while (argsIter.next()) |arg| {
            try args.append(arg);
        }

        return Command{ .Commit = try args.toOwnedSlice() };
    }

    return Command{ .Unknown = command };
}
