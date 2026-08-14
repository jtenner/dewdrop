# Function ABI plans

## Status

Implemented as deterministic backend-neutral callable signatures for builtins, top-level functions, trait requirements, and impl methods. Program linking now closes generic demand transitively and materializes concrete functions by canonical Wasm carrier vector. Equivalent source shapes such as `I8`, `U32`, and `I32` share the `i32` specialization. Each specialized function retains a deterministic `<DeclId>:<carrier,...>` ABI key; unspecialized generic recipes are never emitted. Every public generic in the root module instead receives one public all-reference specialization under its source export name. Escaping exact nominal references use a private static-to-erased adapter only when their concrete callable signature differs from that fallback.

## API

```moonbit
pub fn plan_module_functions(
  CollectedModule,
  ResolvedModuleTypes,
) -> PlannedModuleFunctions
```

Stable lookup uses `PlannedModuleFunctions::callable_of(DeclId)`.

## Callable kinds

Plans distinguish:

```moonbit
PlannedBuiltinCallable(Bytes)
PlannedFunctionCallable(BodyId)
PlannedTraitMethodCallable(DeclId)
PlannedImplMethodCallable(DeclId, BodyId?)
```

Builtin plans retain the host registry name. Executable functions and impl methods retain exact body identity. Trait requirements retain their owning trait for future dictionary layout. An optional impl-method body permits future foreign/external implementations without changing plan identity.

## Signature recipes

Every callable retains:

- exact declaration identity, source name, and semantic visibility;
- containing trait/impl generic span;
- declaration-local generic span;
- exact parameter span;
- receiver presence;
- contextual impl target type and receiver shape;
- normalized result type and shape;
- source offset.

Every parameter retains exact `ParameterId`, declaration, source index, receiver flag, normalized `ResolvedTypeId`, runtime value shape, and source offset.

The stable order is the existing source-ordered `CollectedModule.callables` arena. `callable_by_declaration` provides constant-time lowering lookup without assigning final Starshine indices.

## `Self` and ABI shapes

Impl method signatures preserve their original normalized type recipe but substitute the containing impl target when computing ABI shape for `Self`.

Therefore:

- `self` in `impl Item` has reference shape;
- `self` in `impl I32` has `i32` shape;
- `self` in a generic aggregate impl remains reference shape;
- trait requirement `Self` remains generic until dictionary/erasure ABI selection.

Trait-level and impl-level generics remain rigid signature recipes during module function planning. Program fragment linking materializes demanded generic function copies after whole-program call and function-reference reachability is known.

## Determinism and performance

Planning scans callable and parameter arenas once. It reuses stable parameter spans and does not inspect executable expression bodies. A 1,024-method module remains iterative.

Release-mode measurements:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| 512 generic functions | 42.98 µs | 25.48 µs | 76.73 µs | 144.37 µs |
| 512 impl methods | 48.55 µs | 31.32 µs | 94.54 µs | 171.03 µs |
| Collect, resolve, and plan 256 functions | 749.80 µs | 693.63 µs | 1.29 ms | 2.30 ms |

## Closure ABI extension

Concrete closure entries use canonical environment-first signatures `(eqref, parameters...) -> result`. Program linking coalesces these independently from direct signatures. First-class values use an open WasmGC closure base containing one abstract function reference. Named references instantiate that base directly; each lambda instantiates a final subtype that stores its captures after the inherited entry field. Calls evaluate the target once, test whether the entry has the source direct signature, and select a typed direct or environment-first `call_ref` branch. The environment-first branch passes the flattened closure object itself.

## Erased generic callable boundary

A public generic owned by the linked root module materializes an all-reference specialization whose ABI key uses `eqref` for every generic parameter. That specialization retains the source name and public visibility; the unspecialized recipe remains elided. Dependency-module public generics do not add dead fallback functions to the final executable.

When an escaping generic reference expects an exact nominal signature such as `fn(Item) -> Item`, but carrier canonicalization selected `(eqref) -> eqref`, the linker emits one private adapter for the exact structural signature. The adapter passes exact GC references directly into the erased fallback and casts erased reference results back to the frozen nominal type. Singleton closure globals and declarative element entries point at the adapter, not the incompatible fallback. Physically identical scalar function references continue to use their specialized function directly and receive no redundant closure adapter.

For every demanded scalar specialization of a public root generic whose supported generic occurrences require representation conversion, the linker additionally exports a deterministic `<name>$dew$<carrier,...>` adapter. Five immutable one-field WasmGC box families cover `i32`, `i64`, `f32`, `f64`, and `v128`. Direct scalar parameters/results are boxed around the all-`eqref` fallback. A direct generic field inside a struct receives a boundary-only clone: static-to-erased conversion reads the selected scalar carrier slot, boxes it into the aggregate's `eqref` slot, and erased-to-static conversion unboxes it back into the selected slot while deterministically zeroing the unused slots. Conversion descends through nested generic struct and enum graphs. Enum conversion reads the shared base tag once per dispatch branch, reconstructs the exact payload subtype, converts tuple and struct payload leaves, and recursively converts nested nominal payloads. For cyclic nominal type graphs, the backend discovers repeated instantiated declarations in deterministic callable/type/field order and emits private direction-specific `(ref Nominal) -> (ref Nominal)` conversion helpers after ordinary functions and initialization. Inline conversion calls those helpers only at cycle edges; each helper reconstructs one runtime node before recurring, so finite recursive values terminate while type-level cycles no longer require finite compiler cloning. Deterministic `eqref` scratch locals preserve evaluate-once behavior and reconstruction proceeds from leaves outward. Ordinary Dew calls still target unboxed specializations, so these allocations and helper calls occur only at explicit erased boundaries. Box and helper types are emitted only when demanded.

Generic signature instantiation descends through structural function types instead of treating `fn(...) -> ...` as rigid. Specialized bodies therefore select carrier-correct direct and environment-first callback signatures and result block types. Export adapters synthesize final flattened closure subtypes for structural callback parameters and results. Each wrapper stores the target closure once after the inherited entry field, converts visible arguments into the captured callback's representation, tests the captured entry's direct signature, and dispatches through the matching direct or environment-first typed `call_ref`. Results are converted back to the wrapper-visible representation. Generic scalar leaves use the existing lazy box families, while callback parameters/results nested inside another callback signature receive direction-correct recursive wrappers rather than a second callable ABI. Recursive struct and enum reconstruction also recognizes function-valued fields and payloads, stores each source callback in a deterministic scratch local, and inserts the direction-correct wrapper into the reconstructed nominal value. Function-value calls that depend on member inference remain pending until fields are instantiated, and lowering structurally recovers the matching concrete resolved function type from a frozen `BodyFunctionType`; instantiated struct fields and enum pattern bindings therefore execute with exact typed `call_ref` signatures.

A public root generic whose symbolic bounds are used to construct erased trait values or invoke direct bound methods/operators receives an evidence-carrying all-reference fallback. Ordinary physical parameters remain first and one `eqref` vtable parameter per source-ordered bound is appended afterward. Trait coercions cast the hidden parameter to the exact typed vtable before constructing the object. Static bound calls evaluate their visible operands first, load the same vtable, select the source-ordered typed method field, and execute `call_ref` without an intermediate envelope. Direct bound evidence also forwards through private, recursive, and imported generic calls. Each target specialization compacts its demanded runtime dictionaries into contiguous trailing parameters after its own physical source parameters; each specialized call records the caller-local evidence indices and appends those immutable locals only after every visible argument has evaluated. When a target bound selects a concrete generic implementation whose prerequisites still come from runtime evidence, the same normalization and forwarding path recursively preserves the complete ordered evidence tree, specializes every exact implementation method, and supplies the leaf runtime dictionaries directly. Recursive evidence copying stages direct child indices after descendants so each frozen prerequisite span retains its intended tree level. A core-Wasm consumer can therefore define structurally equivalent trait/vtable/object types and supply its own receiver and `ref.func` implementation without exposing GC references to JavaScript.

Bounded generic function references use the same exact evidence requests as direct calls. When a reference occurs inside a generic specialization, link planning records the caller body and specialization identity, source expression, exact target specialization identity, and ordered caller-local runtime-evidence parameter indices. Backend planning emits a final subtype of the common closure base whose inherited field is the trampoline `ref.func` and whose remaining immutable `eqref` fields capture those dictionaries in source-bound order. The environment-first trampoline receives the closure plus visible callback arguments, evaluates those arguments before loading capture fields, casts the environment to the exact subtype, appends the captured dictionaries, and directly calls the already materialized target specialization. Closed generic callers use a zero-capture subtype/trampoline so a generic-body reference still selects the exact evidence-aware target rather than a carrier-only singleton. Same-module and imported targets use the same representation. The structural callback ABI remains unchanged, and an external core-Wasm consumer can call an exported `reader<t: Value>() -> fn(t) -> I32`, pass its own vtable, receive the closure as `eqref`, and invoke the captured callback. Malformed capture spans, missing caller specializations, and missing target specializations fail visibly before type/code emission.

Erased concrete implementations with caller-local prerequisites preserve the existing V1 trait-object and vtable ABI. The linker resolves the complete concrete evidence tree, normalizes its runtime leaves into source-ordered caller parameter indices, materializes the exact implementation-method specialization, and records the capture span on the specialized dictionary. At coercion, the backend first boxes scalar receivers when required, then allocates one immutable capture struct `{ receiver: eqref, evidence_0: eqref, ... }`. The ordinary trait object stores that capture struct in its receiver field and continues to reference a shared typed-funcref vtable. A private adapter casts the receiver field to the exact capture type, restores the concrete receiver, evaluates ordinary method arguments, loads evidence fields in order, and directly calls the exact implementation specialization. No vtable signature, external hidden-parameter order, or dynamic `call_ref` ABI changes. Generic dictionary templates with unresolved source parameters remain planning recipes only: they emit neither dead adapters nor startup globals. Malformed capture spans fail before type/code emission.

Program linking computes transitive total/discardable summaries before callback and runtime-trait directization. A summary is accepted only when the callable's complete reachable expression tree contains total local operations and calls to already summarized callees; recursive, trapping, mutating, dynamic, callback-invoking, or unknown calls remain unsummarized. Callback summaries follow immutable aliases and exact transitive forwarding chains, including imported public APIs. Runtime-trait summaries may cross ignored total helper preludes and same-evidence control flow. Internal exact callers are rewritten while public wrapper bodies and their original ABI remain available for external callers. Escaping, returned, captured, conditionally/multiply invoked, and differing-evidence values retain the ordinary closure or trait-object representation.

Frozen exported callables carry V4 SHA-256 ABI fingerprints, public nominal declarations carry V2 fingerprints, and module-interface content uses the V2 domain while remaining persisted in frozen-interface/cache V12. Callable V4 includes the `DEW_RUNTIME_TRAIT_EVIDENCE_ABI_V1` domain marker. The executable `dew.abi` compatibility record advances its language version to 2. In addition to module path, source export name, normalized parameter/result type trees, physical shapes, ordered fields/variants, and schema identities, every fingerprint writes each generic parameter's ordered trait bounds. Exported implementation records write their owner bounds before the trait and target type trees and canonicalize owner parameters by relative ordinal. Bound-only API changes therefore invalidate callable, nominal, implementation, and transitive interface fingerprints, while independently assigned module and declaration IDs remain irrelevant. Explicit compatibility negotiation remains necessary.

`tools/dew-abi.mjs` is the scalar executable host consumer. `list` discovers and deterministically sorts valid `<source>$dew$<carrier,...>` function exports. `call` selects one source/carrier vector, performs explicit `i32`/`i64`/`f32`/`f64` JavaScript conversion, invokes `__dew_init` once, calls the adapter, and emits normalized JSON. It rejects `v128` because the JavaScript WebAssembly API cannot invoke it and rejects `eqref` because aggregate/reference values require an in-Wasm package consumer.

`tools/dew-wasm-consumer.mjs PROVIDER_WASM CONSUMER_WASM EXPORT RESULT_TYPE [EXPECTED_PROVIDER_PATH EXPECTED_INTERFACE_FINGERPRINT]` validates the provider's required `dew.abi` record before instantiation, optionally enforces an exact module/interface identity, invokes exported `__dew_init` exactly once, and then instantiates a Wasm consumer with the provider exports under the `dew` import namespace. The focused `tests/abi-consumers/generic-aggregate-callback-i32.wat` and `generic-enum-callback-i32.wat` consumers define structurally equivalent aggregate, enum-subtype, and flattened-closure types. They construct direct `i32` callbacks, import `identity_box$dew$i32` or `identity_choice$dew$i32`, and call the callbacks returned by the static-to-erased-to-static adapter paths. `generic-eqref-identity.wat` constructs an exact nominal struct, invokes the public `(eqref) -> eqref` fallback, casts the result back to that struct, and reads its scalar field. `generic-v128-identity.wat` constructs a SIMD vector, invokes `identity$dew$v128`, and extracts lane zero after the adapter's box/fallback/unbox path. `runtime-trait-evidence-i32.wat` defines its own receiver, method, vtable, trait-object, and closure-base types. It supplies its vtables to direct static-bound, recursively prerequisite-bearing static, erased, callback-capture, and erased-dictionary-capture exports. One erased path captures a single consumer dictionary beneath two concrete implementation layers; another captures two ordered dictionaries and computes `value * 10 + other`, so reversing the fields changes the observable result. The consumer produces `673`, including `421` from that ordered two-dictionary path. The `tests/abi-consumers/imported-package` manifest builds a multi-module provider whose root adapter uses an imported generic callback aggregate; the existing aggregate consumer links against that provider without changing its structural import type. JavaScript observes only the final scalar result; all `eqref`, closure, trait dictionary, variant, and `v128` values remain inside Wasm.

## Current boundary

Directization/reachability pruning, stable symbolic ABI identities and
compatibility negotiation, recursive generic aggregate/callback conversion, and
verified package recovery are implemented. Remaining ABI work is tracked in
`docs/roadmap.md`: equivalent-signature deduplication, explicit Wasm/JavaScript
interop, the supported runtime baseline, and incremental artifact reuse.
