# Coverage-gap findings (August 2026)

While adding edge-case snapshot fixtures, several supported-looking features
turned out to be partially unsupported. Each finding below was reduced to a
minimal repro and confirmed against the current compiler. None of these are
regressions; they are pre-existing gaps surfaced by the new fixtures.

## 1. Narrow-width literal patterns are rejected by the parser

> FIXED (August 5, 2026): pattern parsing now accepts every fixed-width numeric
> token (`I8`, `I16`, `I32`, `I64`, `U8`, `U16`, `U32`, `U64`, `F32`, and
> `F64`) in both direct and signed-prefix forms. Backend literal matching now
> shares the ordinary prefix emitter, so negative signed minima, negative
> floats, and explicit unary `+` compare through the correct physical carrier.
> `control-flow/all-numeric-literal-match-runtime` verifies all ten types in
> Node and Wago.

Previously, `match` patterns accepted literal tokens only for `I32`, `U32`,
`I64`, `U64`, `F32`, and `F64`. Suffixed `i8`/`i16`/`u8`/`u16` literals in a
pattern produced `ExpectedPattern`, while parsed negative literals reached an
unsupported backend expression.

Repro:

```dew
fn f(x: I32) -> I32 {
  match x {
    // `128i8` style narrow literals are not parseable here
    1i8 => 0
    _ => 1
  }
}
```

The parser and backend now handle these forms directly; no width-widening or
enum-carrier workaround is required.

## 2. Let-bound enum values fail Wasm validation when passed to functions

> FIXED (August 5, 2026): let-bound nominal locals are now declared with their
> precise `(ref N)` type instead of the erased `eqref_null` fallback. A shared
> backend helper selects those precise local types and inserts `ref.cast` when
> an erased control-flow or pattern result is stored into one. This covers
> direct constructors, `if`/`match` initializers, pattern rebinding, and mutable
> reassignment without reintroducing nullable locals. String, `fixed_array`,
> `map`, and `set` remain erased (the latter three are explicitly excluded;
> strings are not in the nominal layout table and are handled by the text
> runtime). Regression coverage:
> `functions/let-bound-nominal-args-runtime` and
> `control-flow/narrow-payload-match-runtime`.

Constructing an enum inline and passing it to a function compiles and runs,
but binding the value with `let` first and then passing it to a function
fails backend validation:

```dew
enum Two {
  Byte(U8)
  Wide(U16)
}

fn extract(value: Two) -> I32 {
  match value {
    Two::Byte(item) => item.into()
    Two::Wide(item) => item.into()
  }
}

pub fn main() -> U32 {
  let byte = Two::Byte(255u8)
  let wide = Two::Wide(65535u16)
  if extract(byte) == 255 && extract(wide) == 65535 {
    // ...
  } else {
    // ...
  }
}
```

`dew run` reports
`StarshineProgramValidationError(Validation({ issue: FunctionBody("type
mismatch"), func_idx: Some(FuncIdx(3)) }))`. The same code with inline
constructor calls (`extract(Two::Byte(255u8))`) passes. Root cause: the local
was declared as nullable `eqref_null` (the `Ref`-shape fallback), so `local.get`
yielded an erased nullable `eqref` that cannot be passed to a `(ref N)`
parameter without a `ref.cast` — and the call path emits no cast, unlike the
field-get path. Structs are affected the same way. See the resolution note
above.

## 3. String literal patterns parse but are unsupported in the backend

> FIXED (August 10, 2026): string literal patterns now construct the same flat
> immutable runtime values as ordinary literals and compare exact logical UTF-8
> bytes through the retained `dew_string_equals` runtime helper. Program
> reachability treats that helper as an explicit compiler-generated dependency.
> `control-flow/string-literal-match-runtime` covers empty, ASCII, Unicode, and
> fallback matches in Node and Wago.

Previously, string literal patterns were accepted by the parser and survived
semantic analysis, but code generation reported `UnsupportedExpression`:

```dew
fn classify(text: String) -> I32 {
  match text {
    "zero" => 0
    _ => -1
  }
}
```

## 4. Non-Unit tail expression breaks resolution inside Unit functions

> FIXED (August 10, 2026): body inference no longer constrains a discarded tail
> expression to `Unit` when the callable's declared result is `Unit`. Lowering
> retains the tail's actual carrier and the backend emits one final `drop` for
> functions and lambdas. The `functions/unit-discarded-tail-runtime` snapshot
> covers method, operator, and lambda cases.

Previously, inside a function whose return type was `Unit`, a non-Unit tail
expression (such as a method call or binary expression whose value is discarded)
broke operator/method resolution earlier in the same body. Ending the block with
a `let` instead of the expression compiled cleanly:

```dew
// FAILS: NoMatchingMethod on value.find("b")
pub fn main() -> Unit {
  let value = "abc"
  let index = value.find("b")
  index
}

// OK: block ends in a let
pub fn main() -> Unit {
  let value = "abc"
  let index = value.find("b")
}
```

This is a body inference ordering/constraint gap rather than a text-library
issue; the same shape fails for user-defined methods and binary operators.

## 5. Local module-value cycles surface weak diagnostics via the CLI

> FIXED (August 10, 2026): source-diagnostic collection now gives eager-cycle
> planning precedence for cyclic module-value bodies. It suppresses duplicate
> and inference-cascade diagnostics for those declarations, reports mutual and
> self cycles at their declaration offsets, and labels additional cycle members.
> `modules/local-module-value-cycle` locks in the CLI-facing result.

Previously, the white-box `EagerModuleInitializationCycle` diagnostic was
asserted in `src/semantic/module_initialization_plan_wbtest.mbt` for local cycles,
but the CLI (`dew check`) surfaced inference fallout first:

- Direct references (`let first = second; let second = first`) report
  `UnresolvedModuleValue(17179869184000, 0)` — the offset appears to be a
  packed semantic id being printed as a source offset (hypothesis; the
  constant also appears as a sentinel in other diagnostics).
- The type-constrained form (`let second = first + 1`) reports
  `NoMatchingMethod` on `+` instead.

The `EagerModuleInitializationCycle` diagnostic is CLI-reachable only across
modules, which the existing `modules/cross-module-initialization-cycle`
fixture covers.

## 6. `into()` on a narrow signed literal is ambiguous without a target

With no constraining target type, `(-128i8).into()` reports
`AmbiguousMethod`. Annotating the comparison operand does not help
(`a.into() == (-128i32)` still reports `AmbiguousMethod`), and binding
annotations are not supported syntax. The target must be pinned by a
return-type-constrained context:

```dew
// AMBIGUOUS
let a = -128i8
if a.into() == -128 { ... }

// OK: helper return type constrains into()'s target
fn widen(value: I8) -> I32 {
  value.into()
}

let a = -128i8
if widen(a) == -128 { ... }
```

## First ordinary compiler warning

The compiler now transports `UnreachableBlockItem` flow findings as ordered,
source-located warnings rather than silently discarding them or failing the
build. `control-flow/unreachable-code-warning` compiles and executes while its
JSON oracle locks in the warning severity, source excerpt, caret, and order.

## Return, drop, and `Never` carrier coverage

The August 10, 2026 hardening pass added
`control-flow/return-drop-never-carriers-runtime`. It executes bare returns on
both branches, emits non-tail drops for i32, i64, f32, f64, v128, reference,
and Unit-shaped expressions, and validates `Never` joins against every current
single-value carrier. The implementation also treats a selected `Never` call as
bottom in an already-constrained context and schedules bare returns without a
synthetic expression, avoiding both false type mismatches and negative
expression indexing during optimization/emission.

## Related fixture notes

- `numeric/literal-out-of-range` and
  `numeric/literal-out-of-range-wide` lock in semantic signed-width overflow
  diagnostics, while `numeric/literal-out-of-range-matrix` uses separate
  declarations so parser recovery retains every invalid signed/unsigned
  magnitude diagnostic. `numeric/signed-minimum-narrow-runtime` covers the
  valid `-128i8` and `-32768i16` spellings.
- `text/bytes-to-string-surrogate-trap`, `text/string-view-oob-trap`, and
  `text/string-byte-at-oob-trap` verify the documented trap (not clamp)
  behavior for malformed UTF-8 and out-of-bounds text access.
- The `modules/module-value-cycle` fixture was dropped: local cycles cannot
  produce the intended diagnostic through the CLI (finding 5).
- `functions/let-bound-nominal-args-runtime` locks in the fix for finding 2
  (let-bound enum, struct, and string values passed to typed functions), and
  `control-flow/narrow-payload-match-runtime` no longer avoids the pattern.
