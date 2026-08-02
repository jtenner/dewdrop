# Closures and first-class function values

## Status

The first unblocking milestone is implemented: Dew now parses function types in declaration type positions using:

```dew
fn(I32, Bool) -> I64
fn() -> Unit
fn(I32) -> fn(Bool) -> String
```

Parser types preserve ordered parameter types, result type, and source offset. Collection lowers them iteratively into `FunctionTypeSyntax`, reusing the module type-argument arena for the parameter span. Type resolution currently visits all child types and then emits `UnsupportedFunctionType`; function values, references, anonymous function expressions, captures, closure layouts, and indirect calls are intentionally not yet accepted.

This staged boundary makes the syntax and diagnostics deterministic without prematurely selecting the runtime ABI.

## Proposed representation

A captured closure should use a WasmGC object containing:

1. a typed function reference for a uniform lowered closure signature;
2. an environment reference, omitted or represented by a canonical empty environment for non-capturing functions.

The lowered callable signature should receive the environment explicitly before source parameters. Direct calls may bypass closure allocation when the callee and environment are statically known. Escaping non-capturing function references may use a shared singleton closure object.

## Required next milestones

1. Add semantic `ResolvedFunctionType` and body-level function type terms.
2. Resolve unambiguous named functions as values separately from direct-call overload resolution.
3. Emit non-capturing function references and calls through typed `call_ref`.
4. Parse anonymous function expressions and collect nested callable bodies.
5. Compute deterministic free-variable/capture sets.
6. Emit environment structs and captured loads.
7. Add escape analysis and directization before allocation optimization.

## Constraints

- Function overload sets cannot become values without an expected function type or explicit disambiguation.
- Captures must preserve lexical binding identity, mutability rules, and deterministic source order.
- Cross-module function-value interfaces require stable signature and closure ABI fingerprints.
- Generic function values remain blocked on executable generic ABI work.
- Runtime performance favors directization and allocation elimination, but these optimizations must not define source semantics.
