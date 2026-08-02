# Structural declaration recovery

Date: 2026-07-29

## Problem

The initial module synchronizer discarded the failed physical line and stopped before the next line beginning with a declaration keyword. This could misclassify nested members as top-level declarations:

```dew
impl Value {
  fn broken(self) -> Unit {
    let value =
  }

  fn nested(self) -> Unit {}
}

type After = I32
```

After the method failure, a keyword-only synchronizer could emit `nested` as a module function instead of skipping the failed impl.

The same risk applied to trait methods, local `let` declarations, enum struct variants, and keyword-led syntax inside blocks, matches, and functional loops.

## Failure-only recovery metadata

Recovery now uses a private recursive failure wrapper:

```text
RecoveryFailure =
  DeclarationFailure(DeclarationError)
  ExpressionFailure(ExpressionError)
  PatternFailure(PatternError)
  InsideBrace(RecoveryFailure)
  InsideParenthesis(RecoveryFailure)
  InsideBracket(RecoveryFailure)
  InsideAngle(RecoveryFailure)
```

Each parser routine that owns an already-consumed opening delimiter wraps a child failure only if that child fails before the owner successfully consumes its matching closer.

Examples:

- `parse_block_after_left_brace` failures are wrapped by `InsideBrace` at the call site.
- Call-argument failures are wrapped by `InsideParenthesis`.
- Index failures are wrapped by `InsideBracket`.
- Type-argument and type-parameter failures are wrapped by `InsideAngle`.
- Tuple-pattern and struct-pattern failures preserve their own delimiter frames.
- Match, functional while, function, impl, trait, struct, enum, and enum-variant bodies add their enclosing brace frames.

The wrapper exists only on an error path. Successful parsing does not allocate recovery frames, update delimiter counters, or add fields to `Parser`.

## Stable public APIs

The public APIs still return the original errors:

```moonbit
Parser::parse_expression() -> Result[Expr, ExpressionError]
Parser::parse_pattern() -> Result[Pattern, PatternError]
Parser::parse_declaration() -> Result[Declaration, DeclarationError]
```

Private recoverable entry points preserve structural frames. Public entry points strip those frames and return the original diagnostic value. Module streaming uses the recoverable declaration entry point and keeps the same `ParseEvent::Diagnostic(ParseDiagnostic)` representation.

The prior match-specific `MatchArm` type was already generalized to `PatternArm`; no public recovery metadata is retained in AST nodes or events.

## Recovery fence

When module parsing receives a `RecoveryFailure`, it flattens the recursive wrappers into four scalar depths:

```text
RecoveryFence {
  braces
  parentheses
  brackets
  angles
}
```

If all depths are zero, recovery retains the inexpensive line-based behavior. Otherwise it scans forward while updating the fence:

- `{` and `}` update brace depth.
- `(` and `)` update parenthesis depth.
- `[` and `]` update bracket depth.
- `<`, `>`, and contextual `>>` update an already-active angle depth.

A `<` begins an additional angle level only when angle recovery is already active. This avoids treating ordinary comparison operators encountered during brace recovery as generic openings.

Recovery does not consider declaration keywords while any delimiter depth remains open. Once every depth reaches zero, it consumes through the current physical line, skips blank lines, and resumes before the next declaration-keyword line.

## Exact nested-body behavior

For a failure inside:

```dew
impl Value {
  fn broken(self) -> Unit {
    if ready {
      match state {
        _ => malformed +
      }
    }
  }
}
```

the failure carries frames for the match body, if block, method block, and impl body. Recovery consumes all four closing braces before it can consider another `fn`, `let`, `type`, or other declaration keyword.

This prevents nested-member leakage while retaining one-token parser lookahead and forward-only input consumption.

## Closed-delimiter correctness

A delimiter frame is not retained after its closer has been consumed successfully. For example:

```dew
trait Broken {} extra
type After = Bool
```

The trait body is closed before the trailing-token error. Recovery therefore uses a line fence rather than searching for another trait closing brace, and `After` remains recoverable.

## Conservative unclosed declarations

If an enclosing delimiter never closes, recovery reaches EOF rather than guessing that a keyword inside the open scope is top-level:

```dew
fn broken() -> Unit {
  malformed +
type Uncertain = I32
```

Only the original function diagnostic is emitted. `Uncertain` is not emitted because its module-level status cannot be proven.

This deliberately favors structural correctness over speculative recovery. A future editor-only recovery mode may apply additional heuristics, but the compiler stream remains deterministic.

## Diagnostic conversion

Recovery frames preserve the original diagnostic category:

- Pattern failures inside match or while become `MatchPatternError` when exposed as expression errors.
- Expression failures inside declarations become `DeclarationExpressionError`.
- Function-block formatting errors retain their established declaration-specific mappings, such as `FunctionBodyNewline`, `LineEnd`, and `UnclosedFunction`.

`ParseEvent` still emits one error-severity diagnostic for one failed declaration. Skipped nested members do not produce cascaded top-level diagnostics.

## Complexity

- Successful parsing: no recovery-frame allocation and no persistent parser-state growth.
- Failed parsing: one small wrapper per still-open delimiter owner.
- Recovery scan: linear in the skipped token count.
- Recovery memory: constant scalar fence after failure flattening.
- Source behavior: forward-only, no rewind, no source retention, and no token replay.

## Tests

Coverage includes:

- Malformed trait methods followed by valid nested methods
- Malformed impl methods followed by valid nested methods
- Failures inside nested function `if` and match bodies
- Failures inside functional while arms
- Malformed enum struct-variant fields
- Multiline malformed function parameter lists
- Multiline generic-parameter recovery
- Parenthesized-group recovery
- Call and index recovery
- Closed-body trailing-token recovery
- Conservative recovery to EOF for unclosed declarations
- Lazy module event behavior
- A 1,024-parenthesis failure proving iterative frame flattening and reconstruction
- A 256-declaration nested recovery stress workload producing 256 diagnostics and 256 subsequent valid aliases

## Benchmarks

The benchmark source is `src/parser/type_alias_module_bench_test.mbt`.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| structural impl recovery parse-only, n=64 | 43.11–43.12 us | 29.90 us | 31.75 us | 167.66 us |
| structural impl recovery end-to-end, n=64 | 166.97–171.27 us | 225.37 us | 192.72 us | 561.74 us |
| nested function recovery parse-only, n=64 | 71.19–71.44 us | 46.98 us | 51.51 us | 261.31 us |
| nested function recovery end-to-end, n=64 | 210.00–214.00 us | 241.21 us | 220.15 us | 634.29 us |
| unclosed declaration recovery to EOF | 2.02–2.03 us | 2.30 us | 1.89 us | 6.20 us |

Backend values should only be compared within one runner. Successful module parsing remains benchmarked separately to expose any hot-path regression.
