# Constructor, block, and if-expression parsing

Date: 2026-07-29

Updated August 13, 2026: explicit nominal construction now uses `::{ ... }`; the legacy `Target { ... }` spelling is rejected.

## Constructor expressions

A `{ ... }` token begins an untyped `ObjectExpr` in unary-value-seeking mode.
Explicit struct construction is the postfix token pair `::{`, attached to the
current value in binary-operator-seeking mode:

```dew
Point::{
  x: 10
  y: 20
}

Message::Data::{
  value: payload
}
```

The AST form is:

```text
ConstructExpr(target, fields, opening_brace_offset)
```

Construction remains in binary-seeking mode, so calls, fields, indexes, qualifications, and infix operators may follow it. The parser accepts any expression-shaped target without semantic lookup. Nominal struct/enum validation, methods, and general static qualification are implemented by later semantic phases.

`ObjectExpr` and `ConstructExpr` share one field-body parser. Field ordering, mandatory terminating newlines, blank lines, comments, nested values, and malformed-field diagnostics therefore remain identical.

A newline after `::` is soft because the postfix is incomplete. A bare `{` after a complete target is no longer construction syntax and remains available to enclosing block parsers.

## Brace-aware expression contexts

Control-flow conditions need `{` to remain available as the following block delimiter. The public parser still uses normal expression behavior:

```moonbit
Parser::parse_expression()
```

Internally, `parse_expression_context(stop_at_left_brace=true)` stops before an ungrouped `{` while in binary-seeking mode. The brace remains in one-token lookahead. This boolean is a call-local parameter and does not enlarge `Parser` state.

The stop rule applies only at grouping depth zero. Explicit construction no longer conflicts with the condition/body boundary:

```dew
if Point::{}.is_valid() {
  run()
}
```

Parentheses remain available for ordinary grouping.

No source rewinding or competing parse tree is needed.

## Reusable blocks

Function bodies and control-flow branches now share:

```text
Block {
  items
  opening_brace_offset
}

BlockItem =
  LetItem
  ReturnItem
  ExpressionItem
```

The grammar remains newline-structural:

```text
block      = "{" "}"
           | "{" newline newline* block-item* "}"
block-item = "let" "mut"? identifier "=" expression newline
           | "return" expression? newline
           | expression newline
```

`Block::tail_expression` returns the final expression item when one exists. It does not synthesize a `Unit` AST node. Function declarations now store `Block` directly; declaration-level adapters preserve the established function-body newline and unclosed-function diagnostics.

A general bare block expression is not introduced because `{ field: value }` is already the one-lookahead object-literal syntax. `BlockExpr` wraps blocks in syntactically known expression positions such as `else` branches.

## If expressions

```text
if-expression = "if" condition block
                ("else" (block | if-expression))?
```

Examples:

```dew
if ready {
  run()
}

if ready {
  first
} else {
  second
}

if first {
  one
} else if second {
  two
} else {
  three
}
```

The AST is:

```text
IfExpr(condition, then_block, optional_else_expression, if_offset)
```

A block `else` is represented as `BlockExpr(Block)`. An `else if` is represented as a nested `IfExpr`. The complete if expression remains in binary-seeking mode, permitting postfix and infix continuation.

Because `else` is optional and the parser has exactly one token of lookahead, `else` must occur on the same physical line as the preceding `}`. A newline after `}` terminates the no-else `if` and remains available to the enclosing block or declaration parser.

## Typing policy

The parser retains an optional else branch but does not decide value versus effect context.

Semantic analysis applies these rules:

- An `if` used as a value must have an `else` branch.
- Branch result types of a value-producing `if` must unify.
- An `if` without `else` has type `Unit`.
- If a no-else branch does not explicitly end in a Unit-producing expression, an implicit Unit result follows it; any prior value is discarded.
- An if-with-else used only for effect may also discard branch values and produce Unit.
- A value-producing `else if` chain must end in a final `else`.

Implicit Unit is a typing/lowering rule rather than a parser-allocated node.

## Tests

Coverage includes named and qualified `::{ ... }` construction, rejection of the legacy bare-brace spelling, empty and populated bodies, soft newlines after `::`, postfix continuation, infix precedence, top-level newline termination before `::`, if-valued fields, binary conditions, explicit constructor conditions/scrutinees/loop states, optional else, value branches, nested else-if, same-line else enforcement, reusable function blocks, tail lookup, malformed conditions/bodies/items/else branches, unclosed blocks, and a 1,024-arm iterative else-if stress chain.

## Benchmarks

The benchmark source is `src/parser/constructor_if_bench_test.mbt`.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only object fields, n=64 | 6.97–14.74 us | 6.17 us | 8.10 us | 39.03 us |
| parse-only qualified constructor fields, n=64 | 7.11–11.13 us | 6.54 us | 9.26 us | 38.05 us |
| tokenize + parse qualified constructor fields, n=64 | 22.68–37.19 us | 33.29 us | 66.96 us | 117.74 us |
| parse-only else-if chain, n=64 | 19.09–34.06 us | 16.31 us | 18.92 us | 114.99 us |
| tokenize + parse else-if chain, n=64 | 49.38–93.47 us | 94.49 us | 102.41 us | 287.07 us |
| parse-only if block items, n=128 | 17.72–31.41 us | 16.54 us | 20.31 us | 82.30 us |
| tokenize + parse if block items, n=128 | 59.67–110.48 us | 126.83 us | 132.88 us | 362.36 us |
| short no-else if, end-to-end | 860.46 ns–1.74 us | 1.52 us | 1.28 us | 4.36 us |
| short value if, end-to-end | 1.20–2.08 us | 1.86 us | 2.14 us | 6.82 us |

Several runs showed broad host frequency and scheduler variance, including unrelated tokenize-only workloads. These measurements should be treated as runner-specific snapshots and maintained as ranges after repeated full-suite verification.
