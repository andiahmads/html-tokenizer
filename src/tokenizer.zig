const std = @import("std");
const Reader = @import("reader.zig").Reader;
const token = @import("token.zig");

// tokenizer HTML pada dasarnya adalah satu mesin State yang sangat besar
// mari kita mulai dengan memodelkan semua state dengan menggunakan enum
// silakan kunjungi https://html.spec.whatwg.org/multipage/parsing.html
pub const tokenizerState = enum {
    data,
    rcdata,
    rawtext,
    script_data,
    plaintext,
    tag_open,
    end_tag_open,
    tag_name,
    rcdata_less_than_sign,
    rcdata_end_tag_open,
    rcdata_end_tag_name,
    rawtext_less_than_sign,
    rawtext_end_tag_open,
    rawtext_end_tag_name,
    script_data_less_than_sign,
    script_data_end_tag_open,
    script_data_end_tag_name,
    script_data_escape_start,
    script_data_escape_start_dash_state,
    script_data_escaped,
    script_data_escaped_dash,
    script_data_escaped_dash_dash,
    script_data_escaped_less_than_sign,
    script_data_escaped_end_tag_open,
    script_data_escaped_end_tag_name,
    script_data_double_escape_start,
    script_data_double_escaped,
    script_data_double_escaped_dash,
    script_data_double_escaped_dash_dash,
    script_data_double_escaped_less_than_sign,
    script_data_double_escape_end,
    before_attribute_name,
    attribute_name,
    after_attribute_name,
    before_attribute_value,
    attribute_value_double_quoted,
    attribute_value_single_quoted,
    attribute_value_unquoted,
    after_attribute_value_quoted,
    self_closing_start_tag,
    bogus_comment,
    markup_declartion_open,
    comment_start,
    comment_start_dash,
    comment,
    comment_less_than_sign,
    comment_less_than_sign_bang,
    comment_less_than_sign_bang_dash,
    comment_less_than_sign_bang_dash_dash,
    comment_end_dash,
    comment_end,
    comment_end_bang,
    doctype,
    before_doctype_name,
    doctype_name,
    after_doctype_name,
    after_doctype_public_keyword,
    before_doctype_public_identifier,
    doctype_public_identifier_double_quote,
    doctype_public_identifier_single_quote,
    after_doctype_public_identifier,
    between_doctype_public_and_system_identifiers,
    after_doctype_system_keyword_state,
    before_doctype_system_identifier_state,
    doctype_system_identifier_double_quoted,
    doctype_system_identifier_single_quoted,
    after_doctype_system_identifier,
    bogus_doctype_state,
    cdata_section,
    cdata_section_bracket,
    cdata_section_end,
    character_reference_state,
    named_character_reference_state,
    ambiguos_character_reference_state,
    numeric_character_reference_state,
    hexadecimal_character_reference_start_state,
    decimal_character_reference_start_state,
    hexadecimal_character_reference_state,
    decimal_character_reference_state,
    numeric_character_reference_end_state,
};

pub const Tokenizer = struct {
    reader: Reader,
    const Self = @This();

    pub fn new(source: []u8) Self {
        return Self{ .reader = Reader{
            .source = source,
            .ptr = 0,
        } };
    }
    pub fn step(self: *Self) ?token.Token {
        std.debug.print("{?c}\n", .{self.reader.next_character()});
        std.debug.print("{?c}\n", .{self.reader.next_character()});
        std.debug.print("{?c}\n", .{self.reader.next_character()});
        std.debug.print("{?c}\n", .{self.reader.next_character()});
        return null;
    }
};
