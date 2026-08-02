# Closures and first-class function values

## Status

The first two unblocking milestones are implemented: Dew parses and semantically resolves function types in declaration type positions using:

```dew
fn(I32, Bool) -> I64
fn() -> Unit
fn(I32) -> fn(Bool) -> String
```

Parser types preserve ordered parameter types, result type, and source offset. Collection lowers them iteratively into `FunctionTypeSyntax`, reusing the module type-argument arena for the parameter span. Resolution interns `FunctionType` nodes structurally and traverses them through generic alias substitution, alias normalization, imported-interface translation, visibility checks, coherence signature comparison, nominal reachability, and frozen-interface cache V2.

Lowering currently assigns function values the provisional nullable `eqref` shape. This permits signatures and pass-through bodies to type-check without prematurely fixing the eventual closure-object layout. Calls rooted at local or module values still report `InvalidCallTarget`; named function references, anonymous function expressions, captures, closure allocation, and indirect calls are not yet accepted.

## Proposed representation

A captured closure should use a WasmGC object containing:

1. a typed function reference for a uniform lowered closure signature;
2. an environment reference, omitted or represented by a canonical empty environment for non-capturing functions.

The lowered callable signature should receive the environment explicitly before source parameters. Direct calls may bypass closure allocation when the callee and environment are statically known. Escaping non-capturing function references may use a shared singleton closure object.

## Required next milestones

1. Resolve unambiguous named functions as values separately from direct-call overload resolution.
2. Emit non-capturing function references and calls through typed `call_ref`.
3. Parse anonymous function expressions and collect nested callable bodies.
4. Compute deterministic free-variable/capture sets.
5. Emit environment structs and captured loads.
6. Add escape analysis and directization before allocation optimization.

## Constraints

- Function overload sets cannot become values without an expected function type or explicit disambiguation.
- Captures must preserve lexical binding identity, mutability rules, and deterministic source order.
- Cross-module function-value interfaces require stable signature and closure ABI fingerprints.
- Generic function values remain blocked on executable generic ABI work.
- Runtime performance favors directization and allocation elimination, but these optimizations must not define source semantics.
