# Independent large-array cancellation review

Reviewed baseline `ed76fd17957fd472b92a69d2fa3f5f63680f2cd5` and candidate `3da9b38d6500d600e16e7d64c7f9d0aaf695cc7d` in the private Wago checkout. This review used source and saved data only. I did not build or run tests. Root had timed jobs active.

## Confirmed defects

None found in this change.

## Source assessment

All seven changed files were inspected: `ARCHITECTURE.md`, `collector.go`, `native_alloc.go`, `card_driven_test.go`, `major_blocks_coverage_test.go`, `native_large_array_cancel_test.go`, and `native_large_array_cancel_debug_test.go` (runtime files are under `src/core/runtime/gc/native`). I also read the linked allocation, handle reuse, checked identity, collection entry, nursery compaction, and shutdown paths.

The saved index is written after the new handle is obtained and before it is appended. No collection can occur between these steps. Cancellation accepts the index only if it is in range and the slot has the reserved identity. Otherwise it uses the prior forward search. A stale index therefore cannot delete a different live handle. The copy retains the order of all remaining handles.

The free-list append, backing rewind or free, consumed-state check, state reset, and epoch wrap rules are unchanged. Cancellation still returns at most one reserved identity per active state. Collection and shutdown cancel the struct batch first; its compaction can remove the unused large-array entry. The new hint then fails validation and the search can find no entry, as before. The large reservation is still freed once. Consumed reservations do not reach this path.

The new scalar is at the end of `Collector`. It adds one Go `int` and no pointer, per-object field, or per-reservation allocation. Prior collector offsets and the 40-byte native reservation state stay fixed. The updated size tests check this on their supported targets.

The new tests cover live ledger order, nursery and throughput backing, checked generation reuse, a consumed object, epoch wrap, duplicate multiplicity, short and long suffixes, struct-batch compaction, moved slots, and a failed minor collection. The failed-collection test checks roots and verifies the heap after the failure. These tests support the change; the source checks above are the basis of the correctness assessment.

## Speed and memory evidence

The raw microbenchmark logs and the committed harness support a large gain when the reserved entry has a long live prefix and a short suffix. For example, at 100,000 live handles and one later handle, the three baseline values are 41,863 / 41,564 / 42,551 ns/op. Candidate values are 16.91 / 16.91 / 17.19 ns/op. Both report zero Go bytes and allocations per timed operation. The harness times reservation, cancellation, and suffix copies; it does not claim to time the cancellation call alone.

Front-position cases still copy the full suffix. At 100,000 handles their medians are 15,427 and 15,378 ns/op. At one million handles they are 493,505 and 486,828 ns/op. These small differences are within the visible sample noise. The change does not remove the linear suffix copy or the fallback scan.

The controls recorded for these microbenchmarks are Linux AMD64, Ryzen 7 8845HS, Go 1.27.2, GOWORK off, GOMAXPROCS 4, the same harness, 100 ms per sample, and three samples. Source comparison confirms that the rebase adds tests/docs/CI and does not change the reviewed runtime files. Three samples do not give a precise estimate for small gains. There is no native ARM64 or 32-bit timing evidence.

The saved full compiler profiles use the same compiler and request hashes. They produce the same Wasm and cache hashes and return main value 42. Their wall times are 116.993817 and 103.331937 seconds. Large-array cancellation falls from 13.30 seconds flat CPU to 0.01 seconds flat / 0.03 seconds cumulative. This is strong evidence that the intended scan cost is removed in that job. These are single profiled runs. The baseline banner reports unpatched/unverified host identities, while the candidate has new embedded identities. Use the plain host runs below for the controlled wall-time claim.

All four plain samples have matching compiler, request, output Wasm, and output cache hashes. They all return main value 42. Each uses the expected host binary hash, the same flags and settings, a fresh WAGO_HOME, and a transform-result cache miss. Run order is baseline/candidate/candidate/baseline:

| Run | Wall seconds | User + system CPU seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| baseline | 108.349079 | 110.172117 | 1,114,944 |
| candidate | 105.508511 | 107.361405 | 1,058,320 |
| candidate repeat | 102.368180 | 104.277683 | 1,136,756 |
| baseline repeat | 114.202170 | 116.025666 | 1,144,680 |

The first pair has 2.62% lower wall time with the candidate. The reverse pair has 10.36% lower wall time. Both support a gain for this compiler job, but they do not establish one precise rate. There are only two samples per side. Baseline wall time itself varies by 5.853 seconds and candidate wall time by 3.140 seconds. The last baseline sample also has a higher recorded load average. Reverse order reduces one run-order bias, but CPU boost, unrelated work, and allocator variation still limit the result. A general speed ratio across compiler inputs or machines is not established.

There is no firm whole-job memory reduction result. In the single profiles, RSS rises from 1,105,168 to 1,151,216 KiB. Go total allocation rises from 1,969,304,496 to 1,975,989,408 bytes, while end heap allocation is close (918,689,128 versus 918,534,040 bytes). Plain RSS is lower for the candidate in both pairs, but the repeat candidate uses 78,436 KiB more than the first candidate. These values include the full job, allocator variation, and profile effects. They do not establish a leak or a whole-job memory cost caused by the hint. The source and footprint tests establish a bounded one-word struct increase: 3,128 to 3,136 bytes on measured AMD64. Microbenchmark zero B/op describes the warmed loop only.

There is no code-size gain. Generated output hashes match, so output code size is unchanged in this case. The plain native host `.text` grows from 5,647,185 to 5,647,345 bytes: 160 bytes (about 0.003%). Cancellation grows from 659 to 805 bytes and preparation from 755 to 765 bytes, a combined 156-byte increase before alignment. The whole executable is 352 bytes smaller, but debug and other sections also change. That is not a machine-code size gain.

Plain baseline and candidate host build times are 5.464 and 5.538 seconds. These single builds are not a cold/warm series and do not show a meaningful build-cost change. Package test wall times include different test work and are not build-cost controls. The candidate's native execution log shows 18 named tests passing, including dynamic large arrays, mixed reservations, fallback collection, traps, native ABI checks, and nursery growth. The ARM64 build log records successful cross-compilation in 1.771 seconds. This does not show ARM64 runtime behavior or speed.

The plain host identities use the same host source digest, Go version, base source, and Facet patch. Only the candidate applies `runtime-index.patch`; neither includes the diagnostic package. The recorded candidate runtime source hashes also match the reviewed checkout. These controls are suitable for this plain comparison. The environment record states that root ran one timed job at a time; unrelated user work can still add noise, and CPU boost is enabled.

## Unverified risks and limits

No unverified code defect was identified. The remaining limits are measurement limits: two full-job samples per side do not give a precise general speed ratio; memory samples do not prove equal peak memory; comparative build cost has only one sample per build; targets other than native AMD64 lack runtime measurements.

## Draft PR claim check

Read `.tmp/wago-investigation-2026-10-20/gc-pr-body.md`. The raw benchmark numbers, full-job table, two pair percentages, one-word collector growth, 160-byte host text increase, build timings, runtime hash matches, and validation scope agree with the inspected evidence. The draft states the main measurement limits and does not claim a general speed ratio or whole-job memory gain.

One wording issue was sent to root before publication: replace "matching CPU profile pair" with "separate diagnostic profile runs", unless an additional check proves that those profile hosts differ only in the runtime patch and identity strings. The saved baseline profile does not carry the same level of host identity evidence as the plain hosts. This is an evidence description issue, not a code defect.

## Evidence read and unread

Read: exact Git diff; scoped source named above; raw baseline and candidate benchmark logs; microbenchmark summary; baseline and candidate normal/debug logs and candidate race log; review scope and identities; host build harness; runtime-index and diagnostic/counter patches; baseline and candidate full-job samples and logs; baseline and candidate CPU top and line reports; distance-counter sample and log; environment record; plain host identities; source hashes; native cleanup symbol sizes and ELF sections; native execution and ARM64 cross-compile logs; all four plain samples and logs; plain sample aggregate; draft PR body.

Unread: binary CPU/heap/allocation pprof payloads (the saved text CPU reports were read); PR 948 cold/warm and codec comparison data, which are outside this candidate's scope; prior Claude and invariant-review conclusions, to keep this review independent. No changed source file or required final plain result was left unread.
