# Expression parser performance

Initial measurements: 2026-07-28

Latest native verification: 2026-07-29

## Environment

- Linux 6.12.95, x86-64
- AMD Ryzen 7 8845HS, 8 cores / 16 threads
- `moon` 0.1.20260713
- `moonc` 0.10.4
- Release builds via `moon bench --release`

The benchmark source is `src/parser/expression_bench_test.mbt`. Timing varies with CPU scheduling and frequency scaling, so ranges from repeated runs are more meaningful than a single minimum.

## Workloads

- **Left associative n=256:** 256 integer operands and 255 `+` operators, 511 tokens.
- **Right associative n=256:** 256 integer operands and 255 `**` operators, 511 tokens.
- **Postfix chain n=64:** 64 repetitions of `.field[1](2,)`, 577 tokens including the root name.
- **Qualified chain n=128:** `Root` followed by 128 `::item_n` qualifications, 257 tokens.
- **Short mixed:** `alpha + beta * gamma`, 5 tokens.

Parse-only benchmarks construct the reusable token array outside the timed closure. They include parser-state and AST allocation. End-to-end benchmarks stream directly from `Tokenizer` into `Parser` and include decoding, lexing, parsing, and AST allocation. Tokenize-only benchmarks additionally materialize an output token array, so they are not a direct decomposition of end-to-end time.

## Native baseline and optimized results

The first native baseline was recorded before the optimization pass:

| Benchmark | Initial mean |
|---|---:|
| parse-only left n=256 | 21.94 us |
| parse-only right n=256 | 22.87 us |
| parse-only postfix n=64 | 24.11 us |
| tokenize + parse left n=256 | 81.36 us |
| tokenize-only integer n=256 | 63.26 us |

Representative optimized ranges from repeated native runs:

| Benchmark | Optimized mean range | Approximate throughput |
|---|---:|---:|
| parse-only left n=256 | 16.17–18.24 us | 28–32 M tokens/s |
| parse-only right n=256 | 15.65–18.29 us | 28–33 M tokens/s |
| parse-only postfix n=64 | 18.95–21.27 us | 27–30 M tokens/s |
| tokenize + parse left n=256 | 36.31–41.23 us | 12–14 M tokens/s |
| tokenize-only integer n=256 | 23.29–28.24 us | 18–22 M tokens/s |
| tokenize-only identifier n=256 | 34.25–37.45 us | 13.6–14.9 M tokens/s |
| parse-only short mixed | 274.04–322.61 ns | — |
| tokenize + parse short mixed | 648.49–694.99 ns | — |

The end-to-end 256-term workload improved by more than one half in the latest verification relative to the initial measurement. Long parse-only workloads improved by roughly 18–30%, depending on operator shape and run-to-run variation. Adding significant newline handling did not regress these newline-free benchmark workloads.

## Cross-backend optimized snapshot

These are runner-specific measurements and should only be compared within a backend:

| Benchmark | Native | WasmGC | JavaScript |
|---|---:|---:|---:|
| parse-only left n=256 | ~17 us | 10.17 us | 12.10 us |
| parse-only right n=256 | ~16–17 us | 12.05 us | 17.46 us |
| parse-only postfix n=64 | ~19–20 us | 11.25 us | 12.08 us |
| tokenize + parse left n=256 | ~40 us | 28.72 us | 37.42 us |
| tokenize-only integer n=256 | ~26 us | 20.60 us | 30.80 us |

## Qualified access

`::` is handled directly in binary-operator-seeking mode as a right-unary property operation. It consumes one following identifier, replaces the current top value with `QualifiedExpr`, and remains in binary-seeking mode. It does not allocate operator-stack metadata or trigger infix reduction.

| Qualified chain n=128 | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only | 5.24–7.96 us | 5.14 us | 5.41 us | 21.23 us |
| tokenize + parse | 21.11–40.87 us | 47.27 us | 36.00 us | 112.04 us |

The additional symbol branch did not change `Parser` state size. Contemporaneous legacy-expression results remained within the broader scheduler/frequency variation already observed in repeated runs.

## Implemented optimizations

### Compact operator stack

The initial operator stack stored payload-carrying `PendingOperator` enum values. The native backend allocated those values. The optimized parser stores operator codes and byte offsets in parallel scalar arrays. This removes one temporary object per pending operator, with the largest benefit for right-associative expressions that retain many operators until finalization.

### Allocation-free operator metadata

Binary operator lookup originally returned an optional tuple containing operator, precedence, and associativity. It now returns only the operator enum; precedence and associativity are computed by direct matches. The operator stack stores compact integer codes.

### Nullable operand pops

The initial `pop_expression` returned `Result[Expr, ExpressionError]`. Native generated code allocated and unwrapped success values on the hot reduction path. It now returns `Expr?`, whose reference-valued option lowers to a nullable reference. Errors are constructed only on the failure path.

### Lookahead consumption without a second peek

Internal parser branches previously called public `take_token`, which called `peek_token` again. Internal consumption now clears the already-loaded lookahead directly. This removes redundant calls and reference-count traffic while retaining the public API.

### Reusable tokenizer scratch builder

Identifiers and numbers previously created a new `StringBuilder` for every token. `Tokenizer` now owns one reusable scratch builder and resets it between tokens. Identifier-heavy tokenization improved substantially.

### Scalar cursor refill

The lexer previously filled lookahead through `Utf8Cursor::next`, which constructs an optional `(codepoint, offset)` tuple. Because lexer and cursor share a package, lexer refill now calls the scalar decoder directly and writes the two fields into its lookahead slots.

### Scalar lexer hot path

The native backend showed that every internal `peek` and `take` allocated a `(UInt, UInt64)` tuple. Trivia, identifiers, numbers, symbols, and top-level token dispatch now inspect lookahead fields and advance them directly. Tuple-returning helpers remain only on less frequent string and multiline-string paths.

## Rejected optimization

Preallocating both parser stacks with capacity 16 slightly improved a long flat expression but made the postfix-chain workload about 19% slower. Every call argument and index expression creates a small nested parser stack, so eager capacity multiplied wasted allocation. The parser retains minimum-capacity arrays and lets unusually deep expressions grow them.

## Remaining opportunities

1. Convert quoted and multiline string scanning from tuple-returning `peek`/`take` to the scalar lookahead path.
2. Benchmark raw-file-descriptor input separately from in-memory input, including refill counts and buffer sizes.
3. Investigate keyword recognition before allocating a completed identifier string.
4. Benchmark long Unicode identifiers and malformed WTF-8 paths separately from ASCII identifiers.
5. Measure allocation counts with a MoonBit-compatible heap profiler when one is available; current timings reveal allocation effects indirectly but do not report bytes or object counts.
6. Consider specialized small call-argument storage only if profiling shows argument-array allocation to be material.
