# Physical type tables and emission order

The native linker now checks source physical fragments before reading their
indices. Link completion and final module emission both check the linked
tables. Emission returns a phase-7 numeric record before writing sections;
link checks retain phase 5. All nine fields are tested.

## Checks

- Source type indices equal their table positions. Field spans are checked
  before reads; physical field indices retain declared order.
- Source recursive groups form a complete, duplicate-free partition. Stored
  group identities and first indices agree with the owned spans.
- Module/type/signature relocation arrays have the required lengths. Missing
  and out-of-range physical indices remain errors.
- Non-cross-module relocation equals the checked module base plus local index.
  Wide diagnostic arithmetic cannot wrap a corrupt base.
- Cross-module recursive groups have checked spans and emission order. Every
  node has a present source module/fragment and a matching relocation. Only
  the existing generated closure/trait families may use canonical aliases;
  their kind and declaration identity must match the selected representative.
- Nominal lookup entries retain the physical declaration and relocation.
  Value declarations cannot become nominal lookup entries. Module identities
  must match their stored positions.
- Each canonical signature has a source function or function type, valid
  operand/result spans, and an exact relocated type index. Canonical records
  cannot duplicate physical indices; source aliases may share one record.
- A separate walk reconstructs the exact emitted type prefix: physical groups,
  raw-array storage types, canonical signatures, scalar erased boxes, and the
  initializer signature. It checks the graph schedule, every assigned index,
  and the final type count. It does not allocate by an unchecked type count.

The schedule check groups signatures by source module once. Its work is linear
in modules, edges, fragments, emitted fields, and signature records. This is a
new correctness check, not a speed-work change.

## Limits

This checks the linked type-section prefix. It does not finish source-to-Wasm
heap/nullability proofs, prove all canonical trait field/signature layouts, or
freeze the late adapter and text-runtime types that emission still appends.
Those tasks remain open. A passing Wasm validator is not a source-mapped shadow
stack proof.

## Validation

- Initial five source-fragment tests passed (9.816 seconds).
- Fourteen fragment/relocation tests passed (11.362 seconds); full integration
  passed all 268 tests (58.063 seconds).
- Seventeen tests plus canonical signatures passed (11.984 seconds);
  integration passed (67.051 seconds).
- Final focused suite: 21 tests passed (12.453 seconds). Each negative case
  starts with a checked valid plan and changes one field or table entry.
- One backend test checks the complete phase-7 record before emission.
- Final native: 1,176 tests passed (171.156 seconds).
- Final integration: all 268 tests passed (57.362 seconds).
- Library: 326 tests and all shared execution corpora passed (34.219 seconds).
- Hardening: 473 tests, 146 exact invariant records, and all shared emission
  corpora passed (146.418 seconds).
- Generated checks passed (17.627 seconds).
- Clean bootstrap passed (163.770 seconds). Compiler B and C have matching
  core and linked bytes, SHA-256
  `969b9933b45cba2bfcb5c0e63efc2847be09d621fd5b9415c4f92dd0b90274f6`.
- Stress: all 15 tests passed (0.359 seconds).

Runs above 30 seconds remain recorded speed bugs. No speed fixes are included.
