# Wago PR 997: root faults fixed

The unused-table case already passes at `d329e9df9`. The old PR description was
stale. Forced collection still lost A.outer's live root through A → B → A under
both call ABIs. A foreign-store numeric relay had the same fault. An added host
callback control also exposed a collector-lease lock wait.

Commit [`d868ee7fb`](https://github.com/wago-org/wago/commit/d868ee7fb3fb8c123669a2301154da8bbcd62c8e)
fixes those remaining faults in [PR 997](https://github.com/wago-org/wago/pull/997).
It follows exact foreign return maps, skips foreign collector words, retains
numeric relay maps, and publishes parked host chains before releasing the public
caller's collector lease. The source note contains the lifetime proof and bounds.

The complete normal and checked root suites, checked benchmark module, final
normal/checked Wago suites, ARM64 root controls, RV64 parked-root controls, full
lint and docs checks pass. One extra ARM64 QEMU shared-memory marker test fails
on both parent and candidate. Root and host-reentry cases pass. Native platform
qualification and independent review remain pending; the PR stays draft.

The final deep-frame cost is within 0.3% of the baseline sample median and keeps
zero allocations. Numeric relay compilation adds 1.355 µs, 519 B and 11 allocations;
native bytes stay unchanged. Two host controls improve about 2–3%. This is a
correctness repair and does not establish the four-second compiler target.
A newly supported numeric-host path can allocate a lazy 23,440-byte GC state.

Evidence:

- [Source identity](data/wago-pr997-root-faults-2026-10-22/identity.json)
- [Committed source patch](data/wago-pr997-root-faults-2026-10-22/final-source.patch)
- [Original lost-root failure](data/wago-pr997-root-faults-2026-10-22/red.log)
- [Foreign-store failure](data/wago-pr997-root-faults-2026-10-22/foreign-stores-red.log)
- [Normal suite](data/wago-pr997-root-faults-2026-10-22/normal-root-v2.json)
- [Checked suite](data/wago-pr997-root-faults-2026-10-22/checked-root-v2.json)
- [Final checked Wago](data/wago-pr997-root-faults-2026-10-22/publish-checked-wago.json)
- [Final ARM64 roots](data/wago-pr997-root-faults-2026-10-22/arm64-publish.json)
- [RV64 roots](data/wago-pr997-root-faults-2026-10-22/rv64-fast-guards.json)
- [Existing ARM64 emulation failure](data/wago-pr997-root-faults-2026-10-22/arm64-threads-baseline.log)
- [Paired costs](data/wago-pr997-root-faults-2026-10-22/benchmark-summary.json)
- [Final host costs](data/wago-pr997-root-faults-2026-10-22/host-guard-summary.json)
- [Full lint](data/wago-pr997-root-faults-2026-10-22/full-lint.json)

Raw failing attempts remain visible. The cold builds and suites that exceed
30 seconds remain performance bugs under the project budget. Test binaries and
corpus clones are excluded from the packet. User changes in the main Dewdrop
checkout were not included in this work.
