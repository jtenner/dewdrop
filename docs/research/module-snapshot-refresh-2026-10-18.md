# Refresh module snapshots after callback type liveness

The final snapshot update and normal check both pass all 461 fixtures on Node
and Wago. Both runs compile each fixture twice, compare its diagnostics, and
require identical Wasm bytes. Valid Wasm is checked before either engine runs.
No check was disabled.

The golden change contains 219 WAT files. No JSON expectation changed: errors,
warnings, output, traps, and host settings are unchanged. The
[per-file audit](data/module-snapshot-refresh-2026-10-18/wat-audit.json) reads
every changed WAT file. After resolving type references, all 219 retain the
same body tokens, including constants, call targets, field indices, memory
operations, exports, and data bytes.

Type counts fall in 215 files. Three code-point fixtures change only their
`compiler.facts` section. `generics/option-result-runtime` grows from 32 to 34
types: it has two more structurally duplicate Result payload types, each with
an I32 tag and an erased reference field. Generic-enum layout candidate
collection also sees the new helper signatures. This residual static cost is
not proved necessary or minimal. It adds no allocation instruction or changed
runtime result in this fixture.

The audit excludes custom-section bytes and uses 64 rounds of structural type
fingerprints. It is a bounded structural check, not a proof for all nominal
or recursive type graphs. Wasm validation, repeated-byte checks, unchanged
expectations, and the two runtime engines provide separate checks.

## Compiler time and source identity

The source is commit `fc00559474`. All 749 recorded compiler, standard-library,
and runner inputs, plus all 503 fixture source files, match that commit.
The private native debug generator rebuilt in 7.143 seconds.
Its SHA-256 is
`68d1ee0bd54a7bb493adc9baf15c4be1f1952c680260ac5320b46868b36e873b`.

| Run | Batch elapsed | Compiler children | Longest compiler child |
| --- | ---: | ---: | ---: |
| Update | 58.134 s | 922 | 1.946 s |
| Normal check | 63.864 s | 922 | 2.385 s |

Each run has 822 successful compiler calls and 100 expected error calls from
50 invalid-source fixtures, including their repeats. All 1,844 compiler calls
were measured. None exceeded 30 seconds. The batch time also covers validation
and both runtime engines. Eight fixture workers run at once, so their child
times overlap. These are validation times under host load, not speed benchmarks.

The [timing hook](data/module-snapshot-refresh-2026-10-18/compiler-timing-hook.py)
wraps only `module_snapshot_gen.exe` calls. It preserves arguments, results,
and errors. Each completed call writes one append-only JSON line outside the
source tree. The [compact timings](data/module-snapshot-refresh-2026-10-18/compiler-timings.json)
retain each fixture, repeat flag, elapsed time, and exit status. The
[validation record](data/module-snapshot-refresh-2026-10-18/validation.json)
records exact commands, source and harness identities, and full raw-log hashes.

## Architecture budgets and review

All ten architecture performance budgets pass with the canonical updated WAT
and fresh private artifacts from the final release CLI. Its SHA-256 is
`d426709075299d333ca8700003b252cccd5c958dd2917859d603c2ccbd7bb768`.
The builds took 0.180 to 0.199 seconds each; the budget and configured consumer
checks took 0.358 seconds. The aggregate callback case is 4,046 Wasm bytes and
17,835 canonical WAT bytes. No budget was raised. The
[architecture record](data/module-snapshot-refresh-2026-10-18/architecture-validation.json)
contains all metrics, artifact hashes, budgets, and commands.

The [independent source review](data/module-snapshot-refresh-2026-10-18/callback-liveness-review.json)
found a missing live-lambda callback signature root. Its regression failed
before the guard and passed after it. The final review found no remaining
confirmed defect in the checked liveness, cache policy, or Unit binding changes.
It records both the earlier source hashes and the formatted committed hashes,
plus the reviewed scope and limits. This review does not replace the full
compiler or self-host bootstrap checks.

Repeat the normal lane:

```sh
mise exec wasm-tools@1.262.0 go@1.27.2 -- \
  python3 tools/module-snapshots/run.py --target-dir /tmp/dew-snapshot-check
python3 docs/research/data/module-snapshot-refresh-2026-10-18/audit-wat.py \
  --baseline fc00559474 --output /tmp/dew-snapshot-audit
```
