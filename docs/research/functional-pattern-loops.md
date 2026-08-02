# Functional pattern-loop parsing

Date: 2026-07-29

## Decision

Dew's initial `while` form is a functional state loop modeled after MoonBit's functional looping style. It does not parse a conventional Boolean condition followed by a statement block.

```dew
let value = while initial {
  State::Next(next) if next.is_valid() => {
    continue next
  }
  State::Done(result) => break result
  _ => break 0
}
```

The loop evaluates `initial` once, matches the current state against ordered pattern arms, and requires explicit state transition or termination.

## Grammar

```text
while-expression = "while" expression-before-block while-body
while-body       = "{" "}"
                 | "{" newline newline* pattern-arm* "}"
pattern-arm      = arm-patterns match-guard? "=>"
                   pattern-arm-body newline
pattern-arm-body = expression | block
arm-patterns     = pattern ("," newline* pattern)*
match-guard      = "if" expression

continue-expression = "continue" expression
break-expression    = "break" expression
```

`while` reuses the match subsystem's `PatternArm` representation. Alternatives, guards, tuple and struct rest patterns, nested payloads, and underscore-prefixed discards therefore behave identically in matches and loops.

## Execution model

For:

```dew
while initial {
  PatternA(value) if condition => continue next
  PatternB(result) => break result
  _ => break fallback
}
```

execution is intended to proceed as follows:

1. Evaluate `initial` once to produce the current state.
2. Test arms from top to bottom.
3. Test comma-separated alternatives within an arm.
4. Introduce immutable non-discarded pattern bindings.
5. Evaluate the optional guard.
6. Execute the selected body.
7. `continue next` evaluates `next`, replaces the current state, and branches to the loop header.
8. `break result` evaluates `result`, exits the loop, and produces the `WhileExpr` result.

A false guard continues with the next arm. Guards do not contribute unconditional exhaustiveness coverage.

## AST

```text
PatternArm {
  pattern
  guard_condition?
  body
  offset
}

WhileExpr(initial, arms, while_offset)
BreakExpr(value, break_offset)
ContinueExpr(value, continue_offset)
```

The prior match-specific `MatchArm` name was generalized to `PatternArm`, avoiding a second structurally identical arm representation and allowing match and while parsing to share pattern-list and guard helpers.

`break` and `continue` are expressions so they can be direct arm bodies:

```dew
State::Next(next) => continue next
State::Done(value) => break value
```

They can also appear inside reusable blocks and nested control flow:

```dew
State::Next(next) => {
  if next.is_valid() {
    continue next
  }
  break fallback
}
```

Their eventual type is the bottom/diverging type in the containing expression context. Parser acceptance outside a loop is intentional; semantic control-flow validation reports the missing enclosing loop without adding loop-depth fields to `Parser`.

## Operand boundaries

Both transfers require a value whose first token is on the same physical line:

```dew
continue next
break result
```

These are rejected:

```dew
continue
next

break
result
```

Once the operand has begun, normal incomplete-expression newline rules apply. This same-line start requirement prevents a missing transfer value from consuming the next pattern arm as its operand.

There is no bare `break` or bare `continue` in the functional form. A future Unit-state or Unit-result design must provide an explicit Unit value rather than adding context-sensitive arity to the control keywords.

## Type rules reserved for semantic analysis

For one functional while:

- The initial expression has state type `S`.
- Every arm pattern is checked against `S`.
- Every `continue` targeting the loop must produce `S`.
- Every `break` targeting the loop must produce one result type `R`.
- `WhileExpr` has result type `R`.
- Every reachable selected-arm path must end in `continue`, `break`, `return`, or another diverging expression.
- The arm set must be exhaustive for `S` after accounting for guards.
- Alternative patterns must bind identical names with unifiable types, as for match arms.

Nested control transfers target the nearest enclosing functional while. Labels remain deferred.

## Brace disambiguation

The initial expression uses the existing stop-before-ungrouped-left-brace context:

```dew
while state {
  _ => break result
}
```

A constructor initial state must be grouped:

```dew
while (State {}) {
  _ => break result
}
```

This preserves deterministic one-token parsing across `if`, `match`, and `while`.

## Expression composition

A completed loop returns to binary-seeking mode:

```dew
while state {
  _ => break result
}.field + 1
```

The parser therefore treats a functional while as an ordinary value-producing expression. Its actual result type and reachability are semantic concerns.

## Diagnostics and hardening

Dedicated diagnostics cover:

- Missing while body
- Missing body-opening newline
- Missing arm arrow
- Missing arm-ending newline
- Missing break value
- Missing continue value
- Unclosed functional while
- Pattern and lexical errors inherited from pattern arms

Tests cover guarded state arms, direct and block transfers, alternatives, tuple and struct rest, underscore discards, grouped constructor initial states, postfix/infix continuation, transfer expressions outside loops, missing values, malformed arm structure, compact empty bodies, unclosed bodies, and a 512-arm iterative stress case.

## Benchmarks

The benchmark source is `src/parser/functional_while_bench_test.mbt`.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only guarded arms, n=256 | 150.60–160.23 us | 76.74 us | 81.35 us | 521.35 us |
| tokenize-only guarded arms, n=256 | 274.39–278.02 us | 376.68 us | 317.85 us | 806.57 us |
| tokenize + parse guarded arms, n=256 | 407.88–413.55 us | 459.57 us | 381.80 us | 1.29 ms |
| short state loop, end-to-end | 2.69–2.78 us | 2.73 us | 2.30 us | 8.73 us |

Backend timings should only be compared within one runner. The implementation adds no fields to persistent parser state.

## Deferred loop features

- Conventional mutable Boolean-condition `while`
- The reserved `loop` keyword
- Multiple comma-separated state expressions
- Loop labels and labeled transfers
- Bare Unit-valued break or continue
- Captured rest patterns
Semantic state/result typing is implemented in `docs/research/pattern-match-functional-loop-inference.md`. Constructor-level exhaustiveness and transfer-path analysis are implemented in `docs/research/structured-flow-exhaustiveness.md`.
