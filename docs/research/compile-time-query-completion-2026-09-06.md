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

- Self-host evaluation and structural logical instances, including name queries.
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
