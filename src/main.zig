const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // Get system args
    const args = try std.process.argsAlloc(allocator);
    if (args.len != 2) {
        std.debug.print("Invalid number of arguments\n", .{});
        std.debug.print("Usage: ./zcc <number>\n", .{});
        return;
    }
    defer std.process.argsFree(allocator, args);

    // Covert string to usize
    const number = try std.fmt.parseInt(usize, args[1], 10);

    // Create tmp assemably file
    const tmpfs = std.fs.cwd().createFile("tmp.s", .{ .truncate = true }) catch |err| {
        std.debug.panic("Create tmp assemably file failed: {s}\n", .{@errorName(err)});
    };
    defer tmpfs.close();

    // Write assemably file
    tmpfs.writer().print("  .global main\n", .{}) catch unreachable;
    tmpfs.writer().print("main:\n", .{}) catch unreachable;
    tmpfs.writer().print("  mov ${d}, %rax\n", .{number}) catch unreachable;
    tmpfs.writer().print("  ret\n", .{}) catch unreachable;
}
