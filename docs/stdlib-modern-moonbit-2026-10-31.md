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
`29dde5c78` with a local, unsigned dependency commit. No upstream write occurred.

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
