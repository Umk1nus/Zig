const std = @import("std");

pub fn find(item: []const u8, allocator: std.mem.Allocator) !u8 {
    const halfLength = item.len / 2;

    const firstCompartment = item[0..halfLength];
    const secondCompartment = item[halfLength..];

    var map = std.AutoHashMap(u8, void).init(allocator);

    for (firstCompartment) |i| {
        var m = try map.getOrPut(i);
        if (!m.found_existing) {
            m.value_ptr.* = {};
        }
    }

    for (secondCompartment) |j| {
        if (map.contains(j)) {
            return j;
        }
    }

    return undefined;
}

pub fn getPriority(character: u8) u32 {
    return if (character >= 'a') character - 'a' + 1 else character - 'A' + 27;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("data.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const readFile = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(readFile);

    var contentFile = std.mem.tokenizeAny(u8, readFile, "\n");

    while (contentFile.next()) |item| {
        const commonCharacter = try find(item, allocator);
        const priority = getPriority(commonCharacter);
        std.debug.print("{c} - {}\n", .{ commonCharacter, priority });
    }
}
