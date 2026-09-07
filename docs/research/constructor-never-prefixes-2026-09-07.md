# Non-returning constructor evaluations

The expanded shared fixture exposed three defects:

1. Native emission selected a physical variant layout before noticing that a
   nested tuple payload returns. That demanded storage for a value that cannot
   exist and rejected the valid function.
2. Self-host emission still emitted tuple/variant construction and later
   arguments after the return, producing an invalid Wasm stack.
3. The self-host field verifier rejected declared Unit fields even though its
   physical layout assigns them reference marker slots.

Native constructor scheduling now checks the flow of the ordered evaluations
before selecting storage. A non-returning prefix is emitted without a
constructor. Tuple scheduling also stops at its first non-returning child.

Self-host lowering replaces such products, array literals, struct constructors,
and selected variant calls with the existing evaluation-sequence IR before
specialization and physical planning. The prefix retains source expression IDs
and ends at the first non-returning input. Lowering owns its child arena, so
appending a prefix cannot mutate the collected source. Constructor namespaces
are excluded from runtime evaluations, including consumed qualified targets.

Declared Unit fields have a separate identity-indexed marker certificate. They
do not enter the generic-erasure map and cannot authorize scalar boxing or
missing generic evidence. Reads and constructor constraints retain the Unit
carrier; only storage receives a null marker.

## Validation

Nine shared execution cases pass in both compilers: generic Unit payloads,
Unit tuple payloads, declared and reordered struct fields, non-returning struct
and tuple-variant arguments, a generic nested tuple payload, and declared Unit
field construction/read. Two self-host internal tests check source arena
ownership, exact prefix length/terminal expression, and marker permissions.

Native focused generation: 0.138 seconds; execution: 0.027 seconds. The first
native backend rebuild took 90.864 seconds, a performance bug. Self-host shared
constructor execution: 0.002 seconds. Combined hardening: 252 tests, 38 exact
records, and all shared probes pass in 37.387 seconds; generation: 7.042 seconds.
Earlier red runs exposed invalid fixture block syntax, the missing Unit marker
certificate, late construction, and a namespace mistakenly used as an operand.
None of those failed runs count as successful validation.

The routine native lane passes all 949 tests (122.722 seconds). The clean
A/B/C bootstrap passes in 159.649 seconds; A build takes 42.824 seconds and
A/B execution takes 41.905/53.387 seconds. B/C core and linked bytes match:
`e8fd73ef9602c194dbb74014b68834155acd821a6d547a7b8820407622200572`.
