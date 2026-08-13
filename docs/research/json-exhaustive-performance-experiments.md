# Exhaustive JSON performance experiments

Date: 2026-08-13

## Scope

This tranche tested the remaining proposed JSON, collection, backend, tooling, and
API directions after canonical String/number provenance:

- generated fixed-schema typed decoding;
- source-retaining validated-document output;
- root-level structural indexes for selective raw access;
- exact Set-backed duplicate tracking after fixing collection scratch locals;
- recursive generic visitor linkage;
- Array-before-Map/Set backend scratch allocation;
- static allocation-site and phase-oriented benchmark instrumentation;
- constructor-to-array-store forwarding, nominal-cast CSE, and private Result
  success-path specialization feasibility.

Only the generally correct backend fix and reusable static allocation-site metric
were retained. Prototype benchmark drivers remain reproducible research tools.

## Retained compiler fix

Array operations initialize shared collection scratch locals before Map/Set
operations are encountered. The previous allocator initialized the remaining
Map/Set scratch locals only when the shared reference scratch local was absent.
A body using Array before Set could therefore reach Set emission without bucket,
hash, or entry scratch locals and fail with `UnsupportedExpression(..., -303)`.
Map emission could fail analogously with `-202`.

Scratch local allocation is now independent per required carrier. The focused
Array-before-Set reproducer compiles and validates, and a backend regression test
covers it. This unblocks exact collection experiments without changing runtime
semantics or generated output for unaffected bodies.

## Static allocation instrumentation

`tools/wasm-metrics.mjs` now reports `allocation_sites`, defined as static
`struct.new` plus `array.new*` instruction sites. This is deliberately not a
runtime allocation count; it is deterministic evidence for comparing generated
module structure and selecting functions for deeper profiling.

The comparison module currently contains 216 `struct.new` sites, 27 `array.new*`
sites, 243 aggregate allocation sites, and 330 `ref.cast` sites. These counts are
identical across small, medium, and large fixtures because the compiler emits one
shared generic JSON implementation and only the embedded fixture data differs.

## Exact Set-backed duplicate tracking

After the scratch-local fix, parse and validation prototypes replaced object-key
Array/Bloom tracking with `Set<String>`. Five rounds of 101 paired samples:

| Fixture | Operation | Bloom + exact fallback | Exact Set | Set delta |
|---|---|---:|---:|---:|
| small | parse | 388.05 ns | 438.31 ns | +12.95% |
| small | validate | 279.90 ns | 304.07 ns | +8.64% |
| small | round trip | 700.65 ns | 758.33 ns | +8.23% |
| medium | parse | 5.426 us | 5.582 us | +2.78% |
| medium | validate | 4.268 us | 4.125 us | -3.20% |
| medium | round trip | 10.011 us | 10.319 us | +3.13% |
| large | parse | 15.537 us | 15.060 us | -3.05% |
| large | validate | 11.361 us | 10.648 us | -6.27% |
| large | round trip | 28.348 us | 28.053 us | -1.32% |

The exact Set path improves large validation but regresses all small workloads,
medium parse and round trip, and large parse only modestly. It is not retained as
the general JSON policy. A future hybrid could switch only for exceptionally
wide objects after allocation profiling establishes a stable threshold.

## Generated typed-decoding prototype

A benchmark-only generator emitted a fixed root struct and compile-time value
ranges for each json-as fixture. Each generated field parsed its validated source
slice independently. This tests schema materialization and code generation while
making the limits of a slice-based implementation explicit.

| Fixture | Generated Dew prototype | Current Dew compact parse | json-as typed parse |
|---|---:|---:|---:|
| small | 183.74 ns | 392.80 ns | 83.40 ns |
| medium | 4.370 us | 5.438 us | 1.735 us |
| large | 32.767 us | 15.470 us | 3.461 us |

The small and medium results prove that frozen-schema code generation can remove
meaningful dynamic-tree overhead. The large fixture has 79 root fields, and
independently invoking the generic parser for every field repeats setup and loses
badly. A production typed decoder therefore needs one shared cursor/event engine,
not generated calls to the public whole-value parser. The prototype is not a
public API.

Generated module sizes were 15.1 KiB, 17.4 KiB, and 28.6 KiB for small, medium,
and large. These remain much smaller than the compared json-as modules, but the
prototype does not yet implement typed numeric conversion or schema diagnostics.

## Structural-index prototype

A benchmark-only root index retained validated source, constructed entries with
compile-time key and source ranges, and parsed one selected root value on demand.
It measured 376.33 ns, 5.512 us, and 11.255 us for small, medium, and large.

This does not beat raw validation/source retention on current fixtures, and its
modules grow to 20.2 KiB, 24.8 KiB, and 46.2 KiB. Index construction is useful
only when amortized across repeated selective lookups or when values remain
unmaterialized. A public structural index still needs explicit contracts for
nested paths, duplicate handling, escaped keys, limits, ownership, index memory,
and repeated access. The prototype is not retained.

## Source-retaining validated-document output

A source-only validated document with trusted source output was prototyped.
Parse plus output measured 301.07 ns, 4.307 us, and 11.286 us. This is essentially
the existing `JsonRawDocument` contract with a redundant name and no canonical
reconstruction. It was reverted instead of duplicating the API.

## Recursive generic visitor linkage

Minimal recursive generic trait visitors, including a mutually recursive generic
Tree walker with runtime trait evidence, now compile and link successfully. The
historical JSON visitor failure was therefore not reproduced by recursion plus
generic evidence alone. The missing case must involve the larger JSON API's
specific capture, nominal recursive value, or callback flow. No compiler change
was justified without a failing minimal regression.

## Backend optimization feasibility

### Constructor-to-array-store forwarding

The JSON construction pattern passes recursive `JsonValue` and `JsonMember`
references through Array's public mutating `push` builtin. Safe forwarding would
need an interprocedural proof that the fresh aggregate has one consumer, that
Array growth does not expose or duplicate it, and that all initializer effects
remain ordered exactly once. Existing struct scalar replacement handles reads,
not mutable collection stores. No bounded correct rewrite was identified.

### Nominal-cast CSE

The comparison module has 330 static `ref.cast` sites, but many are required at
distinct recursive Array, enum, and aggregate boundaries. Local cast elimination
requires a carrier-typed value already proven to have the exact same physical
nominal type and dominance over every use. Existing field CSE does not retain
that physical proof across mutable collection calls. A broad peephole would be
unsound, so no change was retained.

### Result success-path specialization

JSON parser helpers expose public and recursive `Result<..., JsonParseError>`
contracts. Removing success wrappers across calls would change private and public
ABIs together and requires adapter or inlining evidence for every error edge.
Current private enum ABI specialization intentionally excludes recursive,
generic, public, multi-field, and escaping carriers. A JSON-specific exception
would violate the architecture boundary; no change was retained.

## Current pinned json-as comparison

The latest stable compatibility run remains:

| Fixture | Dew compact parse | Dew retained parse | Dew validate | Dew raw document | json-as dynamic parse | json-as typed parse |
|---|---:|---:|---:|---:|---:|---:|
| small | 392.80 ns | 314.97 ns | 281.27 ns | 294.73 ns | 232.36 ns | 83.40 ns |
| medium | 5.438 us | 3.928 us | 4.260 us | 4.258 us | 753.10 ns | 1.735 us |
| large | 15.470 us | 11.401 us | 11.326 us | 11.261 us | 2.640 us | 3.461 us |

Retained parse is 1.36x, 5.22x, and 4.32x slower than json-as dynamic, and 3.78x,
2.26x, and 3.29x slower than json-as typed for small, medium, and large.
Compatibility stringify is 4.44x, 8.22x, and 8.21x slower than json-as typed
stringify. json-as dynamic source passthrough remains semantically inequivalent.

## Credible remaining improvements

1. Build a non-generic or proven-linking cursor/event core, then layer generated
   typed decoding over one pass rather than reparsing field slices.
2. Add opt-in runtime allocation counters at generic WasmGC aggregate emission
   points, with deterministic benchmark exports and zero production overhead.
3. Use those counters to evaluate constructor/store fusion and Result forwarding
   on isolated private functions before broadening their proof domains.
4. Prototype thresholded Set tracking only for objects substantially wider than
   the current large fixture; retain Bloom/exact fallback below that threshold.
5. Design structural indexes for repeated nested lookups, where construction can
   be amortized, rather than one lookup immediately after validation.
6. Investigate exact physical nominal-value propagation through immutable locals
   and call summaries before attempting cast CSE.

The evidence continues to point away from scanner micro-optimizations. The main
remaining gap is one-pass schema-directed construction, recursive aggregate
allocation, collection mutation, Result propagation, and required nominal casts.
