# Callback signature targets

Indirect call signatures must come from the target's function type. The old
self-host emitter rebuilt missing signatures from call operands and the result
shape. That recovery could hide lost type evidence behind a valid-looking ABI.
It is now removed, together with its unused argument-shape recovery helper.

Missing target types report ABI-704 before publishing a signature. Signature
scopes have checked expression spans (ARN-101), and each call target must belong
to its scope before indexing (ARN-102). All three negative probes change one
field of a valid plan and check all nine numeric failure fields. The fixture
has three expressions; its block root is stored separately.

Scopes retain the source declaration and body for diagnostics. Lambda scopes
use the linked fragment's parent declaration, not the anonymous declaration in
the virtual lambda body. A positive lambda test first failed on that placeholder.

The missing-type baseline passed 822 tests and failed the intended missing-trap
test in 97.559 seconds. The first fix passed 823 tests and 415 exact records in
96.620 seconds. The span tests passed semantically, but the first host expectations
incorrectly used four expressions; correcting them to three passed all 417 records.
The lambda owner baseline passed 825 tests and failed its new positive test in
97.539 seconds. Final hardening passes 826 tests, 417 exact failure records,
and all shared execution probes in 93.583 seconds. Generated checks pass in
4.738 seconds. Clean bootstrap passes in 196.741 seconds. Compiler B and C,
both raw and linked, have SHA-256
`321be9aa4e5e51fcc3654a3150219bcdeb8d19a563cb52942b7ff3410b79f8df`.

This does not close full indirect-call heap/nullability checks, lower-level
signature arena checks, or the remaining anonymous signature assertions.
Runs over 30 seconds are timing defects. Speed work is not included.
