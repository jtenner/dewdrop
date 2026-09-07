# Set storage in Dew

`Set<K>` owns `Map<K, Unit>`. `SetIter<K>` wraps `MapKeyIter<K, Unit>` and uses
the public Map iterator methods. Set has no builtin declarations, special
inference, special layout, or special emitted instruction sequence.

Insert compares the count before and after one Map insertion. This preserves the
Boolean result without hashing or comparing a key twice. Growth, cached hashes,
collision chains, clear, and aliases use Map's ordinary Dew implementation.

The migration removes the remaining native hash-table runtime and its extra
runtime types. It also removes two unused inference target arrays per expression
from live bodies, family artifacts, cache checks, and binary codecs. Codecs remain
version 1 because no version has been released. Six dead emitter scratch slots
and their parameter plumbing are removed.

The shared native/self-host corpus checks eight cases: insertion and duplicates;
129 colliding keys with growth and removal; alias-preserving clear; iterator
lookahead and exhaustion; iteration after growth; String/Bytes content keys;
full-width I64 keys; and exact user hash/equality call counts. Missing Hash is
checked separately through the exact CT-021 diagnostic. Source-policy checks
reject Set builtins, ordinal dispatch, and old Set IR nodes.

This work exposed a separate compiler binding identity defect. See
[the binding log](compile-time-binding-identities-2026-09-06.md). It is fixed in a
separate compiler commit, not by changing Set's type or adding an exception.

| Check | Result | Seconds |
| --- | --- | ---: |
| Routine native | 931 passed | 126.829 |
| Full integration | 266 passed | 47.544 |
| Stdlib and shared execution | 325 tests and all shared checks passed | 21.335 |
| Self-host hardening | 230 tests, 29 invariant records, all shared checks passed | 51.548 |
| Self-host real Set compilation/execution | 8 passed | 1.375 |
| Generated source, API, and policy checks | passed | 14.955 |
| Clean A/B/C bootstrap | identical B/C bytes | 159.120 |

The native, integration, hardening, and bootstrap runs exceed 30 seconds and
remain performance bugs. Native semantic tests took 78.813 seconds and backend
tests 36.625. Bootstrap A build took 38.512 seconds, A compilation 42.475, and B
compilation 54.752. Correctness remains the first task.

B/C SHA-256:
`3fefd2b01aee879f8db1ee13db2d3bef9d047307fd908faa3dec62a0fbb8d0c9`.
