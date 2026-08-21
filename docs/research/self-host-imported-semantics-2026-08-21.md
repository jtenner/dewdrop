# Self-host imported semantic recipes — August 21, 2026

## Status

The Dew self-host compiler now freezes and imports the semantic recipes needed
by cross-module body inference.

Frozen interfaces now retain:

- public aggregate fields and field mutability;
- enum variants and tuple payload types;
- callable kinds, generic spans, parameter recipes, return types, and canonical
  function types;
- generic-parameter bound spans;
- ordinary implementation evidence whose trait and target heads are visible and
  package-owned;
- exact source declaration, field, variant, parameter, callable, and
  implementation identities.

Resolved consumer imports now retain:

- translated callable signatures;
- generic parameter identities and translated prerequisite bounds;
- parameter types and receiver flags;
- struct and variant fields grouped by owner declaration;
- enum variants and translated payload types;
- imported nominal and transparent-alias declaration types;
- module-value type slots;
- translated inherent and trait implementation evidence;
- declaration-indexed callable and implementation lookup tables.

## Type translation

Each imported source type is copied into the consumer's canonical resolved-type
arena. The iterative importer handles:

- errors and primitives;
- generic parameters;
- nominal, trait, and `Self` identities;
- products;
- applications;
- function types.

The traversal uses explicit task and result stacks. It memoizes each source
interface type. Structural products, applications, and functions are interned
against types already present in the consumer arena.

Imported callable function types are rebuilt from the translated parameter and
result recipes. This guarantees that the function type is canonical in the
consumer arena even when an earlier provisional cyclic interface did not retain
a final structural type index.

## Interface evidence rules

Private and test-only declarations do not cross an interface. Implementation
evidence is exported only when:

1. the implementation is not `foreign`;
2. the implementation is not from a test-only file;
3. all local nominal and trait types in its target and trait recipes are public;
4. the trait or target head belongs to the implementation package.

Ordinary orphan evidence is therefore rejected before import. Public derived
implementations use the same rules as handwritten implementations. Their
synthetic methods are exported as ordinary implementation callables.

## Determinism

Fields, variants, callables, implementations, generic parameters, bounds, and
parameters keep source/interface order. Program import outputs keep manifest
module order, including cyclic signature graphs.

Focused tests cover:

- frozen aggregate, callable, and evidence recipes;
- imported generic callable bounds;
- field grouping and mutability;
- enum payload translation;
- module-value and type maps;
- implementation trait and target translation;
- generic derived evidence and method export;
- private and test-only evidence exclusion;
- product and function canonicalization;
- cyclic manifest order;
- orphan evidence exclusion.

## Current boundary

Module `let` declarations have imported type slots, but their useful concrete
types still depend on module-value inference. Callable selection, member and
operator resolution, implementation indexing, overlap checks, obligations, and
evidence selection remain in the next inference tranche.

Local type unification has since landed. See
[`self-host-local-unification-2026-08-21.md`](self-host-local-unification-2026-08-21.md).
The next dependency phase is the basic body inference core.
