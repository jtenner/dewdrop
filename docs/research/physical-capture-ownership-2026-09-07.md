# Physical capture ownership

The old physical child checker treated capture reads as leaves and checked only
the value of a capture write. A valid global capture span also did not prove
that its entries belonged to the selected lambda or that a closure recipe
retained all captures.

Both compilers now check lambda identity, root body, global capture spans,
stored capture owner and relative ID, and body-relative capture reads/writes.
Named bodies have an empty capture table. Native closure construction and direct
lambda calls also require their recipe span to equal the selected lambda's
capture span. Self-host closure expressions already select the lambda's sole
capture span directly. Entry checks run before child processing; self-host
final verification repeats them before emission.

ARN-101/104/106 retain full numeric context. Capture arena/relative-ID tag is 17,
capture owner is 18, recipe start/length are 19/20, lambda identity is 16,
and lambda root body is 21. Native phase is 7 and self-host phase is 6.

Measured red runs:

- Native: all seven new mutations fail against the old checker in 14.224 seconds.
- Self-host: 350 tests pass and four new mutations fail in 79.679 seconds.
  The exact-record checker fails too; the old verifier accepted all mutations.

The focused native run passes all 31 body/capture/list checks in 15.281 seconds.
The self-host lane passes all 354 tests, 103 exact failure records, and all
shared corpora in 89.157 seconds. The full native lane passes 1,055 tests in
189.244 seconds. All 268 integration tests pass in 81.875 seconds.
The library lane passes 326 tests and all shared corpora in 35.610 seconds.
Clean bootstrap passes in 516.945 seconds: A builds in 129.678 seconds,
A compiles B in 206.866 seconds, and B compiles C in 140.887 seconds.
B/C core and linked bytes match, SHA-256
`2043993d8ed7174b6ba7aed086e6fd6a1b7d8f633b3210472f978497396af12e`.
These timings were measured while unrelated CPU-heavy work was running on the
host; they are not an isolated performance comparison. No external process was
changed. Generated checks pass in 14.716 seconds. The pinned provider is
unchanged from its full 10,990-test checkpoint.
All 15 stress tests pass in 10.070 seconds. Speed defects remain recorded;
this batch does not optimize them.
Capture-source local ownership and forwarded
environment agreement still need checks; this batch does not claim those are
proved. The existing self-host emitter checks active capture sources and outer
environment forwarding, but skips erased captures before those checks. Native
direct capture emission also ignores a named source's body ID when selecting a
local. The next source-ownership checks must cover both paths before emission.
Full reference-type agreement and speed work are also out of scope here.
