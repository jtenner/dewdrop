# Native selected lambda shape checks

The native selected-lambda materializer rejected only a top-level Generic
result. Error results and invalid leaves of product results could reach
`program_append_specialization_value_types`. Selected capture layouts checked
top-level Generic/Error only; selected parameters had no corresponding guard.

The result guard was first extracted without changing which shapes it accepts.
Two regression tests then failed: Error/product-Error results and a product
containing Generic returned success (0/2 pass, 9.398 seconds). The first test
compile had a missing `raise` annotation in its helper (1.559 seconds); that
fixture error is not counted as the regression.

All three selected boundaries now use the existing worklist-based product shape
check after substitution. The checker returns a complete numeric SPC-301 record;
the production wrapper renders that record before aborting. Fields are phase 4,
module, owner declaration, root body, lambda expression start, expected zero,
and actual 1 for Generic or 2 for Error. Detail is `0xffffffff` for a result,
`(1 << 32) | localOrdinal` for a parameter, or `(2 << 32) | captureOrdinal` for
a capture. Ordinals refer to the lambda-owned spans. All nine fields are tested.

Four focused tests pass in 9.668 seconds, including concrete scalars, references,
products with erased Unit leaves, and Unit/Never shapes. This does not turn
Never into a physical operand; the existing physical conversion erases it.
Both existing compile-time lambda layout tests pass (1.363 seconds), including
exact I64 storage, erased Unit captures, re-planning, and serialization. The
full native lane passes all 1,104 tests (153.096 seconds). All 268 integration
tests pass (57.579 seconds). The library lane passes 326 tests and all shared
execution corpora (33.643 seconds). Self-host hardening passes all 450 tests,
137 exact records, and all shared execution corpora (146.175 seconds, including
the cold native rebuild). Clean bootstrap passes in 169.478 seconds, with the
same B/C hash as the preceding Dew implementation:
`577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
Generated checks pass in 12.889 seconds, and all 15 stress tests pass in 0.367
seconds. Runs above 30 seconds remain speed bugs. The pinned provider and FFI
bindings are unchanged.

These guards do not prove full heap/nullability agreement or all template/local
capture-cell rules. They do not suppress source diagnostics or convert generic
templates into physical signatures. No performance changes are included.
