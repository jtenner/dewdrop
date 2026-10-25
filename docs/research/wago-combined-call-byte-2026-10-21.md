# Combined reference-call and decoder result

The measured performance source is `dewdrop/local-gc-perf-20261020` at
`5efc7acb1ffebf07a70031baf8e1952a3ad00546`. Its recorded manager/runtime version
is `local-gc-5efc7acb1`; `wago` resolves to `/home/dev/.local/bin/wago` in a login
shell. Both binaries were built from that source. All39 installed CLI/build/run
checks pass. The new fixture checks private/addressable direct calls, indirect
calls and call_ref. The first smoke attempt passed an unsupported --core flag
to the installed build command; that usage error remains saved separately. The
corrected seven extra checks passed without changing binaries or runtime code.

Pending public changes included in this install:

- PR1009 (`f240a3aa4`): private reference arguments/results use register calls;
  return result placement retires stale global-cell cache state.
- PR948 follow-up (`2c53a7838`): six native read resolvers load their space byte.
- PR1003 (`d7b8ac6ef`, `254473b30`, `5b1943728`): reject invalid physical spans
  before type reads; abstract-array byte load; bounded combined-test corrections.
- PR1008 (`cb943b219`): keep wrapper edges when compact mode omits the terminal
  inline leaf body. Linker rejection and original masks remain intact.

The local test commit adds the eight-way inline/forwarding/reference-ABI matrix.
Fresh/codec, forced-GC/Tiny, hidden operands, exact source masks, final target ABI
and function identity checks pass. Full normal/checked suites pass176.914/177.532
seconds; checked bench41.171 seconds. The user's unrelated dirty ARM64 call.go
remains byte-identical to SHA33b8f91b38727df8487afc9c7a99d6c59bca0ed5d8be1b927c0ad6fefa2f0818.
Held stable/canonical recycling experiments are excluded. Their negative
small-guest/large-free-list results remain saved; no default collector change
was justified by the single compiler gain.

## Matched full compiler job

Three balanced serial rounds use control/combined/V8, combined/control/V8,
control/combined/V8. Both Wago versions share the same metadata-span safety
repair and abstract-array byte decoder. The combined candidate adds PR1009,
the six decoder changes and the compact forwarder guard. CPU12,14,
GOMAXPROCS=2, identical compiler/request bytes, fresh native caches and transform
result misses. No task-owned build/test overlaps these runs.

| Version | Samples, seconds | Median, seconds |
| --- | --- | ---: |
| Control | 42.837453,42.821480,42.818719 | 42.821480 |
| Combined | 37.817123,38.489384,37.803671 | 37.817123 |
| V8 | 4.223876,4.186634,4.082579 | 4.186634 |

The combined candidate takes11.69% less time and remains9.03 times V8. All9
output Wasm/cache hashes match; Wasm validates and main returns42. Every Wago
artifact requires and supplies exact native GC roots. RSS values are retained,
but this small shared-host matrix does not establish a memory improvement.

The earlier independent comparison found reference ABI8.56% and six decoders
2.97% lower wall time against a shared safe control. This combined measurement
is separate; it does not assume those improvements multiply.

Full hashes, per-run commands/logs, exact root metadata/code sizes, source/build
identity, raw samples and install checks are in
[data/wago-combined-call-byte-2026-10-21](data/wago-combined-call-byte-2026-10-21/summary.json).

The upstream head and review-comment watchers remain active. The next safety
work audits exact reference ingress and detached GuestStorage metadata before
any broader trusted typed-access optimization. Both were found by a fresh
Astra source audit and require strict public/callback reproductions.


The selected install now advances to local-gc-321fae779 with PR1010 metadata
query isolation. See wago-guest-storage-types-2026-10-21.md. Native emitters are
unchanged; the timings above remain tied to their original measured source.
