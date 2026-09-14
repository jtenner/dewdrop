# Self-host performance follow-up, 2026-09-14

## Merge with master

Merged remote master `2423d85c` into the performance branch. Its Starshine pin
`7bf3c39c` is an ancestor of the tested local pin `de52f1d14`, so the merge retains
`de52f1d14` and includes all remote repairs. No Starshine code conflict exists.

All 271 integration tests passed after the merge. The full A/B/C self-host run
also passed with CPU profiling enabled. B and C still have linked SHA-256
`215f26625c8e00510b3428a11f350c94919a40fec828d76f03c42a0bbc24aacf`.
Logs and profiles are in `.tmp/self-host-perf-followup/`.

## Initial findings

The A-to-B CPU profile attributes about 1.9 seconds to garbage collection.
Function symbols are lost during linking, so the remaining hot functions need
names before selecting a source fix. The native linker generates an 18 MB C
translation unit; its C compilation must be timed separately from linker runtime.

## Changes retained

1. Preserve function names while remapping linker indices, then let cleanup remap
   them again. Invalid debug indices are ignored; they do not affect executable
   validity. A regression checks that the provider function name survives cleanup.
   Adding names to the baseline compiler left every executable section unchanged.
2. Allocate known-size Bool and U32 slot arrays directly with `wasm_array_new`.
   Count and capacity start at the requested length. This uses the existing
   one-instruction builtin from ordinary Dew code. Tests cover empty and large
   arrays, both Boolean values, sentinels, writes, and growth after allocation.
3. Use the existing body/specialization/expression call index for array-result
   classification, then read the indexed function slot. Keep diagnostic assertions
   for target bounds and slot identity. The regression compares positive and
   negative generic-call cases with the old linear scan, plus wrong body,
   specialization, and expression keys.
4. Build the native linker fixture with GCC `-O2 -pipe -flto=8`, retaining
   `-fwrapv -fno-strict-aliasing` and MoonBit's mimalloc configuration. This limits
   link-time optimization to eight jobs and keeps the full runtime optimization
   level. The setting is scoped to `src/self_host_link_fixture/moon.pkg` and
   explicitly selects GCC; it is not a workspace-wide compiler change.

## Self-host results

`tools/check-self-host-bootstrap.sh --clean --fast` ran after each compiler
experiment. These runs include the normal host and adapter overhead and are
single observations:

| Version | A builds B | B builds C |
| --- | ---: | ---: |
| Merged baseline, CPU profiler enabled | 20.174 s | 20.253 s |
| Direct slot allocation | 18.177 s | 16.772 s |
| Slot allocation and indexed call lookup | 15.277 s | 15.385 s |

The final B and C linked files match byte for byte:
`5d73b8e16eaaef0fdabd2a62d27f5f2fcd0f42bbff239dc7c161e9bda9edaefc`.

For a fair before/after comparison, both saved compiler B binaries compiled the
same current source request. The benchmark alternates order, discards one warm-up
pair, then measures three pairs without CPU profiling. Every compile has a
30-second timeout and must produce the same Wasm hash. Memory export preparation
is timed separately from execution.

| Same-request comparison | Before median | After median | Time saved |
| --- | ---: | ---: | ---: |
| Complete self-host compile | 18.402 s | 14.294 s | 22.3% |

All eight executions, including warm-up, produced
`52b63d041be1ea33861a7ec363ad5516f6d1e71b0169b11ac808e44822c0ac39`.

The before and after CPU profiles support the selected fixes. Times below are
sampled self time, not independent benchmarks; inlining can move costs between
functions. The before profile uses the original request, while the after profile
uses the paired benchmark request. Use the paired test above for the overall gain.

| CPU cost | Before | After |
| --- | ---: | ---: |
| Garbage collection | 1,713 ms | 1,120 ms |
| Dominant `array_replace_backing` specialization | 1,250 ms | 1 ms |
| `self_host_linked_call_returns_array_element` | 1,142 ms | 4 ms |
| `self_host_bool_slots` | 761 ms | 382 ms |

The remaining largest named scan is
`self_host_linked_field_value_nominal_declaration`, about 633 ms in the after
profile. It is a future optimization candidate, not part of this change.

## Cold native linker experiments

Each C variant compiled the same generated translation unit, linked the same B
core and providers three times, and produced identical linked Wasm. These probes
include C compilation but exclude MoonBit code generation and runtime archive
preparation. Run times are medians.

| Variant | C build | Link run | Decision |
| --- | ---: | ---: | --- |
| GCC `-O2` | 25.576 s | 5.326 s | Baseline |
| GCC `-O1` | 9.847 s | 5.497 s | Reject: slower runtime |
| Clang `-O2`, same allocator | 17.850 s | 5.316 s | Slower build than parallel LTO |
| GCC `-O2 -flto=8` | 7.264 s | 5.175 s | Keep |
| GCC `-O2 --param=max-inline-insns-auto=10` | 21.852 s | 5.112 s | Small runtime gain; much slower build |
| GCC `-O2 -flto` | 20.093 s | 5.119 s | Serial LTO is slower to build |

An actual MoonBit Clang build also changed the default allocator to the system
allocator: cold build 19.754 s, median link 10.521 s. Reject that configuration.
It is not equivalent to the direct Clang probe with mimalloc above.

The retained package settings were tested with a fresh target directory, so the
final measurement includes MoonBit compilation, runtime archives, C compilation,
and native executable linking:

- Cold native linker build: **10.442 s**.
- First B/provider link: **5.138 s**.
- Combined: **15.580 s**, below the 30-second limit.

The earlier 31.446-second observation included a cold build and an A/provider
link. The fresh check here links B, so it is not a paired estimate of a 50% gain.
The same-input C-variant table establishes the build-setting improvement.

## Final validation and reproduction

292 tests passed: 271 integration cases, 19 native core-linker tests, and two new
Dew performance regressions. The focused Dew script was also run from its final
checked-in form. The native workspace check passed in 7.161 seconds, with warnings
and no errors. Python syntax, shell syntax, and `git diff --check` passed.

During test development, two Dew syntax mistakes were corrected. The first call
fixture did not exercise generic-call records. It was changed to require both a
positive generic array-result call and a negative generic call; it now passes
against the original scan. The failed attempts were not counted as passes.

```sh
DEW_NATIVE_TEST_PACKAGES=core_linker tools/test-native.sh
tools/test-self-host-performance.sh
tools/test-integration-native.sh
tools/check-self-host-bootstrap.sh --clean --fast
```

CPU profiles can be collected with `SELF_HOST_CPU_PROFILE_DIR` on the bootstrap
command. `tools/summarize-self-host-profile.py PROFILE COMPILER.wasm` resolves
sample names. Supply `--original-wasm ORIGINAL.wasm` when adding names to an
existing profile; the tool verifies all executable sections before mapping names.

The same-request benchmark is:

```sh
python3 tools/benchmark-self-host-compile.py \
  .tmp/self-host-perf-followup/compiler-b-named.wasm \
  .tmp/self-host-perf-followup/compiler-b-after.wasm \
  .tmp/self-host-perf-followup/compare.request.bin \
  .tmp/self-host-perf-followup/compare-output.wasm --runs 3
```

The request was made by `src/self_host_bootstrap_fixture` with root
`self_host.compiler`, the current Starshine provider and fingerprint, then
`self_host/starshine/ffi.dew`, `self_host/starshine/fingerprint.dew`, and all
non-test compiler sources in sorted order. It writes to the stated `.tmp` path.
It is one shared request, not one request per compiler.

To repeat the cold retained build, choose a new target directory:

```sh
moon run --target-dir .tmp/self-host-linker-cold-check --target native --release \
  --build-only src/self_host_link_fixture
```

The C-only comparisons used the same generated C file with
`-fwrapv -fno-strict-aliasing -pipe`, the stated optimization flags,
`-DMOONBIT_ALLOCATOR=MOONBIT_ALLOCATOR_MIMALLOC`, and the existing MoonBit runtime,
filesystem, math, and backtrace libraries. The generated C hash is stored with
the measurements. Cold checks used fresh directories; compilation was not run
at the same time as timed compiler execution.

Saved evidence:

- [Same-request compiler comparison](data/self-host-performance-followup-2026-09-14/paired-self-host.json)
- [Before profile](data/self-host-performance-followup-2026-09-14/profile-before.json)
- [After profile](data/self-host-performance-followup-2026-09-14/profile-after.json)
- [Native compiler variants](data/self-host-performance-followup-2026-09-14/native-variants.json)
- [Test results and every measured step](data/self-host-performance-followup-2026-09-14/validation-and-timings.json)
