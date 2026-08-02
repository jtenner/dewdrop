# Newline-terminated lets and inline objects

Date: 2026-07-29

## Significant newlines

Dew uses physical line endings as declaration terminators instead of semicolons. The tokenizer emits a `Newline` token for each of:

- LF (`\n`);
- CRLF (`\r\n`) as one token at the CR offset;
- CR (`\r`).

Horizontal and other non-line whitespace remains trivia. A `//` comment consumes through the text of the comment but leaves its terminating line ending to be emitted as `Newline`.

End of input acts as an implicit final newline, so the final declaration does not need a physical trailing line ending.

The tokenizer's `#|` multiline-string scanner necessarily examines the following line to determine whether another `#|` marker continues the string. When it consumes the first non-continuation line ending, it records that offset and emits a pending `Newline` immediately after the multiline-string token. This preserves source order without rewinding the streaming cursor.

## Let declarations

```text
let-declaration = "pub"? "let" "mut"? identifier "=" expression line-end
line-end        = newline | end-of-input
```

Examples:

```dew
let value = expression
let mut value = expression
pub let exported = expression
```

The AST retains visibility, mutability, binding name and offset, initializer expression, and declaration offset. As with other declarations, bare `let` is module-visible and optional `pub` exports it.

A physical newline is required between adjacent declarations. Whitespace alone is not a separator.

## Soft expression newlines

The expression parser treats newlines according to its current deterministic state:

- while seeking a unary value, it consumes and ignores newlines because the expression is incomplete;
- after consuming a binary or prefix operator, the parser returns to value-seeking mode, so continuation on the next line works;
- while seeking a binary/postfix continuation at top level, a newline terminates the expression and remains in lookahead for the declaration parser;
- while a grouping parenthesis is open, newlines are soft even after a complete inner value;
- calls and indexes skip newlines around their internal delimiters;
- newlines are accepted after commas, including trailing commas.

Consequently:

```dew
let value = first +
  second

let grouped = (
  first + second
)
```

are continuations, while:

```dew
let value = function
(argument)
```

binds `function` and starts a separate invalid declaration line with `(` rather than calling across a completed top-level line.

## Inline object literals

```text
object          = "{" newline* (object-field newline+)* "}"
object-field    = identifier ":" expression
```

Examples:

```dew
let empty = {}

let object = {
  a: "b"
  c: 39
  d: {}
}
```

Every non-empty object field requires a terminating newline, including the final field before `}`. Commas are not object-field separators. Blank lines are accepted between fields. The field initializer uses the ordinary expression parser, so a newline is only retained as the field terminator once the initializer is syntactically complete.

Object AST nodes contain ordered `ObjectField` records. Duplicate names and structural type inference are semantic concerns.

## Native release benchmark snapshot

Measured on the same AMD Ryzen 7 8845HS environment as the expression benchmarks:

| Workload | Mean |
|---|---:|
| parse-only object declaration, 64 fields | 13.17–21.59 us |
| tokenize and parse object declaration, 64 fields | 36.34–40.08 us |
| tokenize and parse simple let | 928.59–977.13 ns |
| tokenize and parse generic builtin | 1.83–1.99 us |

The benchmark source is `src/parser/declaration_bench_test.mbt`. Parse-only measurement constructs the token array outside the timed closure; end-to-end measurement includes tokenization and AST allocation.

## Recovery and diagnostics

The initial parser reports dedicated deterministic failures for:

- missing object field names;
- missing field colons;
- missing field-terminating newlines;
- unclosed objects;
- missing declaration line endings;
- expression failures inside let initializers.

Unexpected non-error tokens remain in one-token lookahead where possible. Lexer error tokens are consumed and propagated.
