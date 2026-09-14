# Import and loaded-cache compile costs, 2026-09-14

This pass tests the three remaining candidates from the previous audit. The primary agent implemented and measured every experiment. The baseline includes the fixes in [pass one](compile-scaling-2026-09-14.md) and [pass two](compile-hotpaths-2026-09-14.md); it is not plain commit `6a242163`.

## One list of findings and decisions

| Location | Change tried | Decision and proof |
| --- | --- | --- |
| `src/semantic/imported_semantics.mbt`, `InterfaceTypeImporter` | Replace repeated full type-arena scans with structural keys in a local map. Seed in arena order to keep the first type ID. Own argument arrays so later scratch edits cannot change keys. | Keep. The 4,096-group benchmark fell from 797.15 ms to 2.99 ms. Tests cover existing IDs, seeded structural types, scratch reuse, argument order, projections, and distinct structural heads. Existing trait/preamble import tests also pass. |
| `src/cache_binary/artifact_pack.mbt` and `artifact_pack_lazy.mbt` | Index loaded entries by section and full owner. Keep ordered buckets for several loaded versions. Use an owner set during saved-entry merging. | Keep. Updates fell from 26.72 ms to 0.536 ms; loaded lookups from 28.65 ms to 0.488 ms. A full lazy decode/merge/encode fell from 143.71 ms to 100.74 ms. Full digests, canonical V1 order, first-owner replacement, duplicate errors, and saved-entry corruption checks remain. |
| `src/dew_bootstrap/main.mbt`, compiler identity | Compare the current source-file fingerprint with hashing the built JavaScript compiler plus standard source files. Both use the native bootstrap SHA-256 implementation. | Reject this variant. Source hashing took 52.28 ms; artifact hashing took 128.29 ms, before any build freshness check. Production identity behavior is unchanged. Only a shared hashing helper was extracted for the benchmark. This result does not measure a generated build-time stamp. |

The importer map lives only for one import pass. Cache owner buckets live with the pack. Both add linear index storage. No serialized fields, version numbers, source-language rules, or Wasm emission rules changed. The importer checks argument spans with a diagnostic runtime assertion.

## Method and full-build proof

Run `tools/benchmark-compile-imports.sh` for the new benchmarks. Compiler and cache probes use JavaScript release, matching the shipped compiler host. The identity probe uses native release, matching the bootstrap. Each probe uses three sample groups. Import and upsert probes include constructing their input arenas/indexes. Loaded lookup fixtures are built outside the measured closure. The lazy materialization probe includes full validation, decoding, merging, canonical sorting, and encoding.

The full-build comparison alternates two saved standalone CLI files, discards the first pair, and measures five pairs. Each compile has a 30-second timeout. Warm runs use separate cache directories and require zero parse misses; whole-program caching stays off. The files are `.tmp/compiler-perf-round3/before.js` and `.tmp/compiler-perf-round3/after.js`.

| Full 128-module build | Before median | After median | Time saved |
| --- | ---: | ---: | ---: |
| Layer caches off | 2.228 s | 1.559 s | 30.0% |
| Parse/interface caches warm | 2.191 s | 1.587 s | 27.5% |

Every build produced the same Wasm SHA-256: `0ec67cc8d77fbce3494f86deaf86172b069d4193c5e4fe4e6025fd9c062477f8`.

Run either comparison with:

```sh
python3 tools/benchmark-compile-scaling.py .tmp/compiler-perf-round3/before.js .tmp/compiler-perf-round3/after.js --modules 128 --runs 5
python3 tools/benchmark-compile-scaling.py .tmp/compiler-perf-round3/before.js .tmp/compiler-perf-round3/after.js --modules 128 --runs 5 --cache-mode warm
```

## Self-host build

The command is `tools/check-self-host-bootstrap.sh --clean --fast`. It builds A with MoonBit, runs A to build B, then runs B to build C. It uses Node facet execution and the current pinned Starshine FFI provider. Binaryen is off. `--clean` disables the whole build cache; it does not remove MoonBit tool build products or all layer caches.

The before run's first A link took **31.446 seconds**, including a native linker tool rebuild. This is still a cold-build performance bug, not evidence that linking itself takes 31 seconds. For the first after run, tool preparation was measured separately: JS compiler build 4.528 seconds, native linker preparation 2.215 seconds, and native bootstrap preparation 3.844 seconds. The first A request step still included its native helper build. The repeat run uses built helpers. These are observed runs, not paired statistical estimates of self-host improvement.

The many-module gain does not carry over as a large gain in this self-host build. A's first after build was 15.899 seconds versus 16.300 seconds before. A-to-B and B-to-C execute unchanged Dew compiler code. Small differences in those times must not be called an optimization gain.

| Step | Before (s) | First after (s) | Repeat after (s) |
| --- | ---: | ---: | ---: |
| Time provider build | 0.004 | 0.003 | 0.003 |
| Build A with MoonBit | 16.300 | 15.899 | 13.311 |
| Link A | 31.446 | 4.715 | 4.768 |
| Validate A raw | 0.020 | 0.019 | 0.025 |
| Validate A final | 0.020 | 0.023 | 0.021 |
| Create request for A to build B | 2.581 | 2.574 | 0.117 |
| Run A to build B | 20.198 | 20.055 | 20.730 |
| Validate B core | 0.010 | 0.009 | 0.009 |
| Link B | 5.368 | 5.452 | 5.485 |
| Validate B raw | 0.022 | 0.019 | 0.023 |
| Validate B final | 0.021 | 0.019 | 0.020 |
| Run B semantic probes | 0.060 | 0.061 | 0.069 |
| Create request for B to build C | 0.103 | 0.100 | 0.109 |
| Run B to build C | 20.858 | 20.274 | 20.576 |
| Validate C core | 0.009 | 0.009 | 0.011 |
| Link C | 5.445 | 5.373 | 5.420 |
| Validate C raw | 0.018 | 0.019 | 0.019 |
| Validate C final | 0.018 | 0.019 | 0.019 |

The repeat run also passed. All three core files match the before run byte for byte. B and C core files are equal. B and C linked files are also equal, with SHA-256 `215f26625c8e00510b3428a11f350c94919a40fec828d76f03c42a0bbc24aacf`. Core hashes and byte counts are saved in the data file.

## Checks and saved evidence

326 tests passed: 22 cache tests, 2 new importer tests, 19 standard-loader tests, 3 compiler-driver tests, 9 bootstrap tests, and 271 integration tests. The new cache tests include a replaced saved entry with a valid outer checksum but damaged entry bytes: encoding still reports its error. `moon check --target native` passed in 8.963 seconds with warnings and no errors. Shell syntax and `git diff --check` passed. Each individual test lane stayed below 30 seconds.

The initial attempt to select the new importer file used an unsupported `--file` argument with a package path. It was corrected to the file path lane and both tests passed. No failed check was treated as a pass.

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/import_intern_wbtest.mbt tools/test-native.sh
DEW_NATIVE_TEST_PACKAGES='cache_binary standard_loader compiler_driver dew_bootstrap' tools/test-native.sh
tools/test-integration-native.sh
```

Saved evidence:

- [Benchmark measurements](data/compile-imports-2026-09-14/benchmarks.json)
- [Full build, caches off](data/compile-imports-2026-09-14/pipeline-128-off.json)
- [Full build, warm layer caches](data/compile-imports-2026-09-14/pipeline-128-warm.json)
- [Every self-host step and output hashes](data/compile-imports-2026-09-14/self-host.json)
- [Validation results and command times](data/compile-imports-2026-09-14/validation.json)

Full command logs remain in `.tmp/compiler-perf-round3/`. The work is published on `perf/compiler-compile-times`; these measurements use the local compiler and Starshine revision from the audit, before integration with the diverged remote `master`.
