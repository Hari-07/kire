const std = @import("std");

pub fn run(allocator: std.mem.Allocator, commitArgs: []const []const u8) ![]const []const u8 {
    var commands = std.ArrayList([]const u8).empty;
    defer commands.deinit(allocator);

    const commitCommand = try std.fmt.allocPrint(allocator, "git commit -m {s}", .{commitArgs[0]});
    try commands.append(allocator, commitCommand);
    return try commands.toOwnedSlice(allocator);
}
