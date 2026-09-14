# Compile scaling audit, 2026-09-14

The [second audit](compile-hotpaths-2026-09-14.md) adds four further fixes and cuts full-build time by another 60%.

Four agents reviewed separate areas without changing code. The main agent wrote all fixes and experiments. Baseline: `6a242163`.

## Combined findings

| Area | Repeated work | Change | Proof |
| --- | --- | --- | --- |
| Parser cache | Copies full diagnostic paths at every recursive AST node; deep chains copy quadratic text | Bound field paths on the first pass; repeat with full paths on error | Deep AST roundtrip; every truncation returns the same error as full-path decoding |
| Module interfaces | Each acyclic module computes dependency hashes for all available roots, then keeps one | Compute only the requested root; keep all declaration identities and the full SCC refresh path | Compare single-root and full refresh on a diamond, cross-module type signatures, missing unrelated modules, and missing dependencies |
| Backend facts | Repeated whole-program effect scans and two linear planned-function searches per function | Reverse call edges and a queue; one function-index table | Compare with the old fixed point on chains, cycles, self-calls, imports, and unknown calls; check distinct effect bits |
| Cache packs | Hash each owner during each lookup and each sort comparison; sort twice when encoding | Full owner/digest checks for loaded entries; hash sort keys once; remove duplicate sort | Insertion-order-independent bytes, loaded and indexed hits, wrong full digests, strict decode and re-encode |
| Core linker | Find each recursive group's first type by scanning the type list from zero | Keep a type cursor; remove the unused reverse group array | Empty groups, mixed recursive groups, marker and concrete bindings, invalid marker group; existing linker validation tests |

These changes keep V1 formats. They do not change standard-module semantics or add runtime builtins. Backend and linker index assumptions have diagnostic assertions.

## Measurement method

New `compile_scaling_bench_test.mbt` files cover parser, semantic, backend, and cache packages. The core linker uses `compile_scaling_bench_wbtest.mbt` to reach private helpers. Fixtures are prepared outside the timer. Moon's native release benchmark runner reports ten sample groups.

Run `tools/benchmark-compile-scaling-native.sh` for all five benchmark files. It runs each file separately with `moon bench --target native --release --no-parallelize`, wrapped with `self_host_measure` from `tools/self-host-common.sh`. Build costs are reported separately from benchmark sample times.

`tools/benchmark-compile-scaling.py BEFORE.js AFTER.js --modules 128 --runs 5` compares standalone compiled JavaScript CLI artifacts. By default it disables all compiler caches. `--cache-mode warm` enables parse/interface caches and cache packs in separate fresh directories, requires warm parse hits, and keeps whole-program caching disabled. It omits the shell/build wrapper, alternates run order, discards the first pair, and checks that every output has the same SHA-256 hash. Each compile has a 30-second timeout. The CLI is JavaScript in `tools/run-dew-cli-host.sh`; copying the native bootstrap executable alone does not freeze the compiler.

## Results

Native release means (larger fixture in each family):

| Case | Before | After | Speedup |
| --- | ---: | ---: | ---: |
| Cached expression, 1,024 terms | 571.95 µs | 132.11 µs | 4.33× |
| Interface freeze, 128 modules | 1.81 s | 1.41 s | 1.28× |
| Compiler facts, 512 functions | 2.49 ms | 433.15 µs | 5.75× |
| All loaded cache hits, 512 entries | 65.25 ms | 310.20 µs | 210× |
| Cache encode, 512 entries | 7.50 ms | 1.98 ms | 3.79× |
| Link type maps, 8,192 groups | 14.59 ms | 21.55 µs | 677× |

The complete 128-module CLI build, with all caches disabled, fell from a median **6.472 s to 5.412 s**, a **16.4% time reduction** over five runs per compiler. All twelve outputs, including the discarded first pair, have SHA-256 `0ec67cc8d77fbce3494f86deaf86172b069d4193c5e4fe4e6025fd9c062477f8`.

With warm parse/interface caches and cache packs, the same build fell from **6.368 s to 5.207 s**, an **18.2% time reduction**. The script requires zero parse-cache misses on every measured run. All output hashes also match the uncached build. See [warm build samples](data/compile-scaling-2026-09-14/pipeline-128-warm.json).

Pass speedups are not whole-compiler speedups. Cache lookup still scans loaded entries, but no longer hashes each candidate. At the end of this first pass, interface freezing still constructed content hashes for available interfaces; the second audit removes that repeated work. The largest remaining costs need separate profiles before further changes.

[Raw microbenchmark samples](data/compile-scaling-2026-09-14/microbenchmarks.json) and [complete uncached build samples](data/compile-scaling-2026-09-14/pipeline-128-off.json) are retained.

## Experiment notes

- The first parser fixture lacked required newlines and only decoded a diagnostic. It was rejected. The final fixture checks that parsing has no diagnostics.
- The first complete-build fixture used `import` with unqualified calls. It was rejected and changed to `open`.
- Cold native benchmark builds took 99.588 seconds for semantic and 93.506 seconds for backend. Both exceed the repository's 30-second rule. These times include building the large MoonBit test runners and are not Dew compile sample times.
- A broad native `moon check` found existing `IOError.to_string()` errors in `src/string_bench_gen/main.mbt` and `src/utf_parity_gen/main.mbt`. The five changed packages pass the focused check. The five error-message calls were changed to `@debug.to_string(error)` so the broad check can pass; this does not change measured compiler execution.


## Final validation

- `DEW_NATIVE_TEST_PACKAGES='cache_binary core_linker parser' tools/test-native.sh`: 330 passed.
- `DEW_NATIVE_TEST_PACKAGES='semantic/compile_scaling_wbtest.mbt backend/compile_scaling_wbtest.mbt backend/starshine_compiler_facts_wbtest.mbt standard_loader compiler_driver' tools/test-native.sh`: 32 passed.
- `DEW_NATIVE_TEST_PACKAGES='backend/compile_scaling_wbtest.mbt' tools/test-native.sh`: 2 passed after adding the distinct-effect-bits case. This reruns one earlier case; there are 363 distinct routine/focused tests in total.
- `tools/test-integration-native.sh`: all 271 passed, including cyclic interfaces, cache validation, program linking, and optimization. Each measured file stayed below 30 seconds.
- `moon check --target native`: passed in 7.590 seconds, with existing warnings and no errors.
- All 12 new native benchmark cases passed before and after the fixes.
- `python3 -m py_compile tools/benchmark-compile-scaling.py`, `bash -n tools/benchmark-compile-scaling-native.sh`, and `git diff --check`: passed.

[Validation records](data/compile-scaling-2026-09-14/validation.json) retain test counts and lane times. No Starshine source changed, so its full pinned suite was not required.

The native semantic/backend benchmark runner builds remain above 30 seconds (82.310 s and 88.732 s on the updated run). This is a remaining build-tool performance issue, not a claim of a fast cold native test build. All measured Dew CLI compiles completed below 7 seconds.
