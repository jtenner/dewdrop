# Show foundation

Date: 2026-08-11

`dew.std.show` defines the non-ambient `Show` trait:

```dew
pub trait Show {
  fn append_show(self, builder: StringBuilder) -> Unit
}
```

`show(value)` allocates one `StringBuilder`, dispatches through `Show` evidence, and finishes it into a `String`. `show_append`, `show_append_text`, and `show_append_ascii` let handwritten implementations compose values without opening the builder module or creating intermediate strings.

`Show` is user-facing text production. It has no I/O side effect and is separate from ambient `Debug`, whose current contract writes deterministic diagnostic output through bounded WASI support. There is intentionally no blanket `Show`-from-`Debug` or `Debug`-from-`Show` implementation: doing so would couple user output stability to diagnostics and would force WASI behavior into ordinary string construction.

Initial standard evidence covers Bool, every signed and unsigned fixed-width integer, String, and StringView. Integers use base-ten ASCII with no leading zeroes or positive sign; signed minima are handled without overflowing their signed carrier. Bool uses `true` and `false`; String and StringView append their text without quoting or escaping. Floating-point, Unit, Bytes, SWAR, and SIMD lane formats remain explicit follow-up work rather than receiving accidental unstable spellings.

Postfix `derive(Show)` now generates ordinary coherent implementations for structs and enums. Structs use `Type { field: value }`, empty structs use `Type {}`, unit variants use `Type::Variant`, tuple variants use `Type::Variant(value, ...)`, and struct variants use `Type::Variant { field: value }`. Generic prerequisites are inferred only from payload-bearing type parameters; generated evidence freezes and executes across module/cache boundaries like Eq, Debug, and Hash derivation. Conflicts with handwritten evidence use ordinary coherence diagnostics.

The builder owns output growth and traps on its existing unsigned capacity boundary. Handwritten and generated recursive Show implementations currently rely on finite immutable value depth and are responsible for domain limits. An explicit lower recursion/output budget remains pending; adding one must preserve the builder-oriented method signature or introduce a deliberately versioned formatter context.
