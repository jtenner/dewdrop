# Starshine optimizer audit sync (2026-10-05)

Dewdrop pins Starshine `2368260c6a3f798c8d50089faccb409880d125e5`, now on
Starshine's remote `master`. This fast-forward carries Dewdrop's FFI export and
native-test fixes, its tuple-tail regression, and the four optimizer safety,
correctness, and documentation commits previously on Starshine `main`. The old
local Starshine `master` commit `3bb96abca` is patch-equivalent to changes
already present on remote `master`; its original pointer remains in the local
`archive/master-pre-sync-2026-10-05` branch.

The prior integrated pin `8191ec0b9` passed 9,094/9,094 native release pass tests
and 648/648 native release IR tests. This pin adds branch payload reconstruction,
bottom reference null checks, descriptor-cast compatibility/exactness, branch-table
operand checks, core-versus-suspension tag policy, and narrow branch-hint metadata
repairs. Starshine's complete bounded wasm-gc suite now passes 13,745/13,745.
The complete native spec-harness aggregate also passes; the eight failing fixture
families and the later branch-table defect are repaired without new skips or
mismatch allowances. Focused lanes pass 28/28, 544/544 and 79/79.

The provider build exports 4,235 concrete functions; 27 symbols still need
explicit concrete wrappers. Native full Starshine tests require release mode
because the debug linker cannot lower its non-null value-record arrays. The
native spec replay took 49.232 seconds, the final wasm-gc gate 148.056 seconds,
and the provider build 30.667 seconds. These exceed the 30-second compiler
activity budget and remain build-cost risks, not isolated performance evidence.

The generated Dewdrop FFI manifest and self-host fingerprint use the new
Starshine revision and the rebuilt provider's changed reference-type indices.
Provider SHA-256 is
`ea8d8cc6f14f90c2d74125d90415ac3f8ed892bd434365b06d3613231a53ce9d`.
The generated consumer's exact-byte check passes; its 473 bindings and the
provider's export count are unchanged.

Current Dewdrop validation passes:

- Routine native tests: 1,375/1,375; integration: 272/272; stress: 15/15.
- Generated-source and CLI cache/ABI checks.
- Full language suites: 332 standard-library tests, 61,000 SWAR checks, 17,471 UTF
  checks, 196 WASI checks, 461 Node/Wago snapshots and 85 architecture WAT cases.

Local logs use `.tmp/dewdrop-spec-repair-*.log`; the complete language lane took
486.425 seconds across its
many compile/execution checks. All individual measured routine-native compiler
activities stayed below 30 seconds. These test timings are not pass-local
performance measurements. Broader Starshine release/parity/runtime blockers
remain recorded in its active backlog; a green bounded suite does not close them.

Wago remains at `8ad646c61b533371497acfb0ff44852c18c36d1c`. All 180 repository
packages pass (134 tested, 46 without tests) with WABT 1.0.41 first on `PATH`
and `GOFLAGS=-buildvcs=false`. A raw `go test ./...` also collects the user's
untracked `code-review-2026-10-02-repros/harness` directory, whose independent
probe programs contain multiple `main` declarations. It also selected WABT
1.0.42 instead of the pinned 1.0.41 and hit temporary-build VCS stamping errors.
The successful lane excludes only that scratch harness package, keeps all repo
packages, and preserves all user-owned notes and probes unchanged.
