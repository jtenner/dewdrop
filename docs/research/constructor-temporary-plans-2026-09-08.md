# Frozen constructor temporary values

## Defect and change

The emitter allocated one temporary for each source constructor field, but the
body plan did not contain those temporaries. It selected each type again during
local emission. The new source-order test failed with the exact message
`constructor temporary is missing from the physical plan` (68.871 seconds).

The body planner now records every constructor field temporary after the work
queue closes and before freeze. It retains the source value evidence. Unit uses
an explicit reference marker for stored fields; an unreachable Never field has
the same reserved slot representation, but the existing evaluation schedule
still stops before a constructor instruction or later field evaluation.

Local emission requires the retained record. Missing and duplicate records
report BOD-610; a changed value or mirrored carrier reports ABI-710. Field
ordinals and source ownership are checked before lookup. The existing owned
freeze witness covers the new records and reports BOD-605 on later mutation.

This check exposed an additional defect: global initializers were omitted from
physical body planning. The String-pattern execution probe reported BOD-610
at its global constructor (module 5530, declaration 23751169146883, body
23751169146880, expression 3). That failed run took 108.896 seconds.

Initializers now use the same planner, verifier, and freeze boundary as source
functions. Their explicit signature has zero parameters and the linked global
result carrier. Their function handle follows the linked function table in
initializer order. No source function fragment is invented or selected as a
fallback. The common planner accepts the signature separately from the body
identity. The existing String-pattern probe now passes.

## Tests and limits

Tests cover mixed I64/Unit/I32 fields in source order, a frozen global initializer,
missing body plans, missing/duplicate temporary records, wrong value carriers,
wrong mirrored carriers, out-of-span ordinals, and mutation after freeze.
Seven negative cases verify all nine numeric failure fields.

One intermediate run failed to parse an inline two-field span record (17.834
seconds). Another rejected a malformed global-constructor test fixture; its
548 passing tests and 201 records did not count as a passing lane (69.717
seconds). Those source-format errors are fixed. Final hardening passes 550
tests, 202 exact records, and all shared probes (66.990 seconds).

The library lane passes 326 tests and all shared probes (30.587 seconds).
Generated-file checks pass (5.272 seconds).

The first clean bootstrap exposed a separate emission gap (117.471 seconds).
The diagnostic helper returns Never. A call to it in a reference-valued match
arm produced no Wasm value, but the caller's stack was not marked unreachable.
The provider rejected the exact call branch in `self_host_constructor_scratch_value`.
A small source regression reproduces that stack error (550 tests passed, one
failed; 104.362 seconds). The call-result adapter now emits `unreachable` after
a call only when the retained carrier is Never and flow proves no fallthrough.
It does not invent a reference result or change the selected function signature.
Final hardening passes 551 tests, 202 exact records, and all shared probes
(104.916 seconds). The clean bootstrap passes (329.082 seconds): B/C raw and
linked outputs share SHA-256
`13438ca32402e0c3874675421d18ad6b8a7c6e75f0db3a243b929da2c4f3da49`.
The final one-field-only mutation rerun also passes all 551 tests, 202 exact
records, and shared probes (69.659 seconds). No production source changed
after the successful bootstrap.
Runs over 30 seconds remain speed bugs; no speed work is part of this change.

This is not a complete frozen temporary layout. Other temporary kinds, exact
scratch slots, capture cells, constructor operand recipes, and nominal-type
recovery still require work. Full Wasm reference types also remain open.
