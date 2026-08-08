# Runtime trait values

## Status

Runtime trait values execute end to end for non-generic object-safe traits over nominal reference receivers. Bare trait names in value positions denote erased trait values. Concrete expressions crossing an expected trait boundary freeze exact coherent implementation evidence, construct a WasmGC trait object, and dispatch source-ordered methods through an immutable typed function-reference dictionary and `call_ref`.

Static calls on concrete receivers retain the existing direct-call path and do not plan trait layouts, dictionaries, adapters, globals, or `call_ref` sites.

Imported dictionaries, scalar/SIMD receiver boxes, generic prerequisite-bearing dictionaries, mutable scalar receiver semantics, trait-object identity/equality, and escape-based devirtualization remain subsequent milestones.

## Source and inference model

The initial source form uses an existing bare trait type:

```dew
fn invoke(value: Read) -> I32 {
  value.read()
}
```

Concrete-to-trait conversion is implicit only where an expected trait type exists. Inference records `SelectedInferredTraitObjectCoercion(trait, evidence)` on the source expression. Evidence is selected through ordinary visible coherent implementation lookup and retains the same recursive prerequisite tree used by static generic dispatch. Speculative implementation-selection diagnostics are rolled back so successful coercions do not leak candidate mismatches. Unresolved constructor and call results defer coercion selection until ordinary body constraints settle.

Calls on trait receivers record `SelectedDynamicTraitCallTarget(trait, requirement, slot, type_arguments)`. Slots count receiver-bearing trait requirements in deterministic trait source order. Concrete receivers continue to use `SelectedInferredCallTarget` and static implementation methods.

The initial object-safety check rejects dynamic methods with method-level generics or `Self` occurrences outside the receiver. Static use of those methods remains unaffected.

## Lowering contract

`PlannedExpression` retains its optional trait-object coercion independently of its ordinary expression kind, allowing a struct construction, call, local read, branch, or other value-producing expression to be wrapped without losing its original operation. Dynamic calls lower to `PlannedDynamicTraitCall` with exact trait, requirement, slot, receiver, ordinary arguments, and type arguments.

Backend planning consumes this frozen evidence and does not repeat trait resolution.

## WasmGC representation

Every demanded trait receives one deterministic method-signature type per object-safe receiver method, followed by an immutable vtable and object type:

```text
Method0Signature = func(eqref, ...) -> result
Method1Signature = func(eqref, ...) -> result

TraitVTable = struct {
  method_0: ref null Method0Signature
  method_1: ref null Method1Signature
}

TraitObject = struct {
  receiver: eqref
  vtable: ref TraitVTable
}
```

Method signature types are placed before the vtable in the Wasm type section, so the vtable fields are genuinely typed function references rather than abstract `funcref` fields. This avoids both Wasm tables and a dispatch-time function-reference cast.

Each demanded coherent `(trait, implementation)` pair receives one private dictionary global. Program startup initializes the dictionary exactly once from source-ordered adapter `ref.func` values. Every trait-object construction evaluates its concrete receiver once, loads the shared dictionary global, and allocates only the two-field trait-object envelope.

Nominal receiver adapters have the erased requirement ABI, cast receiver parameter zero from `eqref` to the exact nominal implementation type, forward ordinary arguments, and directly call the implementation method. Adapter functions are rooted through a declarative element segment because trait-object construction uses `ref.func`; no runtime Wasm table is emitted.

A dynamic call evaluates the trait object once into an `eqref` scratch local, loads receiver field zero, evaluates ordinary arguments in source order, loads the exact typed method field through the vtable, and emits `call_ref` with the same method-signature type.

## Determinism and static fast path

Trait layouts follow first source use and trait declaration method order. Dictionaries are keyed by exact trait and implementation declarations. Adapter, function, type, global, and element ordering is deterministic through the existing module and program planners.

Programs containing only concrete trait calls receive none of the runtime trait-value machinery. The static regression fixture contains no `call_ref`, dictionary global, vtable, trait-object type, or adapter.

## Validation

Coverage includes:

- nominal-to-trait coercion with frozen concrete implementation evidence;
- deferred coercion selection for explicit constructors;
- dynamic requirement and source-order slot identity;
- rejection of `Self` outside the receiver at dynamic call sites;
- typed multi-method vtable fields;
- one shared dictionary global initialized with declarative `ref.func` adapters;
- two dynamic `call_ref` sites over one trait object;
- direct static trait dispatch with no dynamic machinery;
- identical runtime output and WAT under Node and Wago Core 3.

The dynamic fixture prints `42|7|trait:value`; the paired static fixture prints `42|trait:static`.
