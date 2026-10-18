# Keep finite coverage proofs stable across arm checks

A field pattern can read a mutable field again for each arm. An earlier failed
guard can change that field. The finite matrix must not combine observations
from different field values into one proof that every arm sequence succeeds.

The confirmed runtime case uses `Flag { mut value: Bool }`. It first tries a
`true` field pattern, then a wildcard guard which flips the field and returns
false, then a `false` field pattern. With an initial false field, all three
arms fail. The former matrix accepted this source and generated code trapped.
An explicit final wildcard returns 40 and demonstrates the missing path.
The independent runtime evidence is in
`/tmp/dewdrop-review-2026-10-18/coverage-review/`.

Both compilers now check the field paths used by the matrix before proving a
finite combination complete. A refutable mutable field path blocks that proof
when any arm has a guard, or when a pattern has a String literal comparison
which calls selected equality code. Scalar and enum-tag tests use fixed Wasm
comparisons. The native literal emitter has no selected-call Bytes pattern
path. The check walks nested products, enum payloads, immutable outer fields,
and alternatives. Enum payload fields are immutable; nested struct fields are
checked. It scans effects even inside irrefutable child patterns.

The check reads frozen field metadata, including imported fields. Missing
metadata is conservative. Dew flow callers now pass the existing imported
field array into body and lambda analysis. The old variants-only wrapper stays
available and treats an unknown imported field as mutable. There is no new
retained index. Temporary traversal visits and entries use the existing matrix
work budget before reads or growth. The ordinary complete-match fast path
still bypasses the matrix.

Controls keep immutable fields with guards, mutable fields without guards,
irrefutable mutable fields beside stable fields, and explicit wildcard
fallbacks valid. Negative tests cover local and imported mutable fields,
nested enum/product/immutable outer paths, functional loops, and selected
String comparisons. The user can add an unconditional wildcard to cover a
mutable guarded path.

Initial focused native validation passed 45 tests in 7.535 seconds. The first
Dew test module compiled in 4.916 seconds, linked in 1.088 seconds, and passed
39 selected flow tests in 0.085 seconds. Final Dew validation passed 41 selected tests in 0.086 seconds. Generation
took 4.600 seconds and linking took 1.089 seconds. This includes both production
callers and the final imported, loop, and String tests. These timings are
compiler process observations; they do not establish a compiler speed change.
