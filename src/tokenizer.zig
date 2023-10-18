const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = @import("reader.zig").Reader;
const mod_token = @import("token.zig");
const Token = mod_token.Token;

// tokenizer HTML pada dasarnya adalah satu mesin State yang sangat besar
// mari kita mulai dengan memodelkan semua state dengan menggunakan enum
// silakan kunjungi https://html.spec.whatwg.org/multipage/parsing.html
const REPLACMENT_CHARACTER = 63; //TODO: replace with proper unicode

pub const TokenizerState = enum {
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
    character_reference,
    named_character_reference,
    ambiguos_character_referenc,
    numeric_character_reference,
    hexadecimal_character_reference_start,
    decimal_character_reference_start,
    hexadecimal_character_reference,
    decimal_character_reference,
    numeric_character_reference_end,
};

pub const Tokenizer = struct {
    reader: Reader,
    state: TokenizerState,
    return_state: ?TokenizerState,

    const Self = @This();

    pub fn new(source: []u8) Self {
        return Self{
            .reader = Reader{
                .source = source,
                .ptr = 0,
            },
            .state = TokenizerState.data,
            .return_state = null,
        };
    }

    fn emit(token: *Token, allocator: Allocator) void {
        defer token.deinit(allocator);
        std.debug.print("{}", .{token});
    }

    fn reconsume(self: *Self, new_state: TokenizerState) void {
        self.state = new_state;
        self.reader.reconsume();
    }

    pub fn step(self: *Self, allocator: Allocator) void {
        // consume the next input character
        switch (self.state) {
            .data => {
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '&' => {
                            // set the return state to the data state
                            self.return_state = .data;

                            // switch to the character reference state
                            self.state = .character_reference;
                        },
                        '<' => {
                            // switch to the tag open state
                            self.state = .tag_open;
                        },
                        '\x00' => {
                            // This is an unexpected-null-character parse error. Emit the current input character as a character token.
                            // emit the current input character as a character token
                            var token = Token{ .character = 0 };
                            emit(&token, allocator);
                        },
                        else => {
                            // emit the current input character as a character token
                            var token = Token{ .character = character };
                            emit(&token, allocator);
                        },
                    }
                } else {
                    // emit an end of file
                    var token = Token{ .end_of_file = {} };
                    emit(&token, allocator);
                }
            },
            .rcdata => {
                // consume the next input character
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '&' => {
                            // Set the return to the RCDATA state
                            self.return_state = .rcdata;

                            // switch to the character reference state
                            self.state = .character_reference;
                        },
                        '<' => {
                            // switch to the RCDATA less-than-sign state,
                            self.state = .rcdata_less_than_sign;
                        },
                        '\x00' => {
                            // this is an unexpected-null-character parse error.
                            // emit a U+FFFD REPLACMENT CHARACTER character token.
                            var token = Token{ .character = REPLACMENT_CHARACTER };
                            emit(&token, allocator);
                        },
                        else => {
                            // emit the current input character as a character token
                            var token = Token{ .character = character };
                            emit(&token, allocator);
                        },
                    }
                } else {
                    // emit an end of file
                    var token = Token{ .end_of_file = {} };
                    emit(&token, allocator);
                }
            },
            .rawtext => {
                // consume the next input character
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '<' => {
                            // switch to the RAWTEXT less-than-sign
                            self.state = .rawtext_less_than_sign;
                        },
                        '\x00' => {
                            // this is an unexpected-null-character parse error.
                            // emit a U+FFFD REPLACMENT CHARACTER character token.
                            var token = Token{ .character = REPLACMENT_CHARACTER };
                            emit(&token, allocator);
                        },
                        else => {
                            // emit the current input character as a character token
                            var token = Token{ .character = character };
                            emit(&token, allocator);
                        },
                    }
                } else {
                    // emit an end of file
                    var token = Token{ .end_of_file = {} };
                    emit(&token, allocator);
                }
            },
            .script_data => {
                // consume the next input character
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '<' => {
                            // switch to the SCRIPT DATA less-than-sign
                            self.state = .script_data_less_than_sign;
                        },
                        '\x00' => {
                            // this is an unexpected-null-character parse error.
                            // emit a U+FFFD REPLACMENT CHARACTER character token.
                            var token = Token{ .character = REPLACMENT_CHARACTER };
                            emit(&token, allocator);
                        },
                        else => {
                            // emit the current input character as a character token
                            var token = Token{ .character = character };
                            emit(&token, allocator);
                        },
                    }
                } else {
                    // emit an end of file
                    var token = Token{ .end_of_file = {} };
                    emit(&token, allocator);
                }
            },
            .plaintext => {
                // consume the next input character
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '<' => {
                            // switch to the SCRIPT DATA less-than-sign
                            self.state = .script_data_less_than_sign;
                        },
                        '\x00' => {
                            // this is an unexpected-null-character parse error.
                            // emit a U+FFFD REPLACMENT CHARACTER character token.
                            var token = Token{ .character = REPLACMENT_CHARACTER };
                            emit(&token, allocator);
                        },
                        else => {
                            // emit the current input character as a character token
                            var token = Token{ .character = character };
                            emit(&token, allocator);
                        },
                    }
                } else {
                    // emit an end of file
                    var token = Token{ .end_of_file = {} };
                    emit(&token, allocator);
                }
            },
            .tag_open => {
                // consume the next input character
                const current_character = self.reader.next_character();
                if (current_character) |character| {
                    switch (character) {
                        '!' => {
                            // switch to the markup_declartion_open
                            self.state = .markup_declartion_open;
                        },
                        '/' => {
                            // switch to the end_tag_open state
                            self.state = .end_tag_open;
                        },
                        'a'...'z', 'A'...'Z', '0'...'9' => {
                            // create new start tag token, set its tag name to empty string. Reconsume in the tag name state
                            self.reconsume(.tag_name);
                        },
                        '?' => {
                            // This is an unexpected-question-mark-instead-of-tag-name parse error.
                            // Create a comment token whose data is the empty string. Reconsume in the bogus comment state.
                        },
                        else => {},
                    }
                } else {}
            },
            else => {},
        }
        // return null;
    }
};
