# Runtime trait values

## Status

Runtime trait values execute end to end for non-generic object-safe traits over nominal reference, scalar, packed, and SIMD receivers, including traits, implementations, methods, and concrete receiver types imported from another linked module. Bare trait names in value positions denote erased trait values. Concrete expressions crossing an expected trait boundary freeze exact coherent implementation evidence, construct a WasmGC trait object, and dispatch source-ordered methods through an immutable typed function-reference dictionary and `call_ref`.

Static calls on concrete receivers retain the existing direct-call path and do not plan trait layouts, dictionaries, adapters, globals, or `call_ref` sites.

Symbolic trait erasure inside generic bodies now executes for every closed linked specialization. Transparent parameter-return bodies, including explicit `return`, propagate the caller's exact evidence and concrete carrier so downstream exact flows remove the generic wrapper, envelope, box, dictionary, adapter, global, `ref.func`, and `call_ref`. Genuinely dynamic generic branches resolve the caller's bound slot through specialization evidence, reconstruct recursive prerequisites, and materialize one exact dictionary plus evidence-aware implementation-method specialization. This works for nominal, scalar, packed, SIMD, prerequisite-bearing, and imported-provider cases.

Public root generics whose symbolic bounds are used at erased trait-object coercions or direct bound methods/operators now receive a runtime-evidence fallback ABI. Every generic carrier remains `eqref`, followed by one trailing `eqref` vtable parameter per declared bound in source order. External Wasm consumers can construct structurally equivalent typed vtables, pass arbitrary consumer-owned receiver objects, invoke static bound operations directly through those vtables, and dynamically invoke returned trait values. Direct bound evidence forwards through private, recursive, and imported generic call chains. Mutable scalar and trait-object identity/equality semantics are defined below; no source operation exposes either capability yet.

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

## External runtime-evidence ABI

The V1 external ABI is intentionally explicit. A supported public root generic uses an all-reference carrier specialization. Its ordinary visible parameters come first; hidden evidence parameters follow in flattened generic-parameter/bound order. Each evidence parameter has the core Wasm type `eqref`, but a use site casts it to the exact trait vtable type before object construction or method-field access. Root runtime specialization evidence records `(trait declaration, absolute parameter index)`, so backend emission never re-resolves a trait or guesses parameter order.

For example, `pub fn choose<t: Value>(Bool, t) -> Value` exports `(i32, eqref, eqref) -> eqref`, while `pub fn read<t: Value>(t) -> I32`, `pub fn boxed_read<t: Value>(t) -> I32`, and `pub fn nested_read<t: Value>(t) -> I32` each export `(eqref, eqref) -> i32`. `pub fn reader<t: Value>() -> fn(t) -> I32` exports `(eqref) -> eqref`: its result is an evidence-capturing closure. `erased_nested<t: Value>(t) -> Inspect` and `erased_pair<t: Value + OtherValue>(t) -> PairInspect` return erased objects whose concrete adapters retain one or two consumer dictionaries. A separate Wasm consumer defines structurally equivalent method-signature, vtable, object, receiver, closure-base, and callback-entry types and places its own `ref.func` implementations in the vtables. The permanent provider is multi-module and exercises direct forwarding, recursively nested concrete prerequisites, callback capture, a one-leaf erased capture beneath two concrete implementation layers, and a source-ordered two-dictionary erased capture. The last path computes `value * 10 + other`, making reversed evidence observable. The consumer returns `673`, including `421` from the ordered two-dictionary path.

Fallback planning derives every declared bound from the frozen callable interface, includes the runtime evidence requirement in specialization identity, and appends hidden parameters only after all source parameters. A direct bound method/operator evaluates its receiver and arguments in source order, loads the runtime vtable parameter, selects the source-ordered typed method field, and executes `call_ref` without allocating a trait envelope. At a nested generic call, runtime evidence nodes are normalized into contiguous callee slots; the call record separately retains the caller's absolute local indices and appends those immutable evidence values after every visible argument has evaluated. This supports private, recursive, and imported chains without inheriting the caller's physical parameter numbering. Evidence classification distinguishes fully concrete roots, direct runtime dictionaries, and concrete implementations with runtime prerequisites. The last form is recursively legal for static bound dispatch: linker materialization preserves every ordered concrete prerequisite node, specializes each exact implementation method, and forwards the leaf runtime slots. Evidence-copy helpers stage direct children separately from recursively emitted descendants before recording each prerequisite span; this prevents a parent from accidentally pointing at a grandchild and losing an implementation layer.

Function-reference inference freezes target obligations as expression evidence. Link planning resolves that evidence in each caller specialization and records the exact target specialization plus ordered caller-local runtime dictionary indices. A surviving bounded reference allocates a final subtype of the common closure base: field zero is an environment-first trampoline and subsequent immutable `eqref` fields are the captured dictionaries. The trampoline evaluates visible callback arguments first, loads evidence fields in source-bound order, and directly calls the exact local or imported target specialization. Closed generic callers receive an evidence-aware zero-capture trampoline instead of reusing a carrier-only singleton. This preserves structural callback signatures, exact specialization identity, and deterministic evaluation while allowing returned, passed, or otherwise escaping callbacks to retain caller evidence.

An erased concrete implementation with runtime prerequisites uses an immutable receiver capture rather than changing the typed vtable. The capture fields are `{ concrete_receiver: eqref, prerequisite_0: eqref, ... }`; the ordinary trait object stores that capture as its receiver and continues to reference the shared method-only vtable. The selected adapter casts the capture, restores or unboxes the receiver, loads ordinary dynamic-call arguments, then appends prerequisite fields before directly invoking the exact implementation-method specialization. Runtime leaves are recursively normalized and deduplicated in source order, so nested concrete evidence trees store only their demanded caller dictionaries. Generic dictionary templates are non-runtime recipes and receive no adapter or startup global. The V1 external vtable ABI, callable fingerprint domain V4, and executable `dew.abi` language version 2 remain unchanged.

## Mutation, identity, and equality semantics

A scalar-to-trait conversion is a value snapshot. The box belongs to the resulting trait value and is never an alias back to the originating scalar local, parameter, field, or module value. Consequently, a future mutable receiver operation may mutate only that owned box; it must not write a changed scalar back through the conversion source. The current language has no mutable receiver form, so emitted carrier boxes remain immutable.

Trait-object reference identity is not a language-observable operation. Copying a trait value preserves its runtime envelope reference, while performing a second concrete-to-trait conversion may allocate a distinct envelope and, for scalars, a distinct box. Programs cannot distinguish those cases through ambient identity. There is also no universal trait-object value equality: equality must come from an explicitly object-safe semantic operation. The current `Eq` shape uses `Self` outside the receiver and is therefore intentionally not dynamically callable.

Dictionary identity is an implementation detail and never defines value equality. Two trait values may share one dictionary while containing unrelated receivers.

## Exact-flow devirtualization and escape analysis

Program lowering now tracks erased trait values with a conservative four-state analysis: pending, unknown/escaping, exact concrete evidence, or a forwarded parameter slot. Exact values retain the trait declaration, recursive evidence key, original body type, physical carrier shape, and nominal head. The analysis propagates through immutable and mutable locals whose assignments all agree, expression blocks, `if`/`match` joins, and transparent parameter-return selectors. A join remains exact only when every incoming path has the same trait, implementation/evidence tree, carrier, and nominal head; differing evidence remains dynamically dispatched.

A local is rewritten to its concrete representation only when every local read participates in an exact flow selected for directization, every assignment has the same exact evidence, and the local is not captured. This is the non-escaping classification. Other uses, captures, unknown assignments, symbolic generic evidence, and differing joins keep the trait-object representation. Rewriting updates the local and all demanded flow expressions together, so initializer evaluation timing, branch evaluation, and source argument order remain unchanged.

Dynamic calls and summarized forwarding chains with closed recursive evidence are rewritten to the exact implementation method. Generic owner carriers and ordered prerequisite roots are transferred to the ordinary specialization request, so prerequisite-bearing implementations use the same evidence-aware method specialization as static generic calls. Trait identity returns become parameter-select expressions that still evaluate every source argument in order. Program lowering computes a transitive total/discardable summary for local and imported callables whose complete expression tree contains only constants, reads, control-flow joins, parameter selection, and calls to already summarized total callees. A public wrapper may therefore contain ignored calls to such helpers without blocking exact internal directization; its public dynamic body remains emitted for external callers. Trapping, recursive, mutating, dynamically dispatched, callback-invoking, or otherwise unknown preludes remain observable and reject the summary.

Private identity, forwarding, and dynamic-call wrappers are removed when every remaining reference comes only from wrappers in the same dead chain. Generic parameter selectors participate in a fixed-point pass: a selector call transfers the callee's trait declaration and bound slot to the caller, preserves every argument evaluation, adopts the selected argument's type and shape, and becomes `PlannedParameterSelect`. Both tail expressions and a single explicit `return parameter` body qualify. Consequently, unused trait-object layouts, envelopes, scalar/SIMD boxes, dictionaries, adapters, globals, declarative `ref.func` roots, and `call_ref` sites are never planned. Public or imported generic declarations remain source-linkable through closed specializations. Supported public roots additionally export the V1 runtime-evidence fallback, including recursively prerequisite-bearing static and erased paths; only bodies with non-forwardable or malformed evidence still omit that fallback rather than exposing an incomplete ABI. Unknown or escaping flows retain ordinary dynamic dispatch.

## Optimization measurements

A release-native 256-call stress body whose calls all carry the same closed prerequisite evidence lowers in `20.40 ms ± 2.08 ms`. The contractual forwarding-chain fixture was also compiled with the exact-flow pass temporarily replaced by the preceding committed planner. The emitted binary shrank from 1,491 to 1,326 bytes (11.1%), and printed WAT shrank from 9,856 to 8,009 bytes (18.7%). The baseline contained one dictionary global, one `ref.func`, one `call_ref`, and five `struct.new` sites; the optimized fixture contains none of the dynamic operations and only three unrelated application/runtime allocation sites. This removes one per-call trait envelope allocation plus the one-time dictionary construction site.

The symbolic-erasure suite includes release-native 256-call link benchmarks. Two post-forwarding runs measured:

- closed generic erasure: `3.04–3.27 ms`;
- genuinely dynamic generic erasure plus its public V1 evidence fallback: `3.30–3.84 ms`;
- external runtime-evidence forwarding through a concrete generic prerequisite: `3.18 ms ± 65.06 µs`;
- external runtime-evidence forwarding through two recursively nested concrete prerequisites: `3.97 ms ± 451.89 µs`;
- external runtime-evidence captured dictionaries across 256 closed calls plus one public fallback: `3.55 ms ± 35.73 µs`;
- binary emission for 256 evidence-aware bounded function references: `7.90 ms ± 212.50 µs`;
- reverse-ordered transitive public effect summaries at depth 256: `9.87–10.54 ms` across two runs.

A Node development probe that repeatedly invokes the external one-leaf captured-dictionary path measured `1.72–1.87 ms` per 100,000 capture-and-dispatch operations after warmup. This is directional rather than a stable runtime budget.

The external runtime-evidence provider with direct, erased, recursively prerequisite-bearing, callback-capture, and erased-dictionary-capture paths is 1,923 Wasm bytes. Its contractual printed module contains four `call_ref` sites and fifteen `struct.new` sites. The captured-dictionary paths each add one receiver/evidence wrapper allocation at the erased boundary while retaining shared immutable vtable globals.

These host-sensitive reruns show that context-sensitive eligibility analysis, call-site evidence spans, imported trait-use collection, and recursive prerequisite-bearing implementation-method specialization remain below 5 ms on the measured workload; they are directional rather than stable performance guarantees.

The closed nominal/prerequisite snapshot emits 1,536 bytes of Wasm and 10,127 bytes of WAT with zero `call_ref`, `ref.func`, globals, tables, or dispatch allocation sites; its three `struct.new` operations are unrelated application/runtime values. The six-carrier dynamic snapshot emits 2,125 bytes of Wasm and 14,350 bytes of WAT with one shared `call_ref` site, six exact dictionaries/`ref.func` roots, no table, and 20 `struct.new` sites; the additional construction site is the externally callable runtime-evidence fallback. The recursive-prerequisite dynamic snapshot emits 1,629 bytes of Wasm and 10,746 bytes of WAT with one dictionary, one `ref.func`, one `call_ref`, no table, and four `struct.new` sites.

A Node WasmGC runtime probe executed ten million loop iterations per sample. The direct baseline measured `3.950 ms ± 0.096 ms`; closed generic erasure measured `3.368 ms ± 0.157 ms` and emitted zero boxes/envelopes/dictionaries; the genuinely dynamic form measured `182.416 ms ± 24.656 ms`, intentionally paying one erased box/envelope construction and typed indirect dispatch per iteration. The runtime numbers are host-sensitive and are retained as directional evidence rather than a stable performance guarantee.

Generic parameter-selector propagation originally recomputed every body summary and rescanned every expression until a fixed point. A forwarding chain of depth `D` therefore required up to `D` whole-program scans. The planner now builds one deterministic declaration-to-call-site index, seeds direct selectors in module/body order, and processes newly discovered transitive selectors through a source-ordered worklist. Each call-site record carries its optional root-body index, so the planner retains only sparse body and generic-call metadata rather than one dense root slot per expression. Every candidate call is rewritten at most once, and malformed spans or indices are rejected locally rather than indexing an arena unchecked. The release-native depth-256 benchmark improved from `72.82 ms ± 21.88 ms` to `19.33–23.54 ms` across two post-change runs, approximately 68–73% faster, while a permanent depth-64 regression proves complete devirtualization with zero materialized generic functions or runtime-trait artifacts.

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
- public root runtime-evidence exports whose static bound call and erased return are both exercised by a structurally typed external Wasm consumer;
- ordinary missing-evidence diagnostics at the closed call site;
- identical inferred coercion/evidence arenas under forward and reversed body schedules;
- prerequisite-aware generic direct calls with ordered recursive evidence;
- dead wrapper, envelope, scalar/SIMD box, dictionary, adapter, global, `ref.func`, and `call_ref` elimination;
- transitive total/discardable helper summaries across public and imported wrapper APIs;
- conservative retention for differing evidence joins, trapping/effectful wrapper conditions, and unknown calls;
- identical runtime output and WAT under Node and Wago Core 3.

The local dynamic fixture prints `42|7|trait:value`; the paired nominal static fixture prints `42|trait:static`; the imported dictionary fixture prints `42|trait:imported`; the five-carrier scalar/SIMD fixture prints `12345|trait:scalars`; the paired scalar static fixture prints `42|trait:scalar-static` without boxes, dictionaries, `ref.func`, or `call_ref`; local and imported generic-evidence fixtures print `427|trait:generic-dictionary` and `427|trait:imported-generic`; the scalar/nominal devirtualization fixture prints `427|trait:devirtualized`; and the prerequisite-bearing flow fixture prints `trait:flow-devirtualized`. The imported public-effect-summary fixture retains three dynamic `call_ref` sites for externally callable fallback bodies while its exact root caller creates no callback singleton, trait envelope, dictionary global, or `ref.func`; the complete fixture has zero globals, zero `ref.func`, and only two unrelated `struct.new` sites. The closed symbolic generic fixture prints `402|trait:open-generic-closed` with no dynamic artifacts; the six-carrier dynamic fixture prints `123456|trait:open-generic-dynamic`; the recursive-prerequisite fixture prints `42|trait:open-generic-prerequisite`; and the imported fixture executes one linked dynamic call in both Node and Wago. Both devirtualization WAT contracts and the closed symbolic generic contract contain zero dictionary globals, adapters, scalar/SIMD boxes, `ref.func`, or `call_ref`; the flow fixture also omits all three private forwarding wrappers.
