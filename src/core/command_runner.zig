const std = @import("std");

pub fn run(allocator: std.mem.Allocator, terminalCommands: []const []const u8) !void {
    for (terminalCommands) |terminalCommand| {
        std.debug.print("{s}\n", .{terminalCommand});
        // TODO: Get rid of using sh -c
        var child = std.process.Child.init(
            &[_][]const u8{ "sh", "-c", terminalCommand },
            allocator,
        );
        child.stdout_behavior = .Inherit;
        try child.spawn();
        _ = try child.wait();

        allocator.free(terminalCommand);
    }
}
