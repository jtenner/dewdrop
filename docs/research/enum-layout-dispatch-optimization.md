# Enum layout and dispatch optimization

## Status

The first post-assembly enum optimization pass is implemented for non-generic WasmGC enums. Tagged envelopes and automatic representation selection have subsequently been removed. Optimized subtype families are now the sole production enum ABI.

Implemented optimizations include:

- exact subtype-shape sharing within one enum base;
- recursive exact-shape sharing;
- unit-variant reuse of the subtype base;
- shared match continuations through result locals and exit blocks;
- dense `br_table` dispatch for suitable unguarded matches;
- a reusable Wago Wasm 3 benchmark harness.

Generic specialization, nested/alternative pattern emission, and cache serialization are implemented by later phases. Measured representation specialization maps proven private unit-only body locals and direct parameter/results to `i32` tags, and proven private unit-or-single-`I32`-payload parameter/results to a packed `i64`. Deeper recursive partition refinement and broader public/generic/function-value payload ABIs remain open.

## Planning controls

`WasmGCPlanningOptions` now freezes only subtype layout and dispatch controls:

```moonbit
pub enum WasmEnumShapeSharing {
  DistinctEnumShapes
  ShareExactEnumShapes
}
```

The remaining policies are:

```moonbit
WasmGCPlanningOptions::subtype_families()
WasmGCPlanningOptions::optimized_subtype_families()
```

The baseline policy retains distinct variant subtypes and linear dispatch solely for controlled measurements. Module and program planning default to the optimized policy: exact shape sharing, unit-base reuse, and dense dispatch.

## Representation-neutral variant field plans

Physical type sharing requires separating source-variant field identity from the representative emitted type.

Module fragments now freeze:

```moonbit
pub struct PlannedWasmVariantField {
  role : PlannedWasmFieldRole
  physical_index : Int
}

variant_field_spans : Array[HirSpan]
variant_fields : Array[PlannedWasmVariantField]
```

Every source variant retains its own tuple source indices or struct `FieldId` values even when several variants map to one emitted physical type. Construction and pattern extraction therefore do not depend on the representative variant's semantic fields.

`payload_type_index_by_variant` may contain the same type index for multiple variants. Unit subtype variants may map directly to the enum base type index.

## Exact shape sharing

Shape equivalence is deliberately exact and deterministic.

Tuple payloads share when they have the same number of source payload types and each consumer-local resolved type ID is equal in order.

Struct payloads share when they have the same number of fields and each field has the same resolved type and planned Wasm value shape in order. Source field names and `FieldId` values do not affect physical shape identity.

The first source variant with a shape owns the emitted type. Later variants map to that type but retain independent variant-field plans.

Map iteration never determines output order. Variants are visited in source order and the first matching source wins.

## Sharing scope

A variant subtype has one declared enum base. Exact subtype sharing is therefore restricted to variants of the same enum declaration.

Different enum bases retain distinct physical subtypes even when payload storage is identical. A focused 64-enum repeated-shape workload emits in 27.51 us, confirming that retaining one base-specific subtype per enum remains inexpensive enough relative to the runtime advantage.

## Recursive shapes

Exact recursive sharing works when source variants contain the same resolved nominal references. The representative source contributes the physical dependency edges, which are identical under exact equality.

This is intentionally not a general recursive structural-equivalence or partition-refinement algorithm. It handles equal resolved recipes without attempting to prove equivalence between differently named recursive graphs.

## Unit base reuse

Optimized subtype families do not emit distinct types for physically empty unit variants.

Instead:

```text
VariantId -> enum base type index
```

Construction stores the source-order tag and allocates the non-final base directly. Match dispatch continues to use the tag, so runtime source identity is preserved.

This reduces a unit-heavy enum from:

```text
one base + one subtype per unit variant
```

to:

```text
one base
```

without changing the enum ABI.

## Tagged-envelope retirement

Automatic selection and its whole-program override map were removed with tagged envelopes. The policy had only one plausible envelope case: unit-only enums.

A final 32-variant all-unit check through Wago measured the optimized subtype base at:

```text
encoded size: 538 bytes
execution:    1037.54-1072.78 ns/call
```

The previous optimized envelope result was:

```text
encoded size: 541 bytes
execution:    approximately 1154.91 ns/call
```

Unit-base reuse was therefore smaller and about 7-10% faster in this targeted run. No production case remained where automatic selection chose a preferable envelope layout.

## Match continuation factoring

The first executable match emitter nested complete fallback trees. A guarded arm could therefore embed the remaining arm chain in both its tag-mismatch and guard-false branches.

The optimized emitter allocates:

- one scrutinee `eqref` scratch local;
- one result local when the match returns a Wasm value.

Each successful arm stores the result and branches to one shared outer exit block. Guard failure falls through to the next arm.

This removes fallback-tree duplication while preserving source arm and guard order.

Controlled guarded full-pipeline measurements improved from:

```text
tagged envelope: 225.54 us -> 214.05 us
subtype family:  226.63 us -> 216.58 us
```

approximately 5.1% and 4.4% respectively in adjacent runs.

## Dense tag dispatch

Dense dispatch is selected when:

- the policy enables dense enum dispatch;
- there are at least two arms;
- every arm has one selected variant;
- no arm has a guard;
- tags are unique;
- tags cover the dense range `0 .. arm_count - 1`;
- no catch-all or duplicate-tag arm is present.

The emitter builds nested case blocks and one `br_table`. Each case initializes bindings, stores the result, and branches to the shared match exit.

Matches that do not satisfy these conditions retain the factored source-ordered linear chain.

The historical envelope comparison for a 32-variant unit enum measured:

```text
linear emitted binary: 878 bytes
dense emitted binary:  541 bytes
linear Wago execution: 5731.38 ns/call
dense Wago execution:  1154.91 ns/call
```

After envelope removal, the optimized subtype-only dense module is 538 bytes and executes in 1037.54-1072.78 ns/call. Current compiler-side emission measures:

```text
distinct subtype plus linear dispatch: 23.55 us
shared subtype plus dense dispatch:    18.00 us
```

The optimized path is both faster to emit and faster to execute for this unit-heavy workload.

## Compiler performance after shape sharing

Current subtype-only measurements for a 32-variant imported enum where every payload has the exact `I32` shape are:

```text
distinct subtype module emission: 11.27 us
optimized subtype emission:        4.75 us
optimized full pipeline:         208.16 us
```

The default production path measured 4.70 us emission and 208.24 us for the full validated binary pipeline. Exact sharing therefore removes substantial type-section planning, emission, validation, and encoding work.

Stable linking for 64 enum modules measured:

```text
default optimized subtype: 55.03 us
distinct subtype:          56.88 us
explicit optimized subtype:56.16 us
```

A module containing 64 unrelated enum bases with the same single-field payload shape emits in 27.51 us. Cross-base sharing is therefore not required to keep the repetitive cross-enum case inexpensive.

## Historical encoded-size evidence

The final dual-representation comparison for four variants with identical `I32` payload shapes was:

```text
distinct envelope: 354 bytes
distinct subtype:  341 bytes
shared envelope:   342 bytes
shared subtype:    314 bytes
automatic:         314 bytes
```

This evidence contributed to envelope removal. The active compiler now emits only the optimized subtype form.

## Wago Wasm 3 integration

A reusable harness lives at:

```text
tools/wago-enum-bench/
```

It uses the sibling Wago `wasm3` branch through the Go API with:

```go
NewRuntimeConfig().WithCoreFeatures(CoreFeaturesV3)
```

The harness reports:

- encoded bytes;
- cold compile nanoseconds and Go allocation bytes;
- instantiate nanoseconds and Go allocation bytes;
- execution nanoseconds and Go allocation bytes;
- a result checksum.

The current Wago branch forces general generated WasmGC code into a bounded, collection-disabled throughput heap because native frame roots are not published at every helper safepoint. The harness therefore supplies an explicit throughput heap size. Heap exhaustion remains a visible benchmark failure.

## Historical Wago representation results

The four-identical-payload workload was measured over three repeated rounds of one million calls after warmup.

Observed execution ranges:

```text
distinct envelope: 3290.66-3394.09 ns/call
distinct subtype:  1128.75-1205.84 ns/call
shared envelope:   3301.38-3381.16 ns/call
shared subtype:    1120.43-1208.91 ns/call
automatic:         1150.60-1171.80 ns/call
```

Subtype execution was approximately 2.8-3.0x faster than envelope execution in this Wago branch. Shape sharing primarily improved compile-time metadata and encoded size; it did not change the envelope's two-allocation runtime cost.

Reported Go allocation volume per host invocation was approximately:

```text
envelope: 21,500 B/call
subtype:   5,397 B/call
```

This includes Wago API/result and generated GC-helper behavior, not just Dew object bytes. The stable difference nevertheless reflects materially less runtime work on the subtype path.

Cold compile measurements were noisy but generally favored shared subtype modules because they contain fewer physical type definitions. Instantiation differences were smaller and less stable than execution differences. These results, together with the all-unit follow-up, led to deleting the envelope implementation rather than retaining a permanent representation switch.

## Remaining optimization boundaries

The following are not yet implemented:

- broader public, generic, function-value, method, imported, multi-field, nested, or non-`I32` scalar-payload representations and adapters;
- generic specialization and erased adapters;
- deeper recursive structural partition refinement;
- nested and alternative pattern code generation;
- full local-lifetime coalescing across nested guarded matches;
- payload-load CSE across nested pattern trees;
- imported-interface-aware exhaustiveness and dead-default removal;
- persistent storage of optimized fragments.

Persistent and cached compilation artifacts are intentionally the next separate design discussion.
