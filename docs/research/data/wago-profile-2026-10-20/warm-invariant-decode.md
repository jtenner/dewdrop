# Decoded warm-cache invariant

Date: 2026-10-20. Read-only scan. No build or test was run.

Dewdrop source root: `/home/dev/Projects/dewdrop`.
Pinned Wago source root: `.tmp/wago-transform-host/build-y_uuvb8q/wago`.

## Exact meaning

The record in `.tmp/wago-profile-2026-10-20/warm-diagnostic/run.log:15` is:

| Field | Value | Meaning |
| --- | --- | --- |
| code | 102 | Requested global arena index is outside the current body's owned span |
| phase | 1 | Body name resolution |
| module_id | 4294901760 / 0xffff0000 | `dew.std.preamble` |
| declaration | 18446462598732842243 | Preamble declaration local index 1283 |
| body | 18446462598732841654 | Preamble body local index 694 |
| expression | 0 | Bad global expression index |
| expected | 72 | Current body's expression span length |
| actual | 0 | Same bad global expression index |
| detail | 4123 | Arena tag 0 (BodyExpressions), span start 4123 |

The legal expression range is `[4123, 4195)`.

Definitions:
- `self_host/compiler/semantic_body_arena_contracts.dew:20-31` maps BodyExpressions to tag 0.
- :41-56 assigns record fields; detail packs arena tag in high 32 bits and the span start in low 32 bits.
- :59-68 emits code 102 after owned-span validation succeeds.
- `semantic_ids.dew:7-26` packs and unpacks module/local IDs.
- `semantic_standard_module_ids.dew:4-5` maps the preamble ID.
- `semantic_body_arena_contracts_test.dew:12-18` checks this exact record format.

Phase 1 and expression tag 0 identify
`SelfHostBodyNameResolver.expression_index`
in `semantic_body_name_resolution.dew:393-394`.
The failed assertion is `"body arena index is invalid"`, not a type-layout check or native compiler check.

The body-owned span itself passed the earlier check. The record contains plausible body/declaration IDs and a nonzero span. It does not show that the entire body record was lost.

## Closest value paths

Only these resolver sites call expression_index:
- :526 `set_expression_reference`
- :1659 while expression control slot
- :1692 break transfer target
- :1711 continue transfer target

`schedule_expression_children` (:1508-1517) rejects the sentinel and values beyond the module-wide expression arena. It does not reject an index that belongs to another body. Thus zero can read `collected.expressions[0]` and flow through some expression work before this body-local assertion catches it.

Sources of expression work include:
- body root (:2043-2049)
- block item value (:1894-1900)
- expression child fields, object field values, arm/pattern literal values
- work list task.first (:2005-2007)

The work record is a GC object with three scalar U32 fields:
`SelfHostBodyNameTask { kind, first, second }`
(:211-215).
`push_task` stores them at :409-415.

Three loops read a task reference, truncate the task array, then run the task:
- :1905-1907
- :1994-1996
- :2054-2056

These are useful liveness trace points. A popped task must remain live after its array slot is removed and through any collecting calls that inspect it. This observation is not proof that this lifetime is wrong.

## What the equal code hash rules out

The parent reports identical 21,170,004-byte native code for passing cold parallel, passing serial-native, and failing warm runs:
`6eb46b29fbf9bc825a9e82116cbb5ca19c325ff36788780b944746ba74408c0f`.

This rules out different native code generation as the direct cold/warm difference.
It does not establish identical runtime root maps, type maps, initial data, call context, collector setup, memory placement, or execution history.

The guest HIR and resolver work lists are created during execution. They are not objects directly read from the Wago artifact. A codec cause must affect runtime setup, metadata, initial program data, or call/GC behavior that later builds or uses those objects.

## Narrow hypotheses, not confirmed defects

1. A restored runtime root map or native GC/type view differs from the fresh one. Compare finished root-map fields and GC descriptor/type-map fields first. Do not assume the source-only AllReferenceLocals list is needed at runtime; it is used during native emission only.
2. The metadata is equal, but memory placement or collection timing exposes a native liveness error. The task pop/truncate lifetime is a focused place to test. The bad value could instead have entered through a HIR child or block item before the task list sees it.
3. Initial global/data or exact value-type decoding differs and produces a bad work item earlier. Static names for resolver task kind and expectation are global U32 values (:27-38); compare their initial values along with data/global hashes.
4. Invocation setup uses a different helper or reference path due to restored generic GC flags. Compare actual helper admission flags, native GC ABI, syncHostSlots, collector profile, type-domain mapping, and native instance context.

Source checks did not find a missing field in finished root maps:
Wago codec writer :783-806 and reader :2210-2290 are symmetric.
TypeDesc contains ID, kind, fields, element kind, sizes, alignment, ref/final/supertype flags (`src/core/runtime/gc/native/desc.go:44-55`); the codec writes all of these at :809-827.
Exact value types and function signatures are decoded into ABI views at codec.go:1577-1597 and :1753-1788. Compare those derived ABI views too, not only serialized hashes.

Direct-prepared marker stripping is a known artifact change, but remains low priority here: its normal consumers are PreparedFunction/host-entry selection, while this run uses CLI Invoke and reaches internal name resolution with GC/imports active.

## Smallest next trace

Limit the trace to module `0xffff0000`, body local `694`, declaration local `1283`.

Record:
- body/lambda root and span at resolver entry
- each scheduled expression ID with source kind, parent expression/block item/arm ID
- task push/pop kind, first, second, and task-array length
- first attempted body-relative expression ID
- GC cycle count immediately before/after the first divergence

The first warm/cold difference matters more than the final code102 record.
If a task changes only after truncate or collection, inspect that function's finished safepoint/callsite offsets and its native local/operand-root state. If the bad ID is already in a collected HIR field, move the trace to its construction.

Keep assertions active. Do not add a codec field, weaken body checks, enlarge a heap, or change GC policy as a speculative correction.

