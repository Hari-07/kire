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
        var args = std.ArrayList([]const u8).empty;
        defer args.deinit(allocator);

        while (argsIter.next()) |arg| {
            try args.append(allocator, arg);
        }

        return Command{ .Commit = try args.toOwnedSlice(allocator) };
    }

    return Command{ .Unknown = command };
}
