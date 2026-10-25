# Direct forwarding calls: full compiler job

Ready [PR1008](https://github.com/wago-org/wago/pull/1008) removes up to four
local forwarding frames at direct call sites. Every edge must have identical
Wasm parameter/result types and only pass each argument through unchanged.
Cycles, imports and type-changing edges are rejected. Export and function
reference identities are kept. No handle or dynamic type check is removed.

Public commit `8b5ed461e8515c4e708056b032387813b13df094` is picked as local
`34c82f912eebafade2f47793cb6850fd6a0e2c35`. The production source matches the
measured private source. The user's ARM64 call edit retains its original hash.

The full job is the same two transforms as the
[integer-inline result](wago-gc-followup-2026-10-21.md), with the same compiler
and request bytes, CPU12,14 and GOMAXPROCS=2. All native caches are fresh;
all transform result caches miss. No task-owned build or test overlaps.
[All samples and commands](data/wago-direct-forwarder-2026-10-21/) are retained.

| Engine | All wall times (s) | Median (s) |
| --- | --- | --- |
| Local GC stack plus integer inlining | 45.358,45.565,45.440 | 45.440 |
| Above plus direct forwarding retargets | 42.074,42.589,42.232 | 42.232 |
| V8 | 3.957,4.026,3.990 | 3.990 |

The median falls7.06%. Wago still takes10.59 times the V8 median. This is a
shared host and one workload; no general speed bound is claimed. All output
hashes agree, Wasm validation passes, main returns42 and all six Wago native
artifacts keep exact root admission. They retain25,794 safepoints and56,923
native callsites. Code remains27,059,224 bytes and metadata3,311,043 bytes.
The pass changes call destinations, not native instruction counts.

Fresh-main diagnostic compilation selects21,610 sites in2,557 callers.
Small8,192-call loops improve1.22x for one wrapper and2.19x for four wrappers.
Runtime coverage includes exact root offsets, later allocating calls, forced
GC/Tiny, normal codec reload, numeric/vector/multiple results, dirty globals,
trap source/order and direct/indirect/reference identity. The staged
reference-result register ABI has strict fresh-artifact tests because the
public codec still rejects its required tail-call feature bit0x100.

The ready branch passed normal and checked compiler/runtime/API/plugin and
conformance checks. An initially stale switch schema is regenerated, and
complete affected settings/API reruns pass in both modes. The separate checked
bench module and focused stats+checker tests pass. Combined normal and checked packages pass in 45.756 and 44.819 seconds.
Focused stats+checker tests pass in 14.491 seconds. The data folder contains
these records and all install checks.

Installed and selected `local-gc-34c82f912` at `/home/dev/.local/bin/wago`.
The runtime is `/home/dev/.local/share/wago/versions/local-gc-34c82f912/standard/normal/wago-runtime`.
All 32 CLI/build/smoke checks pass, including the new four-wrapper loop,
previous numeric/root checks, GC field/array cases and older native code.
The manager and runtime builds each take 4.962 seconds, run concurrently.
The upstream head watcher remains active with one-minute polling.

## Manifest follow-up and current install

Public follow-up `48849d58b5b0a51e0646f02c2eaeccb58ea14129` adds the pass
name to the separate project manifest allowlist. The regression fails before
the fix in 0.242 seconds. Complete project/settings checks pass in 9.954
seconds. Local pick `d06313bc31347491e19b7102404f00c7f3a0b36b` is installed
and selected as `local-gc-d06313bc3`; all 32 smoke checks pass again.
This changes setting admission, with no new speed claim. The runtime is
`/home/dev/.local/share/wago/versions/local-gc-d06313bc3/standard/normal/wago-runtime`.
The manager remains `/home/dev/.local/bin/wago`. The previous installed
version is retained.
