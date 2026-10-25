Cancelling an unused native large-array reservation scans the full nursery handle prefix. A Dewdrop compiler profile on current Wago puts 13.30 CPU seconds in that cleanup call, with 13.29 seconds on the search loop. A separate diagnostic run records 24,879 cancellations and 29.6 billion old search comparisons.

Save the handle-list position when the reservation is appended. Validate its bounds and identity at cancellation; retain the old forward search if the list was compacted. Stable deletion keeps live-handle order. The free, rewind, consumed-reservation, checked-handle, reset, and epoch rules stay the same.

This adds one private `int` at the end of `Collector` (3,128 to 3,136 bytes on AMD64). Existing field offsets and the 40-byte native reservation state stay fixed. No native ABI change and no new allocation per timed operation. Host `.text` grows by 160 bytes in the paired builds; no code-size gain is claimed.

### Measurements

Linux AMD64, Ryzen 7 8845HS, Go 1.27.2. The benchmark uses `GOWORK=off GOMAXPROCS=4`, the same harness on both versions, three 100 ms samples, and real live handles prepared before timing. The loop times real reservation/cancellation calls plus identical suffix copies.

| One million live handles | Base median ns/op | Fix median ns/op |
| --- | ---: | ---: |
| Reservation at tail | 432,076 | 16.73 |
| One later handle | 415,513 | 17.17 |
| 512 later handles | 428,009 | 60.24 |
| 1,024 later handles | 423,109 | 102.1 |
| Reservation at front | 493,505 | 486,828 |

Both versions report `0 B/op` and `0 allocs/op`. Front deletion still copies the live suffix and is unchanged within noise. The old scan also remains as a checked fallback.

The same serial Dewdrop compile request was run in order base/fix/fix/base, with a new native cache each time, no profile code, `-p8`, 512 MiB GC heap, and 64 MiB nursery:

| Run in order | Wall seconds | CPU seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| gc-plain-baseline | 108.349 | 110.172 | 1,114,944 |
| gc-plain-candidate | 105.509 | 107.361 | 1,058,320 |
| gc-plain-candidate-2 | 102.368 | 104.278 | 1,136,756 |
| gc-plain-baseline-2 | 114.202 | 116.026 | 1,144,680 |

Both pairs are faster with the fix (2.62% and 10.36% lower wall time). The range is wide: two runs per side and other active user work do not establish a precise general speed ratio. Every output and transform-cache SHA-256 matches, Wasm validation passes, and the emitted program returns 42. Transform-result caching was forced to miss.

Separate diagnostic profile runs take 116.994 and 103.332 wall seconds. The older baseline profile has unverified embedded host identity labels, so the plain runs above are the controlled wall-time comparison. Cleanup falls from 13.30 seconds flat CPU to 0.01 seconds flat / 0.03 seconds cumulative. Profile and plain timings are separate controls. Per-run RSS varies in both directions; no whole-job memory reduction is claimed. One private host build per side takes 5.464 and 5.538 seconds, which does not establish a build-cost change.

Measurements use base `7997c86c36e05cfba4c4f39cabb026a318f55fc0` plus the same existing Dewdrop safety/worker/Facet patches. The PR is rebased onto `ed76fd17957fd472b92a69d2fa3f5f63680f2cd5`; the intervening commits change tests/docs/CI, not runtime source. SHA-256 checks match both measured runtime files to this PR. The full Dewdrop compiler artifact is an external workload, not a fixture shipped in Wago.

### Validation

- Full native collector package: normal, `wagodebug`, and `-race` pass.
- New regression cases also pass on the base; the benchmark exposes the cost without a flaky timing assertion.
- Cases cover stable ledger order, later allocations, moved/missing entries, struct-batch compaction, nursery/throughput backing, consumed reservations, checked generation reuse, epoch wrap, and failed collection with live roots.
- Eighteen focused native execution tests pass: array/struct allocation, mixed reservations, traps, collection, nursery growth, and ABI checks.
- Linux ARM64 collector test binary cross-compiles; no ARM64 runtime performance claim.
- Independent read-only source review inspects all seven changed files and finds no defect.

Reproduce the small benchmark:

```sh
GOWORK=off GOMAXPROCS=4 go test ./src/core/runtime/gc/native \
  -run '^$' -bench '^BenchmarkNativeLargeArrayCancellation$' \
  -benchtime=100ms -count=3
```
