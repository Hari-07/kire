const std = @import("std");

const parser = @import("core/parser.zig");
const commandRunner = @import("core/command_runner.zig");

const commands = struct {
    const commit = @import("commands/commit.zig").run;
};

pub fn main() !void {
    var argsIter = std.process.args();
    defer argsIter.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const cmd = try parser.parseArgs(allocator, &argsIter);
    const terminalCommands: []const []const u8 = cmds: {
        switch (cmd) {
            .Commit => |commitArgs| {
                defer allocator.free(commitArgs);
                break :cmds try commands.commit(allocator, commitArgs);
            },
            .Unknown => {
                std.debug.print("Unknown command detected", .{});
                break :cmds &[_][]const u8{};
            },
        }
    };
    defer allocator.free(terminalCommands);

    try commandRunner.run(allocator, terminalCommands);
}
