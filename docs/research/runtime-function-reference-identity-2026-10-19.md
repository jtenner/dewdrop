# Exact runtime function reference identity

Four ordinary runtime controls now return 42 with the Native compiler, after
Wasm validation and `__dew_init`. They match their transform counterparts for
ordinary sharing, query-sensitive callees, closures, globals, nested generic
wrappers, and checked trait evidence. The reusable command is:

```sh
tools/test-runtime-generic-identity.sh
```

## Two normal backend faults

First, source-reference singleton creation searched by declaration and physical
shapes. Singleton lookup repeated the same incomplete search. The query helper
had distinct selected I32 and U32 bodies, but both references loaded the first
singleton. An initialized condition mask returned 23 instead of 63: ordinary
I32/U32 sharing and narrow-type separation passed; query identity and the U32
query result failed.

The saved checked keys from `abi-trace.log` are:

| Source instance | Selected key |
| --- | --- |
| ordinary I32 and U32 identity | `17179869184001:i32` |
| ordinary I8 identity | `17179869184001:i8` |
| I32 query helper | `17179869184005:i32:logical[p2;]` |
| U32 query helper | `17179869184005:i32:logical[p3;]` |

Singleton creation now uses the exact target selected for the source expression.
Singleton metadata and lookup keep that ABI key, along with the signature check
needed for adapters. Generic-caller references retain their exact-target path.
The existing target-key map is reused; a source-site map avoids repeating a
linear shape search. No source spelling or carrier guess supplies identity.

Second, a concrete trait reference inside a generic wrapper got a fresh evidence
closure even when its normalized runtime capture list was empty. Its initialized
mask returned 14 instead of 15: method results and different-instance identity
passed, while repeated references to the same checked target compared false.
Only nonempty runtime witness captures now need an evidence closure. Concrete
trait evidence stays in the selected target's ABI key, so no-capture references
use their singleton. Concrete roots with runtime prerequisites still capture.

## Validation and limits

Artifacts are in `.tmp/transforms-v4/generic-builtins/`.

- `singleton-red.log`: query regression fails with one singleton for two target
  bodies; ordinary canonical sharing passes. Run 8.672 s.
- `evidence-red.log`: trait regression exposes two empty witness wrappers. Run
  8.570 s. `evidence-green.log`: all three regressions pass in 9.663 s.
- `native-runtime-final.log`: all four ordinary runtime sources compile in
  1.036–1.333 s each, validate in 0.012–0.016 s, and return 42 in 0.030–0.032 s.
  `identities.json` records the compiler and output hashes. These are validation
  timings, not a controlled speed comparison.
- `runtime-captures-backend.log`: both local and imported escaping runtime
  witness cases pass, 0.694 s. `runtime-captures-semantic.log`: the selected
  runtime-capture test passes, 9.965 s. Their nonempty captures and malformed
  capture-span errors remain checked.
- `api.log`: semantic API refresh 1.336 s. `abi-trace.log` records exact selected
  keys from a private instrumented copy of the built compiler. Earlier and final
  WAT files keep the singleton and allocation evidence.

Repeated concrete named references now load one global rather than allocate an
empty evidence wrapper. No measured runtime speed or retained-heap gain is
claimed. Cache metadata grows with the checked reference sites and selected
functions; the stored key reuses the selected immutable string.

The first checker omitted `__dew_init`, which gave a separate null-reference
failure. The masks above and final runtime controls all run initialization.

Current Dew builtin contract tests pass, but its normal named-reference emitter
still creates a fresh wrapper for each reference. The root agent assigned that
separate backend parity gap for further work; no ordinary Dew runtime parity
pass is claimed here. Compile-time VM identity rules did not change in this fix.
Claude was unavailable under its reported usage limit; no Claude assessment is
claimed. The read-only witness-capture safety trace is in
`.tmp/transforms-v4/identity/runtime-evidence-wrapper-safety.md`.
