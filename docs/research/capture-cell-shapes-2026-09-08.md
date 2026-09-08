# Capture-cell physical evidence

The self-host closure planner converted mutable local shapes directly to Wasm
storage. Generic, Error, and a product containing Error all became references.
Three one-field mutation tests reproduce this: the old builder returns without
a trap (441 tests pass, three fail; 54.816 seconds). The original closure's
capture metadata stays concrete, so a later closure-field check does not catch
the corrupted local-cell shape.

Both base and specialized cell builders now check shape evidence before
publishing a field or a physical cell type. Specialized cells check the result
of type substitution, not the generic template. The existing recursive product
shape check reports Generic as reason 1 and Error as reason 2. SPC-301 records
phase 4, module, owner declaration/body, expression sentinel, expected zero,
actual reason, and the global local index in detail.

Tests cover concrete I64 storage, Generic/Error/product poison in both builders,
and Unit erasure after specialization. Invalid specialized requests are created
by changing one shape in a valid I64 request. They must fail at cell construction,
not merely at the later lambda signature/capture check. All nine numeric fields
are checked by the host harness. All 449 hardening tests, 137 exact records,
and shared execution corpora pass (55.898 seconds). Clean bootstrap passes in
167.648 seconds. Compiler B and C both hash to
`3a1e074bac8211038375abbebc924ce08a569d474992d0183a85f458b8fc7233`.
Generated checks pass in 4.000 seconds. Runs above 30 seconds remain speed bugs.
The native implementation and pinned provider are unchanged in this batch.

The first generation attempt failed Wasm validation (15.563 seconds): the new
helper left the Boolean result of the assertion call as an `if` branch tail.
The helper now explicitly discards that result, matching other assertion sites.
A separate minimal native fixture will check implicit branch-result discard;
this generation failure is not counted as a passing negative test.

This does not prove full heap/nullability agreement or equality between every
concrete local and capture type. Native capture-cell and closure storage checks
remain separate work. No performance changes are included.
