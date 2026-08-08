# Match expressions and pattern parsing

Date: 2026-07-29

## Fat arrow token

Match arms use `=>`, represented by `Symbol::FatArrow`. The lexer recognizes it as a longest-valid compound symbol alongside `=`, `==`, and `>`:

```text
==>  -> EqualEqual, Greater
=>>  -> FatArrow, Greater
```

The symbol scanner remains forward-only and uses existing two-unit lexer lookahead.

## Separate pattern parser

Patterns are parsed by `Parser::parse_pattern` rather than by the expression parser. This prevents expression operators, calls, and arbitrary computation from entering binding syntax.

```text
pattern = wildcard-pattern
        | binding-pattern
        | literal-pattern
        | pattern "::" identifier
        | pattern "(" tuple-pattern-list ")"
        | pattern struct-pattern-body

tuple-pattern-item = pattern | "..."
struct-pattern-member = identifier (":" pattern)? newline
                      | "..." newline
```

Initial forms:

```dew
_
value
42
-42
true
Option::None
Option::Some(value)
List::Cons(head, ..., tail)
Message::Data {
  value
  metadata: details
  ...
}
```

The AST is:

```text
Pattern =
  WildcardPattern(offset)
  BindingPattern(name, offset)
  RestPattern(offset)
  LiteralPattern(expression, offset)
  QualifiedPattern(target, property, separator_offset)
  TuplePattern(target, arguments, opening_offset)
  StructPattern(target, fields, rest_offset?, opening_offset)
  AlternativePattern(first, remaining, offset)
```

Signed numeric patterns are represented using the existing prefix-expression literal shape, while arbitrary prefix expressions remain disallowed. Struct pattern fields support shorthand binding and explicit subpatterns. Fields and non-empty bodies are newline-delimited. Tuple pattern lists allow newlines and one trailing comma. Empty tuple patterns are rejected in favor of the unit form, matching enum declaration and construction conventions.

Bare `...` is accepted only as a tuple payload item or a newline-delimited struct member. Each immediate tuple or struct payload permits at most one rest item. Tuple patterns before the rest match from the front and patterns after it match from the back. Struct rest allows fields omitted from the pattern to be ignored; without rest, semantic validation requires a complete field set. Standalone `...`, `field: ...`, and duplicate rests produce dedicated syntax errors.

Pattern parsing is iterative across `::` qualification chains and recursive only through nested tuple/struct payloads. A 512-segment qualification test verifies the iterative path. Pattern failures use a distinct `PatternError` enum and are wrapped by `ExpressionError::MatchPatternError` only when parsing match arms.

The parser still deliberately excludes range patterns, type annotations, and refutable let patterns. Comma-separated alternatives replace a separate pipe-based or-pattern spelling at the arm level.

Pattern bindings are permanently immutable: `mut` is rejected wherever a pattern is expected. Every binding-position identifier beginning with `_` is normalized to `WildcardPattern(offset)`, introduces no local name, and is omitted from alternative binding-set comparisons:

```dew
Option::Some(_value), Result::Ok(_other) => fallback
```

Both payloads above are discards, not distinct bindings. Struct shorthand retains the structural field name while discarding its value:

```dew
Message::Data {
  _metadata
}
```

The field lookup still uses `_metadata`, but no `_metadata` local binding is created. Code that needs mutation creates an explicit body-local rebinding after the match succeeds:

```dew
Option::Some(value) => {
  let mut value = value
  update(value)
}
```

The initializer refers to the immutable pattern binding, and the new mutable binding enters scope only afterward. This keeps alternative compatibility limited to binding names and types rather than binding mutability.

## Expression stop set

The former `stop_at_left_brace : Bool` was replaced by a compact call-local integer stop set. `expression_stop_left_brace` currently controls condition and match-scrutinee termination. This does not enlarge the persistent `Parser` object and leaves room for future contextual terminators without multiplying boolean parameters.

An ungrouped `{` ends a match scrutinee:

```dew
match left + right {
  _ => result
}
```

A constructor used as the scrutinee must be grouped:

```dew
match (Point {}) {
  _ => result
}
```

## Match grammar

```text
match-expression = "match" expression-before-block match-body
match-body       = "{" "}"
                 | "{" newline newline* match-arm* "}"
match-arm        = arm-patterns match-guard? "=>"
                   match-arm-body newline
arm-patterns     = pattern ("," newline* pattern)*
match-guard      = "if" expression
match-arm-body   = expression | block
```

Examples:

```dew
match option {
  Option::None, Result::Err(_) => fallback
  Option::Some(value) if value > 0 => value
}

match sequence {
  List::Cons(head, ...), Vector::Items(head, ...) if ready => head
}

match message {
  Message::Data {
    value
    ...
  } => {
    let processed = process(value)
    processed
  }
}
```

Arms are newline-delimited and require a newline before the enclosing `}`. Alternative patterns are separated by commas; a comma makes the arm incomplete, so newlines are soft before the next pattern. A trailing alternative comma is rejected. `AlternativePattern` is allocated only after the first comma, preserving the existing compact single-pattern arm path.

An optional `if` guard follows the complete alternative list. Its expression naturally terminates before `=>`, which is not an expression operator. `PatternArm.guard_condition` retains the guard. Semantic analysis must require a `Bool` guard and must evaluate it with the selected alternative's bindings in scope.

All alternatives in one arm share the same guard and body. Name resolution and type checking must ensure that they bind exactly the same variable names and that each corresponding binding type unifies. The parser cannot enforce this correctly because it does not yet distinguish binding identifiers from qualified constructor paths.

Because an arm is incomplete after `=>`, blank lines are soft before its body; both expression and block bodies may begin on a following line. Blank lines and comments are accepted. Compact and multiline empty matches are retained syntactically for later exhaustiveness diagnostics.

A direct `{` after `=>` is a reusable `BlockExpr`. To return an object literal directly, parentheses disambiguate it:

```dew
Object => ({
  field: value
})
```

The AST is:

```text
PatternArm {
  pattern
  guard_condition?
  body
  offset
}

MatchExpr(scrutinee, arms, match_offset)
```

A completed match remains in binary-seeking mode, permitting calls, fields, indexes, qualification, construction, and infix continuation. Match expressions may nest and may contain if expressions or further matches in arm bodies.

## Iterative else-if hardening

Else-if chains no longer recurse through `parse_if_expression`. The common no-else and direct-else forms allocate no temporary chain arrays. When an actual `else if` is encountered, the parser collects conditions, blocks, and offsets, parses the terminal branch, and folds backward into nested `IfExpr` nodes. A 1,024-arm stress test verifies bounded host stack usage.

## Diagnostics and tests

Pattern diagnostics cover missing bases and qualified properties, tuple delimiters, empty payloads, body newlines, field names/newlines, malformed bytes, unclosed tuple/struct patterns, illegal rest positions, and duplicate rests. Match diagnostics cover missing alternative patterns, missing guards, missing bodies, body-opening newlines, arm arrows, arm-ending newlines, pattern failures, lexical failures, and unclosed matches.

Tests cover wildcard/binding/literal patterns, every fixed-width numeric literal token and signed-prefix form, underscore-prefixed discard bindings, discarded struct shorthand fields, discarded alternative payloads, explicit mutable-binding rejection, nested qualified tuple patterns, multiline trailing commas, tuple and struct rest, rest restrictions, struct shorthand and renaming, empty struct patterns, expression-operator termination, 512-part qualifications, comma-separated alternatives, `if` guards, multiline alternative continuation, alternatives combined with rest, unit/tuple/struct match arms, expression and block bodies, object/block disambiguation, binary and constructed scrutinees, postfix continuation, nested match/if composition, comments, empty matches, malformed arms, a 512-alternative arm, and a 512-arm match stress case.

## Benchmarks

The benchmark source is `src/parser/match_pattern_bench_test.mbt`.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| pattern parse-only qualified chain, n=128 | 3.34–3.79 us | 1.56 us | 2.02 us | 11.43 us |
| pattern tokenize + parse qualified chain, n=128 | 19.78–20.57 us | 28.10 us | 24.77 us | 65.10 us |
| match parse-only unit arms, n=256 | 36.69–44.31 us | 19.10 us | 22.93 us | 113.36 us |
| match tokenize-only unit arms, n=256 | 78.24–80.81 us | 108.23 us | 120.14 us | 245.44 us |
| match tokenize + parse unit arms, n=256 | 104.39–115.55 us | 122.78 us | 127.24 us | 333.65 us |
| match parse-only tuple arms, n=128 | 35.38–40.17 us | 18.87 us | 24.10 us | 113.74 us |
| match tokenize + parse tuple arms, n=128 | 106.61–113.54 us | 131.91 us | 111.29 us | 343.02 us |
| match parse-only struct arms, n=64 | 20.73–23.69 us | 11.44 us | 14.59 us | 66.02 us |
| match tokenize + parse struct arms, n=64 | 68.40–72.25 us | 87.72 us | 72.92 us | 220.58 us |
| guarded alternatives parse-only, n=128 | 82.76–90.63 us | 40.63 us | 51.15 us | 263.73 us |
| guarded alternatives tokenize + parse, n=128 | 198.49–211.98 us | 218.30 us | 203.64 us | 653.09 us |
| struct rest parse-only, n=64 | 24.00–25.61 us | 13.42 us | 17.12 us | 79.07 us |
| struct rest tokenize + parse, n=64 | 77.17–79.22 us | 99.11 us | 89.36 us | 251.47 us |
| short mixed match, end-to-end | 1.89–2.03 us | 2.22 us | 1.87 us | 6.47 us |

Backend values should only be compared within one runner. The separate pattern parser and match-arm loops add no fields to persistent parser state.
