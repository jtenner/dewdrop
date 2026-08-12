# Cross-module semantic imports

## Status

Dew now resolves public imported types, traits, aliases, function signatures, direct function calls, aggregate interface metadata, and initial implementation evidence through frozen module interfaces.

The implementation remains immutable-phase oriented:

```text
manifest collection
  -> dependency graph and SCCs
  -> frozen interfaces
  -> module open scopes
  -> consumer-local imported type/signature recipes
  -> imported body name resolution
  -> imported call inference
```

Static program linking, imported aggregate construction, imported implementation dispatch, module values, generic specialization, and runtime trait evidence are implemented by later phases.

## Import scopes

`build_module_import_scope` builds one immutable scope per consumer module. Local declarations are not inserted into this scope and therefore retain deterministic priority during resolution.

A scope contains:

- imported public type declarations;
- imported public trait declarations;
- imported top-level function and builtin overload chains;
- source interface indices;
- imported module indices;
- ambiguity diagnostics;
- exact source declaration IDs.

Two imported modules exporting the same unqualified name produce an ambiguity diagnostic. A local declaration with that spelling still wins during body lookup, although the import-level ambiguity remains visible.

Trait requirements are retained in interfaces but are not inserted as ordinary imported values. Impl methods are likewise not inserted into the value namespace.

## Imported declaration types

`resolve_module_types_with_imports` applies the following lookup order:

1. declaration-owned generic parameters;
2. contextual `Self`;
3. primitive types;
4. same-module types and traits;
5. imported public types and traits.

Imported nominal and trait declarations retain their original globally packed `DeclId`. Their type recipes are copied into the consumer's resolved-type interner only when needed.

Transparent aliases are preserved across interfaces:

- non-generic imported aliases normalize directly to their semantic target;
- generic imported aliases substitute consumer type arguments through an iterative substitution traversal;
- imported alias expansion does not recurse on the host stack.

Module SCCs use a bounded two-pass interface freeze. The first pass publishes public declaration skeletons; the second pass re-resolves signatures once every interface in the SCC is available. This permits cyclic nominal signatures without making worker scheduling part of identity assignment.

## Imported callable signatures

`resolve_module_imports` translates public callable parameter and result recipes into the consumer's resolved-type arena.

It publishes:

```moonbit
pub struct ResolvedImportedCallable {
  declaration : DeclId
  generic_parameters : HirSpan
  parameters : HirSpan
  result_type : ResolvedTypeId
}

pub struct ResolvedModuleImports {
  module_id : ModuleId
  scope : ModuleImportScope
  callables : Array[ResolvedImportedCallable]
  parameter_types : Array[ResolvedTypeId]
  implementations : Array[ResolvedImportedImplementation]
  callable_by_declaration : Map[DeclId, Int]
}
```

The type importer is iterative and memoized per referenced interface. Memo tables are allocated lazily, avoiding an earlier quadratic allocation pattern where every consumer allocated a full type memo for every manifest module.

Primitive, generic, nominal, trait, `Self`, and applied types are translated. Structural recipes are reused in the consumer arena when an equivalent type already exists.

## Imported body names and calls

`resolve_module_names_with_imports` resolves imported values after lexical locals and same-module values. Imported types and traits may also act as qualified roots.

`BodyNameReference` now distinguishes:

```moonbit
ImportedValueNameReference(Int)
```

The integer identifies the head of a frozen imported overload chain.

`infer_module_bodies_with_imports` supports:

- direct non-generic imported calls;
- imported generic calls;
- expected-result-driven generic selection;
- nominal parameter and result types;
- exact external `DeclId` selection;
- frozen inferred generic arguments;
- local declarations shadowing imported values.

Selected imported calls use the existing evidence form:

```moonbit
SelectedInferredCallTarget(external_declaration, type_arguments)
```

Inference therefore does not need a separate foreign-call selection model.

## Program analysis

The convenience orchestration API is:

```moonbit
pub fn analyze_program_semantics(
  CollectedProgram,
) -> AnalyzedProgramSemantics
```

It freezes interfaces, resolves imported signatures, resolves body names, and infers bodies in dependency-SCC order. Final module results remain manifest indexed.

## Aggregate and implementation interface evidence

Frozen interfaces now retain public aggregate metadata:

- fields with exact `FieldId`, owner, optional variant, type, name, and location;
- variants with exact `VariantId`, owner, kind, payload types, name, and location.

Imported implementation evidence is translated into consumer-local resolved type IDs:

```moonbit
pub struct ResolvedImportedImplementation {
  declaration : DeclId
  trait_type : ResolvedTypeId
  target_type : ResolvedTypeId
}
```

This evidence is not yet merged into `ModuleImplIndex`; method/operator dispatch therefore remains same-module plus the compiler-owned preamble.

## Benchmarks

All measurements use `@bench.T`, native release mode, and the dedicated `module_system_bench_test.mbt` workloads.

### Initial baseline

| Workload | Mean |
|---|---:|
| Module graph, 256-module chain | 37.09 us |
| Interface freeze, 64 modules x 32 functions | 2.17 ms |
| Full manifest pipeline, 64 modules x 32 functions | 9.33 ms |

### First imported-type implementation

| Workload | Mean |
|---|---:|
| Module graph, 256-module chain | 37.94 us |
| Interface freeze, 64 modules x 32 functions | 2.38 ms |
| Full manifest pipeline, 64 modules x 32 functions | 10.05 ms |

This exposed redundant scope construction and eager per-interface memo allocation.

### Final measured implementation

| Workload | Mean |
|---|---:|
| Module graph, 256-module chain | 34.50 us |
| Interface freeze, 64 modules x 32 functions | 1.98 ms |
| Full manifest pipeline, 64 modules x 32 functions | 8.47 ms |
| Imported signature resolution, 128 calls | 45.28 us |
| Imported call inference, 128 generic calls | 86.03 us |
| Imported semantic pipeline, 128 generic calls | 163.70 us |

Relative to the initial baseline, the final interface-freeze workload is approximately 8.8% faster and the full manifest workload approximately 9.2% faster. The graph result is also lower, though microsecond-scale measurements should be treated as noisy.

The key optimization was lazy per-interface type memo allocation. Only interfaces whose recipes are actually imported allocate memo storage.

## Current boundary

Not yet implemented:

- imported module-level `let` values, whose exported type requires the module-value inference barrier;
- nested and alternative imported enum pattern emission; direct imported unit, tuple, and struct variant patterns are now inferred and executable;
- imported implementation evidence in coherence and method/operator dispatch;
- module aliases and selective imports;
- alias-qualified imported types, traits, variants, patterns, static impls, and non-callable values beyond the implemented function-call path;
- separate-Wasm-module imports for external calls; the current executable path statically links scalar and non-generic struct definitions into one module;
- cross-module eager initialization cycle diagnostics;
- interface fingerprints and persistent cache serialization.
