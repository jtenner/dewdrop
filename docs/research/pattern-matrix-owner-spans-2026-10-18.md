# Keep matrix work tied to the selected enum

A complete match over three `Maybe<Bit>` values passed native checks but failed
Dew's finite-coverage budget when the module also had 5,000 unrelated enum
variants. The matrix repeatedly scanned the entire local/imported variant
array for each selected enum. The native check uses existing owner spans.
The native source check passed in 0.215 s; the Dew regression failed in 0.236 s.

Dew now uses a selected local constructor as a span seed. Collected variants
for one enum are contiguous; the collector appends all variants of an enum
in one call. The matrix walks only that owner's two boundaries and charges
those reads, then charges the result before allocation. Imported matches
reuse the existing import context's owner-span map. No new index is built or
retained. The legacy variants-only flow wrapper keeps its charged scan when
an import span map is unavailable. Both production callers pass the existing
map through body and lambda flow analysis.

Both compilers get imported enum owners from frozen pattern type heads,
with charged type visits, instead of scanning all imported constructor IDs.
The Dew fast irrefutability check uses the same frozen type identity and the
existing import owner span. Its fallback counts constructors without creating
an array, and stops after the second constructor. This also removes the extra
import scan and allocation noted in review item R2.

Tests build a 5,000-variant noise enum and a complete 27-row nested match,
locally and across imports. The corrected private local regression passed in
0.237 s. A combined current-source Dew module passed all 63 selected tests in
0.461 s, with generation 4.653 s and linking 1.119 s. The two committed large
cases cover local and imported enum parity. Final native flow validation passed 53 tests in 8.837 s. The full Dew suite
passed 1,353 tests in 1.381 s, with generation 6.748 s and linking 1.338 s.
The emitted execution check passed in 0.342 s.

Raw commands and results are in
`/tmp/dewdrop-review-2026-10-18/semantics/matrix-noise-{native,red-*,green-*}.json`
and `flow-review-final-*.json`. These measurements check behavior and bound
metadata visits. They do not establish a whole-compiler memory reduction.
