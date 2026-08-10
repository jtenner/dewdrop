# Compiler interface freezing and ABI fingerprint performance

Date: August 9, 2026

## Scope

This audit profiled the existing release-native semantic benchmark with 64 modules and 32 public functions per module. The manifest forms a dependency chain, so it exercises imported interface construction, callable ABI hashing, nominal/content fingerprints, and transitive reachable-interface fingerprints while keeping graph construction small.

The benchmark source is `src/semantic/module_system_bench_test.mbt`:

- `bench module interface freeze modules=64 functions=32`
- `bench module full manifest pipeline modules=64 functions=32`
- `bench module interface fingerprint refresh modules=64 functions=32`

## Primary finding: unnecessary body inference

`freeze_program_interfaces_with_cached` previously ran full module-value/body inference for every uncached module. The frozen interface used those inferred values only to recover the semantic types of exported top-level `let` declarations. Function-only modules therefore paid name resolution, imported-semantic construction, and body inference for every function even though no inferred body type entered the interface.

Interface freezing now scans declarations first and runs `infer_frozen_module_values` only when the module actually publishes a top-level `let`. The classifier uses exactly the same visibility rules as interface construction, including compiler-owned standard modules that intentionally publish non-public top-level declarations. Private/test-only/user-module lets do not force interface-time body inference. Public lets continue to receive their inferred semantic type, and ordinary later body analysis remains unchanged.

A paired release-native measurement temporarily restored the preceding committed implementation for the same pre-collected 64-module/32-function program:

```text
Before: 1.21 s ± 88.37 ms
After:  181-270 ms across repeated host-load samples
Improvement: approximately 78-85%
```

The wide optimized range reflects concurrent host activity, but the skipped work and speedup remained unambiguous across runs. This optimization also reduces temporary inference arenas and imported body-semantic allocations for interface-only jobs.

## ABI fingerprint construction

Fingerprint bytes, domains, ordering, and SHA-256 outputs remain unchanged. The optimized implementation changes only construction work:

1. Module `path + NUL + content fingerprint` records are built once for the whole frozen program rather than once per module.
2. Their deterministic lexical order is computed once and reused for every transitive reachable-interface hash.
3. Direct dependency records use sorted dependency module indices rather than sorting paths and rescanning every interface to recover each dependency.
4. Callable, nominal declaration, module-content, and graph fingerprint buffers receive bounded size hints to avoid repeated growth and copying.
5. Graph fingerprint buffers size themselves from the actual reachable count, avoiding unnecessary allocation for unrelated modules.

The isolated 64-module/32-function fingerprint-refresh benchmark changed from:

```text
Before: 41.38 ms ± 3.06 ms
After:  35.80 ms ± 3.73 ms
Improvement: approximately 13%
```

A temporary transitive-only probe fell from about 6.33 ms to 3.40 ms while validating the record-order construction. It was removed after profiling; the permanent refresh benchmark covers the production batch path.

## Correctness and determinism

The optimization preserves:

- callable V4, nominal V2, module-content V2, and graph V1 fingerprint domains;
- exact serialized bytes and SHA-256 results;
- source order inside declarations, fields, variants, requirements, callables, and implementations;
- lexical order for dependency records and reachable module records;
- manifest-indexed frozen interface output;
- SCC execution and repeated cyclic-interface behavior;
- public module-value type inference;
- cached and uncached interface equivalence.

White-box coverage checks the exported-let inference classifier and verifies that inferred public-let types remain frozen. Existing ABI, cache, module graph, imported-module-value, and snapshot tests continue to exercise the externally observable results.

## Remaining opportunities

- Profile declaration fingerprint field/variant/requirement grouping on aggregate-heavy interfaces before adding indexes; the current function-heavy benchmark is dominated by hashing rather than scans.
- Consider validating and freezing exported module lets independently from executable function bodies if module-value inference becomes a measurable interface bottleneck.
- Preserve the current no-exported-let fast path when workspace interface caching and parallel interface jobs are added.
- Avoid transitive reachability bitset caching unless large sparse graphs justify its memory cost; the current reusable record ordering captures most of the avoidable allocation without quadratic retained memory.
