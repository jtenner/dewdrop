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

The private frozen-interface payload first advanced from V7 to V8 for aligned
`generic_bound_types`, then to V9 when imported call checking required one bound
span per frozen generic parameter. V10 adds the owner generic-parameter span to
every frozen implementation so imported generic evidence can instantiate and
enforce its own prerequisites. The outer persistent envelope and filenames
advance with it to `v10-<fingerprint>.dwi`; older artifacts are ignored by
construction rather than decoded under a newer layout.

## Call-site obligation checking

Local and imported generic calls now instantiate every declared bound with the
inferred call type arguments and require one visible, valid, coherent
implementation matching both the concrete target and the complete applied trait
type. `Convert<I32>` evidence therefore does not satisfy `Convert<I64>`.
Failures produce `UnsatisfiedTraitObligation` at the call argument. Imported
interfaces retain one bound span per generic parameter, and import translation
maps bound types into the consumer's resolved arena before checking evidence.

Generic implementation candidates now enforce their own ordered prerequisites
before they can satisfy method, operator, indexing, map/set, or generic-call
evidence. The same recursive check applies to local and imported implementations,
rebuilds imported trait-obligation buckets in the consumer index, and caps nested
prerequisite traversal at 64 levels. An implementation such as
`impl<t: Marker> Value for Box<t>` therefore cannot provide `Value` for
`Box<No>` merely because its target head unifies.

A 256-call release-native inference benchmark measured:

```text
unbounded generic calls     342.21 us
one bound per generic call  415.47 us
```

The approximately 0.29 us per-call validation cost in this deliberately dense
workload includes coherent bucket lookup, trial unification of target and trait
application, and rollback. Empty-bound callables take the existing fast path.

A parallel 256-call generic-method benchmark measured 657.64 us for an
unbounded generic implementation and 725.18 us when its inferred owner argument
had one prerequisite, approximately 0.26 us per candidate selection. Generic
implementations with no prerequisites return through a dedicated no-allocation
fast path. These measurements are development observations rather than
regression budgets.

## Current boundary

Generic body operator/method selection does not yet consume bound evidence, and
selected call-site evidence is validated but not yet frozen into lowering as a
dictionary/evidence record. Public interface fingerprints do not yet claim a
stable generic-bound ABI. Those are the next obligation-solving steps.

## Validation

Tests cover function, builtin, and trait declarations; ordered multi-bound
parsing; nested applied bounds adjacent to the outer `>`; unbounded parameters;
flat HIR retention; trait-namespace resolution; byte-identical V10
frozen-interface serialization/deserialization; local and imported call-bound
checking; local, transitive, operator, and imported generic-implementation
prerequisites; marker traits; and exact applied-trait argument matching.
