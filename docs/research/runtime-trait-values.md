# Runtime trait values

## Status

Runtime trait values execute end to end for non-generic object-safe traits over nominal reference, scalar, packed, and SIMD receivers, including traits, implementations, methods, and concrete receiver types imported from another linked module. Bare trait names in value positions denote erased trait values. Concrete expressions crossing an expected trait boundary freeze exact coherent implementation evidence, construct a WasmGC trait object, and dispatch source-ordered methods through an immutable typed function-reference dictionary and `call_ref`.

Static calls on concrete receivers retain the existing direct-call path and do not plan trait layouts, dictionaries, adapters, globals, or `call_ref` sites.

Symbolic trait erasure inside generic bodies now executes for every closed linked specialization. Transparent parameter-return bodies, including explicit `return`, propagate the caller's exact evidence and concrete carrier so downstream exact flows remove the generic wrapper, envelope, box, dictionary, adapter, global, `ref.func`, and `call_ref`. Genuinely dynamic generic branches resolve the caller's bound slot through specialization evidence, reconstruct recursive prerequisites, and materialize one exact dictionary plus evidence-aware implementation-method specialization. This works for nominal, scalar, packed, SIMD, prerequisite-bearing, and imported-provider cases. A standalone externally callable generic ABI that accepts runtime evidence for callers outside the linked program remains pending. Mutable scalar and trait-object identity/equality semantics are defined below; no source operation exposes either capability yet.

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

Each demanded coherent `(trait, implementation, evidence tree)` combination receives one private dictionary global. Program startup initializes the dictionary exactly once from source-ordered adapter `ref.func` values. Evidence identity includes concrete owner carriers and ordered prerequisite implementation trees, so generic uses with the same receiver carrier but different prerequisite selections never coalesce. Every trait-object construction evaluates its concrete receiver once and loads the shared exact-evidence dictionary global. Reference receivers allocate only the two-field trait-object envelope. Scalar, packed, and SIMD receivers first allocate one immutable single-field carrier box (`i32`, `i64`, `f32`, `f64`, or `v128`) and place that box in the envelope's erased receiver field.

Nominal receiver adapters have the erased requirement ABI and cast receiver parameter zero from `eqref` to the exact nominal implementation type. Scalar/SIMD adapters cast to the carrier-specific box and load field zero before the direct implementation call. Both forms forward ordinary arguments in source order. A generic implementation adapter calls the exact evidence-aware implementation-method specialization; its specialization key includes owner carriers and ordered prerequisite evidence. Imported trait requirements are reconstructed from frozen callable metadata in the consumer's resolved arena, while imported implementation methods and receiver nominals retain their provider identities. Program linking maps the adapter's external cast and direct call to the provider's final type and function indices. Adapter functions are rooted through a declarative element segment because trait-object construction uses `ref.func`; no runtime Wasm table is emitted.

A dynamic call evaluates the trait object once into an `eqref` scratch local, loads receiver field zero, evaluates ordinary arguments in source order, loads the exact typed method field through the vtable, and emits `call_ref` with the same method-signature type.

When a generic specialization crosses an erased boundary, linker materialization substitutes every `BoundInferredTraitEvidence` node through the caller's specialization-evidence forest before choosing a dictionary. Recursive prerequisite requests are copied in source order and participate in the same deterministic identity used by ordinary module-local dictionary planning. Materializing an adapter may recursively materialize the implementation method's evidence-aware specialization; module scalar counts are merged from the latest fragment state so same-module recursive materialization cannot overwrite newly added signatures or functions.

A trait layout demanded independently by a provider generic body and a consumer dynamic call is canonicalized program-wide by trait and requirement declaration identity. Method signature, vtable, and object physical nodes therefore receive one final type index across modules rather than relying on engine-specific structural-type canonicalization. This preserves identical behavior under Node and Wago Core 3.

## Mutation, identity, and equality semantics

A scalar-to-trait conversion is a value snapshot. The box belongs to the resulting trait value and is never an alias back to the originating scalar local, parameter, field, or module value. Consequently, a future mutable receiver operation may mutate only that owned box; it must not write a changed scalar back through the conversion source. The current language has no mutable receiver form, so emitted carrier boxes remain immutable.

Trait-object reference identity is not a language-observable operation. Copying a trait value preserves its runtime envelope reference, while performing a second concrete-to-trait conversion may allocate a distinct envelope and, for scalars, a distinct box. Programs cannot distinguish those cases through ambient identity. There is also no universal trait-object value equality: equality must come from an explicitly object-safe semantic operation. The current `Eq` shape uses `Self` outside the receiver and is therefore intentionally not dynamically callable.

Dictionary identity is an implementation detail and never defines value equality. Two trait values may share one dictionary while containing unrelated receivers.

## Exact-flow devirtualization and escape analysis

Program lowering now tracks erased trait values with a conservative four-state analysis: pending, unknown/escaping, exact concrete evidence, or a forwarded parameter slot. Exact values retain the trait declaration, recursive evidence key, original body type, physical carrier shape, and nominal head. The analysis propagates through immutable and mutable locals whose assignments all agree, expression blocks, `if`/`match` joins, and transparent parameter-return selectors. A join remains exact only when every incoming path has the same trait, implementation/evidence tree, carrier, and nominal head; differing evidence remains dynamically dispatched.

A local is rewritten to its concrete representation only when every local read participates in an exact flow selected for directization, every assignment has the same exact evidence, and the local is not captured. This is the non-escaping classification. Other uses, captures, unknown assignments, symbolic generic evidence, and differing joins keep the trait-object representation. Rewriting updates the local and all demanded flow expressions together, so initializer evaluation timing, branch evaluation, and source argument order remain unchanged.

Dynamic calls and transparent forwarding chains with closed recursive evidence are rewritten to the exact implementation method. Generic owner carriers and ordered prerequisite roots are transferred to the ordinary specialization request, so prerequisite-bearing implementations use the same evidence-aware method specialization as static generic calls. Transparent trait identity returns become parameter-select expressions that still evaluate every source argument in order. Wrapper summaries are accepted only when eliminating the wrapper cannot remove another call, mutation, loop, or other potentially effectful expression.

Private identity, forwarding, and dynamic-call wrappers are removed when every remaining reference comes only from wrappers in the same dead chain. Generic parameter selectors participate in a fixed-point pass: a selector call transfers the callee's trait declaration and bound slot to the caller, preserves every argument evaluation, adopts the selected argument's type and shape, and becomes `PlannedParameterSelect`. Both tail expressions and a single explicit `return parameter` body qualify. Consequently, unused trait-object layouts, envelopes, scalar/SIMD boxes, dictionaries, adapters, globals, declarative `ref.func` roots, and `call_ref` sites are never planned. Public or imported generic declarations remain source-linkable through closed specializations; their ordinary erased fallback export is omitted when the body needs symbolic runtime evidence because that external dictionary ABI is not yet defined. Unknown or escaping flows retain ordinary dynamic dispatch.

## Optimization measurements

A release-native 256-call stress body whose calls all carry the same closed prerequisite evidence lowers in `20.40 ms ± 2.08 ms`. The contractual forwarding-chain fixture was also compiled with the exact-flow pass temporarily replaced by the preceding committed planner. The emitted binary shrank from 1,491 to 1,326 bytes (11.1%), and printed WAT shrank from 9,856 to 8,009 bytes (18.7%). The baseline contained one dictionary global, one `ref.func`, one `call_ref`, and five `struct.new` sites; the optimized fixture contains none of the dynamic operations and only three unrelated application/runtime allocation sites. This removes one per-call trait envelope allocation plus the one-time dictionary construction site.

The symbolic-erasure tranche adds release-native 256-call link benchmarks:

- closed generic erasure: `25.61 ms ± 7.90 ms`;
- genuinely dynamic generic erasure: `27.23 ms ± 11.76 ms`.

The closed nominal/prerequisite snapshot emits 1,536 bytes of Wasm and 10,127 bytes of WAT with zero `call_ref`, `ref.func`, globals, tables, or dispatch allocation sites; its three `struct.new` operations are unrelated application/runtime values. The six-carrier dynamic snapshot emits 2,083 bytes of Wasm and 14,031 bytes of WAT with one shared `call_ref` site, six exact dictionaries/`ref.func` roots, no table, and 19 `struct.new` sites. The recursive-prerequisite dynamic snapshot emits 1,629 bytes of Wasm and 10,746 bytes of WAT with one dictionary, one `ref.func`, one `call_ref`, no table, and four `struct.new` sites.

A Node WasmGC runtime probe executed ten million loop iterations per sample. The direct baseline measured `3.950 ms ± 0.096 ms`; closed generic erasure measured `3.368 ms ± 0.157 ms` and emitted zero boxes/envelopes/dictionaries; the genuinely dynamic form measured `182.416 ms ± 24.656 ms`, intentionally paying one erased box/envelope construction and typed indirect dispatch per iteration. The runtime numbers are host-sensitive and are retained as directional evidence rather than a stable performance guarantee.

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
- generic implementation dictionaries keyed by distinct prerequisite evidence trees;
- exact-flow devirtualization through locals, branches, parameters, tail returns, explicit returns, and private forwarding chains;
- closed symbolic generic erasure with zero dynamic artifacts;
- dynamic symbolic generic erasure across nominal, scalar, packed, and SIMD carriers;
- recursive prerequisite dictionary reconstruction inside a generic specialization;
- imported public generic providers with canonical cross-module trait layouts;
- ordinary missing-evidence diagnostics at the closed call site;
- identical inferred coercion/evidence arenas under forward and reversed body schedules;
- prerequisite-aware generic direct calls with ordered recursive evidence;
- dead wrapper, envelope, scalar/SIMD box, dictionary, adapter, global, `ref.func`, and `call_ref` elimination;
- conservative retention for differing evidence joins and potentially effectful wrapper conditions;
- identical runtime output and WAT under Node and Wago Core 3.

The local dynamic fixture prints `42|7|trait:value`; the paired nominal static fixture prints `42|trait:static`; the imported dictionary fixture prints `42|trait:imported`; the five-carrier scalar/SIMD fixture prints `12345|trait:scalars`; the paired scalar static fixture prints `42|trait:scalar-static` without boxes, dictionaries, `ref.func`, or `call_ref`; local and imported generic-evidence fixtures print `427|trait:generic-dictionary` and `427|trait:imported-generic`; the scalar/nominal devirtualization fixture prints `427|trait:devirtualized`; and the prerequisite-bearing flow fixture prints `trait:flow-devirtualized`. The closed symbolic generic fixture prints `402|trait:open-generic-closed` with no dynamic artifacts; the six-carrier dynamic fixture prints `123456|trait:open-generic-dynamic`; the recursive-prerequisite fixture prints `42|trait:open-generic-prerequisite`; and the imported fixture executes one linked dynamic call in both Node and Wago. Both devirtualization WAT contracts and the closed symbolic generic contract contain zero dictionary globals, adapters, scalar/SIMD boxes, `ref.func`, or `call_ref`; the flow fixture also omits all three private forwarding wrappers.
