const std = @import("std");
const Allocator = std.mem.Allocator;

pub const TokenTag = enum {
    DocType,
    Tag,
    Comment,
    Character,
    EndOfFile,
};

pub const Attribute = struct {
    key: []u8,
    value: []u8,
};

pub const DocType = struct {
    name: ?[]const u8,
    public_identifier: ?[]const u8,
    system_identifier: ?[]const u8,
    force_quick: bool,

    // deinit function
    const Self = @This();
    pub fn deinit(self: *const Self, allocator: Allocator) void {
        // handle tipe data optional
        if (self.name) |name| {
            allocator.free(name);
        }
        if (self.public_identifier) |public_identifier| {
            allocator.free(public_identifier);
        }
        if (self.system_identifier) |system_identifier| {
            allocator.free(system_identifier);
        }
    }
};

pub const Tag = struct {
    is_opening: bool,
    name: []const u8,
    self_closing: bool,
    attributes: std.ArrayListUnmanaged(Attribute),

    const Self = @This();

    pub fn deinit(self: *Self, allocator: Allocator) void {
        allocator.free(self.name);
        self.attributes.deinit(allocator);
    }
};

pub const Token = union(TokenTag) {
    DocType: DocType,
    Tag: Tag,
    Comment: []u8,
    Character: []u8,
    EndOfFile: void,

    const Self = @This();
    pub fn deinit(self: *Self, allocator: Allocator) void {
        switch (self.*) {
            TokenTag.DocType => |doctype| doctype.deinit(allocator),
            TokenTag.Tag => self.Tag.deinit(allocator),
            TokenTag.Comment => |comment| allocator.free(comment),
            else => {},
        }
    }
};