# Self-host body name resolution — August 20, 2026

## Status

The Dew self-host compiler now resolves executable body names after signature
interfaces and import scopes are frozen.

The port adds:

- `semantic_body_names.dew`: local, control, capture, expression-reference,
  pattern-reference, diagnostic, body, lambda, and module result models;
- `semantic_body_name_resolution.dew`: iterative lexical traversal, pattern
  binding, functional-loop targets, lambda environments and captures, imported
  value lookup, and stable result merging;
- `semantic_body_name_resolution_test.dew`: focused local, pattern, loop,
  lambda, import, ambiguity, order, transfer, and stress tests.

## Name precedence

Body value lookup follows this order:

1. lexical locals;
2. enclosing lambda captures;
3. local foreign-library aliases and module values;
4. opened imported values;
5. type, trait, primitive, and variant constructor candidates when the syntax
   permits them.

Local module values shadow opened imported values. Two different opened public
values with the same spelling produce a deterministic import-scope ambiguity and
an `AmbiguousImportedValueName` body diagnostic.

Exact imports retain their `@alias` namespace. Qualified type and trait roots,
qualified patterns, and qualified value expressions retain the imported module
identity for later inference.

## Lexical and control behavior

Parameters are installed before the body. A `let` initializer is resolved before
its binding becomes visible. Later bindings shadow earlier bindings only inside
their lexical scope.

Pattern alternatives share one canonical local set. Duplicate, missing, and
extra alternative bindings remain explicit diagnostics. Pattern locals are
visible in guards and arm bodies and do not leak into later arms or enclosing
blocks.

Functional `while` expressions receive stable control IDs. `break` and
`continue` target the nearest active functional loop. Transfers outside a loop
remain visible diagnostics.

## Lambda captures

Each lambda receives a lexical snapshot taken at its source position. Bindings
declared later are not visible. Captures retain whether their source local is
mutable and identify either a root body local or a parent lambda local.

Nested captures are routed through intermediate lambdas. The implementation
uses two lambda passes so final capture spans stay in lambda-ID order without
storing compiler-sized job aggregates in nested arrays.

## HIR ordering correction

Name resolution exposed an existing block-HIR ordering defect. Recursive block
lowering appended nested block items inside the parent block's span. Parent body
traversal could therefore visit an arm or nested-loop item outside its lexical
scope.

`semantic_body_lowering.dew` now stages each block's own lowered items and
appends them only after nested expressions are complete. Every block item span
is contiguous and contains only that block's direct items.

## Stack and determinism properties

Expression traversal uses an explicit task stack. Sequential local resolution
passes the 1,024-local stress case. Diagnostics are sorted by source offset and
stable diagnostic rank. Body outputs are merged in body-ID order regardless of
the requested execution order.

The temporary arm-subtree drain keeps pattern scopes active while nested block
work completes. Before large nested-expression fixed-point stress, this should
be replaced by an explicit scope-boundary task frame so nested arm traversal is
fully stack-independent.

## Current boundary

This phase records imported callable and module-value identities but does not yet
import full callable recipes, fields, variants, implementation evidence, or
inferred module-let types. Those belong to imported semantic recipes and
inference.

Derive requests now expand into ordinary synthetic implementations and body
HIR. See
[`self-host-derive-expansion-2026-08-20.md`](self-host-derive-expansion-2026-08-20.md).
The next phase is imported semantic recipes and then inference, local
unification, callable and member resolution, trait obligations, and evidence.
