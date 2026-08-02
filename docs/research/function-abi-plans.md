# Function ABI plans

## Status

Implemented as deterministic backend-neutral callable signatures for builtins, top-level functions, trait requirements, and impl methods. The artifact is embedded in `PlannedModuleLowering` and precedes Starshine function/type index assignment. Reachable concrete first-class signatures are now refined to typed Wasm references, and equivalent signatures are structurally coalesced across modules during program linking.

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

Trait-level and impl-level generics remain rigid signature recipes. No monomorphized function copies are produced by this phase.

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

## Remaining work

1. Define generic shape-specialized and erased fallback ABIs.
2. Build trait dictionary method slots from trait requirement plans.
3. Emit adapters only where static and erased ABI shapes differ.
4. Extend callable reachability so unused signature and closure-entry types can be removed after directization.
5. Define persistent cross-package export/import naming, signature fingerprints, and ABI compatibility rules.
6. Add shared mutable-capture cells and closure escape/directization optimization.
