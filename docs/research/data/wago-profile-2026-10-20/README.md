# Wago profiling evidence

Read [the report](../../wago-runtime-profile-2026-10-20.md) first.
`samples.json` contains measured commands, statuses, resource use, and phase logs.
`identity.json` contains source, compiler, request, tool, and provider identities.
Only successful runs have validated output/cache hashes. Failed and incomplete
probes remain visible and must not be used as speed results.

## Current-main rebuild

`current-main/` holds the exact build identity, validation record, raw run logs,
and samples for Wago `7997c86c36e05cfba4c4f39cabb026a318f55fc0`. Its builder
now lives in `tools/build-wago-transform-host.py`. These runs use the same
compiler and request bytes as the earlier profile. The driver accepts
`WAGO_PROFILE_HOST_OVERRIDE` and `WAGO_PROFILE_HOME_OVERRIDE` for these runs.
The older diagnostic patch below targets only `2dd978ccda6f`; do not apply it
to current main. Go profile and collector counter claims below refer to that
older build.

## Private diagnostic build

Run from the Dewdrop root at the recorded commit. Use the pinned host builder to
obtain an existing baseline host and its `.identity.json`, then:

```sh
source tools/self-host-common.sh
self_host_measure 'diagnostic host build' python3 \
  docs/research/data/wago-profile-2026-10-20/build_profile_host.py \
  .tmp/transforms-v5/worker-host-start/host .tmp/wago-profile-rebuilt
```

Add `--gcstats` for collector counters. The helper copies the baseline's pinned,
safety-patched private Wago tree, verifies the production host source identity,
applies `diagnostic.patch`, and builds with Go 1.27.2. It changes no dependency
checkout or module-cache source. A missing old private tree can be replaced by a
new `tools/build-wago-transform-host.py` build at the same Dewdrop commit.
Use a fresh absolute `WAGO_HOME` for each build/flag variant. These diagnostics do
not set the production link-time identity variables.

The saved `run.py` is the exact local experiment driver, not a production CLI.
It uses the artifact paths from this session under `.tmp/wago-profile-2026-10-20`
and `.tmp/transform-workers/run-rvr6ozve`. Restore those artifacts or adjust paths
before a rerun. Original compiler, adapted compiler, request, and provider hashes
are in `identity.json`. `tools/test-transform-workers.py` shows the ordinary
request-generation path. The fixture command in this run was:

```sh
source tools/self-host-common.sh
self_host_measure 'profile request' \
  _build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe \
  .tmp/wago-profile-2026-10-20/request.bin \
  starshine-mb/dist/ffi/starshine-ffi.wasm \
  self_host/starshine/fingerprint-prefix.bin \
  .tmp/wago-profile-2026-10-20/output.wasm example.app \
  examples/transforms/parallel.dew --standard-root "$PWD" \
  --transform-cache - .tmp/wago-profile-2026-10-20/output.cache --cache-report
```

The driver uses a 300-second child timer. Its completed bounded native probe is
Linux AMD64 only and attaches to its own child. It reads leaf registers, not
stacks or guest memory. Use it only for diagnostic runs. It is not a general
sampler or an acceptance test. Separate Go CPU recording from native probes.

## Reading the records

- `serial-cold-complete/cpu.pprof`: complete ordinary serial Go CPU profile.
- `serial-cold-complete/cpu-top.txt`, `cpu-cumulative.txt`, and
  `handle-source.txt`: readable summaries and line attribution.
- `parallel-cold-complete/`: complete ordinary two-worker profile and phase logs.
- `serial-gcstats/run.log`: existing collector/helper telemetry. Counters add
  substantial runtime overhead.
- `serial-native-bounded/`: added handle occupancy counters, final code map,
  native function boundary, sampled leaf addresses, disassembly, and summary.
  The 21 MB native image is not stored here; its hash and size are in samples.
- `node-control-*`: ordinary Node controls. `node-profile/` also has V8 CPU data.
- `serial-no-global/`: one `WAGO_PIN_GLOBAL_K=0` experiment, with a fresh native
  cache. The current artifact key does not encode this switch. Do not report a
  qualified gain from this single observation.
- `production-warm/`, `warm-diagnostic/`, `serial-warm/`, `parallel-warm/`:
  failed cached-artifact executions. No performance win is claimed.
- `serial-cold/`: valid first wall/phase result, but CPU recording was lost to
  the guest's `os.Exit` path. Its empty CPU file is not a profile.
- `serial-native/rejected.json`: first native sampler stalled during startup;
  it and the blocked harness were closed. The bounded replacement passed.

Profiles can be read with `mise exec go@1.27.2 -- go tool pprof`. Function names
are embedded in the Go profiles; source listing needs the matching diagnostic
source copy. Native probe function ranges include wrappers and padding. Native
probe counts do not measure CPU percentages or inline Wasm source locations.

`compile-scan.md`, `gc-scan.md`, `warm-cache-scan.md`, `module-global-scan.md`, and
`warm-invariant-decode.md` are read-only source analyses. Their hypotheses are not
additional measured findings. The report states which hypotheses the data supports
or rules out. Normal runtime settings and safety checks were not changed.
