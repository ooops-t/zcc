const std = @import("std");

// Find the first character that is not a number
fn strtol(str: []u8) usize {
    for (str) |s, index| {
        if (s < 48 or s > 57)
            return index;
    }

    return 0;
}

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

    // Create tmp assemably file
    const tmpfs = std.fs.cwd().createFile("tmp.s", .{ .truncate = true }) catch |err| {
        std.debug.panic("Create tmp assemably file failed: {s}\n", .{@errorName(err)});
    };
    defer tmpfs.close();

    // Write assemably file
    tmpfs.writer().print("  .global main\n", .{}) catch unreachable;
    tmpfs.writer().print("main:\n", .{}) catch unreachable;

    // Get the first number
    var start: usize = strtol(args[1]);
    var number = try std.fmt.parseInt(usize, args[1][0..start], 10);
    tmpfs.writer().print("  mov ${d}, %rax\n", .{number}) catch unreachable;

    var end: usize = 0;
    for (args[1]) |value, index| {
        if ('+' == value) {
            start = index + 1; // Skip
            end = strtol(args[1][start..]) + start;
            if (start == end) {
                number = try std.fmt.parseInt(usize, args[1][start..], 10);
            } else {
                number = try std.fmt.parseInt(usize, args[1][start..end], 10);
            }
            tmpfs.writer().print("  add ${d}, %rax\n", .{number}) catch unreachable;
            continue;
        }

        if ('-' == value) {
            start = index + 1; // Skip
            end = strtol(args[1][start..]) + start;
            if (start == end) {
                number = try std.fmt.parseInt(usize, args[1][start..], 10);
            } else {
                number = try std.fmt.parseInt(usize, args[1][start..end], 10);
            }
            tmpfs.writer().print("  sub ${d}, %rax\n", .{number}) catch unreachable;
            continue;
        }
    }

    tmpfs.writer().print("  ret\n", .{}) catch unreachable;
}
