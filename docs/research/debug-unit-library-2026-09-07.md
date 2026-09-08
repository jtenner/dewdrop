# Unit Debug migration

Unit output is now two ASCII stores and the existing checked Dew foreign-write
loop. The Unit argument still runs once before its erased value is passed to
the selected Debug implementation. There is no Bytes wrapper or opaque write
call in this implementation.

The source-policy regression fails before migration in 0.052 seconds.
The shared six-case corpus covers direct and generic Unit output, a visible
argument effect, and three invalid host results after successful compilation
and instantiation. Baseline compilation takes 0.435 seconds; all six baseline
checks pass in 0.024 seconds. New compilation takes 13.802 seconds; all six
checks pass in 0.026 seconds. Native/self-host runner wiring is included.
The self-host lane passes in 87.895 seconds: 350 tests, 99 exact failure records,
and all shared corpora. The six Unit checks take 1.604 seconds. The library lane
passes 326 tests and all shared corpora in 35.525 seconds. Generated checks pass
in 22.034 seconds. Broad compiler checks remain at the preceding
physical-local-identity checkpoint; this batch changes library code only.

Bool and test assertions still use the old write transport. No speed work
is included.
