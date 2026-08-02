# Dew token-kind implementation

Date: 2026-07-29

## Architecture

`Tokenizer` consumes `Utf8Cursor` with exactly two decoded-unit lookahead slots. Input is never rewound. Two units are sufficient for fixed compound symbols after consuming their first unit, dotted `@identifier` paths, line comments, and MoonBit-style `#|` multiline string continuation markers.

The hot ASCII paths inspect and advance those scalar fields directly. This avoids allocating optional `(codepoint, offset)` tuples for every internal peek and take. Lexer refill calls the package-private scalar cursor decoder directly rather than routing through the cursor's public tuple-returning pull API.

The tokenizer returns `Iter[Token]`. Every token contains:

```text
Token(TokenKind, ByteOffset, Index)
```

`ByteOffset` is the absolute UTF-8 byte offset and `Index` is a monotonically increasing token index.

## Implemented token payloads

- `Newline` represents one physical LF, CRLF, or CR line ending; CRLF emits one token.
- Fixed `Symbol` variants do not allocate decoded text.
- Keywords use a closed `Keyword` enum.
- Ordinary and `@` identifiers allocate one MoonBit `String` containing the decoded name. A single tokenizer-owned scratch `StringBuilder` is reset and reused between identifier and number tokens.
- Numeric tokens are width-specific: `I32(UInt64)`, `U32(UInt64)`, `I64(UInt64)`, `U64(UInt64)`, `F32(Float)`, and `F64(Double)`. Integer payloads store unsigned magnitude because unary `-` is tokenized separately.
- Quoted and multiline string literals produce `Bytes`, preserving WTF-8 surrogates and malformed raw bytes.
- Recoverable failures produce `TokenKind::Error` and tokenization continues.

## Symbols

The initial symbol set includes parentheses, braces, brackets, `^`, `+`, `-`, `*`, `/`, `**`, `%`, `:`, `::`, `=`, `==`, `=>`, `,`, `;`, `.`, `...`, `<`, `>`, `->`, `!`, `&`, and `|`. `=>` is the dedicated match-arm `FatArrow` token; `...` is `Ellipsis` and acts as a rest pattern inside tuple-like and struct-like pattern payloads.

`@name` and dotted forms such as `@wasm.i64_trunc_i32` are emitted as one `AtIdentifier(String)` token.

## Numbers

Dew mirrors MoonBit's integer suffixes and adds an explicit `F` suffix for symmetry:

```text
1      I32
1U     U32
1L     I64
1UL    U64
1.0    F64
1.0F   F32
```

Floating-point spellings must contain a decimal point, including when scientific notation is used. Thus `1e3` is rejected and `1.0e3` is accepted. The scanner accumulates decimal integer magnitudes directly into `UInt64`; floating-point spellings use MoonBit's IEEE parser after lexical validation.

## Strings

Double-quoted strings support `\\`, `\"`, `\n`, `\r`, `\t`, `\0`, `\b`, `\f`, and `\xHH` escapes. Their payload is decoded bytes rather than a MoonBit string.

MoonBit-style multiline strings begin with `#|`. Consecutive lines may have horizontal indentation followed by another `#|`. The markers and indentation are omitted, and marked lines are joined with one `\n`. A line without a continuation marker ends the token. Because determining this consumes the candidate line ending and indentation, the tokenizer queues a pending `Newline` at the consumed offset when the line does not continue the string.

## Trivia

Horizontal and other non-line Unicode whitespace is skipped. LF, CRLF, and CR are significant `Newline` tokens. `//` comments consume through the text of their line but leave the line ending for normal tokenization. Block comments are not implemented yet.

## Identifier policy

ASCII identifiers begin with a letter or `_` and continue with letters, digits, or `_`. The current provisional Unicode policy accepts any non-whitespace Unicode scalar outside ASCII as an identifier character. A future Unicode XID policy should replace this broad rule.

WTF-8 surrogates and malformed-byte sentinels are rejected outside string literals.
