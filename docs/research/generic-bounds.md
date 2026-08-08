# Generic bound syntax and retained representation

## Syntax

Every declaration form that already accepts generic parameters now accepts
ordered trait bounds:

```dew
fn equal<t: Eq>(left: t, right: t) -> Bool {
  left == right
}

struct Wrapper<t: Eq + Debug> {
  value: t
}
```

The grammar is `name (":" type ("+" type)*)?`. Commas still separate generic
parameters, one trailing comma remains legal, and applied trait types use the
ordinary recursive type parser.

## Representation

Parser `TypeParameter` records retain an ordered `Array[TypeExpr]` of bounds.
Collection lowers every bound into the module-wide flat type-syntax arena and
stores one `HirSpan` on the corresponding `CollectedGenericParameter`. The
parallel `generic_bounds` arena avoids widening each bound into a recursive
object and preserves exact per-node file provenance through the existing type
syntax side table.

Type resolution resolves each retained bound with the trait-only name
expectation. A type, primitive, generic parameter, or unknown spelling therefore
produces the same deterministic `ExpectedTraitType`/`UnknownTrait` diagnostics
used by implementation heads. Resolved bounds are aligned in
`ResolvedModuleTypes.generic_bound_types` with the collected bound arena.

## Cache format

The private frozen-interface payload and outer persistent cache envelope advance
from V7 to V8. V8 serializes `generic_bound_types` immediately after generic
parameter types. Cache filenames use `v8-<fingerprint>.dwi`; old artifacts are
ignored by construction rather than decoded under the new layout.

## Current boundary

This milestone freezes syntax and resolved trait identities only. Generic body
operator/method selection does not yet consume bound evidence, call sites do not
yet prove obligations, and public interface fingerprints do not yet claim a
stable generic-bound ABI. Those are the next obligation-solving steps.

## Validation

Tests cover function, builtin, and trait declarations; ordered multi-bound
parsing; unbounded parameters; flat HIR retention; trait-namespace resolution;
and byte-identical V8 frozen-interface serialization/deserialization.
