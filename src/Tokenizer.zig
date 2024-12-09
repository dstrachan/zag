const std = @import("std");
const assert = std.debug.assert;

pub const Token = @import("Token.zig");

const Tokenizer = @This();

buffer: [:0]const u8,
index: usize,

pub fn init(buffer: [:0]const u8) Tokenizer {
    // Skip the UTF-8 BOM if present.
    return .{
        .buffer = buffer,
        .index = if (std.mem.startsWith(u8, buffer, "\xEF\xBB\xBF")) 3 else 0,
    };
}

const State = enum {
    start,
    colon,
    plus,
    minus,
    asterisk,
    percent,
    ampersand,
    pipe,
    caret,
    equal,
    angle_bracket_left,
    angle_bracket_right,
    dollar,
    comma,
    hash,
    underscore,
    tilde,
    bang,
    question_mark,
    at,
    period,
    apostrophe,
    slash,
    line_comment_start,
    line_comment,
    backslash,
    multiline_string_literal_line,
    number_literal,
    string_literal,
    string_literal_backslash,
    backtick,
    symbol_literal,
    identifier,
    expect_newline,
    invalid,
};

/// After this returns invalid, it will reset on the next newline, returning tokens starting from there.
/// An eof token will always be returned at the end.
pub fn next(self: *Tokenizer) Token {
    var result: Token = .{
        .tag = undefined,
        .loc = .{
            .start = self.index,
            .end = undefined,
        },
    };

    state: switch (State.start) {
        .start => switch (self.buffer[self.index]) {
            0 => {
                if (self.index == self.buffer.len) {
                    return .{
                        .tag = .eof,
                        .loc = .{
                            .start = self.index,
                            .end = self.index,
                        },
                    };
                } else {
                    continue :state .invalid;
                }
            },
            ' ', '\n', '\t', '\r' => {
                self.index += 1;
                result.loc.start = self.index;
                continue :state .start;
            },

            // Punctuation
            '(' => {
                result.tag = .l_paren;
                self.index += 1;
            },
            ')' => {
                result.tag = .r_paren;
                self.index += 1;
            },
            '{' => {
                result.tag = .l_brace;
                self.index += 1;
            },
            '}' => {
                result.tag = .r_brace;
                self.index += 1;
            },
            '[' => {
                result.tag = .l_bracket;
                self.index += 1;
            },
            ']' => {
                result.tag = .r_bracket;
                self.index += 1;
            },
            ';' => {
                result.tag = .semicolon;
                self.index += 1;
            },

            // Operators
            ':' => continue :state .colon,
            '+' => continue :state .plus,
            '-' => continue :state .minus,
            '*' => continue :state .asterisk,
            '%' => continue :state .percent,
            '&' => continue :state .ampersand,
            '|' => continue :state .pipe,
            '^' => continue :state .caret,
            '=' => continue :state .equal,
            '<' => continue :state .angle_bracket_left,
            '>' => continue :state .angle_bracket_right,
            '$' => continue :state .dollar,
            ',' => continue :state .comma,
            '#' => continue :state .hash,
            '_' => continue :state .underscore,
            '~' => continue :state .tilde,
            '!' => continue :state .bang,
            '?' => continue :state .question_mark,
            '@' => continue :state .at,
            '.' => continue :state .period,

            // Iterators
            '\'' => continue :state .apostrophe,
            '/' => continue :state .slash,
            '\\' => continue :state .backslash,

            // Literals
            '0'...'9' => {
                result.tag = .number_literal;
                self.index += 1;
                continue :state .number_literal;
            },
            '"' => {
                result.tag = .string_literal;
                continue :state .string_literal;
            },
            '`' => {
                result.tag = .symbol_literal;
                continue :state .backtick;
            },
            'a'...'z', 'A'...'Z' => {
                result.tag = .identifier;
                continue :state .identifier;
            },
            else => continue :state .invalid,
        },

        .colon => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .colon_colon;
                    self.index += 1;
                },
                else => result.tag = .colon,
            }
        },

        .plus => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .plus_colon;
                    self.index += 1;
                },
                else => result.tag = .plus,
            }
        },

        .minus => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .minus_colon;
                    self.index += 1;
                },
                else => result.tag = .minus,
            }
        },

        .asterisk => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .asterisk_colon;
                    self.index += 1;
                },
                else => result.tag = .asterisk,
            }
        },

        .percent => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .percent_colon;
                    self.index += 1;
                },
                else => result.tag = .percent,
            }
        },

        .ampersand => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .ampersand_colon;
                    self.index += 1;
                },
                else => result.tag = .ampersand,
            }
        },

        .pipe => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .pipe_colon;
                    self.index += 1;
                },
                else => result.tag = .pipe,
            }
        },

        .caret => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .caret_colon;
                    self.index += 1;
                },
                else => result.tag = .caret,
            }
        },

        .equal => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .equal_colon;
                    self.index += 1;
                },
                else => result.tag = .equal,
            }
        },

        .angle_bracket_left => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .angle_bracket_left_colon;
                    self.index += 1;
                },
                '=' => {
                    result.tag = .angle_bracket_left_equal;
                    self.index += 1;
                },
                '>' => {
                    result.tag = .angle_bracket_left_right;
                    self.index += 1;
                },
                else => result.tag = .angle_bracket_left,
            }
        },

        .angle_bracket_right => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .angle_bracket_right_colon;
                    self.index += 1;
                },
                '=' => {
                    result.tag = .angle_bracket_right_equal;
                    self.index += 1;
                },
                else => result.tag = .angle_bracket_right,
            }
        },

        .dollar => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .dollar_colon;
                    self.index += 1;
                },
                else => result.tag = .dollar,
            }
        },

        .comma => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .comma_colon;
                    self.index += 1;
                },
                else => result.tag = .comma,
            }
        },

        .hash => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .hash_colon;
                    self.index += 1;
                },
                else => result.tag = .hash,
            }
        },

        .tilde => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .tilde_colon;
                    self.index += 1;
                },
                else => result.tag = .tilde,
            }
        },

        .underscore => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .underscore_colon;
                    self.index += 1;
                },
                else => result.tag = .underscore,
            }
        },

        .bang => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .bang_colon;
                    self.index += 1;
                },
                else => result.tag = .bang,
            }
        },

        .question_mark => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .question_mark_colon;
                    self.index += 1;
                },
                else => result.tag = .question_mark,
            }
        },

        .at => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                '"' => {
                    result.tag = .identifier;
                    continue :state .string_literal;
                },
                ':' => {
                    result.tag = .at_colon;
                    self.index += 1;
                },
                else => result.tag = .at,
            }
        },

        .period => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .period_colon;
                    self.index += 1;
                },
                else => result.tag = .period,
            }
        },

        .apostrophe => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                ':' => {
                    result.tag = .apostrophe_colon;
                    self.index += 1;
                },
                else => result.tag = .apostrophe,
            }
        },

        .slash => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                '/' => continue :state .line_comment_start,
                ':' => {
                    result.tag = .slash_colon;
                    self.index += 1;
                },
                else => result.tag = .slash,
            }
        },
        .line_comment_start => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => {
                    if (self.index != self.buffer.len) {
                        continue :state .invalid;
                    } else return .{
                        .tag = .eof,
                        .loc = .{
                            .start = self.index,
                            .end = self.index,
                        },
                    };
                },
                '\n' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },
                '\r' => continue :state .expect_newline,
                0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                    continue :state .invalid;
                },
                else => continue :state .line_comment,
            }
        },
        .line_comment => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => {
                    if (self.index != self.buffer.len) {
                        continue :state .invalid;
                    } else return .{
                        .tag = .eof,
                        .loc = .{
                            .start = self.index,
                            .end = self.index,
                        },
                    };
                },
                '\n' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },
                '\r' => continue :state .expect_newline,
                0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                    continue :state .invalid;
                },
                else => continue :state .line_comment,
            }
        },

        .backslash => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                '\\' => {
                    result.tag = .multiline_string_literal_line;
                    continue :state .multiline_string_literal_line;
                },
                ':' => {
                    result.tag = .backslash_colon;
                    self.index += 1;
                },
                else => result.tag = .backslash,
            }
        },
        .multiline_string_literal_line => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => if (self.index != self.buffer.len) {
                    continue :state .invalid;
                },
                '\n' => {},
                '\r' => if (self.buffer[self.index + 1] != '\n') {
                    continue :state .invalid;
                },
                0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => continue :state .invalid,
                else => continue :state .multiline_string_literal_line,
            }
        },

        .number_literal => switch (self.buffer[self.index]) {
            '0'...'9', '.' => {
                self.index += 1;
                continue :state .number_literal;
            },
            else => {},
        },

        .string_literal => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => {
                    if (self.index != self.buffer.len) {
                        continue :state .invalid;
                    } else {
                        result.tag = .invalid;
                    }
                },
                '\n' => result.tag = .invalid,
                '\\' => continue :state .string_literal_backslash,
                '"' => self.index += 1,
                0x01...0x09, 0x0b...0x1f, 0x7f => {
                    continue :state .invalid;
                },
                else => continue :state .string_literal,
            }
        },
        .string_literal_backslash => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0, '\n' => result.tag = .invalid,
                else => continue :state .string_literal,
            }
        },

        .backtick => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                '"' => continue :state .string_literal,
                'a'...'z', 'A'...'Z', '0'...'9' => continue :state .symbol_literal,
                else => {},
            }
        },
        .symbol_literal => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                'a'...'z', 'A'...'Z', '0'...'9' => continue :state .symbol_literal,
                else => {},
            }
        },

        .identifier => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                'a'...'z', 'A'...'Z', '0'...'9' => continue :state .identifier,
                else => {
                    const ident = self.buffer[result.loc.start..self.index];
                    if (Token.getKeyword(ident)) |tag| {
                        result.tag = tag;
                    }
                },
            }
        },

        .expect_newline => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => {
                    if (self.index == self.buffer.len) {
                        result.tag = .invalid;
                    } else {
                        continue :state .invalid;
                    }
                },
                '\n' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },
                else => continue :state .invalid,
            }
        },

        .invalid => {
            self.index += 1;
            switch (self.buffer[self.index]) {
                0 => if (self.index == self.buffer.len) {
                    result.tag = .invalid;
                } else {
                    continue :state .invalid;
                },
                '\n' => result.tag = .invalid,
                else => continue :state .invalid,
            }
        },
    }

    result.loc.end = self.index;
    return result;
}

fn testTokenize(source: [:0]const u8, expected_token_tags: []const Token.Tag) !void {
    var tokenizer = Tokenizer.init(source);
    for (expected_token_tags) |expected_token_tag| {
        const token = tokenizer.next();
        try std.testing.expectEqual(expected_token_tag, token.tag);
    }
    // Last token should always be eof, even when the last token was invalid,
    // in which case the tokenizer is in an invalid state, which can only be
    // recovered by opinionated means outside the scope of this implementation.
    const last_token = tokenizer.next();
    try std.testing.expectEqual(Token.Tag.eof, last_token.tag);
    try std.testing.expectEqual(source.len, last_token.loc.start);
    try std.testing.expectEqual(source.len, last_token.loc.end);
}

test {
    std.testing.refAllDecls(@This());
}

test "tokenize punctuation" {
    try testTokenize("(", &.{.l_paren});
    try testTokenize(")", &.{.r_paren});
    try testTokenize("{", &.{.l_brace});
    try testTokenize("}", &.{.r_brace});
    try testTokenize("[", &.{.l_bracket});
    try testTokenize("]", &.{.r_bracket});
    try testTokenize(";", &.{.semicolon});
}

test "tokenize operators" {
    try testTokenize(":", &.{.colon});
    try testTokenize("::", &.{.colon_colon});
    try testTokenize("+", &.{.plus});
    try testTokenize("+:", &.{.plus_colon});
    try testTokenize("-", &.{.minus});
    try testTokenize("-:", &.{.minus_colon});
    try testTokenize("*", &.{.asterisk});
    try testTokenize("*:", &.{.asterisk_colon});
    try testTokenize("%", &.{.percent});
    try testTokenize("%:", &.{.percent_colon});
    try testTokenize("&", &.{.ampersand});
    try testTokenize("&:", &.{.ampersand_colon});
    try testTokenize("|", &.{.pipe});
    try testTokenize("|:", &.{.pipe_colon});
    try testTokenize("^", &.{.caret});
    try testTokenize("^:", &.{.caret_colon});
    try testTokenize("=", &.{.equal});
    try testTokenize("=:", &.{.equal_colon});
    try testTokenize("<", &.{.angle_bracket_left});
    try testTokenize("<:", &.{.angle_bracket_left_colon});
    try testTokenize("<=", &.{.angle_bracket_left_equal});
    try testTokenize("<>", &.{.angle_bracket_left_right});
    try testTokenize(">", &.{.angle_bracket_right});
    try testTokenize(">:", &.{.angle_bracket_right_colon});
    try testTokenize(">=", &.{.angle_bracket_right_equal});
    try testTokenize("$", &.{.dollar});
    try testTokenize("$:", &.{.dollar_colon});
    try testTokenize(",", &.{.comma});
    try testTokenize(",:", &.{.comma_colon});
    try testTokenize("#", &.{.hash});
    try testTokenize("#:", &.{.hash_colon});
    try testTokenize("_", &.{.underscore});
    try testTokenize("_:", &.{.underscore_colon});
    try testTokenize("~", &.{.tilde});
    try testTokenize("~:", &.{.tilde_colon});
    try testTokenize("!", &.{.bang});
    try testTokenize("!:", &.{.bang_colon});
    try testTokenize("?", &.{.question_mark});
    try testTokenize("?:", &.{.question_mark_colon});
    try testTokenize("@", &.{.at});
    try testTokenize("@:", &.{.at_colon});
    try testTokenize(".", &.{.period});
    try testTokenize(".:", &.{.period_colon});
}

test "tokenize iterators" {
    try testTokenize("'", &.{.apostrophe});
    try testTokenize("':", &.{.apostrophe_colon});
    try testTokenize("/", &.{.slash});
    try testTokenize("/:", &.{.slash_colon});
    try testTokenize("\\", &.{.backslash});
    try testTokenize("\\:", &.{.backslash_colon});
}

test "tokenize number literals" {
    try testTokenize("0", &.{.number_literal});
    try testTokenize("0 1", &.{ .number_literal, .number_literal });
    try testTokenize("0.", &.{.number_literal});
    try testTokenize("0. 1.", &.{ .number_literal, .number_literal });
    try testTokenize("0.0", &.{.number_literal});
    try testTokenize("0.0 1.1", &.{ .number_literal, .number_literal });
    try testTokenize("0.1.2", &.{.number_literal});
    try testTokenize("-1", &.{ .minus, .number_literal });
    try testTokenize("1-2", &.{ .number_literal, .minus, .number_literal });
}

test "tokenize string literals" {
    try testTokenize("\"abc\"", &.{.string_literal});
    try testTokenize("\"a\\bc\"", &.{.string_literal});
}

test "newline in string literal" {
    try testTokenize(
        \\"
        \\"
    , &.{ .invalid, .invalid });
}

test "code point literal with unicode code point" {
    try testTokenize(
        \\"💩"
    , &.{.string_literal});
}

test "tokenize multiline string literals" {
    try testTokenize("\\\\", &.{.multiline_string_literal_line});
    try testTokenize(
        \\\\line 1
        \\\\line 2
    , &.{ .multiline_string_literal_line, .multiline_string_literal_line });
}

test "tokenize symbol literals" {
    try testTokenize("`sym", &.{.symbol_literal});
    try testTokenize("`x`y`z", &.{ .symbol_literal, .symbol_literal, .symbol_literal });
    try testTokenize("`sym sym", &.{ .symbol_literal, .identifier });
    try testTokenize("`abc123_identifier", &.{ .symbol_literal, .underscore, .identifier });
    try testTokenize(
        \\`"abc123_identifier"
    , &.{.symbol_literal});
}

test "tokenize identifiers" {
    try testTokenize("UpperCase", &.{.identifier});
    try testTokenize("x1_y2", &.{ .identifier, .underscore, .identifier });
    try testTokenize(
        \\@"x1_y2"
    , &.{.identifier});
}

test "line comments" {
    try testTokenize("//", &.{});
    try testTokenize("// a / b", &.{});
    try testTokenize("// /", &.{});
    try testTokenize("////", &.{});
}

test "line comment followed by identifier" {
    try testTokenize(
        \\    Unexpected,
        \\    // another
        \\    Another,
    , &.{
        .identifier,
        .comma,
        .identifier,
        .comma,
    });
}

test "UTF-8 BOM is recognized and skipped" {
    try testTokenize("\xEF\xBB\xBFa;\n", &.{
        .identifier,
        .semicolon,
    });
}

test "utf8" {
    try testTokenize("//\xc2\x80", &.{});
    try testTokenize("//\xf4\x8f\xbf\xbf", &.{});
}

test "invalid utf8" {
    try testTokenize("//\x80", &.{});
    try testTokenize("//\xbf", &.{});
    try testTokenize("//\xf8", &.{});
    try testTokenize("//\xff", &.{});
    try testTokenize("//\xc2\xc0", &.{});
    try testTokenize("//\xe0", &.{});
    try testTokenize("//\xf0", &.{});
    try testTokenize("//\xf0\x90\x80\xc0", &.{});
}

test "illegal unicode codepoints" {
    // unicode newline characters.U+0085, U+2028, U+2029
    try testTokenize("//\xc2\x84", &.{});
    try testTokenize("//\xc2\x85", &.{});
    try testTokenize("//\xc2\x86", &.{});
    try testTokenize("//\xe2\x80\xa7", &.{});
    try testTokenize("//\xe2\x80\xa8", &.{});
    try testTokenize("//\xe2\x80\xa9", &.{});
    try testTokenize("//\xe2\x80\xaa", &.{});
}
