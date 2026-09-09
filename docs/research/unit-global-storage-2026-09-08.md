# Erased Unit globals preserve initializer effects

The initializer link tests exposed a self-host stack underflow: `let x = ()`
allocated a reference global, then emitted `global.set` after an empty result.
Native compilation already erased Unit/Never globals and retained their
initializer functions.

Self-host linking now assigns physical global slots only to stack-producing
values. Unit/Never entries retain the missing-slot marker, and global counts
are separate from initializer counts. Link verification checks that exact
mapping against source shapes. Emission creates/stores only present globals;
the source initializer functions still run in dependency order. Global reads
check the frozen body carrier, concrete source shape, slot bounds, and erasure
state. Unit reads emit nothing. Never reads emit `unreachable`.

The shared Unit corpus now checks a reference global, a Unit effect, a scalar
effect, another Unit effect, and an empty Unit global. Reading the values twice
must return 42 both times: all three effects run once, and the scalar slot stays
aligned. Native library checks pass, including all 24 Unit cases (29.381
seconds). The first self-host run passes 627 tests, 265 exact records, and all
shared probes, including those 24 cases (68.069 seconds). Its shell driver then
failed because the test file list was edited while bash was reading the running
script; a fresh run is required. Do not edit active test drivers.

Five additional one-field mutation tests cover wrong storage slots, carrier
disagreement, and Generic/Error values at the read boundary. The fresh hardening
run passes 632 tests, 270 exact records, and all shared probes (66.375 seconds).
Generated checks pass (5.012 seconds). The clean Node bootstrap passes
(206.629 seconds). Compiler B and C have identical raw and linked SHA-256 hashes:
`c2e0ae580b0acdab98876581b6115d4873170909f261f96ce67df337cf603fe2`.

This also closes the positive Unit-global failure recorded in the preceding
initializer-link batch. No native production or FFI/provider code change is
needed. Runs above 30 seconds remain speed bugs.
