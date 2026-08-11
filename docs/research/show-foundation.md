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

Initial standard evidence covers Bool, every signed and unsigned fixed-width integer, String, and StringView. Integers use base-ten ASCII with no leading zeroes or positive sign; signed minima are handled without overflowing their signed carrier. Bool uses `true` and `false`; String and StringView append their text without quoting or escaping. Floating-point, Unit, Bytes, SWAR, SIMD lane, and aggregate-derived formats remain explicit follow-up work rather than receiving accidental unstable spellings.

The builder owns output growth and traps on its existing unsigned capacity boundary. Handwritten recursive Show implementations are responsible for their own recursion and domain limits. Before `derive(Show)` is enabled, Dew must freeze aggregate punctuation/escaping and add an explicit bounded recursion/output policy that can be shared by generated implementations without changing this builder-oriented method signature.
