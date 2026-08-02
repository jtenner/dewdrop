# Type aliases and module event streaming

Date: 2026-07-29

## Type alias grammar

```text
type-alias = "pub"? "type" identifier type-parameters?
             "=" type line-end
```

Examples:

```dew
type UserId = U64

pub type Rows<t> = Result<List<t>>
```

The target may begin on a following physical line because the declaration is syntactically incomplete after `=`:

```dew
type Nested<t> =
  Map<String,
    List<t>,
  >
```

Aliases reuse the shared type-parameter and recursive `TypeExpr` parsers, including multiline type arguments, one trailing comma, and contextual `>>` closing. Alias transparency, cycles, expansion limits, unknown types, and generic arity are semantic concerns.

## Alias AST

```text
TypeAliasDeclaration {
  visibility
  name
  name_offset
  type_parameters
  target
  offset
}
```

`Declaration::TypeAlias` carries the declaration. A bare alias is module-visible; `pub type` exports it.

## Streaming module API

The module parser now exposes one lazy interleaved event stream:

```text
ParseEvent =
  Declaration(Declaration)
  Diagnostic(ParseDiagnostic)

ParseDiagnostic {
  severity
  error
}
```

Entry points:

```moonbit
Parser::parse_events() -> Iter[ParseEvent]
parse(Iter[Token]) -> Iter[ParseEvent]
parse_bytes(Bytes) -> Iter[ParseEvent]
```

The iterator skips blank lines, parses declarations only when pulled, emits each successful declaration immediately, and emits declaration, expression, or lexical failures as error-severity diagnostics. It does not collect a module AST or separate declaration and diagnostic buffers.

## Recovery

Recovery now uses private failure-only structural metadata. Every still-open delimiter owner wraps a propagated failure with a brace, parenthesis, bracket, or generic-angle frame. Module synchronization flattens those frames into scalar depths and ignores declaration keywords until all enclosing syntax has closed.

A failure with no open delimiters retains the inexpensive line policy:

1. Discard the remainder of the current physical line.
2. Skip blank lines.
3. Discard non-declaration lines.
4. Stop before the next line beginning with a declaration keyword.

A structurally nested failure instead scans through all recorded closers, including nested delimiters encountered during recovery, consumes the enclosing declaration's ending line, and only then resumes keyword-led synchronization. Unclosed declarations conservatively recover to EOF rather than guessing that a keyword inside an open scope is top-level.

The keyword set includes `pub`, `builtin`, `let`, `trait`, `struct`, `enum`, `type`, `fn`, `impl`, and `foreign`. Every recovery path either consumes input or reaches EOF, guaranteeing forward progress. Public parser errors and `ParseEvent` values remain unchanged, and successful parsing does not allocate recovery frames or add fields to `Parser`.

Detailed design, adversarial coverage, and structural recovery benchmarks are recorded in `docs/research/structural-declaration-recovery.md`.

## Diagnostics

`DiagnosticSeverity` currently defines `Error`, `Warning`, `Info`, and `Hint`. Parser failures are emitted as `Error`; the remaining levels are available for later semantic and recovery diagnostics. The original `DeclarationError` is retained intact inside each event.

## Tests

Coverage includes generic and multiline aliases, EOF termination, malformed names/equals/targets, extra line tokens, nested generic closers, declaration separation, blank modules, lazy pull behavior, token and byte entry-point equivalence, lexical failures, malformed-body recovery, nested trait/impl/function/enum recovery, functional-loop failures, delimiter fences, conservative EOF recovery, and declaration order across mixed modules.

## Benchmarks

The benchmark source is `src/parser/type_alias_module_bench_test.mbt`. Module workloads contain 256 generic aliases. Recovery workloads contain 64 malformed lines interleaved with 64 valid aliases. Streaming benchmarks count events without materializing an output event array.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| alias parse-only recursive target | 560.04 ns–1.11 us | 477.76 ns | 313.83 ns | 2.25 us |
| alias tokenize-only recursive target | 1.24–2.45 us | 3.04 us | 1.45 us | 6.13 us |
| alias tokenize + parse recursive target | 1.58–3.07 us | 3.74 us | 1.60 us | 6.44 us |
| module parse-only aliases, n=256 | 97.17–185.70 us | 98.55 us | 63.96 us | 415.71 us |
| module tokenize + parse aliases, n=256 | 277.92–495.44 us | 560.39 us | 273.83 us | 953.32 us |
| module recovery, 64 flat errors + 64 aliases | 48.80–81.03 us | 141.35 us | 57.50 us | 169.98 us |
| structural impl recovery parse-only, n=64 | 43.11–43.12 us | 29.90 us | 31.75 us | 167.66 us |
| structural impl recovery end-to-end, n=64 | 166.97–171.27 us | 225.37 us | 192.72 us | 561.74 us |
| nested function recovery parse-only, n=64 | 71.19–71.44 us | 46.98 us | 51.51 us | 261.31 us |
| nested function recovery end-to-end, n=64 | 210.00–214.00 us | 241.21 us | 220.15 us | 634.29 us |
| unclosed declaration recovery to EOF | 2.02–2.03 us | 2.30 us | 1.89 us | 6.20 us |
| empty module stream | 159.53–304.24 ns | 113.30 ns | 117.97 ns | 609.98 ns |

Several end-to-end runs showed substantial scheduler/frequency variance. Parse-only and end-to-end values must therefore be compared within the same backend and repeated before optimization decisions.
