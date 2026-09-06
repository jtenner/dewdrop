# Compile-time query completion work

This continues the September 5 work. Unchecked tasks remain unchecked until both
compiler paths and their execution tests pass.

## Native member names and scalar layout

`field_names<T>()` and `variant_names<T>()` select a declaration by its logical
type identity. Their results keep source order. Generic queries wait for concrete
arguments and use the existing logical instance keys. The folded IR contains a
string-array constant, not a call to a reflection runtime. Each evaluation builds
a fresh array, so mutating one result cannot change another.

`size_of<T>()` and `align_of<T>()` describe raw scalar memory representation, not
GC object allocation. Narrow integers occupy 1 or 2 bytes; 32-bit words and Bool
occupy 4; 64-bit words occupy 8; SIMD values occupy 16. Packed lane values use their
backing word size. Alignment is the natural scalar alignment, not a claim that
Wasm forbids unaligned loads. Unit has size 0 and alignment 1. Never, Type,
references, tuples, and nominal GC objects do not have a supported byte layout.

No GC field offsets can be reported. `field_offset` still needs an explicit
linear-memory aggregate layout contract; the GC field index is not a byte offset.
The later [raw tuple layout work](raw-type-layout-2026-09-06.md) supplies that
contract for ordered tuples; nominal GC records remain unsupported.

The new module dependency on Array is declared in `std/types.dew` and included by
source discovery. This work found a pre-existing identity collision between
`dew.std.types` and `dew.std.facet`: both used reserved module slot 70. Types now
uses slot 79, beyond the Facet family at 70–78. A wildcard collection test checks
that every loaded module ID is unique.

Initial checks: 27 focused semantic tests pass; the Wasm fixture passes 30 checks,
including names, empty names, generic forwarding, fresh-array mutation, and scalar
layout. The routine native suite passed in 70.041 s; integration passed all 266
tests in 45.790 s. Scoped API refresh passed in 3.619 s; generated-source checks
passed in 18.770 s. The routine backend lane took 34.893 s. The runs above 30 s
are performance defects, not hidden passes under the timing policy.

## Still active

- Deferred member types with unconstrained generic owners.
- Guarded type checking and refreshing flow after branch selection.
- Early pruning of physical dependencies and unused storage.
- Full native/self-host execution parity and bootstrap comparison.

## Self-host member types and evaluator foundations

The self-host parser now accepts computed member types, including module aliases
and explicit `::<...>` syntax. A pending split `>>` cannot consume an ordinary
call's argument list. Member resolution selects declaration identities, preserves
generic arguments and payload order, and returns real resolved types. Nested
queries preserve their caller's traversal scratch. Cycles, missing members,
ordinary-function impostors, invalid signatures, and invalid selectors stay
source errors. Imported query overloads are rejected, not chosen by order.

The pure self-host evaluator now has structural logical types and scalar query
rules. It keeps pending types separate from erroneous types; identical physical
carriers do not establish type equality. Work stacks and explicit resource errors
bound traversal. This is a foundation, not yet self-host source-call folding.

The hardening suite passes 175 tests, 29 exact numeric trap records, both host
record tests, and all emission/semantic probes in 19.264 s. The initial cold C
build took 90.092 s and is a visible performance defect. Intermediate parser and
typing failures were corrected before the passing run.

## Self-host logical specialization keys

Query-sensitive functions and their transitive callers now retain structural
logical arguments in the existing specialization request index. Equality is
structural, not based on a hash or Wasm carrier. Nested applications, products,
functions, nominal IDs, trait IDs, and primitive identities survive reading from
both resolved and inferred arenas. Generic caller bindings use complete semantic
IDs; the I32 resolved-type encoding adds before negation to avoid overflow.

A source test forwards `I8` and `U8` through `outer<T>` into `inner<Box<T>>` and
checks that both logical requests survive. The hardening suite passes 176 tests
and the existing record and execution probes. Folding into per-request bodies
and using those bodies at every emission boundary remains the next step.

## Self-host source-call folding and physical closure

The evaluator now folds source calls in private per-request module arenas. Call
scanning, fragment planning, body planning, verification, and emission select the
same instance. Its request record retains the exact declaration and structural
evidence; reuse with a different identity is an invariant failure. Receiver
normalization preserves that evidence instead of making an ABI-only request.

Queries and dead expressions lose their call targets. Branch selection preserves
the selected expression's own identity and conversion boundary. Consumed method
callees still visit their runtime receiver. The reachable graph includes nested
lambdas; discarded lambdas add no function, closure, or mutable capture-cell
fragment. Generic templates are not rewritten. Full local/type dependency pruning
and post-selection flow refresh are still open.

`implements` uses the checked implementation index and structural substitutions.
Imported generic prerequisites keep their original IDs and spans. Absence is
false; ambiguity, cycles, and search limits are distinct diagnostics. A 65-level
valid prerequisite chain is tested. Query errors include the module, declaration,
body, specialization request, expression, and source offset. Static assertions
run only in retained branches and report CT-021/CT-022, not anonymous traps.

The bootstrap fixture now includes `dew.std.types`; omitting it had produced
misleading downstream specialization failures. Its emission probe validates
source phases before linking. The shared corpus has 32 checks and a separate
generic branch test returning 13234. It runs against both compilers. The self-host
resolver also now resolves explicit generic call arguments inside lambda spans;
the previous omission sent the missing sentinel into SOL-207.

Self-host hardening passes 184 tests, 29 exact invariant records, both host record
tests, and all execution/semantic probes. Warm runs took about 20 s. The final
run took 107.909 s due to a cold native C build; this remains a performance defect.
Native shared execution passed 32 checks in 0.039 s; its cold build took 88.106 s.
Native logical lambda entry work is a separate follow-up commit.

## Native logical lambda entries

Query sensitivity now includes expressions inside lambdas, by their owning body
ID. Each selected query instance has its own live lambda function entries, with
the owner's full logical key. Function-reference lookup checks that exact key;
it does not select the first lambda declaration in the link table. Calls inside
lambda bodies are scanned with the root function's substitutions. Emission uses
the selected module and lambda-entry table. The generic source template remains
unchanged. This does not yet rebuild generic capture/parameter storage layouts;
those remain part of the physical-storage task.

All 27 focused native query tests pass (13.500 s), including a new IR and link
test with distinct Unit/I32 lambda results. The 32 shared execution checks pass.
The full integration lane passes (51.675 s, a timing defect).
The routine native lane passes in 23.394 s. A lambda that would require changed
signature/capture storage now reports CT-038 before emission; it must not reuse
the old physical signature. This guard remains until those layouts are rebuilt.

## Local compile-time type bindings

Both parsers and compilers now accept ordered, block-scoped type bindings:

```dew
type Item = field_type<Box<I64>>("item")
let read = fn(value: Item) -> Item {
  type Inner = Item
  identity::<Inner>(value)
}
```

These are real type aliases, not runtime `Type` objects or strings. The right-hand
side sees preceding bindings. An inner binding can shadow an outer one without
changing it. Lambdas retain the type scope at their declaration. Bindings do not
leak into later functions or module signatures. Local generic alias parameter
lists are not part of this syntax; a binding can use its owning function's type
parameters. At this checkpoint unconstrained member projections still reported
CT-035; the deferred projection work below replaces that restriction.

A type-binding HIR expression keeps the type syntax reachable to signature
checking even when unused. Its logical result is Unit and it emits no value.
Native parse-event codec V1 uses block-item tag 5; round-trip tests cover computed
targets. Native scope maps are immutable snapshots and copy only when a new
binding is added. Self-host scopes use an arena stack with captured lambda
snapshots and checked restoration.

The initial two native tests failed on the missing syntax, then passed after the
implementation. The full parser suite passes 289 tests (1.714 s), focused semantic
tests pass (7.709 s), and both engines pass 33 shared execution checks. Native
execution took 0.024 s. Self-host hardening passes 186 tests and all record and
execution probes. Its cold build run took 108.284 s; the routine native lane took
62.728 s. These remain visible timing defects. Scoped API refresh passed in
3.467 s.

## Bootstrap regression: mixed Result payloads

The first clean bootstrap after the query work failed while compiler A emitted
compiler B. `self_host_specialization_evidence_type_equal` matched a
`Result<Bool, String>`. An emitter heuristic saw that the Ok arm returned its
Boolean payload and incorrectly used that carrier for the Err arm's String too.
The final validator reported a String call argument as i32.

A small shared fixture reproduces this without rebuilding the whole compiler:
one arm returns the Bool payload, the other compares the String error message.
Both the Ok and Err executions must return true. The unpatched self-host compiler
fails Wasm validation on this fixture. The correction restricts legacy fallback
inference to the current arm and never lets it override a frozen body plan.
The payload/result assertion also checks the current arm, not any sibling arm.
Tracing the plan exposed a second defect: local allocation changed its verified
reference carrier to the inferred scalar. Local allocation now consumes the
frozen carrier directly; the legacy recovery path is only for calls without a
body plan. No name or sibling arm can rewrite a planned local during allocation.

The hardening suite passes 186 tests, 29 exact invariant records, both host record
tests, all execution/semantic probes, and the expanded 35 shared query checks in
20.421 s. The clean bootstrap now builds and validates compiler B, which passes
the semantic probes. B then rejects the two type-producing builtin signatures
with CT-037 when compiling C. This is a separate storage-permission defect; the
A/B/C fixed point is not yet established. A built in 31.195 s and emitted B in
44.624 s; both exceed the performance budget. The whole failed run took 92.237 s.
The expanded fixture also exposes a native backend `UnsupportedExpression`
(root declaration 11, expression 63). The previous 33 native cases passed;
the 35-case native run is not green and remains a required follow-up.

## Native constructor reachability correction

The expanded fixture exposed the wrong constructor operand span in the native
query reachability visitor. `PlannedVariantTupleNew` stores type arguments second
and runtime arguments third. Struct and named-variant constructors use that same
ordering. The visitor had read the second span as values, removed live payloads,
and sometimes visited unrelated expression IDs. All three cases now visit the
third span in its correct arena.

The native fixture builds and passes all 39 current checks, including both mixed
Result arms and the new raw-layout cases. The build took 8.890 s in the debug
native tool, execution 0.025 s, and 32 focused semantic tests passed in 14.822 s.
Release C rebuilds took about 89 s and remain performance defects. The test
generator now reports module, declaration, body, expression, source offset, and
IR kind when an expression cannot be emitted.

## Deferred member aliases and logical query operands

Both compilers now retain `field_type<T>("item")` and
`variant_payload_types<T>("Value")` as structural type projections when `T`
is not yet known. Alias substitution reduces a projection with concrete owner
arguments. Pure queries reduce it again under the caller's exact logical
bindings. Nested and imported aliases preserve declaration identity; no pending
projection becomes Ref or a physical signature certificate.

Projection identity includes the owner type, validated builtin operation, and
selector. Native interface codec V1 preserves these fields and rejects invalid
owner indices or operations. Recursive resolution uses fresh traversal stacks;
canonical type arenas and cycle guards remain shared. Alias dependency walks
include projection owners and product members. Invalid concrete aliases are
checked even when unused.

Eight native computed-type tests pass (11.672 s), including nested imported
aliases and frozen interface round trips. Both compiler paths pass 47 shared
query executions. Native fixture execution took 0.025 s. The hardening run
passed 191 tests, 29 invariant records, and all execution/semantic probes in
39.540 s; this total exceeds the 30 s performance budget. The final hardening
run also covers unused-alias validation and passes in 37.869 s. The preceding
native integration run passed in 51.851 s.

This does not yet finish runtime generic projection signatures or guarded body
inference. Those remain explicit tasks, along with early storage pruning and
post-selection flow/effect refresh.

## Ordered non-returning evaluations and refreshed flow

The query rewrite now refreshes flow in postorder, then walks the reduced graph
again to remove cut edges. Strict argument lists stop at the first expression
that cannot fall through. The parent call is replaced with an explicit ordered
evaluation prefix: native parameter-select IR or self-host evaluation-sequence
IR. Earlier values are discarded after evaluation; the final transfer keeps its
own source expression and control target. Later arguments and statements do not
reach specialization. Blocks, arms, bodies, and lambda roots get refreshed flow.
Repeating the rewrite does not grow the expression-child arena.

The execution fixture exposed an independent array-literal dependency defect:
a nonempty literal required an otherwise unreferenced runtime push function.
Self-host literals now evaluate their elements in source order and use one
`array.new_fixed`, followed by the existing wrapper constructor. Unit elements
retain their effects and receive only a storage marker. This removes the hidden
push target and repeated growth calls; the broader Array layout migration is
still separate work.

Native query tests pass 35 cases in 15.471 s. Both paths pass 49 shared execution
checks, including a side effect before a non-returning argument and selected
generic returns. Hardening passes 192 tests and 29 exact invariant records,
plus all execution/semantic probes (38.063 s). The routine native suite passes
848 tests in 80.255 s. Its semantic (30.891 s) and backend (34.593 s) lanes exceed
the 30 s budget and remain performance defects. Storage pruning and guarded
type inference are not yet complete.

The full A/B/C bootstrap also passes after these changes. Compiler B and C are
byte-identical in raw, core, and linked form. A builds in 35.931 s; A-to-B takes
45.321 s and B-to-C 47.857 s. The full check takes 148.050 s. These long build
times remain performance defects; the fixed-point and semantic checks pass.

## Dead local and pattern storage

Planned locals and patterns now record explicit elision. Their logical type,
shape, and identity stay intact. Each selected body and lambda marks its live
local reads, writes, declarations, and pattern bindings. Parameters keep their
declared ABI positions; erased Unit parameters still use the normal projection.
Native local allocation and self-host frozen local-slot allocation omit dead
locals. They do not rewrite dead I64 types to Unit or Ref.

The reachability graph now visits patterns and their literal expressions.
Previously a live numeric match literal could be poisoned by query pruning.
Native nominal-demand scans ignore dead patterns, and dead lambda signatures
are not roots of physical function-type planning.

Two focused native storage tests pass (8.333 s). Both compilers pass 51 shared
execution checks, including separate generic local layouts and literal matches.
The native fixture built in 9.058 s and ran in 0.030 s. Hardening passed in
38.577 s before the final dedicated local-elision test. The full native
integration lane passes in 63.039 s. Both totals exceed the performance budget.
Self-host nominal type tables and generic template storage still require an
earlier demand boundary; this checkpoint does not claim to finish that work.

Final checkpoint hardening passes 193 tests, 29 exact invariant records, and
51 shared execution checks in 41.005 s. The added local-elision test passes;
the elapsed time remains over the performance budget.

## Independent specialization runs

Each self-host specialization run now owns its request-indexed query instances
and a copy of its diagnostic list. Immutable source facts remain shared. A later
plan cannot reuse an earlier plan's request numbers or invalidate its selected
bodies. The new test failed on the shared context and passes with private state;
it also mutates the second context to verify the first remains intact. Hardening
passes 194 tests, 29 invariant records, and 51 execution checks in 29.524 s.

## Self-host nominal storage demand

Physical nominal tables now follow reachable non-generic functions and exact
selected requests. Live expressions, locals, patterns, lambda captures, and
callable signatures seed a type-arena work queue. Generic substitutions retain
logical nominal identities. Required declarations then enqueue their declared
fields and variant payloads, including imported and recursive dependencies.
Sparse visited sets bound each scope's traversal; a declaration enters the
global queue only once. Lookup spans and identities are checked before access.
Discarded generic bodies are not scanned as physical templates. The common
closure runtime type remains separate from nominal demand.

Hardening passes 196 tests, 29 invariant records, and 51 shared query checks in
29.463 s. The new tests cover a discarded generic enum constructor/match and a
recursive record with a transitive field type. The stable-source A/B/C bootstrap
passes and B/C outputs are byte-identical (146.757 s total). An earlier comparison
used different request sources because a helper was reformatted during the run;
the two request files confirm that change. The repeated run used unchanged Dew
source. Full bootstrap time remains a performance defect.

## Generic lambda templates have no physical signatures

Native fragment planning now uses a private view that excludes query-sensitive
generic lambda bodies and their typed storage. The logical source template stays
intact. Each live exact instance creates its own lambda function, signature, and
capture layout directly; it no longer needs a placeholder generic signature.
The common closure ABI remains visible separately. Selected function-type maps
use exact lambda expression identities even when no template entry exists.

The regression first trapped with `SPC-301 unresolved member projection reached
a physical signature`. Its discarded branch passes a lambda containing
`field_type<T>("item")` to a generic function. The fixed path emits neither the
lambda function nor its closure/capture types. All 38 focused native query tests
pass in 17.233 s. Both compilers pass 52 shared execution checks; hardening passes
196 tests and 29 invariant records in 29.534 s. Native nominal root discovery
still scans generic source bodies, and guarded inference/runtime projection
types remain separate unfinished work.

The full native integration lane also passes in 51.474 s; that elapsed time is
still over budget. The scoped generated-API refresh passes in 3.503 s.

## Native inferred member projection terms

Native inference now retains `BodyMemberTypeProjection(owner, operation, name)`
when a signature's owner is not yet known. Substitution visits the owner instead
of treating the projection as an opaque resolved ID. An immutable per-module
recipe table retains local/imported generic parameter IDs, field declarations,
and ordered variant payloads. Concrete owners reduce through these recipes;
unknown owners remain symbolic. Projection operators are not injective: the
solver does not infer an owner from the projected field type.

Call checking orders ordinary parameter constraints before dependent member
constraints. If the owner expression itself still needs inference, the body
holds the equation with its original source location and drains it in the shared
resolution loop. Speculative solver transactions cannot append these persistent
equations. A final unresolved equation is a visible failure, not an erased check.
This does not yet defer errors under compile-time branch guards.

Projection owners survive zonking, body/lambda/module-value copying, compaction,
logical query reads, signature pooling, and frozen module values. V1 body codecs
use type tag 6 and diagnostic tag 2. New graph checks reject invalid operations
and cyclic/forward projection-owner links. Missing members and resource limits
keep a dedicated diagnostic and its constraint origin. Freezing also retains any
new diagnostics rather than dropping them after the constraint phase.

The two original call-inference tests failed before the change. The later-owner
argument test exposed a separate early-check error and now passes too. All 46
focused query tests pass in 23.080 s, including eight projection tests covering
imports, generic forwarding, ordered payloads, call origins, codecs, and occurs
checks. The routine native suite passed 857 tests in 84.445 s before the final
two projection cases. Semantic (34.359 s) and backend (31.588 s) lanes remain over
budget. Hardening passes 196 tests, 29 invariant records, and 52 execution checks
in 38.248 s; the API refresh passes in 3.394 s.

This checkpoint covers native inference, not runtime emission of generic member
signatures. Exact private physical types and the self-host solver port are next.
Native nominal demand and guarded branch inference also remain open.
