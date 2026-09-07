# WASI foreign imports

The raw Preview 1 module no longer uses builtins. Its 46 public functions are
explicitly declared foreign host imports. Public foreign members keep the same
module API without extra wrapper bodies. A policy test checks the complete
field set and result types; execution checks the full signatures and arguments.

The native foreign declaration path previously supported linked Wasm providers
only. `foreign import` now records an explicit host-import flag in syntax,
collection, and callable planning. The parse-event cache key changes with the
new record layout; all codec versions remain 1. Imported physical identities
have a distinct host kind with an exact namespace and field, including through
the planning codec.

The self-host emitter previously prefixed only the provider named `starshine`.
The fragment planner now records the complete import namespace for every
foreign declaration. The emitter copies that identity without a name check.

The shared executable corpus observes all 46 calls in order. It checks every
argument's value and JavaScript carrier (`number` versus `bigint`), not just
arity. This includes mixed-width signatures, negative I64 offsets, and Unit
results. It rejects unexpected namespaces, imports, calls, or missing memory.
The bootstrap request fixture now includes the raw WASI module.

Measured checks:

- Routine native lane: 959 tests pass, 132.834 seconds.
- Exact foreign-host planning codec round trip: one test passes, 0.035 seconds.
- Native library lane: 326 tests and all shared corpora pass, including all 46
  foreign calls, 14.658 seconds.
- Self-host hardening: 280 tests, 61 exact failure records, all 46 foreign calls,
  and the other shared execution probes pass, 68.497 seconds.
- Native integration: 268 tests pass, 77.673 seconds. A concurrent generated
  check caused lock waits; later checks run alone.
- Generated checks pass alone in 4.699 seconds. The concurrent attempt failed
  because a Moon lock message polluted an exact CLI diagnostic comparison;
  no diagnostic expectation was weakened.
- The raw WASI snapshot runs twice with identical output and passes in Node
  and Wago, 0.601 seconds. The cold snapshot generator build took 92.953 seconds;
  its old WAT expectation changed with the new declaration plans.

Runs above 30 seconds remain speed defects. No speed changes are included.

The clean A/B/C bootstrap passes in 159.863 seconds. B/C core and linked bytes
match. The linked SHA-256 is
`0b79658080ae88187f14242f4b58d733fab917b19ea0af8e50112a681a4556f6`.

The higher-level Bytes I/O adapters and private legacy raw builtins in
`dew.std.wasi` remain separate migration work.
