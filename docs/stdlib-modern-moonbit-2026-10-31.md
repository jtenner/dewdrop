# Dewdrop modern MoonBit — G0

Owner directive dated 2026-10-31: use modern MoonBit for now. This supersedes
the old SDK requirement in the historical G0 report. Work date: 2026-11-01 UTC.
Branch: `campaign/stdlib-modern-moonbit`, based on `c2145c52`.

## Changes

### Pin alignment

Current baseline: Moon `0.1.20261023 (3778465 2026-10-23)`, moonc
`v0.10.17+d971670cd (2026-10-23)`, bundled core `0.10.17+d971670cd`.
`tools/MOON_TOOLCHAIN.json` records these exact versions. Both G0 shell runners
check the selected SDK and bundled core through `tools/check-moon-toolchain.py`.
README states the owner decision. The global SDK is unchanged.

Audit: root and Starshine `moon.mod` use `moonbitlang/x@0.5.5`; neither declares
a separate core version. `moon.work` selects the root and Starshine source
members. These declarations need no change. There is no tracked Moon lockfile;
`.mooncakes/.moon-lock` is an empty generated lock, not a dependency pin.
The Wasm tool and Wago pins are unchanged. Historical measurements retain their
original SDK identities.

Starshine is patched from `1b237952167f582abd492aec27adf10c5a6c9e60` to
`29dde5c78291a976abd5f739da920915f04fdc36` with a local, unsigned dependency commit. No upstream write occurred.

### Mechanical fixes

- `src/transforms/floats.mbt`: four integer `.to_float()` calls become
  `Float::from_uint64/from_int64/from_uint/from_int`, preserving direct f32
  rounding and signedness.
- Starshine `src/wast/lower_to_lib.mbt` and `src/passes/precompute.mbt`: removed
  integer `reinterpret_as_float` calls become `Float::reinterpret_from_int`
  and `Float::reinterpret_from_uint`. NaN payload bits remain unchanged.
- Starshine `src/passes/{global_effects,global_type_optimization,
  global_type_optimization_fields,i64_to_i32_lowering,intrinsic_lowering,
  make_shared_objects,tail_call}.mbt`, `src/ffi_bridge/ffi_bridge.mbt`, and
  `src/cmd/cmd.mbt`: removed `.is_ok()` calls become `is Ok(_)` patterns.

### Semantic adaptations — NONE

No runtime algorithm, test expectation, or snapshot was changed.

## Initial failure

`bash tools/dew-test/run.sh` exited 1 in 4.31 seconds; no tests ran.
All five errors were MoonBit 4015 (missing method):

| Source | Receiver / missing method |
| --- | --- |
| `src/transforms/floats.mbt:169:18` | `UInt64.to_float` |
| `src/transforms/floats.mbt:171:41` | `Int64.to_float` |
| `src/transforms/floats.mbt:174:26` | `UInt.to_float` |
| `src/transforms/floats.mbt:176:25` | `Int.to_float` |
| `starshine-mb/src/wast/lower_to_lib.mbt:814:56` | `Int.reinterpret_as_float` |

A follow-up build exposed the remaining Starshine predicates and bit cast.
Exact diagnostics and command timings are in
`docs/research/data/stdlib-modern-moonbit/`. Gate results follow after the run.

## Build and gate commands

Integration HEAD for the final runs: `4b2103130990902a3de9c8143520abc630f32e05`.
Its tree is `2d2c75ff36b0d2071af971da8d6e0d6426a35144`.
Later report commits change evidence and docs only.

```sh
moon build --target native -j 2 src/dew_test_gen
bash tools/dew-test/run.sh
env PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin bash tools/module-snapshots/run.sh --target-dir /data/workspace/dewdrop/.tmp/modern-snapshots
```

The native compiler build succeeds. Its first successful build took 67.88
seconds, including native C compilation. **PERFORMANCE BUG:** this exceeds the
repo's 30-second compiler activity limit. No compiler setting or algorithm was
changed to hide the cost. The first snapshot generator build took 20.060 seconds.
Per-invocation times from the final runs are saved in the logs.

Mechanical runner changes also add wall-time measurements and visible warnings
for compiler calls over 30 seconds. They do not suppress failures or change the
fixture set. The final snapshot run has no filters, no update flag, and no
reproduction bypass. Both Node and Wago are selected by the default runner.

The dependency compatibility patch is saved as
[starshine-modern.patch](research/data/stdlib-modern-moonbit/starshine-modern.patch)
so the local dependency commit can be reviewed without an upstream write.
Apply it with `git am` on the original pinned Starshine revision if needed.

## Final std results

`bash tools/dew-test/run.sh` exits 0 in 74.63 seconds. It compiles all 30 public
manifest files, checks repeat-compilation byte identity, runs all private B-tree
files, checks builtin traps, and completes every operation probe.

| Lane | Executed | Passed | Failed |
| --- | ---: | ---: | ---: |
| Public std tests | 355 | 355 | 0 |
| Private B-tree tests | 41 | 41 | 0 |
| Builtin trap exports | 42 | 42 | 0 |
| Operation probes (42 check scripts) | 4,121 | 4,121 | 0 |

There are no failed std test or probe identities. The 42 builtin trap functions
are counted from the emitted Wasm exports; the std harness checks every one.
The 46 compiler calls are measured separately. None exceeds 30 seconds in the
final std run.

### Per-probe counts

| Probe | Passed |
| --- | ---: |
| native scalar Into conversion | 750 |
| native memory operation | 201 |
| native SIMD memory operation | 432 |
| native arithmetic operation | 1332 |
| native math operation | 238 |
| native specialization product | 30 |
| native generic query order | 6 |
| native specialization callback | 367 |
| native member/index | 10 |
| native WASI foreign | 46 |
| native Debug dispatch | 6 |
| native integer Debug | 24 |
| native float Debug | 21 |
| native V128 Debug | 10 |
| native SWAR Debug | 17 |
| native Unit Debug | 6 |
| native Bool Debug | 11 |
| native derived Debug | 9 |
| native text Debug | 15 |
| native intrinsic name | 17 |
| native builtin reference | 10 |
| native production assertion | 2 |
| native WASI Bytes | 19 |
| Bytes staging | 54 |
| native product pattern | 27 |
| native constructor evaluation | 9 |
| native operator call recipe | 6 |
| native Unit branch | 27 |
| native raw Wasm array storage | 27 |
| native raw Unit array | 3 |
| native FixedArray | 13 |
| native raw array | 34 |
| native packed field | 36 |
| native array operation | 33 |
| native ring operation | 20 |
| native Map operation | 12 |
| native Set operation | 8 |
| native Bytes operation | 53 |
| native StringView operation | 26 |
| native String operation | 47 |
| native String pattern | 5 |
| native type query | 102 |

## Final module snapshot results

The full snapshot command exits 1 in 114.61 seconds: **461 fixtures executed,
453 passed, 8 failed**. Both runtimes are Node `v22.23.3` and the pinned Wago
runner. `wasm-tools` is `1.262.0 (e22db44da 2026-10-13)`, the exact repo pin.
All 922 fixture compiler calls (two per fixture) are measured. None exceeds
30 seconds. The failures are WAT comparisons only; their compilation, repeat
byte check, diagnostics, and runtime outputs passed before WAT comparison.
No new failure identity appears. All eight historical mismatches remain:

| Full failure identity | Modern result |
| --- | --- |
| `tests/module-snapshots/collections/binary-heap-runtime.wat` | WAT mismatch persists |
| `tests/module-snapshots/generics/bounded-function-reference-runtime-evidence.wat` | WAT mismatch persists |
| `tests/module-snapshots/generics/generic-enum-adapter-runtime.wat` | WAT mismatch persists |
| `tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.wat` | WAT mismatch persists |
| `tests/module-snapshots/modules/imported-bounded-function-reference-runtime-evidence.wat` | WAT mismatch persists |
| `tests/module-snapshots/text/show-collections-runtime.wat` | WAT mismatch persists |
| `tests/module-snapshots/text/show-derived-runtime.wat` | WAT mismatch persists |
| `tests/module-snapshots/types/derive-debug-runtime.wat` | WAT mismatch persists |

Full diffs are preserved in
[snapshots.log.gz](research/data/stdlib-modern-moonbit/snapshots.log.gz).
No expected WAT or test file was edited. The differences include generated
function/type indices and emitted code; this run does not claim that a new core
caused these previously known differences.

## Evidence and cleanup

Machine results are in
[results.json](research/data/stdlib-modern-moonbit/results.json).
The initial errors, later errors, successful build, and both complete gate runs
are preserved as gzip logs in the same directory. First-pass logs are also kept;
they have the same 355/41 std counts and the same eight snapshot failures.
`/usr/bin/time -p` measured each lane; the final runners also measure each compile.
The final warm snapshot generator build time is recorded in its log.

Removed `_build`, `.tmp/modern-snapshots`, `.mooncakes`, `.dew/cache`, generated
`tools/dew-test/*.wasm`, and generated std harness metadata after both lanes
finished. Source and evidence remain. The global SDK was not changed.
No stdlib implementation work or worker dispatch occurred.

The G0 compiler builds have no remaining MoonBit incompatibility. The cold
native build has the 67.88-second performance bug recorded above.

G0 BLOCKED — all eight known WAT snapshot mismatches listed above remain.
