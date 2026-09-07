# Integer Debug formatting in Dew

The eight signed and unsigned integer Debug formatters are ordinary functions in
`std/preamble/110-debug.dew`. Decimal conversion uses a bounded 32-byte scratch
range and no GC allocation. The shared output loop calls the private foreign
`DebugOutput.__dew_debug_fd_write` declaration and checks errno and progress.
The host must not re-enter Debug while that synchronous scratch range is owned.

Unsigned subtraction computes negative magnitudes without signed overflow,
including I64 minimum. I8/I16 and U8/U16 normalize their declared widths before
widening. This preserves the previous output even after an explicit unsafe cast
leaves non-canonical high bits in an i32 carrier. Zero always emits one digit.

The native backend and pinned Starshine bridge no longer contain either integer
formatting builder or any of the eight runtime dispatch entries. Self-host
runtime classification no longer accepts them. Existing `Debug` trait calls,
custom implementations, derived methods, and Swar decimal wrappers keep their
normal Dew call/evidence paths. Floating-point, text, and V128 Debug builtins
remain open for their own migration; this commit does not claim those are gone.

The shared corpus checks 21 outputs: zero, every signed minimum/maximum width,
unsigned maxima, Swar wrappers, a generic call, and four unsafe narrow casts.
It forces three-byte partial host writes. Three negative checks require one
exact host call followed by a trap for errno, zero progress, or excess progress.
Compilation errors and unexpected host calls are not accepted as those traps.

## Measured checks

- New policy checks fail before migration (14 subtest failures, 0.037 seconds).
- Original native code passes the first 20 behavior checks (compile 0.432,
  execution 0.023 seconds). The expanded 24-check corpus passes too (compile
  0.396, execution 0.021 seconds).
- New Dew code passes all 24 native checks (compile 10.301, execution 0.023
  seconds).
- The bridge removal test fails before removal in 6.999 seconds. The policy
  checks now pass, and all 11 bridge tests pass in 7.047 seconds.
- Bridge commit `cd618d5df` removes the old formatters without changing the
  public interface. Provider rebuild takes 10.747 seconds; consumer metadata
  regeneration after that commit takes 4.125 seconds.
- All 24 integer Debug checks pass in the self-host compiler in 1.268 seconds.
- Full self-host hardening passes 325 tests, 75 exact records, and all shared
  corpora in 77.939 seconds; this remains a speed bug.
- The first native lane stops on two stale preamble-count expectations in
  92.895 seconds. The lane-type test now checks every exact parameter/result
  primitive and distinct ID instead of counting library declarations. The
  manifest test compares with the empty-file preamble's semantic-ID count;
  that count includes more entries than the top-level declaration arena (an
  initial arena-length comparison failed in 8.621 seconds).
  All five tests in the two files now pass in 9.407 seconds.
- The full native rerun passes all 1,024 tests in 139.629 seconds. Semantic tests
  take 83.572 seconds; slow lanes remain speed bugs, not hidden failures.
- The first integration run finds two more fixed preamble-count expectations
  (56.588 seconds). Those tests now compare the complete collected declaration
  prefix with the empty-source preamble and verify optional-source exclusion,
  including the missing optional builder API, rather than a helper count.
- The library suite passes 326 tests and all shared corpora, including 24 integer
  Debug checks, in 27.733 seconds.
- The integration rerun passes all 268 tests in 65.903 seconds, including all 24
  preamble cases. This remains a speed bug.
- Generated-source checks pass in 17.494 seconds.
- Clean bootstrap passes in 165.082 seconds. A build takes 39.765 seconds;
  A/B execution takes 44.253/56.780 seconds. These remain speed bugs. B/C core
  and linked bytes match. Linked SHA-256:
  `77700100458ad01e36df52e9b9f28104185d9117eba016308168f2df86bd2f96`.
  No speed work is included.
  Remaining verification is in progress; no speed work is included.
