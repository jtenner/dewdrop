# Compiler adversarial correctness and performance audit

## Scope

This audit followed cross-package orphan-rule enforcement and intentionally targeted hostile cache payloads, imported evidence scaling, external nominal-reference ABI edges, and backend optimizations that looked attractive but had not been measured.

The audit rules were:

- reproduce correctness failures before changing implementation code;
- keep malformed inputs fail-visible rather than converting them into cache misses;
- preserve deterministic implementation and diagnostic order;
- retain exact coherence semantics while reducing candidate work;
- reject optimizations whose measured result is slower, even when their asymptotic story appears better.

## Confirmed cache-decoder crash

The V11 orphan-evidence check called ordinary resolved-type head helpers directly on type IDs decoded from the cache payload. A structurally decodable payload could therefore place an out-of-range implementation `trait_type` or `target_type` in a frozen interface and make `deserialize_frozen_interfaces` abort through an array bounds failure instead of returning `Err`.

The decoder now uses bounded implementation-head traversal that:

- rejects out-of-range type IDs;
- rejects invalid applied-type argument spans;
- bounds traversal by the resolved-type arena length, rejecting cyclic applied heads;
- validates trait-implementation declaration ownership and generic-parameter spans;
- distinguishes invalid implementation evidence from a structurally valid orphan implementation.

The permanent regression test constructs an invalid V11 payload through the ordinary serializer and requires:

```text
Err("frozen-interface cache contains invalid implementation evidence")
```

rather than a process abort.

## Imported implementation indexing

`build_module_impl_index_with_imports` previously performed two avoidable broad scans:

1. every imported implementation rescanned every callable in every imported interface to find its methods;
2. every imported trait implementation compared against every earlier implementation before filtering by trait and normalized target head.

The implementation now:

- indexes imported implementation callables once by owner declaration;
- rebuilds the existing compact implementation buckets once after imported evidence is appended;
- performs local/imported and imported/imported coherence comparisons only inside the exact trait/target-head bucket;
- reuses that bucket layout for later inference rather than rebuilding it a second time.

Source order inside each bucket remains implementation-index order, so overlap diagnostics, specificity changes, and coherence removal retain their previous deterministic ordering.

Paired release-native runs with 512 imported implementations on distinct nominal heads measured:

```text
before   11.28-11.35 ms mean
after     7.68-7.78 ms mean
change   about 32% lower mean time
```

The benchmark remains in `src/semantic/impl_method_bench_test.mbt`.

## Imported aggregate metadata

`resolve_module_imports` previously rescanned the complete frozen field array once for every imported struct or enum declaration. Frozen fields already preserve declaration/source order, as do enum variants, so field translation now advances one monotonic cursor exactly once through each interface.

Paired release-native stress runs with 1,024 imported structs and eight fields each measured:

```text
before   22.60-32.65 ms mean
after     8.55-10.11 ms mean
change   roughly 60-70% lower mean time in the stress regime
```

The benchmark remains in `src/semantic/module_system_bench_test.mbt`.

## External nominal-reference ABI probes

The legal local-trait/imported-target ABI path was expanded beyond a local receiver variable. Backend validation now also covers:

- an imported nominal value loaded from a local aggregate field;
- the same imported nominal value captured by a local lambda;
- calls into a local implementation method whose Wasm parameter uses the provider's exact nominal reference type.

Both generated module validation and binary encoding must succeed. This guards against broadening the targeted cast fix into redundant casts while also checking erased local/capture storage paths.

The semantic suite also explicitly verifies that compiler preamble traits such as `Eq` remain standard-package-owned when referenced from an ordinary module; an ordinary implementation for an imported nominal target remains an orphan.

## Rejected optimization

Starshine currently determines whether a generic specialization is a runtime-trait implementation specialization while finishing calls. Caching that Boolean in `StarshineGenericSpecialization` looked like an obvious reduction from repeated scans to one scan per function.

A 4,096-call generic-chain emission benchmark showed the attempted change was slower on this compiler/runtime:

```text
existing path       about 11.1-12.0 ms
cached-Boolean path about 14.1-16.7 ms
```

The implementation change was reverted. The 4,096-call benchmark remains to make future changes measurable. A future optimization should use profiling and likely place an indexed specialization classification in the frozen program-link plan instead of widening the hot backend specialization value.

## Remaining adversarial opportunities

1. Validate the complete frozen resolved-type graph in one bounded linear pass, then let individual cache consumers use unchecked arena access without repeating local guards.
2. Replace temporary per-implementation callable arrays with compact owner spans if allocation profiling shows the map is material.
3. Index imported declaration metadata used by `is_struct`, `is_enum`, and `generic_parameters_of`; those helpers still linearly scan imported declarations.
4. Profile declaration fingerprint field/variant/requirement grouping on aggregate-heavy interfaces; function-heavy interface freezing now skips unnecessary body inference and reuses deterministic graph-fingerprint records as documented in `compiler-interface-freezing-performance.md`.
5. Add randomized malformed V11 payload generation for type IDs, spans, declaration ownership, ordering, and cyclic structural recipes.
6. Add explicit compiler work budgets for type-graph traversal, implementation overlap, and imported-interface cardinality so hostile source or cache input fails diagnostically rather than exhausting resources.
