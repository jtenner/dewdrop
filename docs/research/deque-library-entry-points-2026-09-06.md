# Deque library entry points

All 15 deque entry points now have ordinary Dew bodies that call the
circular-buffer library. The compiler has no deque operation or method ordinal
table. Constructors request growable storage. Push traps on rejection rather
than silently discarding a value supplied through a bounded-buffer alias.

Three new execution tests cover both ends through wrap and growth, clear through
an alias, retained capacity, empty results, and front-to-back iteration.
The semantic test checks resolved type diagnostics as well as inference and
lowering. Source policy checks first failed with the old builtins present.

The shared ring storage is still compiler-owned at this commit. The failing
generic ring execution exposed by Queue also applies here and is not skipped.
The next circular-buffer commit must replace that storage and pass both suites.

The two source-policy tests pass (0.042 seconds). The focused native deque lane
passes (33.421 seconds); its run time remains a performance bug. API files are
regenerated. Full runtime success is not claimed at this intermediate commit.

Follow-up: the [Dew ring storage migration](circular-buffer-library-storage-2026-09-06.md)
removes that generic emitter path. Deque now passes full native stdlib execution
and the shared native/self-host ring corpus, including product values.
