# Self-host local unification — August 21, 2026

## Status

The Dew self-host compiler now has the body-local type representation and
rollback-capable unification solver required by body inference.

The port adds:

- `semantic_inference_types.dew`;
- `semantic_local_unification.dew`;
- `semantic_local_unification_test.dew`.

## Type representation

Body types use one compact signed `I32` identity:

- `0` is the shared error type;
- positive values index body-local terms;
- values below `-1` encode immutable resolved-type arena indexes.

Body-local terms cover:

- inference variables;
- products;
- applications;
- function types.

This keeps rigid resolved types allocation-free while permitting body-local
structural types to contain inference variables.

## Unification

The solver implements iterative:

- union-find with union by size and path compression;
- variable binding;
- body/body structural unification;
- resolved/resolved structural unification;
- mixed body/resolved structural unification;
- product, application, and function decomposition;
- occurs checking;
- mismatch poisoning;
- unresolved-variable discovery;
- final type zonking.

A mismatch emits one `LocalTypeMismatch` diagnostic and poisons directly
involved inference variables with the shared error type. Later constraints can
flow through that poison without producing duplicate mismatch cascades.

An occurs-check failure emits `InfiniteLocalType` and poisons the recursive
variable class.

## Candidate snapshots

Inference candidate trials can create nested snapshots. Each snapshot records:

- undo-log start;
- variable count;
- body-type count;
- type-argument count;
- diagnostic count.

Parent, size, and binding mutations are undo-logged only while a snapshot is
active. Rollback restores mutations and truncates all candidate allocations and
diagnostics. Commit preserves the selected candidate. Nested commits remain
part of an outer rollback until the outer snapshot commits.

Path compression is disabled while snapshots are active so rollback does not
need to log incidental compression writes.

## Stack safety

Occurs checking, unification decomposition, unresolved-variable scans, and
zonking use explicit work stacks. Focused tests cover 1,024 nested applications
and 1,024 equivalent variables.

## Test coverage

The focused suite covers:

- variable union and binding;
- resolved/body application decomposition;
- products and functions;
- mismatch diagnostics and poison recovery;
- infinite-type rejection;
- allocation and diagnostic rollback;
- nested snapshot commit and rollback;
- zonking and poison propagation;
- 1,024-level occurs checking;
- 1,024-variable union-find behavior.

## Next phase

The next dependency phase is the basic body inference pass: allocate expression,
pattern, local, lambda, and return type slots; import rigid signature types;
apply literal and direct flow constraints; then freeze body-local types through
this solver. Callable, member, operator, trait-obligation, and evidence
selection follow as layered inference tranches.
