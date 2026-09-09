# StringBuilder append functions in Dew

String, StringView, and ASCII append now have ordinary Dew bodies. A private
typed `ref.cast` exposes the same mutable object as BytesBuilder. String and
view inputs use the existing raw text casts; ASCII range checking is Dew code.
This neither allocates a replacement builder nor resets its consumed state.
The cast is not a public safe conversion between the builder types.

Native and provider dispatch no longer accept the three old append names.
The shared provider append helpers now serve BytesBuilder only. Byte storage,
growth, capacity allocation, scalar encoding, and finish remain open work.

The shared source checks cover returned append functions, nested UTF-8 views,
empty inputs, repeated appends, source preservation, ASCII limits, finished
aliases, and exactly-once left-to-right argument evaluation. Raw GC checks also
cover builder aliases across the private cast, growth, and shared consumption.
The native raw-instruction test requires exactly one cast to the BytesBuilder heap.

The returned-view test found a separate reachability defect: the program work
queue followed calls but omitted function references. A function used only as
a returned value could be elided. Both initializer and callable scans now use
the existing target reader that also accepts function references. The regression
fails before this change and keeps the target live after it. No standard path,
source name, or declaration ordinal is used by this fix.

Measured checks so far:

- Policy baseline: 14 expected subtest failures; all three test methods then pass.
- Provider baseline: 20 pass, one expected failure in 7.357 seconds. Final focused
  file: 20 pass in 6.449 seconds. Provider commit `c39b43953`.
- Reachability regression: one pass, one expected failure in 11.722 seconds;
  both pass after the fix in 11.300 seconds.
- Native String build: 10.291 seconds; all 35 runtime cases pass in 0.023 seconds.
- Raw instruction file: 20 pass in 6.835 seconds. Raw GC storage: 21 cases pass.
- Provider build: 10.197 seconds; consumer generation: 4.066 seconds. All 476
  selected FFI declarations retain their signatures; only the provider hash changes.

The first reachability fixture missed the required String module selection and
trapped in test setup; it was corrected before recording the intended failure.
An initial Moon name filter selected zero tests; that is not pass evidence.
Early String builds failed with MissingFunction; stale Wasm output was not used
as successful runtime evidence. The first self-host run passed all shared runtime
checks but exposed three stale fixture body counts: each fixture gained one Dew
append body. Updated exact counts retain those helpers. Final hardening passes
859 tests, 448 exact failure records, and the shared runtime corpus in 92.487
seconds. The native library lane passes in 36.689 seconds; generated checks pass
in 19.435 seconds. Full native passes 1,284 tests in 200.918 seconds; integration
passes all 270 tests in 60.583 seconds. Clean bootstrap passes in 179.585 seconds.
Raw and linked compiler B/C outputs match at SHA-256
`e046d0658484a3a81accd9c8a6cf94db9a21b7c221b27d65c5afb86e8b7ab0fc`.
Runs above 30 seconds remain timing defects; speed work is deferred.
