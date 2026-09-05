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
- Pending Starshine generated export wrappers and clean-provider reproduction.
- Short tuple, unit, and named-field variant constructors; contextual selection,
  imports, opens, impl receivers, ambiguity, and self-host emission.
- Stack: ordinary library functions, no declaration-ID builtin dispatch.
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
