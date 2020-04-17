const std = @import("std");
const version = std.builtin.Version{
    .major = 0,
    .minor = 1,
};

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();
    const alloc = &allocator.allocator;

    var arguments = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, arguments);

    if (arguments.len < 2 or std.mem.eql(u8, arguments[1], "help") or std.mem.eql(u8, arguments[1], "--help")) {
        std.debug.warn(usage, .{ version, arguments[0] });
        std.process.exit(0);
    }
    var file = try std.fs.cwd().openFile(arguments[1], .{});
    defer file.close();

    const file_content = try file.inStream().readAllAlloc(alloc, try file.getEndPos());
    var tokens = std.mem.tokenize(file_content, " ");

    var had_errors = false;
    while (tokens.next()) |token| {
        had_errors = true;
        std.debug.warn("encountered illegal token '{}'\n", .{token});
    }
    if (std.mem.indexOfAny(u8, file_content, "\n\t\r ")) |val| {
        had_errors = true;
        std.debug.warn("encountered illegal whitespace\n", .{});
    }
    if (had_errors) {
        std.process.exit(1);
    } else {
        try std.io.getStdOut().outStream().print("Hello, World!\n", .{});
    }
}

const usage =
    \\Odo v{}
    \\
    \\run odo code with {} <file.odo>
    \\
;
