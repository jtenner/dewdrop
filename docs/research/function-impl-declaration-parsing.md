# Function and impl declaration parsing

Date: 2026-07-29

## Function grammar

```text
function-declaration = "pub"? "fn" identifier type-parameters?
                       "(" function-parameters? ")"
                       "->" type block line-end

function-parameter   = "self"
                     | "self" ":" type
                     | identifier ":" type

block                = "{" "}"
                     | "{" newline newline* block-item* "}"

block-item           = "let" "mut"? identifier "=" expression newline
                     | "return" expression? newline
                     | expression newline
```

Return types are mandatory, including `-> Unit`. A compact empty body is valid. Every non-empty body begins after a newline, and every body item has a terminating newline. End of input is an implicit line end only after the function's closing brace, not in place of a missing brace or body-item newline.

Function bodies and control-flow branches now share `Block` and `BlockItem`. They retain ordered let, return, and expression items, and `Block::tail_expression` exposes a final expression item for later implicit-return analysis. `if` expressions may occur in any expression item; loops and pattern matching remain later additions.

## Receivers on ordinary functions

Ordinary functions store an optional receiver separately from ordinary parameters:

```text
receiver   : ReceiverParameter?
parameters : Array[FnParameter]
```

`ReceiverParameter` retains an optional explicit receiver type and source offset. This layout keeps the common receiverless parameter array compact instead of wrapping every value parameter in a larger tagged enum.

A first `self` turns the function into a method. Examples:

```dew
fn clone(self) -> Self {
  self
}

fn length(self: List<I32>) -> I32 {
  0
}
```

`self` is only legal as the first parameter. An explicit receiver type is retained for ordinary functions and inherent methods. A shorthand receiver without an explicit type must be resolved from a containing impl/type context or rejected during semantic analysis if no `Self` context exists.

Trait methods share this parameter representation but apply the stricter trait rule: an explicit receiver type must be exactly `Self`, and `self: Self` normalizes to the shorthand receiver form.

## Applied types

`TypeExpr` now represents both named and applied types:

```text
NamedType(name, offset)
AppliedType(base, arguments, open_offset)
```

Examples:

```dew
List<I32>
Result<List<I32>>
Outer<Inner<Result<I32>>>
```

The lexer retains `>>` as the expression shift token. The declaration type parser contextually treats one `ShiftRight` token as two adjacent generic closers. A small type-local closer state carries the second close through recursive type parsing without enlarging the hot expression `Parser` object. Extra unmatched closers are diagnosed as `UnexpectedTypeCloser`.

Type argument lists accept one trailing comma and newlines after commas.

## Impl grammar

```text
impl-declaration = "impl" type-parameters? type impl-body line-end
                 | "impl" type-parameters? type "for" type impl-body line-end
                 | "foreign" "impl" type-parameters? type "for" type
                   impl-body line-end

impl-body        = "{" "}"
                 | "{" newline newline* function-declaration* "}"
```

The forms are:

```dew
impl Counter {
  fn increment(self: Counter) -> Counter {
    self
  }
}

impl Into<I32> for I64 {
  fn into(self) -> I32 {
    @wasm.i64_trunc_i32(self)
  }
}

impl<a> Convert<List<a>> for Wrapper<List<a>> {
  fn convert(self) -> List<a> {
    self
  }
}

foreign impl Display for External {
  fn display(self) -> String {
    "external"
  }
}
```

An impl without `for` is inherent and stores no trait type. A foreign impl must name both a trait and target. Neither ordinary nor foreign impl declarations accept `pub`; ordinary trait impl evidence follows trait/type visibility rules, while foreign impl evidence remains private to its exact declaring module.

Impl bodies contain ordinary function declarations without separate `pub` modifiers. Their first `self` parameter determines whether they are instance methods; methods without it are static. Signature conformance, receiver compatibility with the target type, required/missing trait methods, duplicate methods, overload resolution, coherence, and foreign-impl scope are semantic checks.

## AST

`FunctionDeclaration` retains visibility, name, generic parameters, shared function parameters, return type, a reusable `Block`, and offsets.

`ImplDeclaration` retains:

- whether the impl is foreign;
- ordered impl type parameters;
- optional trait type;
- target type;
- ordered method declarations;
- source offset.

## Stress and diagnostics

Tests cover generic and public functions, local mutable lets, explicit and empty returns, final expressions, typed and shorthand receivers, receiver position, nested applied types with adjacent `>>`, extra closers, empty and malformed bodies, inherent/trait/generic/foreign impls, invalid visibility, invalid members, declaration newlines, unclosed bodies, intrinsic calls, and a 256-method impl stress case.

## Benchmarks

The benchmark source is `src/parser/function_impl_bench_test.mbt`. Parse-only measurements materialize tokens outside the timed closure.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| function parse-only body items, n=64 | 15.52–22.45 us | 8.11 us | 9.59 us | 51.03 us |
| function tokenize-only body items, n=64 | 32.20–45.24 us | 43.06 us | 41.50 us | 99.53 us |
| function tokenize + parse body items, n=64 | 44.94–63.58 us | 49.07 us | 47.94 us | 143.96 us |
| function tokenize + parse typed receiver | 1.44–2.13 us | 1.46 us | 1.28 us | 4.59 us |
| impl parse-only methods, n=64 | 37.10–54.98 us | 19.57 us | 23.95 us | 131.26 us |
| impl tokenize-only methods, n=64 | 76.87–105.79 us | 95.05 us | 87.17 us | 233.62 us |
| impl tokenize + parse methods, n=64 | 101.86–135.03 us | 114.36 us | 102.80 us | 335.16 us |
| short generic impl, end-to-end | 2.98–4.14 us | 3.23 us | 2.56 us | 10.14 us |
| short foreign impl, end-to-end | 2.14–3.48 us | 2.16 us | 2.16 us | 6.58 us |

Backend timings should only be compared within the same runner. The full native benchmark suite still shows the expression parser at its prior performance range after moving generic-closer state out of the hot `Parser` object.
