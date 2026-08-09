# Runtime trait values

## Status

Runtime trait values execute end to end for non-generic object-safe traits over nominal reference, scalar, packed, and SIMD receivers, including traits, implementations, methods, and concrete receiver types imported from another linked module. Bare trait names in value positions denote erased trait values. Concrete expressions crossing an expected trait boundary freeze exact coherent implementation evidence, construct a WasmGC trait object, and dispatch source-ordered methods through an immutable typed function-reference dictionary and `call_ref`.

Static calls on concrete receivers retain the existing direct-call path and do not plan trait layouts, dictionaries, adapters, globals, or `call_ref` sites.

Generic prerequisite-bearing dictionaries and escape-based devirtualization remain subsequent execution milestones. Mutable scalar and trait-object identity/equality semantics are now defined below; no source operation exposes either capability yet.

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

Each demanded coherent `(trait, implementation)` pair receives one private dictionary global. Program startup initializes the dictionary exactly once from source-ordered adapter `ref.func` values. Every trait-object construction evaluates its concrete receiver once and loads the shared dictionary global. Reference receivers allocate only the two-field trait-object envelope. Scalar, packed, and SIMD receivers first allocate one immutable single-field carrier box (`i32`, `i64`, `f32`, `f64`, or `v128`) and place that box in the envelope's erased receiver field.

Nominal receiver adapters have the erased requirement ABI and cast receiver parameter zero from `eqref` to the exact nominal implementation type. Scalar/SIMD adapters cast to the carrier-specific box and load field zero before the direct implementation call. Both forms forward ordinary arguments in source order. Imported trait requirements are reconstructed from frozen callable metadata in the consumer's resolved arena, while imported implementation methods and receiver nominals retain their provider identities. Program linking maps the adapter's external cast and direct call to the provider's final type and function indices. Adapter functions are rooted through a declarative element segment because trait-object construction uses `ref.func`; no runtime Wasm table is emitted.

A dynamic call evaluates the trait object once into an `eqref` scratch local, loads receiver field zero, evaluates ordinary arguments in source order, loads the exact typed method field through the vtable, and emits `call_ref` with the same method-signature type.

## Mutation, identity, and equality semantics

A scalar-to-trait conversion is a value snapshot. The box belongs to the resulting trait value and is never an alias back to the originating scalar local, parameter, field, or module value. Consequently, a future mutable receiver operation may mutate only that owned box; it must not write a changed scalar back through the conversion source. The current language has no mutable receiver form, so emitted carrier boxes remain immutable.

Trait-object reference identity is not a language-observable operation. Copying a trait value preserves its runtime envelope reference, while performing a second concrete-to-trait conversion may allocate a distinct envelope and, for scalars, a distinct box. Programs cannot distinguish those cases through ambient identity. There is also no universal trait-object value equality: equality must come from an explicitly object-safe semantic operation. The current `Eq` shape uses `Self` outside the receiver and is therefore intentionally not dynamically callable.

Dictionary identity is an implementation detail and never defines value equality. Two trait values may share one dictionary while containing unrelated receivers.

## Determinism and static fast path

Trait layouts follow first source use and trait declaration method order. Dictionaries are keyed by exact trait and implementation declarations. Adapter, function, type, global, and element ordering is deterministic through the existing module and program planners.

Programs containing only concrete trait calls receive none of the runtime trait-value machinery. The static regression fixture contains no `call_ref`, dictionary global, vtable, trait-object type, or adapter.

## Validation

Coverage includes:

- nominal-to-trait coercion with frozen concrete implementation evidence;
- boundary-only `i32`, `i64`, `f32`, `f64`, packed, and `v128` carrier boxes;
- deferred coercion selection for explicit constructors;
- dynamic requirement and source-order slot identity;
- rejection of `Self` outside the receiver at dynamic call sites;
- typed multi-method vtable fields;
- one shared dictionary global initialized with declarative `ref.func` adapters;
- two dynamic `call_ref` sites over one trait object;
- direct static trait dispatch with no dynamic machinery;
- imported trait requirements, implementation methods, nominal receivers, dictionaries, and adapters;
- identical runtime output and WAT under Node and Wago Core 3.

The local dynamic fixture prints `42|7|trait:value`; the paired nominal static fixture prints `42|trait:static`; the imported dictionary fixture prints `42|trait:imported`; the five-carrier scalar/SIMD fixture prints `12345|trait:scalars`; and the paired scalar static fixture prints `42|trait:scalar-static` without boxes, dictionaries, `ref.func`, or `call_ref`.
