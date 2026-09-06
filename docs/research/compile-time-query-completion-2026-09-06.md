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

- Deferred member types and local compile-time type bindings.
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
