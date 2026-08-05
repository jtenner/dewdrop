# Coverage-gap findings (August 2026)

While adding edge-case snapshot fixtures, several supported-looking features
turned out to be partially unsupported. Each finding below was reduced to a
minimal repro and confirmed against the current compiler. None of these are
regressions; they are pre-existing gaps surfaced by the new fixtures.

## 1. Narrow-width literal patterns are rejected by the parser

`match` patterns accept literal tokens only for `I32`, `U32`, `I64`, `U64`,
`F32`, `F64`, strings, and bools. Suffixed `i8`/`i16`/`u8`/`u16` literals in a
pattern produce `ExpectedPattern` (see the token filter in
`src/parser/patterns.mbt` around the `LiteralPattern` construction).

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

Workaround: match wide-width literals and constrain the payload width in the
binding, or match enum carriers with narrow payloads (see finding 2).

## 2. Let-bound enum values fail Wasm validation when passed to functions

> FIXED (August 5, 2026): let-bound nominal locals are now declared with their
> precise `(ref N)` type instead of the erased `eqref_null` fallback. The fix
> is a one-line change in `starshine_body_locals`
> (`src/backend/starshine_code.mbt`): the nominal branch no longer requires
> `layout.generic_parameters.length > 0`, so every struct/enum in the nominal
> layout table gets a precise local type. String, `fixed_array`, `map`, and
> `set` remain erased (the latter three are explicitly excluded; strings are
> not in the nominal layout table and are handled by the text runtime).
> Regression coverage: `functions/let-bound-nominal-args-runtime` (let-bound
> enum, struct, and string passed to typed functions) and
> `control-flow/narrow-payload-match-runtime` now uses the natural let-bound
> form it previously had to dodge.

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

String literal patterns are accepted by the parser and survive semantic
analysis, but code generation reports `UnsupportedExpression`:

```dew
fn classify(text: String) -> I32 {
  match text {
    "zero" => 0
    _ => -1
  }
}
```

## 4. Non-Unit tail expression breaks resolution inside Unit functions

Inside a function whose return type is `Unit`, a non-Unit tail expression
(such as a method call or binary expression whose value is discarded) breaks
operator/method resolution earlier in the same body. Ending the block with a
`let` instead of the expression compiles cleanly:

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

The white-box `EagerModuleInitializationCycle` diagnostic is asserted in
`src/semantic/module_initialization_plan_wbtest.mbt` for local cycles, but via
the CLI (`dew check`) those same sources never reach the initialization plan:

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

## Related fixture notes

- `numeric/literal-out-of-range-matrix` locks in the full out-of-range
  diagnostic surface (including `128i8` versus the valid `-128i8`).
- `text/bytes-to-string-surrogate-trap`, `text/string-view-oob-trap`, and
  `text/string-byte-at-oob-trap` verify the documented trap (not clamp)
  behavior for malformed UTF-8 and out-of-bounds text access.
- The `modules/module-value-cycle` fixture was dropped: local cycles cannot
  produce the intended diagnostic through the CLI (finding 5).
- `functions/let-bound-nominal-args-runtime` locks in the fix for finding 2
  (let-bound enum, struct, and string values passed to typed functions), and
  `control-flow/narrow-payload-match-runtime` no longer avoids the pattern.
