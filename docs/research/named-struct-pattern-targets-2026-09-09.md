# Named struct pattern targets

## Defect and fix

Local inference records a named struct pattern as a selected constructor with
the exact declaration and a false variant flag. Named enum-variant patterns
have a true variant flag. Physical pattern selection ignored that distinction
and searched only enum subtype fragments. An ordinary nested struct match thus
failed with `linked named-field pattern has no exact variant type` (isolated
source probe: 0.136 seconds).

Named-field pattern selection now uses the retained constructor kind. A struct
selection searches only struct fragments for that declaration; an enum-variant
selection keeps the enum path. There is no retry by name, subject carrier,
logical nominal type, or another constructor. Missing selections remain missing.

The planner-level test checks the selected struct's physical type and two
one-field mutations: remove the constructor selection, or change its kind to
enum variant. Neither mutation can select the struct by another path.

The shared packed corpus adds four cases that bind all four small integer
types through nested struct patterns. Pattern fields are deliberately ordered
differently from the declaration. These cases reuse the checked packed reads
from `4c4683e`. This does not freeze pattern paths or implement generic payload
boxing; those are separate remaining work.

## Validation

The first test draft used a single-line named-field pattern and failed source
parsing (62.390 seconds); it is not a witness of the target bug. The corrected
multiline fixture retains its exact struct declaration, then fails the physical
target assertion: 703 tests pass, one fails (64.257 seconds).

Hardening passes all 704 internal tests, all 328 numeric record checks, and all
shared corpora (62.470 seconds). All 36 packed cases pass in both compilers.
The native library lane passes (27.030 seconds), as do generated checks
(4.334 seconds). Clean bootstrap passes (184.197 seconds), with identical
B/C raw and linked hashes:
`e41274806c4823fa84bb2ed47d746b945393f6631a06d3df38481efc5a6d602c`.
Runs above 30 seconds remain timing bugs.
