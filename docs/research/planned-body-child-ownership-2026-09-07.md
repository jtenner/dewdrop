# Lowered body child ownership

The new native span boundary checks owned arenas and roots, but expression
operands and child lists still need their own checks. A global arena bound
cannot prove that an operand belongs to the selected body. Optional operands
must accept only the declared missing sentinel, not every negative integer.

Prepared seven native tests for required unary operands, optional returns,
logical local reads, block references, argument list spans/members, and block
item spans. Each begins with valid lowered source and changes one child or list.
They use the existing boundary API. Before the fix, all seven tests failed in
10.313 seconds: each malformed state was accepted as `Ok(())`.

## Native implementation

The native boundary now checks every planned expression variant explicitly.
Required children must belong to the body; only `-1` can erase an optional
return, receiver, alternative, or guard. List spans are checked before reads.
Arguments, constructor values, block items, pattern children/fields, and arm
members retain their owning body. Logical local uses and pattern bindings have
owned local checks. Lambda IDs and capture-list arena bounds are checked too.

One checker retains the first complete numeric failure. Later checks cannot
overwrite it or access a list after its span check fails. ARN-101 list tags are
10 expression children, 11 block items, 12 object fields, 13 arm children,
14 pattern children, 15 pattern fields, and 17 captures. ARN-104 uses owned
arena tags 1 expressions, 2 locals, 3 blocks, 4 patterns, 5 arms, and 16 lambdas.
Non-expression list checks use the missing expression sentinel; the body and
owned arena stay explicit in the record.

The first 14 body/child tests pass in 11.883 seconds. Eight additional tests
cover constructor fields, arm ownership/guards, tuple and struct patterns, and
closure indices/spans. All 22 focused tests pass in 13.237 seconds.
All 1,046 native tests pass in 145.381 seconds (600 semantic tests in 88.300
seconds; 95 backend tests in 44.519 seconds). All 268 integration tests pass
in 57.398 seconds. The library lane passes 326 tests and all shared corpora in
30.550 seconds. Hardening passes 337 tests, 86 exact invariant records, typed
FFI smoke, and all emission/semantic probes in 69.940 seconds. A fresh clean
bootstrap passes in 165.395 seconds: A build 45.057, A execution 42.896, and
B execution 55.846 seconds. B/C core and linked bytes match; linked SHA-256 is
`b59741bceb31675079ee96a24e9f5296c065df77cfb60a756db77ab00cfc7895`.
Generated-file and policy checks pass. The preceding boundary batch passed all
15 stress tests; the pinned provider remains unchanged since its 10,990-test
run. Timings over 30 seconds remain speed bugs, outside this change's scope.

The self-host counterpart remains to be implemented. Capture source identity,
complete control scope, type-argument arenas, IR graph cycles, call ABI checks,
and the emission shadow stack are not proved by these child bounds. Speed work
remains out of scope.
