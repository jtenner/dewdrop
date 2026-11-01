# Item 06: bounded binary cursor

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: eight new tests, not yet run. Import is expected to fail
until the module exists. No baseline tests or snapshots changed.

Contract: a cursor owns a Bytes reference and a U32 position. Failed reads
leave that position unchanged. Errors contain position, requested length,
and available length. Slice reads and remaining bytes share the input.
Read/write U16/U32/U64 in explicit little or big endian order. Bounds use
`requested > length - position`; no unchecked addition precedes this check.

## Current candidate

Rebased test checkpoint: `8aec5834` (original `ac789499`). Current dependency
base: `8dc8bdf406733f8a29662f28c68528276870b0de`, the campaign head with hex.
The uncommitted draft was saved with `git stash push -u`, then restored after
rebase. Hex assertions and registration remain. Hex uses text mask 128,
binary uses 256; wildcard mask is 447. Slots are hex 81 and binary 82.
Combined wildcard facts are 82 modules, 93 source paths, and 79 root import edges. No B-tree source
or snapshot was changed.

The eight Dew tests include 28 short-width cases (all lengths below 2, 4,
and 8 for each endian), nonzero error offsets, subsequent successful reads,
unaligned shared views, zero/max values, exact byte vectors, end/empty reads,
U32 maximum length, shared cursor aliases, and a version 1 capsule-shaped
request. The production fixture also checks both endian writes and reads.

The first scheduled gate never started before the session was stopped;
there was no cold compiler result from that attempt. All current gates use
one exclusive `flock /data/workspace/wave1-control/build.lock`, a private
Clang wrapper (`clang "$@" -fbracket-depth=4096 -g0 -O0`), and `-j 1`.
No global SDK setting changed. The shell trap removes `_build`, `.mooncakes`,
`.dew/cache`, generated Wasm and harness files before the lock is released.

## Gates and evidence

Status: READY candidate, not landed. No functional blocker remains.
Eight new Dew tests pass. Two new native tests pass (registry identity and
binary import closure). Final native results: registry 2/2, source provider
identity 1/1, module-system integration 26/26, preamble integration 25/25.
Thus the item gates contain 8 passed / 0 failed Dew tests and 54 passed /
0 failed native tests. These counts include existing gate tests; only 10
are new. The full combined standard runner belongs to the orchestrator.
No public B-tree provider tests are counted again here.

Run from `/data/workspace/wave1-item-06`:

```sh
mkdir -p .tmp
cat > .tmp/clang <<'CC'
#!/usr/bin/env bash
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
CC
chmod +x .tmp/clang
cp docs/research/stdlib-wave1-06-gates.sh .tmp/gate.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh > .tmp/gate-summary.log 2>&1
```

The saved script contains every exact timed command and the cleanup trap.
PATH includes `/tmp/burn-starshine-fix-tools` for the existing Bun executable,
plus `/data/workspace/wave1-control`, `/data/workspace/tools`, and the pinned
`/data/home/.moon/bin`. SDK: moon 0.1.20261023; moonc/core
0.10.17+d971670cd. Starshine gitlink stays
`29dde5c78291a976abd5f739da920915f04fdc36`.

| Gate (exact arguments in saved script) | First seconds / exit | Final seconds / exit | Final peak RSS KiB |
| --- | ---: | ---: | ---: |
| `generate_binary_std.py --check` | 0.01 / 0 | 0.02 / 0 | 12104 |
| `generate_standard_module_identities.py --check` | 0.02 / 0 | 0.02 / 0 | 11992 |
| focused cold `dew_test_gen` compile | 29.14 / 0 | 28.81 / 0 | 1081024 |
| focused Node tests | 0.03 / 0 | 0.03 / 0 | 46504 |
| production `module_snapshot_gen` compile | 20.37 / 0 | 19.87 / 0 | 930768 |
| production Node oracle and measurements | 1.13 / 0 | 1.12 / 0 | 54240 |
| bootstrap/on-disk provider equality | 9.64 / 0 | 9.44 / 0 | 681064 |
| native registry lane | 1.00 / 0 | 0.92 / 0 | 80784 |
| native integration lane | 24.50 / 1 | 25.34 / 0 | 1132400 |
| `moon info --target native src/standard_sources` | 0.20 / 0 | 0.19 / 0 | 34988 |
| `bash tools/check-generated.sh` | 3.57 / 127 | 54.49 / 0 | 837112 |

The first integration failure was the wildcard edge expectation at
`src/semantic/module_system_wbtest.mbt:174`: actual 79, expected 78. The
expected count now includes binary. The first generated check stopped at
`tools/check-generated.sh:101` because `bun` was absent from PATH. The retry
uses the existing campaign Bun executable; no SDK or system file changed.
Both failed logs are retained. The final generated check also passes 14
bootstrap tests, 3 CLI fixtures, and the 261-import Facet smoke check.

**Performance issue:** the aggregate generated check took **54.49 seconds**,
above the 30-second rule. This is not hidden by the green exit. The focused
cold builds, production compiles, and each measured integration owner file
stay below 30 seconds (final owner times: 22.638s and 2.704s). There was no
cold build failure in this item. Warnings remain visible, including the
single-variant `BinaryError` derived-Eq redundant-arm warning, existing
MoonBit warnings, and embedded-source long-line warnings.

Complete logs, including the initial failures, are in
`data/stdlib-wave1-06/logs.tar.xz`; `results.json` holds exact commands,
wall times, peak RSS, and exits. No Wasm binary is in that archive.

## Runtime and memory

The production consumer uses an aliased import; focused tests use `open`.
Its capsule oracle returns 7 bytes remaining after version 1. The compiled
consumer is 13,609 bytes, with **zero imports and zero memory exports**.
The fixture does not modify or replace any compiler reader or version-1 format.

The Node script uses 10 warmup calls and 21 timed calls for each row, with
explicit GC before and after. Every call checks the returned count against
an independent numeric oracle. `scan` checks the LE U64 vector
`01 02 03 04 05 06 07 08 = 578437695752307201`. `roundtrip` builds 28 bytes,
then checks all six integer/endian pairs and the final cursor state.

| Iterations | U64 read median ms | All-six-pair roundtrip median ms |
| ---: | ---: | ---: |
| 1,000 | 0.0750 | 0.5583 |
| 10,000 | 0.2430 | 2.8647 |
| 100,000 | 2.5754 | 27.5773 |

The larger sizes show linear work. This is a new API; no speedup over an
existing reader is claimed. Final scan RSS was 54,099,968 bytes at both
10,000 and 100,000 iterations. Roundtrip RSS was 55,410,688 and 55,541,760
bytes. At 100,000 rounds, post-GC JS heap use changed from 4,218,888 to
4,221,504 bytes. These are process-level samples, not exact Wasm GC object
counts. Full before/after samples are in the runtime log.

Source allocation bounds: a cursor has one Bytes reference and one U32
position. Each integer operation has fixed scalar work (2, 4, or 8 bytes),
with no input copy or temporary byte array. Result values use ordinary Dew
layout rules. Slice reads create a view header, with no byte-buffer copy;
the input backing store stays alive. The roundtrip fixture has one 28-byte
output (32 bytes of V128 backing capacity), builder/view/cursor headers,
and bounded scalar/result temporaries per iteration. It retains no history.
Writes inherit builder growth and consumed-builder checks. Input cursor
invariants follow from private fields and the constructor. After testing
`requested <= length - position`, `position + requested <= length`, so the
addition cannot wrap. Integer byte offsets obey the same proof.

## Changed paths and cleanup

Implementation and API:

- `std/encoding/binary.dew`
- `std/tests/binary_codec_test.dew`
- `std/README.md`
- `tools/generate_binary_std.py`
- `src/standard_sources/standard_binary_sources.mbt`

Shared wiring proposed for orchestrator review:

- `src/standard_sources/registry.mbt`
- `src/standard_sources/pkg.generated.mbti`
- `src/standard_sources/binary_test.mbt`
- `src/semantic/module_system.mbt`
- `src/semantic/module_system_wbtest.mbt`
- `src/semantic/standard_preamble.mbt`
- `src/semantic/standard_preamble_wbtest.mbt`
- `src/semantic/standard_module_identity.mbt`
- `self_host/compiler/semantic_standard_module_ids.dew`
- `tools/standard-module-identities.json`
- `tools/check-generated.sh`

Evidence:

- `docs/research/stdlib-wave1-06.md`
- `docs/research/stdlib-wave1-06-consumer.dew`
- `docs/research/stdlib-wave1-06-runtime.mjs`
- `docs/research/stdlib-wave1-06-gates.sh`
- `docs/research/data/stdlib-wave1-06/results.json`
- `docs/research/data/stdlib-wave1-06/logs.tar.xz`

Both gate scripts released the lock only after cleanup. `_build`,
`.mooncakes`, `.dew/cache`, generated Wasm and harness files are removed.
No B-tree source edits, held fixes, snapshot refreshes, global SDK changes,
or push. The accepted G0 baseline and Mission A snapshot review are unchanged.
The aggregate generated-check time above is the only open performance note;
there is no item blocker.

## Checkpoints

- Rebased test/doc checkpoint: `8aec583474fbdb00d0a751ce85d541de0089dffd`.
- Implementation/generated/evidence checkpoint:
  `407b853364c492fcec0bfc2fe0b0e66c655f2b3e`.
- This final documentation update records those hashes and makes the replay
  wrapper setup explicit outside the build lock. It changes no tested code.

Final inspection confirms a clean tracked worktree, unchanged Starshine
submodule, and no worker-owned build or temporary Wasm artifacts.
