const std = @import("std");
const token = @import("token.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    // defer std.debug.assert(gpa.detectLeaks() == false);
    const allocator = gpa.allocator();

    const html_file = try std.fs.cwd().openFile("index.html", .{});
    defer html_file.close();

    const html_source = try html_file.readToEndAlloc(allocator, 0x1000);
    defer allocator.free(html_source);

    var name = try std.fmt.allocPrint(allocator, "foo", .{});
    var example_token = token.Token{
        .Tag = .{
            .name = name,
            .attributes = std.ArrayListUnmanaged(token.Attribute){},
            .is_opening = true,
            .self_closing = false,
        },
    };

    std.debug.print("{s}\n", .{html_source});
    std.debug.print("{}\n", .{example_token});
    example_token.deinit(allocator);
}
