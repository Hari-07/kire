const std = @import("std");
const string = @import("../utils/string.zig");
const optionsParser = @import("../core/options_parser.zig");

pub fn run(allocator: std.mem.Allocator, commitArgs: []const []const u8, config: optionsParser.KireConfig) ![]const []const u8 {
    var commands = std.ArrayList([]const u8).init(allocator);
    defer commands.deinit();

    var changeMap = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);

    const changedFiles = try getChangedFiles(allocator);
    const packages = config.packages;

    for (changedFiles) |changedFile| {
        var isRootFile = true;
        for (packages) |package| {
            if (string.stringStartsWith(changedFile, package.packagePath)) {
                isRootFile = false;
                if (changeMap.getPtr(package.packageName)) |list| {
                    try list.append(changedFile);
                } else {
                    var newList = std.ArrayList([]const u8).init(allocator);
                    try newList.append(changedFile);
                    try changeMap.put(package.packageName, newList);
                }
            }
        }
        if (isRootFile) {
            if (changeMap.getPtr("root")) |list| {
                try list.append(changedFile);
            } else {
                var newList = std.ArrayList([]const u8).init(allocator);
                try newList.append(changedFile);
                try changeMap.put("root", newList);
            }
        }
    }

    // DEBUG: PRINTING OUT THE CHANGE MAP
    var iterator = changeMap.iterator();
    while (iterator.next()) |entry| {
        const packageName = entry.key_ptr.*;
        const list = entry.value_ptr.*.items;

        const commitCommand = try createCommitString(allocator, packageName, list, commitArgs[0]);
        try commands.append(commitCommand);
    }

    // Cleanup
    for (changedFiles) |changedFile| {
        defer allocator.free(changedFile);
    }
    defer allocator.free(changedFiles);

    var it = changeMap.iterator();
    while (it.next()) |entry| {
        const list = entry.value_ptr.*;
        list.deinit();
    }
    changeMap.deinit();

    return try commands.toOwnedSlice();
}

fn getChangedFiles(allocator: std.mem.Allocator) ![]const []const u8 {
    var changedFiles = std.ArrayList([]const u8).init(allocator);
    defer changedFiles.deinit();

    // Look at what changed using git and then bucket them into changeMap
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "git", "diff", "--cached", "--name-only" },
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    var lines = std.mem.splitScalar(u8, result.stdout, '\n');
    while (lines.next()) |line| {
        const lineCopy = try allocator.dupe(u8, line);
        try changedFiles.append(lineCopy);
    }

    return changedFiles.toOwnedSlice();
}

fn createCommitString(
    allocator: std.mem.Allocator,
    packageName: []const u8,
    files: []const []const u8,
    message: []const u8,
) ![]const u8 {
    var command = std.ArrayList(u8).init(allocator);
    defer command.deinit();

    const writer = command.writer();

    try writer.writeAll("git commit ");

    for (files) |file| {
        try writer.writeAll(file);
        try writer.writeByte(' ');
    }

    try writer.print("-m \"[{s}] {s}\"", .{ packageName, message });

    const commitCommand = try command.toOwnedSlice();
    // defer allocator.free(commitCommand);

    return commitCommand;
}
