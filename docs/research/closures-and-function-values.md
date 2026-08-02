# Closures and first-class function values

## Status

The first two unblocking milestones are implemented: Dew parses and semantically resolves function types in declaration type positions using:

```dew
fn(I32, Bool) -> I64
fn() -> Unit
fn(I32) -> fn(Bool) -> String
```

Parser types preserve ordered parameter types, result type, and source offset. Collection lowers them iteratively into `FunctionTypeSyntax`, reusing the module type-argument arena for the parameter span. Resolution interns `FunctionType` nodes structurally and traverses them through generic alias substitution, alias normalization, imported-interface translation, visibility checks, coherence signature comparison, nominal reachability, and frozen-interface cache V3. Every callable also receives a canonical structural function-type ID after signature normalization.

Semantic lowering retains a provisional reference shape for function values, while WasmGC fragment planning refines every reachable structural function type to a nullable typed function reference. Unambiguous non-generic local/imported function names produce `FunctionReferenceSelection`, and calls through function-typed locals produce `SelectedFunctionValueCallTarget` after structural arity/parameter/result checking. Lowering preserves both operations explicitly. The backend now emits non-capturing references with `ref.func`, declares referenced functions in a declarative element segment, and invokes function values with typed `call_ref`. Function-typed parameters and locals use the exact canonical reference type rather than erased `eqref`.

Program linking structurally coalesces equivalent reachable function signatures across modules. This gives an imported function definition and a consumer-side `fn(T, ...) -> R` value one final Wasm type identity while retaining exact nominal declaration identities inside signatures. Local and imported non-capturing references execute in both Node and Wago Core 3 snapshots. Anonymous function expressions, captures, closure allocation, and generic or overloaded function-value disambiguation are not yet accepted.

## Proposed representation

A captured closure should use a WasmGC object containing:

1. a typed function reference for a uniform lowered closure signature;
2. an environment reference, omitted or represented by a canonical empty environment for non-capturing functions.

The lowered callable signature should receive the environment explicitly before source parameters. Direct calls may bypass closure allocation when the callee and environment are statically known. Escaping non-capturing function references may use a shared singleton closure object.

## Required next milestones

1. Add expected-type disambiguation for overloaded and generic function references.
2. Parse anonymous function expressions and collect nested callable bodies.
3. Compute deterministic free-variable/capture sets.
4. Emit environment structs and captured loads.
5. Introduce the closure-object ABI for captured and uniformly escaping values.
6. Add escape analysis and directization before allocation optimization.

## Constraints

- Function overload sets cannot become values without an expected function type or explicit disambiguation.
- Captures must preserve lexical binding identity, mutability rules, and deterministic source order.
- Cross-module concrete function signatures are structurally coalesced during one program link; persistent package interfaces still require stable signature and closure ABI fingerprints.
- Generic function values remain blocked on executable generic ABI work.
- Runtime performance favors directization and allocation elimination, but these optimizations must not define source semantics.
