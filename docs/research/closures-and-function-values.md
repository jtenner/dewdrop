# Closures and first-class function values

## Status

The first two unblocking milestones are implemented: Dew parses and semantically resolves function types in declaration type positions using:

```dew
fn(I32, Bool) -> I64
fn() -> Unit
fn(I32) -> fn(Bool) -> String
```

Parser types preserve ordered parameter types, result type, and source offset. Collection lowers them iteratively into `FunctionTypeSyntax`, reusing the module type-argument arena for the parameter span. Resolution interns `FunctionType` nodes structurally and traverses them through generic alias substitution, alias normalization, imported-interface translation, visibility checks, coherence signature comparison, nominal reachability, and frozen-interface cache V4. Every callable also receives a canonical structural function-type ID after signature normalization.

Semantic lowering retains a provisional reference shape for function values, while WasmGC fragment planning refines every reachable structural function type to a nullable typed function reference. Unambiguous non-generic local/imported function names produce `FunctionReferenceSelection`, and calls through function-typed locals produce `SelectedFunctionValueCallTarget` after structural arity/parameter/result checking. Lowering preserves both operations explicitly. The backend now emits non-capturing references with `ref.func`, declares referenced functions in a declarative element segment, and invokes function values with typed `call_ref`. Function-typed parameters and locals use the exact canonical reference type rather than erased `eqref`.

Program linking structurally coalesces equivalent reachable function signatures across modules. This gives an imported function definition and a consumer-side `fn(T, ...) -> R` value one final Wasm type identity while retaining exact nominal declaration identities inside signatures. Local and imported non-capturing references execute in both Node and Wago Core 3 snapshots.

Lambda syntax is now parsed in expression position with the same explicit typed signature and block shape as named functions:

```dew
fn(value: I32) -> I32 {
  value + offset
}
```

The `fn` token is decisive in expression value-seeking mode: the parser consumes it once, requires `(`, parses the existing typed-parameter and type grammars, and then consumes the existing newline-delimited block grammar. No token rewind, speculative branch, or multi-token lookahead is introduced. Pipe syntax such as `|value|` is intentionally avoided because `|` is already an infix token and would make the cursor state context-sensitive. Expression lambdas enter normal postfix mode after their block, so immediate calls and field/index continuations remain mechanical.

Collection lowers each lambda header immediately and defers its block into an isolated, source-ordered `HirLambdaBody`. Nested lambdas retain deterministic parent and root-body identities, and their expression/block arenas do not leak into the enclosing `HirBody` span.

Lexical name resolution now processes those isolated bodies after their enclosing root-body jobs. Each lambda receives its own parameter, local, control, and diagnostic spans. A lambda expression freezes the active binding stack at its exact source position, so later declarations are not accidentally visible and shadowed bindings retain the correct identity. Direct captures are ordered by first use. Each capture records an exact `BodyLocalCapture` or `LambdaLocalCapture` source plus mutability. Free variables used only by nested lambdas are routed through every intermediate lambda in deterministic nested-lambda/source order, preparing those environments to construct descendant closures. Module/import names remain ordinary non-captured references.

Lambda parameter and result syntax resolves in the enclosing root declaration's generic/type scope. Each lambda receives one canonical structural `FunctionType`, with alias-normalized parameter and result types, and the frozen-interface cache is versioned to V4 for the added resolved signature tables.

Isolated lambda bodies now run through the ordinary local inference pipeline after root bodies and earlier parent lambdas. Declared parameters and results enter the solver as canonical signature types. Capture types are imported from the exact root-body or parent-lambda local job, preserving applied generic shapes without sharing solver-local variables. Expressions, locals, blocks, patterns, controls, calls, member selections, capture types, and diagnostics merge back into the module-wide HIR-aligned tables. Nested lambda values receive their canonical function types, calls through lambda-valued locals are selected as function-value calls, and return mismatches are diagnosed within the owning lambda span.

Lambda bodies also receive independent structured-flow analysis. Exhaustiveness, unreachable block items, loop fallthrough, and per-expression/block/arm outcomes are merged into the same global HIR-aligned flow tables while diagnostics remain owned by the lambda that produced them.

Semantic lowering now retains explicit `PlannedLambdaClosure` and `PlannedCaptureGet` operations instead of poisoning lambda expressions. Each `PlannedLambdaLowering` freezes the inferred root shape, structured flow, local/capture spans, and complete expression/block/pattern/arm ranges. Planned captures preserve exact source identity, mutability, body type, and storage shape. Nested lambda construction therefore has all environment operands available before physical ABI planning.

The remaining unsupported boundary is executable closure emission: Starshine deliberately rejects these explicit operations until closure/environment physical types and lambda entry functions are planned, so no closure allocation or invocation is claimed yet.

## Proposed representation

A captured closure should use a WasmGC object containing:

1. a typed function reference for a uniform lowered closure signature;
2. an environment reference, omitted or represented by a canonical empty environment for non-capturing functions.

The lowered callable signature should receive the environment explicitly before source parameters. Direct calls may bypass closure allocation when the callee and environment are statically known. Escaping non-capturing function references may use a shared singleton closure object.

## Required next milestones

1. Define canonical immutable and mutable environment field representations.
2. Add explicit closure construction and captured-load lowering operations.
3. Add expected-type disambiguation for overloaded and generic function references.
4. Emit environment structs and captured loads.
5. Introduce the closure-object ABI for captured and uniformly escaping values.
6. Add escape analysis and directization before allocation optimization.

## Constraints

- Function overload sets cannot become values without an expected function type or explicit disambiguation.
- Captures must preserve lexical binding identity, mutability rules, and deterministic source order.
- Cross-module concrete function signatures are structurally coalesced during one program link; persistent package interfaces still require stable signature and closure ABI fingerprints.
- Generic function values remain blocked on executable generic ABI work.
- Runtime performance favors directization and allocation elimination, but these optimizations must not define source semantics.
