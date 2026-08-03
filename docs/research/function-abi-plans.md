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

For every demanded scalar specialization of a public root generic whose generic occurrences are direct parameters/results, the linker additionally exports a deterministic `<name>$dew$<carrier,...>` adapter. Five immutable one-field WasmGC box families cover `i32`, `i64`, `f32`, `f64`, and `v128`. The adapter boxes each scalar argument before calling the all-`eqref` fallback, then casts and unboxes scalar results. Ordinary Dew calls still target unboxed specializations, so allocations occur only when the explicit erased export adapter is invoked. Box types are emitted only for demanded carrier families.

## Remaining work

1. Add recursive representation adapters for generic values nested inside aggregate and structural function signatures; current scalar export adapters deliberately require direct generic parameter/result occurrences.
2. Build trait dictionary method slots from trait requirement plans.
3. Extend callable reachability so unused signature and closure-entry types can be removed after directization.
4. Define persistent cross-package export/import naming, signature fingerprints, and ABI compatibility rules.
5. Add executable host/package consumers for deterministic `$dew$<carrier,...>` specialization adapters.
