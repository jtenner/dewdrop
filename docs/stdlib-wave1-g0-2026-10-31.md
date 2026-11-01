# Dew stdlib wave 1 — gate G0

Baseline source: `edcbdf96403e03c5ccb17502cefb036f00685d88`.
Survey read: `c06100ee`, `docs/stdlib-dew-survey-2026-10-31.md`.
Work date: 2026-11-01 UTC. Scope is setup and baseline only.

## Setup checkpoint

Required SDK, from the survey and `docs/research/btree-step-4-split-landing.md`:
Moon `0.1.20261012 (748b63c 2026-10-12)`, moonc
`v0.10.15+943464bfa`, with the matching core. The saved complete archive
SHA-256 is `6edefa7e433ef4d598c16de3ef9ebad4f35b6116aca45f36d07bf238a9b915c3`.
Neither `/tmp/moon-tc.tar.gz` nor the saved extracted SDK exists on this box.
The exact `starshine-mb` Git pin is
`1b237952167f582abd492aec27adf10c5a6c9e60`, from the baseline gitlink.

Campaign files are under `/data/workspace/stdlib-wave1-g0`.
The shared `/data/home/.moon` install is not changed.
Results and final verdict will follow in the next checkpoint.

## Final verdict: G0 BLOCKED

The exact SDK and matching core are missing. The four dated download attempts
below return HTTP 403. Restore the saved complete SDK archive with SHA-256
`6edefa7e433ef4d598c16de3ef9ebad4f35b6116aca45f36d07bf238a9b915c3`,
or provide working downloads of that SDK and its core, to unblock this gate.
No implementation work or worker dispatch took place.

### Source and tool identity

The campaign branch starts at the required integration commit. Only this report
and its research evidence differ from that commit; compiler, std, tests, and
pins are unchanged. Integration tree: `db39985f8e307ad0612d7ab71cf54cbd95a77540`.
The first documentation checkpoint is `79ecbe51`.

The dependency was obtained from the local Git object store, not from its current
checkout. All 4,208 restored blobs match the exact pin. Its tree is
`c81e2ea8a7b2c1642da7ce0c04bfb66d67a204fe`.
[Source identities](research/data/stdlib-wave1-g0/source-identities.json)
record content manifests and the blob check.

Installed fallback tools used to reproduce the setup failure:

- Moon `0.1.20261023 (3778465 2026-10-23)`;
  SHA-256 `ce8314a2a78354b83e4a68973cfe613de62ee19a9fbab76ce01be67e4bdb71d3`.
- moonc `v0.10.17+d971670cd (2026-10-23)`;
  SHA-256 `45199d26697c58ba549b6ecc64893c6e6d72da1ff5cbec2dc7d59dae7f2e0a4e`.
- Installed core content manifest SHA-256:
  `1fa970e641b3d8e2fa738a144c6f6a4aafe91970cc32f10521d04a53193905af`.
  This is the installed core, not the required matching core.
- Node `v22.23.3`; no Wasm tests reached Node.
- Snapshot tool: `wasm-tools 1.262.0 (e22db44da 2026-10-13)`, exactly the repo pin.

The saved SDK archive hash is historical evidence only. No compatible SDK was
obtained or hashed in this run. A full search under `/data`, `/tmp`, and `/opt`
found only the installed Moon binaries, with no cached SDK archive. The mise
Moon cache is empty. The GitHub Moon releases API returned an empty array.
The official installer was read, not executed; it specifies the versioned URLs
used below. The date-only URLs were also tried as an alternative.

### Commands and measured results

All test commands ran from `/data/workspace/dewdrop`, on 2026-11-01 UTC.
Each command was captured with Python `subprocess.run`, with elapsed wall time
from `time.monotonic`. Exact argument arrays, exits, and unrounded times are in
[the evidence directory](research/data/stdlib-wave1-g0/).
The command recorder is `/data/workspace/stdlib-wave1-g0/run-command.py`.

| Command | Exit | Seconds | Result |
| --- | ---: | ---: | --- |
| `git -C /data/workspace/starshine-mb archive 1b237952167f582abd492aec27adf10c5a6c9e60 \| tar -xf - -C starshine-mb` | 0 | 0.848 | Exact pin restored; all blobs checked |
| `bash tools/dew-test/run.sh` | 1 | 4.536 | Compiler build failed; zero tests executed |
| `bash tools/module-snapshots/run.sh --target-dir /data/workspace/stdlib-wave1-g0/snapshot-build` | 1 | 0.074 | `wasm-tools` absent from default PATH |
| `env PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin bash tools/module-snapshots/run.sh --target-dir /data/workspace/stdlib-wave1-g0/snapshot-build` | 255 | 4.633 | Correct tool found; compiler build failed |

The snapshot generator build took 4.492 seconds within the last command.
No measured compiler activity exceeded 30 seconds.

Download command template (each exact command is also saved as JSON):

```sh
curl -fL --connect-timeout 15 --max-time 45 URL -o /data/workspace/stdlib-wave1-g0/NAME.tar.gz
```

| NAME | URL | Exit | Seconds |
| --- | --- | ---: | ---: |
| sdk-version | `https://cli.moonbitlang.com/binaries/0.1.20261012/moonbit-linux-x86_64.tar.gz` | 22 | 1.151 |
| sdk-date | `https://cli.moonbitlang.com/binaries/20261012/moonbit-linux-x86_64.tar.gz` | 22 | 1.147 |
| core-version | `https://cli.moonbitlang.com/cores/core-0.1.20261012.tar.gz` | 22 | 1.127 |
| core-date | `https://cli.moonbitlang.com/cores/core-20261012.tar.gz` | 22 | 1.114 |

Every download failed with HTTP 403. No SDK was installed. The shared SDK was
not changed.

### Executed counts and complete build failures

| Lane | Executed | Passed | Failed test count |
| --- | ---: | --- | --- |
| Public std | 0 | Not available | Not available |
| Private B-tree | 0 | Not available | Not available |
| Builtin traps and all operation probes | 0 | Not available | Not available |
| Module snapshots | 0 | Not available | Not available |

The std assembler failed on its first public compiler invocation. No public,
private, or probe Wasm artifact was produced, so later runners could not be run
separately. These are setup failures, not failed Dew tests. The saved 355/41
counts must not be used as fresh results.

Both the std compiler build and the snapshot compiler build report these same
five errors, each `Error: [4015]`:

| Full source location | Error |
| --- | --- |
| `src/transforms/floats.mbt:169:18` | `UInt64` has no method `to_float` |
| `src/transforms/floats.mbt:171:41` | `Int64` has no method `to_float` |
| `src/transforms/floats.mbt:174:26` | `UInt` has no method `to_float` |
| `src/transforms/floats.mbt:176:25` | `Int` has no method `to_float` |
| `starshine-mb/src/wast/lower_to_lib.mbt:814:56` | `Int` has no method `reinterpret_as_float` |

[Std diagnostics](research/data/stdlib-wave1-g0/std-run-errors.txt) and
[snapshot diagnostics](research/data/stdlib-wave1-g0/snapshots-path-errors.txt)
preserve the source text and error messages. Full unfiltered logs remain in
`/data/workspace/stdlib-wave1-g0/evidence/`; their hashes and sizes are committed
in `full-log-identities.json` beside the command records.

### Snapshot status

The separate snapshot lane exists and was attempted without `--update`,
filters, or a disabled reproduction check. It could not build its compiler.
Thus none of the eight saved mismatches can be confirmed or corrected by this
run. Each remains **unverified**, with these exact historical names:

1. `tests/module-snapshots/collections/binary-heap-runtime.wat`
2. `tests/module-snapshots/generics/bounded-function-reference-runtime-evidence.wat`
3. `tests/module-snapshots/generics/generic-enum-adapter-runtime.wat`
4. `tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.wat`
5. `tests/module-snapshots/modules/imported-bounded-function-reference-runtime-evidence.wat`
6. `tests/module-snapshots/text/show-collections-runtime.wat`
7. `tests/module-snapshots/text/show-derived-runtime.wat`
8. `tests/module-snapshots/types/derive-debug-runtime.wat`

### Cleanup and next action

Removed the build directories, dependency cache, and temporary pinned dependency
copy created by these attempts. No test fixture or implementation file changed.
Logs and command evidence remain in the campaign area. Commit signing did not
block either checkpoint; no signing override was used.

Restore the exact SDK archive into `/data/workspace/stdlib-wave1-g0`, verify its
saved SHA-256, then extract it there. Select it with per-command `MOON_HOME` and
`PATH`, restore the checked dependency pin, and rerun both complete lanes. G0
remains blocked until those runs produce real counts and named failures.
