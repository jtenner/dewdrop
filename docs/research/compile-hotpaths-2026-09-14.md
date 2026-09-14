# Second compile-time audit, 2026-09-14

Four agents reviewed separate areas without changing files. The main agent made all changes and ran each experiment. This pass starts with the five fixes from the [first audit](compile-scaling-2026-09-14.md), on top of commit `6a242163`. Its baseline includes those fixes, which were uncommitted when measured; it is not the original commit alone.

## One combined list

| Finding | Fix | Correctness proof |
| --- | --- | --- |
| Module freezing rehashes every earlier module's declarations and content | Track hashes computed for completed modules in this compile and reuse them. Keep unconditional full refresh. Never trust a saved hash just because it is nonempty. | Each cold and cached callback result matches full recomputation; cases include a dependency cycle, nominal imports, changed module IDs, and deliberately stale cached content hashes. |
| Cache decoding copies bytes into a buffer, then copies them again | Keep range checks in a byte-view reader; copy owned bytes once and decode strings directly from the view. Use the same bulk copy for pack slices. | Exact bytes, Unicode strings, positions, bounded sections, malformed UTF-8, truncation, and size-limit errors; existing parser and cache tests. |
| Cache lookup scans the entire saved index | Binary-search the first `(kind, owner lane, content lane)` match, then check each equal candidate with the full owner and digests. | Compare lower bounds with a linear oracle, including equal lanes and section boundaries; verify hits and changed-content misses in fresh packs; keep corruption/full-digest tests. |
| Linker marker checks scan all declared supertypes again | Build one subtype-presence flag per type, then use indexed reads. | Compare with the old scan for inheritance chains and relative/invalid supers; test invalid queries and run existing linked-module validation cases. |

The V1 formats, emitted code, standard-module rules, and builtin rules are unchanged. Hash reuse has diagnostic assertions for completion-array sizes and missing computed hashes. The subtype index adds one boolean flag per type.

## Profile and method

A Node CPU profile of the 128-module CLI build took 5.763 seconds. Declaration ABI hashing alone had about 875 ms of self time; SHA-256 and string-buffer writes were also large costs. This supported the content-hash change. [Profile summary](data/compile-hotpaths-2026-09-14/profile-before.json).

Run `tools/benchmark-compile-hotpaths.sh` for the new pass-level cases. These use the JavaScript release target because the shipped CLI runs JavaScript. Fixtures are built outside the measured closure. Content-hash cases use three sample groups; other cases use ten. The complete-link case includes parsing, subtype-index construction, remapping, and encoding. It disables optional cleanup and per-phase validation equally before and after.

For full builds, `tools/benchmark-compile-scaling.py BEFORE.js AFTER.js --modules 128 --runs 5` alternates the two compilers, discards the first pair, and requires byte-identical Wasm. `--cache-mode warm` enables parse/interface caches and cache packs in fresh separate directories. It requires zero warm parse misses. Whole-program caching stays off so each run compiles. Each compile has a 30-second timeout. The before/after standalone CLI files remain in `.tmp/compiler-perf-round2/`.

## Results

| Larger fixture | Before | After | Speedup |
| --- | ---: | ---: | ---: |
| Interface freeze, 128 modules × 8 functions | 3.86 s | 302.68 ms | 12.8× |
| Raw byte decode, 1 MiB partial range | 5.17 ms | 1.93 ms | 2.7× |
| UTF-8 string decode, 1 MiB ASCII | 4.84 ms | 98.91 µs | 48.9× |
| Changed-content cache misses, 4,096 entries | 23.03 ms | 10.38 ms | 2.2× |
| Marker checks, 4,096 types | 6.05 ms | 41.69 µs | 145× |
| Complete link, 4,096 imports / 4,098 types | 13.01 ms | 3.87 ms | 3.4× |

These are pass-level means, not whole-compiler speedups. The cache-index after sample had noticeable variation (±2.43 ms); the full samples are retained.

| Complete 128-module build | Before median | After median | Time reduction |
| --- | ---: | ---: | ---: |
| Caches off | 5.736 s | 2.285 s | 60.2% |
| Warm parse/interface caches | 5.640 s | 2.261 s | 59.9% |

Every before/after output, including discarded first runs, has SHA-256 `0ec67cc8d77fbce3494f86deaf86172b069d4193c5e4fe4e6025fd9c062477f8`. Pass and full-build measurements were run in sequence, without parallel test workloads.

Data: [microbenchmarks](data/compile-hotpaths-2026-09-14/microbenchmarks.json), [uncached builds](data/compile-hotpaths-2026-09-14/pipeline-128-off.json), [warm builds](data/compile-hotpaths-2026-09-14/pipeline-128-warm.json).

## Experiment notes and limits

- The first content-hash benchmark used ten groups and took 56.893 seconds in total. It was changed to three groups and measured again before the fix; that command took 23.341 seconds. Each final benchmark command stayed below 30 seconds.
- The first new cache-hook test allocated slots for only the five supplied modules. The collector also adds standard modules. The test failed with a diagnostic assertion; it now sizes slots from the actual collected program and passes.
- The complete-link baseline temporarily restored only the previous subtype-scan implementation. A `finally` block restored the updated file. Other changes do not affect the measured subtype scan.
- At the end of this pass, loaded cache entries still used a linear full-key scan. The [third pass](compile-imports-2026-09-14.md) adds an owner index. Cached module content is still recomputed unless this invocation has completed and hashed it.


## Final validation

- `DEW_NATIVE_TEST_PACKAGES='cache_binary core_linker' tools/test-native.sh`: 37 passed (these were the first two completed lanes of the initial focused command).
- `DEW_NATIVE_TEST_PACKAGES='semantic/content_hash_wbtest.mbt parser standard_loader compiler_driver' tools/test-native.sh`: 321 passed after the test-slot correction.
- `tools/test-integration-native.sh`: all 271 passed. Each measured test file stayed below 30 seconds.
- `moon check --target native`: passed in 8.452 seconds, with warnings and no errors.
- All 12 new benchmark cases passed before and after their changes.
- `bash -n tools/benchmark-compile-hotpaths.sh` and `git diff --check`: passed.

There are 629 passing tests in this pass. [Validation records](data/compile-hotpaths-2026-09-14/validation.json) include the initial fixture failure and the successful rerun. No Starshine source changed.
