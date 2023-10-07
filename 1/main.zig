const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("data.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const readFile = try file.readToEndAlloc(allocator, 512 * 512);
    defer allocator.free(readFile);

    var contentFile = std.mem.split(u8, readFile, "\n");

    var maxNum: u16 = 0;
    var currentNum: u16 = 0;

    while (contentFile.next()) |el| {
        if (el.len == 0) {
            if (currentNum > maxNum) {
                maxNum = currentNum;
                currentNum = 0;
            }
        } else {
            const result: u16 = try std.fmt.parseInt(u16, el, 10);
            currentNum += result;
        }
    }

    std.debug.print("{}", .{maxNum});
}
