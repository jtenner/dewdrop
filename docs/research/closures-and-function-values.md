# Closures and first-class function values

## Status

The first two unblocking milestones are implemented: Dew parses and semantically resolves function types in declaration type positions using:

```dew
fn(I32, Bool) -> I64
fn() -> Unit
fn(I32) -> fn(Bool) -> String
```

Parser types preserve ordered parameter types, result type, and source offset. Collection lowers them iteratively into `FunctionTypeSyntax`, reusing the module type-argument arena for the parameter span. Resolution interns `FunctionType` nodes structurally and traverses them through generic alias substitution, alias normalization, imported-interface translation, visibility checks, coherence signature comparison, nominal reachability, and frozen-interface cache V4. Every callable also receives a canonical structural function-type ID after signature normalization.

Unambiguous non-generic local/imported function names produce `FunctionReferenceSelection`, and calls through function-typed locals produce `SelectedFunctionValueCallTarget` after structural arity/parameter/result checking. Lowering preserves both operations explicitly. Modules that do not use first-class functions retain the direct callable ABI. Modules that produce, accept, return, or invoke first-class functions use the closure ABI described below; function-valued parameters, locals, results, and globals are GC references to closure objects.

Program linking structurally coalesces equivalent direct and environment-first entry signatures across modules while retaining exact nominal declaration identities inside signatures. Named references, captured lambdas, returned closures, function parameters, module globals, and imported closure values execute in Node snapshots. Wago execution is intentionally not being rerun while its checkout is undergoing a separate rebase.

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

WasmGC physical planning reserves one module closure struct whenever first-class function values are used. Its immutable fields are an abstract nullable function reference and nullable `eqref` environment. Every lambda receives a deterministic environment struct, including empty environments, and every runtime-stored capture maps to a stable physical field. Scalar and SIMD captures retain compact storage; reference, nominal, text, and function captures use GC-safe `eqref` storage with exact casts restored at use sites. Unit/Never captures consume no field. The plan records closure/environment type indices and capture-to-field relocation explicitly. Modules without first-class function use add no closure types.

## Implemented closure ABI

A closure object contains:

1. an abstract function reference;
2. a nullable environment reference.

Lambda entry functions use a signature-specific `(environment, parameters...) -> result` type. Lambda construction allocates its environment, stores captures in deterministic order, then allocates the closure object. Captured reads cast the environment to the exact lambda environment type and use packed signed/unsigned loads where required.

Named non-capturing references share the same value representation without adapter functions: they store the original `ref.func` and a null environment. Invocation stores the target exactly once, tests its environment, and emits one typed branch. A null environment casts the entry to the original direct signature; a non-null environment passes it first and casts to the environment-first entry signature. Both branches use typed `call_ref`, and declarative element segments authorize all referenced named and lambda functions.

The runtime snapshots cover non-capturing lambdas, scalar captures, reference captures, function-valued captures, nested/transitive captures, immediate invocation, returned closures, closure parameters, module-level closures, and imported closures.

## Required next milestones

1. Add expected-type disambiguation for overloaded and generic function references.
2. Define shared mutable-capture cells when scalar local assignment becomes part of the language.
3. Add closure ABI fingerprints to persistent external package interfaces.
4. Add escape analysis, directization, empty-environment singleton reuse, and allocation elimination.
5. Measure closure allocation, call, cast, and capture-load costs in Node and Wago after the Wago rebase completes.

## Constraints

- Function overload sets cannot become values without an expected function type or explicit disambiguation.
- Captures preserve lexical binding identity, deterministic source order, and exact source mutability metadata. Scalar reassignment is not yet a language operation; when it is added, mutable captures must use shared cells rather than copied environment fields.
- Cross-module concrete function signatures are structurally coalesced during one program link; persistent package interfaces still require stable signature and closure ABI fingerprints.
- Generic function values remain blocked on executable generic ABI work.
- Runtime performance favors directization and allocation elimination, but these optimizations must not define source semantics.
