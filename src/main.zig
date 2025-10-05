const std = @import("std");

const commandParser = @import("core/command_parser.zig");
const commandRunner = @import("core/command_runner.zig");
const optionsParser = @import("core/options_parser.zig");

const commands = struct {
    const commit = @import("commands/commit.zig").run;
};

pub fn main() !void {
    var argsIter = std.process.args();
    defer argsIter.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const cmd = try commandParser.parseArgs(allocator, &argsIter);
    const options = try optionsParser.parseOptions(allocator);

    const terminalCommands: []const []const u8 = cmds: {
        switch (cmd) {
            .Commit => |commitArgs| {
                defer allocator.free(commitArgs);
                break :cmds try commands.commit(allocator, commitArgs, options);
            },
            .Unknown => {
                std.debug.print("Unknown command detected\n", .{});
                return;
            },
        }
    };

    try commandRunner.run(allocator, terminalCommands);

    allocator.free(terminalCommands);
    for (options.packages) |package| {
        allocator.free(package.packageName);
        allocator.free(package.packagePath);
    }
    allocator.free(options.packages);
}
