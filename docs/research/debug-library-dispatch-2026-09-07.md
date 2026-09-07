# Debug dispatch in Dew

`debug<t: Debug>` now calls `value.debug()` in Dew. The result-discard helper
is an empty Dew function. Its argument is still evaluated by the normal call
rules. The native compiler no longer keeps a separate pending Debug queue or
changes the selected target after call inference. Both emitters have lost the
old dispatch/discard builtin cases, including the self-host drop fallback.

The shared execution test covers custom implementations, calls through another
generic function, and an explicit I32 call with a Never argument. Before the
change, the last case failed with `NoMatchingMethod`; the red run took 0.919
seconds. The native green build took 5.303 seconds and all three checks passed.

That test also exposed a missing import: an emitted primitive Debug formatter
could call function index 4294967295 when no source file opened the WASI module.
The Debug preamble now declares its own private foreign `fd_write` import.
The existing runtime dependency closure can find foreign imports by full import
identity as well as legacy builtin names. It does not invent a function index.

This is not the end of the Debug migration. Primitive formatting and Bytes I/O
still use compiler runtime bodies. Those bodies and their hidden dependency
closure must move into Dew. The self-host runtime list uses exact formatter
identifiers; the removed dispatch names no longer match a Debug prefix rule.

The policy test checks the ordinary Dew functions and rejects the removed
builtin targets in source, generated files, and the numeric emitter generator.

The scalar link regression caught another issue: inference evidence from unused
bodies rooted Debug implementations, and the specialization scan created calls
from those bodies even when their functions were not reachable. The root walk
now follows evidence roots, prerequisites, and trait-object coercions on used
expressions. The specialization scan uses the same callable roots. The scalar
two-function regression is retained unchanged; Debug must not add imports or
definitions to it.

The full program dependency set is now authoritative when fragments are built.
Running the per-module runtime dependency scan a second time had added another
`fd_write` declaration after the whole-program scan selected the foreign one.
Standalone module planning still runs its local closure. The integration tests
retain their exact one-import and two-import expectations.

The shared corpus now also calls primitive Debug and checks that it writes
exactly `42` to stdout. The other three cases must make no host calls.

## Checks

- Native: all 968 tests pass in 113.378 seconds.
- Integration: 268 tests pass in 66.952 seconds.
- Stdlib: 326 tests and all shared corpora pass in 29.429 seconds.
- Self-host: 294 tests, 64 exact failure records, and all shared corpora pass
  in 127.822 seconds. The Debug corpus passes four checks in both compilers.
- Generated files and policy tests pass in 15.828 seconds.
- Clean A/B/C bootstrap passes in 156.379 seconds. Core and linked B/C output
  bytes match. The linked SHA-256 is
  `6cc687c2c9b37e725e27f05986091e17c5fc73f23fcaa85c8bac44aebbc0b6ec`.

Runs above 30 seconds remain recorded speed defects. No speed changes were
made in this batch.
