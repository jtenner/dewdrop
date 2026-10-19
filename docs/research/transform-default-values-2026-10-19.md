# Checked default values in source transforms

The first valid unit-product probe generated 0 instead of 42. A two-argument
record probe incorrectly generated 42 after reading an empty slot. Evidence:
`.tmp/transforms-v3/default-feature/{default_references,generic-record}-before.dew`.
A concrete foreign nullable cast also failed by trying to read null as a struct;
its log is `default-feature/null-cast-before.log`.

The scalar-kind exporter treated any one-argument applied type as an array and
had no tuple, function, or trait tags. It now uses the checked raw-array
owner table. Nominal record tags retain declaration IDs for any argument count.
Function and trait tags retain their nullable carrier behavior. Unit-only tuple
metadata describes the nested shape, with 128 depth and 65,536 visits allowed.
The VM reconstructs that shape only after charging 16 estimated bytes per shape
byte. Tuples with runtime leaves require a box and reject a null default.

Both VMs normalize unit defaults, preserve null for nullable/function/trait/raw
array carriers, reject null at non-null record/text boundaries, and reject any
value for Never. Null casts check the checked target's nullability before
reading a layout. The nullable type is identified by its checked declaration,
not source spelling. No new host calls or second Wasm instance are used.

The first broader fixture used unsupported `ref.is_null` spelling; it was
corrected to the compiler's existing checked `ref_is_null` opcode. A proposed
generic foreign cast fixture was rejected by ordinary checking, so the final
cast fixture names two concrete foreign types. Neither invalid fixture is
counted as an interpreter failure or a passing execution.

Native VM tests pass 77/77 in 2.225 seconds. Four checked default source cases
pass in 12.468 seconds. They cover nested unit products and null carriers, nullable
casts, one-argument records, two-argument records, and non-unit products. Unit
checks also cover malformed product metadata, construction at the allocation
limit, a non-null cast trap, and Never defaults. All 105 Dew tests pass, including
seven corresponding default tests. Dew generation took 6.965 seconds, linking
1.376 seconds, and execution 16.695 seconds. Its full 59.973-second lane includes a
cold generator rebuild and exceeds the project's 30-second rule.

The ten normal-Wasm controls pass after the separate product-box/nullable-local
backend correction. The saved JS build took 3.939 seconds; each compile took
1.083–1.135 seconds. Peak host RSS was 368,324–374,440 KiB. These single functional
samples do not establish a speed or memory gain. The runtime note is
`raw-array-default-results-2026-10-19.md`; raw samples retain exact build identity.
No identical accounting or peak-heap claim is made by these VM work charges.

Current standalone controls for the final nullable cast and fresh Dew requests
remain pending. Routine checks are recorded in
`.tmp/transforms-v3/default-generic-{native,dew}-final.log`.

## Product-carrier follow-up

A separate read-only source review found that product metadata still returned
an unknown intrinsic carrier. Five actual transform probes then confirmed the
hole: scalar casts to two-leaf, zero-leaf, and one-leaf tuples, a scalar opcode
with a direct tuple result, and a raw i32 struct field declared as a tuple all
produced 42. Their original checked type requires a tuple value, but the VM kept
the integer. Evidence is in `.tmp/transforms-v3/product-carrier-review/`.

Products now have an explicit intrinsic carrier. Normal checked tuple values
must contain a Sequence. Unsafe casts and raw field reads that need a product
layout stop with a diagnostic. The one-leaf runtime cast can be a valid Wasm
ABI; it remains unsupported by this interpreter until it has checked tuple
layout data. The diagnostic must not call that runtime ABI invalid. Five new
Native and Dew source regressions cover this safety boundary and now pass. This change claims no full product-cast support.

Claude was attempted with normal repository authentication and read-only tools
on the fixed default/root/generic snapshot. It stopped before review due to its
session limit, with reset at 20:50 UTC. Stdout, stderr, exit status 1, source hashes,
logs, samples, and instructions are saved in
`.tmp/transforms-v3/claude-default-roots-review/`. No assessment or full coverage
is claimed for that attempt. No credential or authentication setting changed.

## Final combined source checks

All 78 Native VM tests pass. The four default source cases and five product
safety cases also pass. The combined Dew suite passes all 115 tests. Native
package times were 2.256, 4.052, and 13.619 seconds respectively; the full
Native lane took 37.007 seconds. Dew generation took 7.214 seconds, linking
1.439 seconds, and execution 22.549 seconds. The 36.111-second aggregate lane
exceeds the activity rule. Logs are
`.tmp/transforms-v3/products-initializers-native.log` and
`.tmp/transforms-v3/products-initializers-dew-fixed.log`.

Scoped `moon info` and all three scalar/vector generator checks pass. The
current JS build exposes a separate duplicate-owner cache-pack fault on the
public default example. That fault is under repair. Fresh public requests and
self-host fixed-point checks remain pending. No full-feature completion claim
is made by these source-test results.
