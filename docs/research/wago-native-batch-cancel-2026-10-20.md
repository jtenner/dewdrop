# Wago native batch fix and install

The latest selected build and the two later native array PRs are recorded in
[the native array install note](wago-native-array-prs-2026-10-20.md).
The measurements and installation below are the preceding batch-only build.

[PR #999](https://github.com/wago-org/wago/pull/999) adds benchmarks and fixes
large unused handle batches in mixed struct and array code.

## Source

- New workspace: `/home/dev/Projects/wago-gc-native-batch-cancel`.
- PR branch: `perf/gc-native-batch-cancel`.
- Installed source: `/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago`.
- Installed branch: `dewdrop/local-gc-perf-20261020`.
- Installed commit: `ce9e051d656429f5a47b461e75897c1c4505a73b`.

| Pushed commit | Local cherry-pick |
|---|---|
| `4738f4e6f` (benchmarks and tests) | `6b351ee9c` |
| `1153cd382` (fix and results) | `ce9e051d6` |

The changelog conflict kept both sets of entries. The prior one-line local edit
in `src/core/compiler/backend/railshot/arm64/call.go` has the same file hash.
The installed GC source files match the source used for the full compiler check.

## Result

- Batch cycle with one object: 1306 ns to 47.32 ns, about 28 times faster.
- Mixed array workloads: about three times faster on upstream Wago.
- Native scalar control: within 1% of the old build.
- Saved full Dewdrop compile on the local GC stack: 123.955 s to 93.822 s.
- The full compile used 24.31% less time and 10.52% less peak RSS. It remains slow.
- Both output hashes matched. The output validated and returned 42 in Node.

The full result is one before/after pair. Other programs were active.
The PR includes the raw benchmark data and the full test notes.

## Installed command

- Manager: `/home/dev/.local/bin/wago`.
- Runtime: `/home/dev/.local/share/wago/versions/local-gc-ce9e051d6/standard/normal/wago-runtime`.
- Selected version: `local-gc-ce9e051d6`, standard profile, normal Go build.
- Manager build: 6.415 s. Runtime build: 6.265 s. The builds ran at the same time.
- Manager SHA-256: `49d51e6ebcd25232f96325f3bb7ab81f92a0a0c395a10270a3bc9e52e5dbcde1`.
- Runtime SHA-256: `6df479cb906b2c3dc5d0444f0ff1921f16a5e1c31733105bdea9b041f3ec0fa7`.

A fresh login shell finds the manager on PATH. Both installed hashes match the
staged builds. The old runtime remains installed. The old manager is saved at
`/home/dev/Projects/dewdrop/.tmp/wago-batch-cancel-results/install/backup-wago`.

```sh
wago --json --version
wago run --bare --offline --no-input --invoke fib /home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago/tests/fixtures/wasm/fib.wasm 20
```

## Checks

The complete upstream GC/runtime suites passed normally and with register
checks. GC debug checks and focused ARM64 checks passed. The local stacked
branch passed the complete GC debug suite and selected native runtime checks.

The installed command returned 6765 for Fibonacci. All five allocation exports
passed at 500000 iterations. The mixed exports took about 0.18–0.20 s each.
The installed runtime also loaded the prior native artifact and returned the
correct checksum. Native artifact tests used `--allow-native-artifact` for these
locally built files.

Exact commands, output, times, and hashes are saved under
`/home/dev/Projects/dewdrop/.tmp/wago-batch-cancel-results`. The final smoke record is `install/verification.json`.
