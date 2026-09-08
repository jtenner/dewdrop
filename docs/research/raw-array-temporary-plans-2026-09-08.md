# Frozen raw array allocation temporaries

## Missing length record

`array.new` evaluates Dew arguments as length, then initializer, but its Wasm
operands are initializer, then length. The emitter used an I32 temporary to
preserve those orders. That temporary was absent from the physical body plan.
The source regression failed with `raw array length temporary is missing from
the physical plan`; 552 other tests passed (74.699 seconds).

The body planner now records the length value after the work queue closes and
before freeze. The record retains the length's logical type, not the array
result's type. Emission requires that record and checks it against the source.
Missing/duplicate records report BOD-610, different value or mirrored carriers
report ABI-710, and later mutations report BOD-605. Constructor and raw-array
temporary consumers share these checks. Unit and Never cannot be physical
temporary types; a proved nonreturning source reserves an unused I32 length
slot without claiming that its evaluation produces an I32 value.

The first fixed lane passed 553 tests and 202 records (73.399 seconds). Eight
new negative cases check complete numeric records for missing plans, missing
or duplicate slots, changed types, changed mirrored carriers, frozen mutations,
and invalid Unit/Never physical types. Every plan mutation changes one field.

## Nonreturning arguments and declared results

Two execution probes put a return in the length or initializer argument. The
first expanded lane passed 561 compiler tests and 210 exact records, but these
probes exposed a separate error (68.530 seconds): a Dew function declared to
return I64 was classified as the `unreachable` opcode solely because its body
contained that call. The raw-intrinsic verifier then expected Never at an
ordinary I64 call site.

Both compilers now decline this forwarding shortcut when the body is Never
but the callable's declared result is not Never. The ordinary Dew body remains
the implementation. Tests cover I64, reference, and Unit result declarations,
plus a genuinely Never declaration that can still forward the opcode. The
native regression failed before the fix (11.544 seconds) and passes after it
(12.236 seconds). This does not complete the audit of all forwarding contracts.

After that fix, 562 tests and 210 records passed, but the same execution probes
exposed allocation instructions left after a return (187.314 seconds including
a native rebuild). The provider rejected the extra array reference on the
stack. The raw-array emitter now schedules only the evaluation prefix ending
at the first value whose frozen Never carrier and flow both prove divergence.
It omits the remaining arguments and the allocation opcode. Earlier values
are evaluated and discarded in source order; no heap selection is needed for
an instruction that will not execute.

Both probes now return 42. Their validated Wasm text also contains no
`array.new` instruction. Final hardening passes all 562 compiler tests,
210 exact records, both new flow checks, and all shared probes (67.095 seconds).

## Remaining checks and scope

Full native checks pass 1,222 tests (209.601 seconds); integration checks pass
268 tests (64.719 seconds). The library lane passes 326 tests and all shared
probes (39.813 seconds); generated-file checks pass (20.437 seconds). The clean
bootstrap passes (231.923 seconds). Compiler B and C have identical raw and
linked SHA-256 hashes:
`b25fa7ea630c2f527cf5242b50e1014b3a8241fb79e6d15f6f894e4c88a17a39`.
Runs above 30 seconds remain speed bugs.
No provider or generated FFI change is part of this batch. Exact temporary
slots, other temporary kinds, full reference types, and complete raw-opcode
evaluation recipes remain open.
