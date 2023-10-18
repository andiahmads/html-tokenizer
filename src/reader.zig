pub const Reader = struct {
    source: []u8,
    ptr: usize,
    const Self = @This();

    pub fn reconsume(self: *Self) void {
        if (self.ptr != 0) {
            self.ptr -= 1;
        }
    }
    pub fn next_character(self: *Self) ?u8 {
        const char = self.source[self.ptr];
        self.ptr += 1;
        return char;
    }
};
