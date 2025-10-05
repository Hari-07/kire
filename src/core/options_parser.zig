const std = @import("std");
const toml = @import("toml");

// We want to allow easier syntax for the TOML
const KireConfigDTO = struct {
    packages: toml.HashMap([]const u8),
};

pub const KireConfigPackage = struct {
    packageName: []const u8,
    packagePath: []const u8,
};
pub const KireConfig = struct { packages: []const KireConfigPackage };

pub fn parseOptions(allocator: std.mem.Allocator) !KireConfig {
    var parser = toml.Parser(KireConfigDTO).init(allocator);
    defer parser.deinit();

    const result = try parser.parseFile("./kire.toml");
    defer result.deinit();
    const configDto = result.value;

    var packages = std.ArrayList(KireConfigPackage).init(allocator);
    defer packages.deinit();

    var iterator = configDto.packages.map.iterator();
    while (iterator.next()) |entry| {
        const name_copy = try allocator.dupe(u8, entry.key_ptr.*);
        const path_copy = try allocator.dupe(u8, entry.value_ptr.*);

        try packages.append(KireConfigPackage{
            .packageName = name_copy,
            .packagePath = path_copy,
        });
    }

    return KireConfig{ .packages = try packages.toOwnedSlice() };
}
