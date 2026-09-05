# Library-owned runtime and short constructors

## Contract

Standard modules must use the same name resolution, type inference, data layout,
specialization, and call emission rules as user modules. A builtin must describe
one Wasm instruction (including its immediate operands), or an explicit unsafe
cast. Loops, allocation policies, collection operations, text algorithms, and
host ABI marshalling belong in Dew source. Foreign host calls use foreign
declarations, not builtins. Replacing an opaque builtin with a wrapper around
another opaque builtin does not complete a migration.

Use small commits per module. Keep required representation and compiler changes
together, with tests for emitted behavior. Do not rewrite published history.

## Work list

- Stable FFI carrier names and pending generated binding metadata: committed.
- Starshine generated export wrappers and clean-provider rebuild: committed and verified.
- Short tuple, unit, and named-field variant constructors; contextual selection,
  imports, opens, impl receivers, ambiguity, and self-host emission.
- Stack: ordinary library functions, no declaration-ID builtin dispatch (committed and verified).
- Array: library-owned storage, growth, mutation, iteration, and erasure.
- Map and Set: library-owned storage, equality/hash evidence, and iteration.
- CircularBuffer, Queue, and Deque: library-owned ring storage and policies.
- Text, Bytes, views, builders, UTF-8, and hashing: library-owned representation
  and algorithms, including literal creation boundaries.
- Ordering, text iteration, JSON, debugging, and WASI: remove indirect opaque
  operations; use library functions or foreign calls as appropriate.
- Numeric, math, SIMD, packed-lane, memory, and conversion modules: audit every
  operation against the one-instruction or unsafe-cast contract.
- Remove standard-module dispatch and fixed declaration ordinal assumptions;
  retain only explicit low-level representation metadata where needed.
- Run routine native, integration, standard library runtime, and A/B/C bootstrap
  tests. Check a clean checkout with the pinned provider.

## Initial findings

Unqualified tuple and unit variants already had inference support. Named-field
construction used a qualified-root name path that did not admit variant names.
The native constructor inferencer also did not select unqualified variants.
Tests now cover local expected-type disambiguation, absent expected type with
ambiguous owners, and imported/opened named-field variants.

The self-host emitter rejected named-field variant patterns, even with a type
prefix. The new end-to-end short-constructor probe exposed that separate gap.
Field extraction must use the selected variant and field identity; field source
order is not physical field order.

The first hardening test generation took 91.701 seconds after rebuilding the
native test tool. This exceeds the 30-second compiler activity limit and remains
a performance bug. Test linking took 5.578 seconds. All 92 pre-existing Dew tests
and 13 pre-existing emission probes passed; the new named-field probe failed
visibly before its emission fix.

The native field-context regression also failed before the fix. Resolving the
match subject's declared field chain before pattern selection supplies the
expected enum without scanning unrelated fields or treating method selectors as
field reads. Five focused native tests now pass. The self-host hardening lane
passes all 92 tests and all 14 emission probes, including named-field
construction and extraction inside an impl (expected result 42). Its cached
generation takes 2.288 seconds. The self-host field pass also seeds ready fields
before variant pattern selection; the full bootstrap check remains required.

## Imported constructor ambiguity

A new regression found that the self-host compiler selected a unique local
constructor before considering an imported constructor with the same name.
For a bare name without an expected enum, selection now counts candidates in
both scopes. Imported candidates must have visible owning declarations.
Expected enum types and explicit qualifications still select by declaration.
An expression without a variant name exits before scanning candidate tables.
The negative regression failed before the fix and now passes; the complete
hardening lane passes 93 tests, 16 invariant records, two record decoder tests,
14 execution probes, and four semantic probes (generation: 2.278 seconds).

The routine native lane passes all 758 tests. After the named-field and Stack
commits, the full A/B/C run validated both output modules and reached a byte
fixed point (`1edc4483e750b84245943899512458a0c06d72069095433671db19649014cf03`).
Array, text, map, set, ring storage, and the remaining builtin migrations are not done;
the checklist above is the remaining implementation scope, not a completion
claim.

## Final verification for this commit series

Rebuilding the clean pinned Starshine provider takes 11.218 seconds and produces
the same SHA-256, `fca7ab4f7db569732f60ff25213e45c5ec7c158b0098b2169e662ff2f95d81d9`.
The binding generator's check mode passes against those rebuilt bytes. Both
repository worktrees contain the complete committed source and metadata.

`tools/check-self-host-bootstrap.sh --clean --fast` passes after the ambiguity
fix, with the native build cache disabled. B and C both validate and are
byte-identical: `8ed9f21e5d1c02ac93eadf8f4da116b0e485a8f4062b0c3c95d44b544a4e07c0`.
A builds in 27.992 seconds. A-to-B takes 48.893 seconds; B-to-C takes 52.081
seconds. The latter two still exceed the 30-second performance limit.
This is a clean-worktree, rebuilt-provider check, not a separate cloned checkout.

The final hardening run passes 93 tests and all 14 execution probes. The
named-field probe now constructs and matches fields in reverse declaration
order, tests a literal field, and reads a different bound field. It returns 42,
so position-only field selection cannot pass this test. Cached test generation
takes 2.276 seconds. All commits remain local; neither repository was pushed.
