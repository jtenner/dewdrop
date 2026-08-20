# Self-host parser port — August 20, 2026

## Status

The Dew self-host compiler now has a complete source-Bytes parser. The old
`pub fn main() -> I32 { literal }` smoke parser remains only as a compatibility
wrapper over the full parser.

The port is split into reviewable layers under `self_host/compiler/`:

- `parser_ast.dew`: syntax graph, declarations, diagnostics, and parse events;
- `parser_core.dew`: token cursor, type parser, and type parameters;
- `parser_pattern.dew`: literal, constructor, tuple, struct, rest, and qualified patterns;
- `parser_expression.dew`: Pratt expression parsing, calls, indexing, fields,
  construction, explicit type calls, arrays, products, and operators;
- `parser_control.dew`: blocks, lambdas, `if`, `match`, functional `while`,
  `for`, product bindings, `using`, and `defer` lowering;
- `parser_declaration_forms.dew`: functions, tests, implementations, structs,
  enums, aliases, and derivation requests;
- `parser_declarations.dew`: imports, builtins, traits, foreign declarations,
  module event streaming, and declaration-boundary recovery.

## Representation decisions

Source requests are bounded below U32, so the Dew parser stores byte offsets and
token indexes as U32. The MoonBit parser uses UInt64 because its tokenizer also
supports host streams. No accepted bootstrap source can exceed the Dew bound.

The type parser uses an explicit frame stack. This keeps nested generic closing
`>>` handling deterministic and avoids consuming a field-ending newline while a
pending outer generic closer is still active.

Expressions use precedence climbing. `if value is Pattern` is lowered to a
binding match. Conjunction guards use an internal `IsGuardExpr` only between
expression parsing and `if` lowering; it does not escape the completed parser
result. `for` uses the same allocation-free Option iterator lowering as the
production parser.

`using` and `defer` register hidden cleanup lambdas and emit cleanup calls in
reverse order. Return values are evaluated before cleanup. Product bindings are
lowered through one hidden value and indexed product projections.

## Recovery

Module parsing emits interleaved declaration and diagnostic events. After a
failure, recovery tracks brace, parenthesis, and bracket depth, then resumes at
the next declaration-leading keyword. Imports after the declaration preamble
produce a diagnostic without discarding the parsed import.

## Acceptance

Focused Dew tests cover:

- nested, qualified, product, and function types;
- constructor, rest, and multiline struct patterns;
- precedence, postfix operations, arrays, products, lambdas, and control flow;
- `if is`, functional `while`, `for`, product binding, `using`, and `defer` lowering;
- every declaration family and declaration-boundary recovery;
- the historical linked self-host smoke compiler.

`tools/check-self-host-parser.py` compiles parser tests in bounded batches and
requires diagnostic-free parsing for every checked-in Dew source that is
expected to compile. The current corpus covers the standard library, self-host
sources, and successful module snapshot fixtures.

The persistent MoonBit parse-event artifact codec remains part of the later
cache-codec port. The first cache-disabled fixed point consumes the in-memory
Dew syntax graph directly and does not require that persistence format.

## Next phase

Semantic collection and flat HIR landed later on August 20, 2026. See
[`self-host-semantic-collection-2026-08-20.md`](self-host-semantic-collection-2026-08-20.md).
Resolved types, alias normalization, module interfaces, body names, and derive
expansion have since landed. The next phase is imported semantic recipes and
body inference.
