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

The pre-release frozen-interface payload is version 1. It contains aligned
`generic_bound_types`, one bound span per frozen generic parameter, owner generic
spans for implementations, package-ownership validation, and canonical resolved
explicit-call type arguments. The outer persistent envelope and filenames use
`v1-<fingerprint>.dwi`. Breaking pre-release schema changes replace version 1 in
place; stale artifacts are ignored by construction.

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
unbounded generic calls       324.95 us
one frozen bound per call     452.58 us
recursive two-node evidence   701.40 us
```

The same-run direct-bound delta is approximately 0.50 us per call. The
recursive workload freezes 512 evidence nodes, 256 child edges, and 256
owner-carrier arguments and costs approximately 1.47 us more per call than the
unbounded workload. Empty-bound callables and implementations retain
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

A 256-operator release-native benchmark measured 328.97 us for concrete
implementation selection and 233.32 us for direct symbolic-bound selection. The
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

## Executable static evidence

Closed generic calls now resolve every caller-bound node against the enclosing
specialization and copy the resulting concrete forest into the callee
specialization. Specialization identity includes canonical physical carriers,
implementation identities, owner carriers, and ordered prerequisite trees.
Consequently two source types sharing one Wasm carrier—for example `I32` and
`U32`—materialize distinct specializations when they select different evidence,
while calls with identical carrier and evidence still coalesce.

The linker records an exact target for each call expression in each caller
specialization. Symbolic method and operator expressions use their bound slot to
select a concrete implementation node, map the trait requirement to that
implementation's ordinary method, pass the node's owner carriers as method
specialization arguments, and forward its prerequisite children as the method's
own evidence roots. Signature-only trait requirements therefore never become
executable direct calls. Reachability roots the selected implementation methods
before fragment planning.

A release-native link benchmark with 256 alternating calls, two source types
sharing the `i32` carrier, two evidence-distinct `forward` specializations, and
two evidence-distinct transitive `read` specializations measured 1.41 ms ±
30.20 us. The executable runtime fixture is 327 WAT lines and 8,247 bytes; the
nested bounded-generic derived-Eq fixture is 829 lines and 21,154 bytes. These
are development observations rather than regression budgets.

Closed linked runtime-trait boundaries resolve symbolic bound evidence into exact dictionaries or devirtualized direct calls, and public external callers use the versioned V1 runtime-evidence parameter ABI. Bounded generic function references freeze exact expression evidence. When such a reference escapes from a generic specialization, the linker materializes the exact target specialization and records the caller's source-ordered runtime dictionary locals. The backend emits a final closure subtype containing the trampoline entry plus those immutable `eqref` captures; the trampoline receives visible callback arguments first, loads the dictionaries, and directly calls the exact target. Closed generic callers use the same evidence-aware path with zero captured dictionaries, avoiding carrier-only target collisions. Same-module and imported targets execute in Node and Wago, and a structural external Wasm consumer proves that a consumer-owned vtable survives an exported callback factory.

Concrete erased implementations may also contain runtime leaves in their recursive prerequisite trees. Those leaves are normalized to compact specialization slots while retaining their caller-local physical parameter indices for construction. The erased object stores an immutable receiver/evidence capture in its ordinary receiver field; the shared vtable adapter extracts the concrete receiver and source-ordered dictionaries before calling the exact implementation-method specialization. This avoids changing method signatures or the V1 external dictionary layout. Generic evidence templates with unresolved arguments are never emitted as adapters or globals.

A nominal argument carried through an ordinary generic specialization uses the common `eqref` carrier inside the specialized body. Before any direct call whose frozen target parameter is an exact local or imported nominal reference, backend emission now applies the target's final `ref.cast` for every generic specialization, not only generic implementation-method specializations. Scalar targets remain unchanged because the cast helper emits nothing for non-nominal carriers. This makes `read(Item {})` through `fn read<t: Value>` validate identically to the direct nominal call.

## Validation

Tests cover function, builtin, and trait declarations; ordered multi-bound
parsing; nested applied bounds adjacent to the outer `>`; unbounded parameters;
flat HIR retention; trait-namespace resolution; byte-identical version 1
frozen-interface serialization/deserialization; local and imported call-bound
checking; local, transitive, operator, and imported generic-implementation
prerequisites; symbolic generic-body operators, methods, applied trait arguments,
implementation-owner bounds, nested obligations, recursive concrete evidence,
caller-bound evidence, imported evidence, owner carrier/generic arguments,
deterministic body-job rebasing, lowering retention, evidence-distinct
same-carrier specialization, transitive caller-bound forwarding, concrete
symbolic-call resolution, nominal generic-parameter restoration before direct
implementation calls, and bounded generic derived equality; marker traits;
and exact applied-trait argument matching.
