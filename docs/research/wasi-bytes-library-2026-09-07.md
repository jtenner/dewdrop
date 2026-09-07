# WASI Bytes loops in Dew

`std/wasi.dew` now defines `wasi_fd_write` and `wasi_fd_read` as ordinary public
Dew functions. They use the existing raw Preview 1 foreign declarations and
one-to-one memory instructions. The compiler no longer supplies their loops.

The adapter retains its existing contract: one shared 64 KiB scratch page,
65,520-byte windows, exact Bytes views, partial-write retries, and reads that
stop at the limit, EOF, or a short host result. Each host result slot is cleared
before the call. Nonzero errno, zero write progress, and excess progress trap
before retry or copy. Empty operations perform no host call. The page is owned
by the synchronous operation; host callbacks must not re-enter the adapter.
GC builder storage owns read results after the call.

The obsolete read runtime builder, runtime classification, hidden dependency
rooting, and emitter read-index parameter are removed in both the native backend
and the pinned Starshine bridge. The bridge builder's public signature no longer
takes a read-function index; generated bindings must be refreshed together. The
old write builder still serves primitive Debug and test-assertion transport. Its removal belongs
to that migration; this commit does not claim those remaining users are gone.

The shared native/self-host corpus checks six write sizes (including exact and
multiple windows), partial writes, seven read cases, and five invalid host
results. Negative cases require a successfully compiled and instantiated module
and exactly the expected host call before the runtime trap. Host-stub errors and
unexpected calls remain test errors. Policy tests prohibit new adapter builtins
and the removed compiler read implementation.

## Measured checks

- The original native implementation passes all 19 behavior checks: compilation
  0.615 seconds, execution 0.067 seconds.
- The Dew implementation passes the same 19 checks: compilation 10.267 seconds,
  execution 0.067 seconds.
- First self-host hardening run: 325 tests and 75 exact records passed, but the
  new corpus failed with visible missing-module diagnostics (76.314 seconds).
  The request fixture now includes `dew.std.wasi`. The next probe exposed its
  required `main` entry (24.747 seconds); the fixture now uses the same main
  dispatch as the other corpora. Neither setup failure was accepted as a trap
  test result.
- After those fixture fixes, all self-host emission corpora pass in 25.678
  seconds, including all 19 new I/O checks (1.331 seconds).
- Native suite: 1,024 tests pass in 150.743 seconds. Semantic/backend tests took
  94.067/43.485 seconds, still speed bugs. Integration: 268 tests pass in 64.336
  seconds, also a speed bug.
- The bridge removal test first fails in 6.876 seconds. After removal, all ten
  bridge tests pass in 7.051 seconds. The interface check takes 1.014 seconds.
- All 10,983 pinned Starshine tests pass in 263.661 seconds; this remains a
  speed bug. Provider generation/build takes 10.985 seconds and consumer
  binding regeneration takes 4.087 seconds before final unused-helper cleanup.
- Final provider build/consumer regeneration pass in 10.653/4.068 seconds.
  Provider SHA-256 is
  `4aed8b7df16ecff21e3f67e1bde90de4117cf3c601ac80c329994352bd6acd86`.
  The bridge is committed as `2ff6bd7c0` without a push.
- The first post-commit hardening check correctly rejected the stale provider
  revision fingerprint in 4.057 seconds. Regeneration after the bridge commit
  refreshed that revision in 4.051 seconds; its Wasm bytes did not change.
- Library suite: 326 tests and all shared native corpora, including the 19 I/O
  checks, pass in 35.205 seconds. The lane exceeds 30 seconds; no speed fix is
  included.
- Generated-source checks pass in 17.263 seconds. Refreshed-provider hardening
  passes all 325 tests, 75 exact records, and shared corpora in 66.719 seconds;
  the I/O corpus takes 1.309 seconds. The full hardening lane remains a speed bug.
- Clean bootstrap passes in 165.145 seconds. A build takes 40.039 seconds;
  A/B execution takes 43.720/57.025 seconds. These remain speed bugs. B/C core
  and linked bytes match. Linked SHA-256:
  `b5a44610383b0ed8ba9995e9362eadd0e54299894bb6dec1a075a84d5a939e10`.
  No speed changes are included.
