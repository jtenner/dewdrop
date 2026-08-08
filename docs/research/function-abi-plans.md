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

Frozen exported callables carry V2 SHA-256 ABI fingerprints, while public nominal declarations and complete reachable module-interface graphs carry content-sensitive V1 SHA-256 fingerprints persisted in frozen-interface/cache V9. The preimage includes explicit callable, box, and flattened-closure schema domains, module path, source export name, generic arity, normalized parameter/result type trees, and physical shapes. Generic parameters use callable-relative ordinals. Local and dependency nominal/trait identities use stable module path, declaration name, and generic arity when the declaration is visible through the frozen import scope, so independently assigned module IDs no longer perturb callable fingerprints. Nominal fingerprints encode declaration content symbolically, and module-interface fingerprints hash the complete reachable module/content graph so recursive and transitive dependencies remain deterministic. Explicit compatibility negotiation remains necessary.

`tools/dew-abi.mjs` is the scalar executable host consumer. `list` discovers and deterministically sorts valid `<source>$dew$<carrier,...>` function exports. `call` selects one source/carrier vector, performs explicit `i32`/`i64`/`f32`/`f64` JavaScript conversion, invokes `__dew_init` once, calls the adapter, and emits normalized JSON. It rejects `v128` because the JavaScript WebAssembly API cannot invoke it and rejects `eqref` because aggregate/reference values require an in-Wasm package consumer.

`tools/dew-wasm-consumer.mjs PROVIDER_WASM CONSUMER_WASM EXPORT RESULT_TYPE [EXPECTED_PROVIDER_PATH EXPECTED_INTERFACE_FINGERPRINT]` validates the provider's required `dew.abi` record before instantiation, optionally enforces an exact module/interface identity, invokes exported `__dew_init` exactly once, and then instantiates a Wasm consumer with the provider exports under the `dew` import namespace. The focused `tests/abi-consumers/generic-aggregate-callback-i32.wat` and `generic-enum-callback-i32.wat` consumers define structurally equivalent aggregate, enum-subtype, and flattened-closure types. They construct direct `i32` callbacks, import `identity_box$dew$i32` or `identity_choice$dew$i32`, and call the callbacks returned by the static-to-erased-to-static adapter paths. `generic-eqref-identity.wat` constructs an exact nominal struct, invokes the public `(eqref) -> eqref` fallback, casts the result back to that struct, and reads its scalar field. `generic-v128-identity.wat` constructs a SIMD vector, invokes `identity$dew$v128`, and extracts lane zero after the adapter's box/fallback/unbox path. The `tests/abi-consumers/imported-package` manifest builds a multi-module provider whose root adapter uses an imported generic callback aggregate; the existing aggregate consumer links against that provider without changing its structural import type. JavaScript observes only the final scalar `42`; all `eqref`, closure, variant, and `v128` values remain inside Wasm.

## Remaining work

1. Build trait dictionary method slots from trait requirement plans.
2. Extend callable reachability so unused signature and closure-entry types can be removed after directization.
3. Replace the unresolved raw-`DeclId` callable fallback where possible and define compatibility/version negotiation rules over module-interface fingerprints.
4. Define recursive generic aggregate instantiation/layout sharing without weakening exact callback signatures.
5. Stop recollecting dependency source bodies on cache hits only after installed artifact provenance and package recovery are reliable.
