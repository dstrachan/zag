const std = @import("std");

tag: Tag,
loc: Loc,

pub const Loc = struct {
    start: usize,
    end: usize,
};

pub const keywords = std.StaticStringMap(Tag).initComptime(.{});

pub fn getKeyword(bytes: []const u8) ?Tag {
    return keywords.get(bytes);
}

pub const Tag = enum {
    // Punctuation
    l_paren,
    r_paren,
    l_brace,
    r_brace,
    l_bracket,
    r_bracket,
    semicolon,

    // Operators
    colon,
    colon_colon,
    plus,
    plus_colon,
    minus,
    minus_colon,
    asterisk,
    asterisk_colon,
    percent,
    percent_colon,
    ampersand,
    ampersand_colon,
    pipe,
    pipe_colon,
    caret,
    caret_colon,
    equal,
    equal_colon,
    angle_bracket_left,
    angle_bracket_left_colon,
    angle_bracket_left_equal,
    angle_bracket_left_right,
    angle_bracket_right,
    angle_bracket_right_colon,
    angle_bracket_right_equal,
    dollar,
    dollar_colon,
    comma,
    comma_colon,
    hash,
    hash_colon,
    underscore,
    underscore_colon,
    tilde,
    tilde_colon,
    bang,
    bang_colon,
    question_mark,
    question_mark_colon,
    at,
    at_colon,
    period,
    period_colon,

    // Iterators
    apostrophe,
    apostrophe_colon,
    slash,
    slash_colon,
    backslash,
    backslash_colon,

    // Literals
    number_literal,
    string_literal,
    multiline_string_literal_line,
    symbol_literal,
    identifier,

    // Miscellaneous
    invalid,
    eof,

    pub fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            // Punctuation
            .l_paren => "(",
            .r_paren => ")",
            .l_brace => "{",
            .r_brace => "}",
            .l_bracket => "[",
            .r_bracket => "]",
            .semicolon => ";",

            // Operators
            .colon => ":",
            .colon_colon => "::",
            .plus => "+",
            .plus_colon => "+:",
            .minus => "-",
            .minus_colon => "-:",
            .asterisk => "*",
            .asterisk_colon => "*:",
            .percent => "%",
            .percent_colon => "%:",
            .ampersand => "&",
            .ampersand_colon => "&:",
            .pipe => "|",
            .pipe_colon => "|:",
            .caret => "^",
            .caret_colon => "^:",
            .equal => "=",
            .equal_colon => "=:",
            .angle_bracket_left => "<",
            .angle_bracket_left_colon => "<:",
            .angle_bracket_left_equal => "<=",
            .angle_bracket_left_right => "<>",
            .angle_bracket_right => ">",
            .angle_bracket_right_colon => ">:",
            .angle_bracket_right_equal => ">=",
            .dollar => "$",
            .dollar_colon => "$:",
            .comma => ",",
            .comma_colon => ",:",
            .hash => "#",
            .hash_colon => "#:",
            .underscore => "_",
            .underscore_colon => "_:",
            .tilde => "~",
            .tilde_colon => "~:",
            .bang => "!",
            .bang_colon => "!:",
            .question_mark => "?",
            .question_mark_colon => "?:",
            .at => "@",
            .at_colon => "@:",
            .period => ".",
            .period_colon => ".:",

            // Iterators
            .apostrophe => "'",
            .apostrophe_colon => "':",
            .slash => "/",
            .slash_colon => "/:",
            .backslash => "\\",
            .backslash_colon => "\\:",

            // Literals
            .number_literal,
            .string_literal,
            .multiline_string_literal_line,
            .symbol_literal,
            .identifier,
            => null,

            // Miscellaneous
            .invalid,
            .eof,
            => null,
        };
    }

    pub fn symbol(tag: Tag) []const u8 {
        return tag.lexeme() orelse switch (tag) {
            .number_literal => "a number literal",
            .string_literal, .multiline_string_literal_line => "a string literal",
            .symbol_literal => "a symbol literal",
            .identifier => "an identifier",
            .invalid => "invalid token",
            .eof => "EOF",
            else => unreachable,
        };
    }
};

test {
    std.testing.refAllDeclsRecursive(@This());
}
