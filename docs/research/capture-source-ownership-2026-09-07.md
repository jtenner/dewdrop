# Capture source ownership

The capture-table batch checks slots and stored IDs. Source-local ownership
must be checked separately, including logical Unit captures that are erased
before physical fields are emitted.

Native direct capture emission previously ignored the body ID of a named
source. Self-host emission checks active source locals and forwarding, but
returns before those checks for erased captures. Neither body boundary checked
all capture origins before emission.

The new mutation corpus starts with valid captures, then changes only the
source field: another root body, an out-of-range local, an absent lambda, or
a local that exists but is not available in the enclosing environment.
A separate Unit fixture prevents physical erasure from hiding a bad source.
Nested closures provide a positive direct/forwarded-source case.

Measured red runs:

- Native initial five-case run: one positive passes, four mutations fail,
  0.897 seconds.
- Self-host: 355 tests pass and four source mutations fail, 79.727 seconds.
  The exact failure-record checker also fails because no invariant was raised.
- Native expanded run: one positive passes and five mutations fail in
  10.376 seconds, including an existing but unavailable inner-lambda local.

Both body boundaries now check the exact root body or source lambda, the
source local span, and all stored local identity fields. Local identity checks
are shared with ordinary body-local validation. Closure creation also requires
each source to be a direct local or an exact source in the enclosing capture
table. Native direct-lambda recipes run the same check. Lambda-source identity
checks do not recurse through capture tables, so an invalid self-reference
cannot cause an unbounded validator walk. Native emission also keeps the named
source's body ID in its direct-local guard.

The focused native run passes all 37 body/capture/list checks in 20.075 seconds.
The self-host lane passes 360 tests, 108 exact records, and all shared corpora
in 129.541 seconds. The full native lane passes 1,061 tests in 215.240 seconds.
Integration passes in 81.118 seconds. The library lane passes 326 tests and
all shared corpora in 50.946 seconds. Bootstrap passes in 439.069 seconds;
compiler B and C raw and linked hashes all match:
`5883b9645d590e2e0a98a006b48396c843aaf3d2dad20a12a6764640352316a9`.
Generated checks pass in 26.301 seconds, and all 15 stress tests pass in
0.425 seconds. Runs above 30 seconds remain speed bugs; no speed work is
included. Full capture carrier/reference agreement remains separate work.
