# Cross-package trait implementation ownership

## Status

Implemented for ordinary local, generic, derived, imported, and cache-backed trait evidence. An ordinary trait implementation is legal only when its declaring package owns either the trait declaration or the implementation target's nominal head. Primitive targets are owned by the compiler-supplied `dew.std` package. A third-party package must use explicit `foreign impl` syntax when it owns neither side.

Package manifests currently define exactly one ordinary Dew module, so a non-standard package's module identity is its implementation-ownership identity. Strict `dew.modules.json` graphs contain no package metadata and therefore treat every listed module as a distinct ownership domain. All compiler-owned module IDs in the reserved `dew.std` range share one package identity, allowing lane, text, bytes, and preamble modules to implement standard traits and primitive operations across their internal module boundaries.

## Rule

For:

```dew
impl Trait<...> for Target<...> {
  // ...
}
```

at least one condition must hold:

1. `Trait` is declared by the current package;
2. the normalized nominal head of `Target` is declared by the current package;
3. `Target` is primitive and the current package is `dew.std`.

Aliases are normalized before the rule is applied. Generic arguments do not transfer ownership: `ForeignBox<Local>` remains owned by the package that declares `ForeignBox`. An open generic target head remains invalid independently of orphan checking.

Inherent implementations retain their existing rules in this tranche. The orphan rule applies to trait evidence.

## Explicit foreign evidence

`foreign impl Trait for ForeignType` is the deliberate local escape hatch. Its evidence:

- participates in ordinary signature validation, inference, prerequisite solving, static dispatch, and local/imported-overlap checks inside the declaring module;
- is never exported in a frozen interface;
- cannot be imported or re-exported;
- cannot satisfy a caller-visible public evidence requirement;
- may differ independently between modules without creating global coherence.

Ordinary orphan syntax is rejected with `OrphanTraitImpl` at the exact implementation declaration. When source is available, diagnostics label both the foreign trait and foreign nominal target declarations. Invalid orphan evidence is removed before bucket construction and does not participate in later overlap ranking or dispatch.

## Frozen interfaces and cache hardening

Interface freezing independently rechecks package ownership before exporting implementation records, so an erroneous provider cannot leak evidence merely because interface collection precedes body inference. The version 1 private frozen-interface decoder also rejects serialized interfaces containing orphan implementation evidence. Its implementation-head traversal is bounded and validates decoded type IDs and applied-type spans before indexing the resolved arena, so a malformed ownership record returns a cache error instead of aborting the compiler. This protects cache-hit behavior from stale or manually constructed artifacts even when no provider body analysis runs.

Version 1 uses:

```text
DEW_FROZEN_INTERFACES_V1\0
DEW_STD_INTERFACE_CACHE_V1\0
.dew/cache/interfaces/v1-<bundle-fingerprint>.dwi
```

Stale pre-release artifacts are ignored by filename and rejected by payload or envelope magic.

## Backend consequence

A legal implementation may be declared locally for an imported nominal target when the trait is local. Such a local implementation method has a provider-owned nominal parameter ABI even though its body belongs to the consumer module. Program call emission now restores that exact external nominal reference with a targeted `ref.cast` before the local method call. Same-module calls without external nominal parameters retain the prior cast-free path.

## Validation

Coverage includes:

- ordinary generic orphan rejection;
- primitive orphan rejection;
- trait-owned and nominal-target-owned legal implementations;
- module-local `foreign impl` execution and non-export;
- exact source labels for both foreign declarations;
- exclusion before imported coherence;
- version 1 cache decoder rejection of injected orphan evidence and malformed implementation type IDs without process aborts;
- local implementation methods over imported nominal receivers;
- deterministic Node and Wago runtime execution;
- reversed snapshot compilation reproducibility.
