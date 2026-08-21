# Self-host basic body inference

Date: 2026-08-21

## Purpose

This tranche connects the self-hosted body HIR and resolved body names to the rollback-capable local type solver.

It is the first body-inference layer. Callable overload selection, members, enum constructors, trait obligations, imported module values, implementation evidence, lambda-family merging, and final compact module artifacts remain later layers.

## Implemented surface

`self_host/compiler/semantic_basic_body_inference.dew` now provides:

- one local solver per root body;
- expression, local, block, pattern, loop-state, loop-result, and root type slots;
- rigid import of resolved parameter, return, lambda, primitive, nominal, product, application, and function types;
- signed integer boundary handling;
- literal types for all scalar text and byte literals;
- product and typed Array literal constraints;
- lexical local and parameter references;
- function-value calls;
- unique non-generic local function calls and published direct call targets;
- direct-call arity diagnostics;
- sequential `let` constraints;
- explicit and trailing return constraints;
- block result types;
- `if`, `match`, functional `while`, `break`, and `continue` constraints;
- wildcard, binding, literal, product, and alternative pattern constraints;
- prefix, logical, comparison, and same-type arithmetic constraints;
- product-field constraints used by lowered product destructuring;
- assignment type and mutability checks;
- repeatable zonking of every published type slot;
- unresolved, unsupported, mismatch, infinite-type, return, assignment, and numeric diagnostics.

The pass is iterative over the flat HIR arenas. It does not add recursive expression or pattern traversal.

## Layer boundary

Unique and overloaded local module-function calls are now selected by the callable-selection extension to this layer. Generic signatures are instantiated freshly, candidates are tested under solver snapshots, argument and expected-result types select overloads, and the result publishes the declaration plus zonked type arguments. Generic bounds remain for the trait-obligation layer.

Object construction, enum construction, fields, qualified members, indexing, imported values, and trait-based operators are also retained as explicit unsupported roots. Their type variables are poisoned so they do not produce false secondary mismatch or unresolved diagnostics.

Nested lambda bodies are not merged into the module result yet. Lambda expressions receive their frozen signature function type. Lambda-local inference and capture-type routing belong to the body-family tranche.

## Result shape

`SelfHostBasicInferredBody` retains the zonked root and slot arrays plus the local solver type arena and diagnostics. Positive body-local type IDs remain valid against that result's `types` and `type_arguments` arrays. Resolved types keep the compact negative encoding from local unification.

This is intentionally a per-body artifact. Final arena compaction, positive-ID rebasing, module-value SCC inference, lambda-family merging, deterministic global diagnostic merging, and persistent codecs remain in the result-compaction and body-inference driver tranche.

## Tests

Focused tests cover:

- parameters, literals, sequential lets, arithmetic, and trailing returns;
- products, generated destructuring projections, and branches;
- function-value calls;
- selected non-generic direct calls and arity failures;
- typed Array literals;
- match bindings and guards;
- functional-loop state and result types;
- mismatch and immutable-assignment diagnostics;
- iterative inference across 1,024 sequential locals.

The next semantic work is member, method, constructor, indexing, and operator selection, followed by trait obligations, implementation evidence, lambda-family inference, module-value SCC inference, result compaction, and body flow.
