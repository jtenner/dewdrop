# Compile-time types

## Contract

`dew.std.types` contains pure compiler builtins. Their answers use logical types,
not Wasm carrier shapes. Aliases are transparent. Nominal declaration IDs, narrow
integer widths, signedness, tuple order, and generic arguments remain distinct.
Unknown types defer a query; invalid types produce an error. `implements` returns
false only for a completed search with no applicable implementation. Cycles,
resource limits, incoherent candidates, and missing evidence context are errors.

The user selected **real compile-time types** for `field_type` and
`variant_payload_types`. Their results must be usable in declarations and generic
arguments. Strings, opaque reference handles, and metadata IDs do not satisfy
that requirement.

## Current native implementation

The module declares `type_equal`, `is_unit`, `is_never`, `is_integer`,
`is_signed_integer`, `is_float`, `bit_width`, `can_bitcast`, `lane_count`,
`lane_bit_width`, `tuple_length`, `implements`, and `static_assert`.

- Query dispatch uses builtin metadata and declaration identity, not names or a
  standard-module ordinal.
- Required folding runs in unoptimized lowering as well as optimized builds.
- Generic functions that contain queries, and their transitive callers, retain
  logical type arguments in a structural specialization key. Thus `I8` and `U8`
  instances do not share a query result merely because both use `i32`.
- The call planner and body emitter use the same specialized IR instance.
- Branch pruning walks planned IR in postorder. Discarded calls do not create
  specialization requests. Invalid queries in discarded branches are not
  evaluated. No generic template is mutated to one instance's answer.
- Assertions in generic templates are deferred to instances. A failed assertion
  reaches link/source diagnostics with the declaration, instance key, expression,
  source offset, and message.
- Compile-time builtin declarations have no runtime import. Physical closure
  verification rejects surviving query uses with `CT-005`.
- `can_bitcast` follows the existing zero-instruction `unsafe.bitcast` contract.
  It does not conflate that operation with Wasm numeric reinterpret instructions.
- Explicit call type arguments now undergo alias normalization in both native
  and self-host type resolution. This fixes `is_unit<AliasToUnit>` returning false.

## Checks

- The new generic identity regression failed before logical specialization was
  connected, then passed after the change.
- 24 focused native compile-time tests passed in 9.897 seconds, including
  structural identity, trait prerequisites, imported implementations, cycle errors,
  assertion failures, nested branch removal, discarded lambdas, conversion-boundary
  preservation, and the physical closure check.
  The imported case exposed a wrong-span lookup in the new evidence search:
  source-module generic spans must not index consumer-module ID arrays. It now
  uses the parallel imported ID/bound span.
- The native execution fixture passed 20 checks in 0.023 seconds after a warm
  0.245-second build. It checks generic forwarding, generic function references,
  Unit branches, and different
  trait answers for same-layout nominal types. Its harness also rejects unexpected
  runtime imports. The fixture is included in `tools/dew-test/run.sh`.
- The final native lane passed in 57.607 seconds. The final full integration lane
  passed in 45.724 seconds. Both exceed the repository's 30-second threshold and
  remain performance bugs, not waived requirements. The new standard module also
  required updating the wildcard module/dependency-count regression.
- Self-host hardening passed 162 tests, 27 invariant-record checks, and its
  emission/semantic probes, including the new explicit-alias regression. The
  run took 119.148 seconds; test generation took 99.237 seconds. Both are performance
  bugs. This checks the existing self-host compiler plus the alias fix, not query
  parity: the new query evaluator has not been ported.

## Work still required

This is not the completed feature set.

1. Implement and run the matching self-host query, logical specialization, branch,
   evidence, assertion, and physical-boundary paths. Only alias normalization has
   been changed in the self-host compiler so far.
2. Add guarded inference obligations. The current `implements` query does not yet
   make an otherwise invalid generic trait call legal inside its true branch.
   Both branches still undergo ordinary source type checking before lowering.
3. Add real type-valued expressions and their declaration/generic-argument syntax.
   Then implement `field_type` and `variant_payload_types`, including generic
   substitution, imported declarations, aliases, cycles, and source diagnostics.
4. Implement `field_names` and `variant_names` with stable source order and
   declaration-based selection.
5. Define layout-query semantics before implementing `size_of`, `align_of`, and
   `field_offset`. WasmGC does not expose object byte layout. Do not invent offsets
   for GC objects or imply that a reference's carrier size is an object's size.
6. Cover generic closures, function references, recursive calls, imported generic
   callers, test-only implementations, and conditionally unavailable operations.
7. Replace full-module instance copies with bounded body-local overlays after
   correctness is established. Keep structural keys, immutable templates, and a
   single verified emitter input.
8. Refresh public interfaces, run generated checks, integration tests, self-host
   hardening, and a clean B/C bootstrap comparison. No current bootstrap parity is
   claimed for these changes.

## Later library use

After native/self-host parity and guarded inference pass, use `is_unit` to select
erased storage paths in Array and FixedArray; use `implements` for optional fast
paths without hard trait bounds; use `static_assert`, lane queries, and
`can_bitcast` to check packed conversions. Reflection can support generated field
and variant traversal once real type values are implemented. Keep runtime library
algorithms in Dew and keep all standard modules on the ordinary compiler path.
