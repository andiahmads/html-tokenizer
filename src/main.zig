const std = @import("std");
const mod_token = @import("token.zig");
const mod_tokenizer = @import("tokenizer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    // defer std.debug.assert(gpa.detectLeaks() == false);
    const allocator = gpa.allocator();

    const html_file = try std.fs.cwd().openFile("index.html", .{});
    defer html_file.close();

    const html_source = try html_file.readToEndAlloc(allocator, 0x1000);
    defer allocator.free(html_source);

    std.debug.print("{s}\n", .{html_source});

    var tokenizer = mod_tokenizer.Tokenizer.new(html_source);
    tokenizer.step(allocator);
}
