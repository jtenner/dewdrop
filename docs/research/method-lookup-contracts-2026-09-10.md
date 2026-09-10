# Receiver method lookup contracts

The remaining self-host shape-recovery method selectors have three unsafe
fallbacks: a wrong receiver retries a global name search, a wrong argument
count retries without that count, and multiple linked specializations select
the first function. These helpers are not the frozen call-emission selector,
but their answers can still contaminate earlier shape evidence.

The new tests use valid source and clean inference/linking. A Reader method
resolves with its own receiver and zero explicit arguments before lookups with
another nominal owner or one explicit argument. A generic Reader fixture
retains two linked specializations and two exact call-site mappings. A lookup
without those mappings must not invent a selection from their link order.

The change keeps receiver and optional argument-count constraints
together and requires one matching declaration and one non-lambda,
unspecialized physical function. No match or ambiguity stays None for the
caller to handle. This does not replace the exact call-site map or the full
ABI verifier. Other
nominal/type recovery by source name is separate work.

The baseline passes 901 tests and fails all four new tests for their intended
assertions in 88.387 seconds. All 470 exact records and the shared emission
and semantic probes still pass. The implementation moves both selectors to
`starshine_method_lookup.dew`, sharing one constrained scan. The now-unused
global method-by-name function is removed. Duplicate candidates remain
ambiguous even if a corrupt link table reuses a physical index.

The first implementation run passes 903 tests and 470 records, but the two
plain-method fixtures fail their valid-lookup check (87.658 seconds). This
exposes a further old defect: the stored parameter span includes `self`, while
the lookup receives the explicit argument count. The previous unconstrained
retry hid that mismatch. The constrained check now uses length minus one,
guarded by a nonzero length so subtraction cannot wrap.

The corrected run passes all 905 tests, 470 exact records, and all shared
emission/library and semantic probes in 87.448 seconds.

A fifth test now checks the unique-but-incompatible case: only Reader<I32>'s
method is linked, while another local has type Reader<I64>. Both share the
same nominal declaration. Candidate count alone cannot prove compatibility.
The fifth test fails for the intended mismatch in 100.507 seconds; the other
905 tests and all 470 records pass. A name/receiver lookup has no exact logical
type-argument key, so it now declines specialized functions even when only one
is linked. The existing exact call-site map supplies specialized selections.
This is not a proof of generic compatibility based only on physical carriers.

The final hardening run passes 906 tests, 470 exact records, all 318 shared
callback checks, and the other shared emission/library and semantic probes
in 104.711 seconds. Generated-source and policy checks pass in 6.623 seconds.
Clean bootstrap passes in 244.752 seconds. Compiler B/C core and linked bytes
match, with raw and linked SHA-256
`cf3e7f1f2bf79c8376397579118dc13364d93e2965dbe8642b48ac1eb5e20245`.
The provider and FFI are unchanged. Runs over 30 seconds remain timing defects;
speed work is deferred.
