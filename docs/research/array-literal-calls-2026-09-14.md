# Array literals through ordinary library calls

Both compilers lower bracket literals during collection. A private exact import
of `dew.std.array` selects `array_with_capacity`; the resulting local receives
one ordinary `push` call per element, then supplies the block result. The import
alias and local contain `$`, which source identifiers cannot contain. Ordinary
import resolution freezes the function identity before physical planning.

This closes the three binding failures in the
[earlier trial](array-literal-calls-2026-09-09.md): local values named `Array`,
unopened Array names, and unrelated user types named `Array`. Empty, nested,
Unit, packed, product, reference, and function-valued arrays use the same call
inference and storage rules as explicit library calls. Generated block items
preserve element order, early returns, and lambda captures. Child spans are
owned by the generated calls; no unused literal span is left in the arena.

Source discovery includes the Array library for bracket tokens without requiring
an explicit source import. Strings and comments do not trigger that scan. The
closed synthetic import does not open library names in the source namespace.
The library constructor and methods use ordinary declaration lookup, generic
specialization, field layout, and emission. No runtime name lookup is added.

The old source-literal tasks and product-literal emitter are removed. A remaining
unexpanded literal is a visible `COL-101` compiler error. Compile-time name-array
constants still have a separate materialization path; removing that remaining
synthetic wrapper is separate from source bracket lowering. Cache provenance is
refreshed for the new HIR; all formats remain version 1.

## Tests and measurements

- The four native binding tests first failed because they still reached the
  legacy literal plan (1.582 seconds). All four pass with ordinary calls
  (15.424 seconds including the native rebuild).
- The self-host constructor test first failed at the legacy emitter. Its small
  library fixture then needed valid struct-constructor syntax. Collection-error
  checks now prevent malformed fixtures from being mistaken for inference bugs.
- The full routine native semantic run passed 851 tests. The six native product
  and Array emission tests passed in 13.422 seconds including a rebuild.
- The complete Dew suite passed 1,267 tests in 0.856 seconds. Generation took
  8.592 seconds, linking 5.917 seconds, and executed short-inference probes
  0.334 seconds. Four old phase fixtures now supply ordinary constructors.
- All 33 shared Array runtime checks pass under native compilation: build
  1.806 seconds, execution 0.028 seconds. New cases test exact element order,
  a return inside a literal, and a literal lambda's source capture.
- Cold rebuilds of the test generator took 34.510–37.808 seconds. These are
  performance bugs under the 30-second activity limit; warm generation is
  below the limit. Failed syntax drafts and their logs remain visible.

Final validation results follow. Logs are under `.tmp/starshine-update-20260914/`.

The final Array bootstrap passes with identical B/C SHA-256
`3ff4fdb9b19ad4740680d3e8cc7a91e4f317fbced9e93c4bca583851441fb59e`.
A's source build took 13.741 seconds, A emitted B in 20.183 seconds, and B
emitted C in 21.808 seconds. Native links took 4.815, 6.570, and 11.473 seconds.
All validation and B semantic probes passed; all stages stayed below 30 seconds.

The full native integration lane passed all 271 tests. The program-link-plan
group took 43.759 seconds, above the activity limit. The cold release build for hardening
test generation took 40.235 seconds, another measured performance bug.

Final focused checks passed: seven backend Array/product tests (15.746 seconds),
four binding tests (1.949 seconds), and four semantic product/Array tests
(1.601 seconds). The backend test changes the library field layout and shifts
the Array declaration identity. It validates ordinary constructor emission.

Hardening exposed two additional legacy emission fixtures with no library
constructor. Their shared library now declares `array_with_capacity` and
initializes its declared storage/count/capacity fields. The emission probes
still check the same iterator and generic stack results.

The final hardening run passes: 973 tests, 504 exact invariant failure records,
all 33 Array runtime checks, and all emission and semantic probes. Warm test
generation took 7.108 seconds, linking 5.413 seconds, and emission probes
22.029 seconds. The shared legacy fixture repairs require no compiler change.

After saving Starshine generated exports in local commit `de52f1d14`, the
consumer fingerprint was refreshed for that revision. The final saved-provider
bootstrap passes with identical B/C SHA-256
`215f26625c8e00510b3428a11f350c94919a40fec828d76f03c42a0bbc24aacf`.
A source build: 22.547 seconds; A emits B: 21.691 seconds; B emits C:
22.095 seconds. Links: 4.745, 5.668, and 5.720 seconds. All validation and
B semantic probes pass; all measured compiler stages stay below 30 seconds.
