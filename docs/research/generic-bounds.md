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

A 256-call release-native inference benchmark measured after evidence freezing:

```text
unbounded generic calls       335.76 us
one frozen bound per call     438.09 us
recursive two-node evidence   655.63 us
```

The same-run deltas are approximately 0.40 us per direct evidence node and an
additional 0.85 us per call for a generic implementation plus its prerequisite.
The recursive workload freezes 512 evidence nodes, 256 child edges, and 256
owner-carrier arguments. Empty-bound callables and implementations retain
no-evidence fast paths. These measurements are development observations rather
than regression budgets.

A parallel 256-call generic-method benchmark measured 616.97 us for an
unbounded generic implementation and 846.84 us when its inferred owner argument
had one frozen prerequisite. The bounded path performs trial validation and then
freezes the selected prerequisite forest; generic implementations with no
prerequisites return through a dedicated no-evidence fast path.

## Generic-body symbolic selection

A generic body now treats each source-ordered bound as a symbolic evidence slot.
Direct operators and instance methods on a rigid generic parameter select the
matching trait requirement, instantiate `Self` plus applied trait arguments,
and retain `SelectedBoundInferredCallTarget(requirement, evidence, arguments)`.
Implementation methods use their owner implementation's bounds in the same way.
Nested generic-call obligations and generic implementation prerequisites may be
satisfied by those declared symbolic bounds without pretending that a concrete
implementation has already been chosen.

Lowering preserves symbolic method and operator calls as dedicated planned
expression kinds rather than converting trait requirements into ordinary direct
calls. This keeps signature-only trait declarations out of executable function
selection until evidence propagation resolves them.

A 256-operator release-native benchmark measured 299.69 us for concrete
implementation selection and 213.68 us for direct symbolic-bound selection. The
symbolic path avoids implementation-bucket enumeration and candidate rollback;
these are development observations rather than regression budgets.

## Frozen call evidence

Every generic call now retains an ordered recursive evidence forest. Concrete
nodes name the selected implementation, point to ordered prerequisite children,
and retain each owner generic argument as either a physical carrier or an
enclosing generic-parameter ordinal. Symbolic nodes refer directly to the
caller's source-ordered bound slot. This representation avoids retaining
snapshot-local inference IDs, which are invalid after candidate rollback, while
preserving the information needed to specialize generic implementation methods.

Generic implementation method, operator, indexing, and collection-evidence
selection retain their prerequisite roots on the owning expression. Body-job
merging rebases node, child, root, and owner-argument arenas deterministically;
backend-neutral lowering carries the frozen arenas unchanged. Generic-free
bodies allocate no per-body evidence-span table until evidence is actually
selected.

## Current boundary

Specialization identity and transitive materialization do not yet consume the
frozen evidence forests. Symbolic planned calls therefore are not emitted until
concrete evidence is propagated through specialization or dictionaries. Public
interface fingerprints do not yet claim a stable generic-bound ABI. That is the
next obligation-solving step.

## Validation

Tests cover function, builtin, and trait declarations; ordered multi-bound
parsing; nested applied bounds adjacent to the outer `>`; unbounded parameters;
flat HIR retention; trait-namespace resolution; byte-identical V10
frozen-interface serialization/deserialization; local and imported call-bound
checking; local, transitive, operator, and imported generic-implementation
prerequisites; symbolic generic-body operators, methods, applied trait arguments,
implementation-owner bounds, nested obligations, recursive concrete evidence,
caller-bound evidence, imported evidence, owner carrier/generic arguments,
deterministic body-job rebasing, and lowering retention; marker traits; and
exact applied-trait argument matching.
