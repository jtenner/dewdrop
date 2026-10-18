# Generic loop result carriers — 2026-10-18

The unchanged source-Bytes feature probe reached `iter_fold<U32, ...>` after the
lambda and numeric-pattern fixes. Starshine rejected its outer loop block:
the block expected a reference, but its `break` supplied I32.

A small reproducer is:

```dew
fn identity<t>(value: t) -> t {
  while value {
    current => break current
  }
}
pub fn main() -> I32 {
  identity(42i32)
}
```

I32, I64, F32, F64, and nested scalar loops had the same fault. The reference
control compiled. The loop emitter used its original generic shape, while
physical planning and the break expression used the concrete specialization.
A Unit specialization also failed when the emitter required a local slot for
its erased state binding.

`starshine_module.dew` now selects the result from the frozen physical expression
plan, using the existing checked helper. That helper validates the expression,
specialization, and concrete carrier. Discarded and diverging loops still use
Unit. Pattern binding emission now accepts the checked local lookup's erased
case. The lookup still rejects a missing slot for a value that needs a slot.
The change adds no new scan, array, retained index, or runtime instruction.

`semantic_generic_loop_carriers_test.dew` has eight emission regressions. One
passed and seven failed before the repair. All eight pass after it. The cases
cover each scalar carrier, references, Unit, nested loops, conditional result
contexts, and discarded scalar/reference results. The runtime matrix uses the
same generic function under all these specializations and returns 42. The
hardening and emission checks include the new file and runtime probe.

Focused generation took 4.449 seconds, linking 1.089 seconds, and execution
0.256 seconds. The emitted runtime matrix is 1,885 bytes. Its Unit identity loop
has no local access. Scalar identity loops use concrete I32/I64/F32/F64 blocks;
the reference loop uses eqref. None of these identity functions allocates a
struct or array. These checks show the output shape; no speed gain is claimed.

The existing native compiler compiled all reduced scalar, reference, and nested
cases, but failed the Unit binding case with `InvalidLocal`. That separate
native repair is owned by the native backend lane. This self-host record does
not claim that the native Unit case passed.

A patched compiler C was built from the fresh source request with three files
changed: the prior lambda and numeric-pattern repairs, and this loop repair.
Generation took 15.382 seconds and linking 0.947 seconds. It compiled the
unchanged full feature probe in 1.376 seconds, and the emitted program returned
42. The probe covers Option/Result helpers, checked integer conversions,
StringView decimal limits, nested Bool/enum patterns, generic private-field
factory/getter calls across two modules, and iterator folding. A separate
private-construction probe failed in 1.264 seconds with the expected missing
imported construction field diagnostic and wrote no output.

This patched-compiler check is distinct from the final whole-current-source
A/B/C bootstrap check. Exact red/green output, source/compiler hashes, timings,
and Wasm inspection are in
[`data/generic-loop-carriers-2026-10-18/validation.json`](data/generic-loop-carriers-2026-10-18/validation.json).
