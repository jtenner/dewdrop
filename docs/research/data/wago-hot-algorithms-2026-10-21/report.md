# Research report: rebuilding the trait-implementation index is quadratic

I used only Read, Grep and Glob. I did not edit, build or run anything.

## Answer first

My best lead is in the Dewdrop compiler source, not in Wago. The function that builds the trait-implementation index (the "impl index") does two nested scans over all imported callables. Both scans can become linear with an owner chain. That is the same `buckets` + `next` pattern that `SelfHostResolvedTypeInterner` already uses.

**This change cannot affect the pinned compiler WASM.** It only helps after root builds a new compiler WASM, which gets a new hash. That also changes V8's time, so the Wago/V8 ratio may not improve.

## Measured facts (from `docs/research/wago-read-followups-profile-2026-10-21.md`)

- Generated code is 79% of profiled time. CollectMinor is 13%.
- Of 1098 native samples, `index_module_implementations` has 89 and `imported_requirement_identity` has 74. Together that is 163, about 15%.
- Import interning regions: `intern_function` 53 and `simple_equal` 17.
- These are locality samples, not execution counts.

## Source facts

**1. The impl index scans are quadratic.** Function: `self_host_index_module_implementations_with_imports`, `self_host/compiler/semantic_impl_index.dew:1432`.
- Lines 1443–1549: for each imported impl, it scans every entry in `imports.callables` to find `FrozenImplCallable(owner)`. Cost: O(I·C), where I = imported impls and C = imported callables.
- Line 1492: for each matched trait method, it calls `self_host_imported_requirement_identity` (`:1412`). That function scans all of `imports.callables` again. Cost: another O(M_t·C), where M_t = trait methods.
- Line 1304, in the local-impl path: the same requirement scan runs for each local trait method. The local loop at 1294 also scans all of `collected.methods` for each local impl: O(L·Mc).

**2. The index is rebuilt many times.** It is never edited after it is built (a grep found no writes outside the builder). Call sites:
- `semantic_inference_trait_obligations.dew:23`: memoized only per body inferencer, so one full build per body that needs trait obligations or trait-object coercion.
- `semantic_compile_time_guard_dispatch.dew:326`: one build per guarded body, plus a full `self_host_resolve_module_imports` at `:320`.
- `semantic_compile_time_implements.dew:448`: one build per `implements` query, plus a full import resolve at `:442`.
- Also `:318` (associated scopes), `semantic_lowering_plan.dew:1737` and `semantic_compile_time_recheck.dew:79`.

**3. Import interning is a linear scan.** `SelfHostInterfaceTypeImporter::intern_function` (`semantic_imported_semantics.dew:542`), and the same pattern in `intern_applied` (501), `intern_product` (463) and `intern_imported_simple` (414), scan all of `resolved.types`. `intern_function` runs once per imported callable (`:1008`). Cost per resolve: O(C·T), where T = type count. The `intern_function` at `semantic_resolved_types.dew:619` is already hashed, so it is not the problem.

## Inference

- `array_get_unchecked` (80) and `array_length` (34) are probably called from these scan loops. Their loop bodies are exactly `callables.length()` plus `callables[slot]` plus a tag match.
- I cannot see dynamic counts. How many builds happen per job is unknown.

---

## Proposal: make the impl-index build linear

**Change**, in `semantic_impl_index.dew` only:

1. Before the imported-impl loop, do one pass over `imports.callables` and build two chains:
   - `owner_head: Map<U64, U32>` + `owner_next: Array<U32>`, for `FrozenImplCallable(owner)` entries.
   - `trait_head: Map<U64, U32>` + `trait_next: Array<U32>`, for `FrozenTraitCallable(owner)` entries.
   - Fill the chains in **reverse** slot order. Then each chain runs in ascending slot order, which is the current push order.
2. Lines 1466–1529: walk `owner_head[imported.declaration]` instead of all callables.
3. Change `self_host_imported_requirement_identity` to walk the `trait_` chain and compare `name`. Walk the whole chain so the `EVD-212` duplicate assertion still runs.
4. Pass the same requirement chain into `self_host_index_module_implementations_context` for line 1304.
5. Optional, same commit or the next one: a `collected.methods` parent chain for the local loop at 1294.

**Complexity:**
- Before: O(I·C + M_t·C + L·Mc) per build.
- After: O(C + I + M + Σ chain lengths) expected. The trait chain is only as long as one trait's requirement list.
- The pairwise coherence loop (1550–1632) does not change.

**Work removed:** per build, about I·C callable loads and tag matches, plus M_t·C loads, `==` checks and string compares.

**Correctness:**
- Output order must stay byte-identical. Method order sets `method_slot`, the dispatch order and the diagnostic order.
- No cache lives past the call, so there is nothing to invalidate. All checks stay.
- Standard and user modules use the same code path. No codec or version change.

**Memory:** two `U32` arrays of length C and two maps with ≤ I and ≤ T_traits entries. All are short-lived, so expect a small young-generation cost (memory that the minor collector frees soon).

**Smallest test that tells the answer:**
1. Build two compiler WASMs from the same tree: A without the change, B with it. Run the same fixed request bytes on the installed Wago stack, three runs each.
2. All output WASM and cache hashes must equal the pinned outputs, and `main` must return 42.
3. The deciding check: a native-PC profile of B. Samples for `index_module_implementations` + `imported_requirement_identity` should drop from ~163 to near 0, and `array_get_unchecked` / `array_length` should drop too.
4. If the job time changes less than the run-to-run spread while those regions do drop, the regions were not the real cost. Then stop.

**Implementation plan (one atomic commit):**
1. TDD: add a case to `self_host/compiler/semantic_impl_index_test.dew`. Use two imported impls whose callables are interleaved in the callable list. Assert the order of `methods` and `method_dispatch`, and the requirement identities. Also run the existing `semantic_trait_evidence_test.dew` and `semantic_imported_trait_contract_test.dew`.
2. Add the chain builders and rewrite the two loops plus `self_host_imported_requirement_identity`.
3. Run `tools/test-native.sh`, then `tools/test-integration-native.sh`.
4. Do the A/B check above. Write the note in `docs/research/`.

---

## Fallback: hash the import interner

Apply the same chain idea to `SelfHostInterfaceTypeImporter` in `semantic_imported_semantics.dew:414–585`.

1. When a builder starts, do one O(T) pass over `resolved.types` and key each type on its raw ids. Example: `mix(tag, result, param ids…)`. Ids are already canonical, so no recursive hash is needed.
2. Add to the chain on each push.
3. Return the **lowest** matching index, to match the current first-hit linear scan.

- Cost: O(C·T) → O(T + C) per resolve.
- This also helps every repeated resolve at the 5 call sites above.
- Risk: the table is shared and mutated across resolves. Rebuild the chain for each builder; do not keep it on `SelfHostResolvedModuleTypes`.
- Test: the same A/B check. `intern_function` and `simple_equal` samples should drop.

## What I did not propose, and why

- **Cross-body or cross-query memo of index/imports.** It is a larger win, but the import resolve mutates the shared resolved-types table, and the compile-time paths use a different `resolved` than `imports.resolved`. It needs an equality proof first. Do it only if, after the proposal, a counter still shows many builds per module.
- **A Wago loop-hoisting pass over these scans.** It needs reasoning across the loop back-edge. That is the interval or epoch class you said not to propose. Removing the scans in source removes the need.

I gave no speed guarantee. The 4-second V8 target is not shown to be reachable by this change.

**What you do now:** decide if root should build a new, non-pinned compiler WASM for the A/B test. My pick is yes: do the primary proposal first. It is local, it keeps the order, and it adds no cache.
