# Bool Debug migration

Bool output is now ordinary Dew branching and ASCII stores, followed by the
checked foreign-write loop. Its direct and generic forms retain `true`/`false`
output. The shared corpus also checks one visible argument effect, partial
host writes, and invalid responses at both the first and final host call.

The source-policy test fails before migration in 0.046 seconds. Baseline
compilation takes 0.437 seconds; all 11 baseline checks pass in 0.037 seconds.
New native compilation takes 13.268 seconds; all 11 checks pass in 0.027 seconds.
Native/self-host wiring is included. The self-host lane passes 350 tests,
99 exact records, and every shared corpus in 103.591 seconds. Its 11 Bool
checks take 1.954 seconds. The library lane passes 326 tests and all shared
corpora in 34.683 seconds. Generated checks pass in 23.152 seconds. Broad
compiler checks remain at the physical-local-identity checkpoint until the
next compiler batch. Runs above 30 seconds remain recorded speed defects.

No primitive Debug implementation now calls the old Bytes write builtin.
The unused-looking declaration is still needed by the compiler's test-assertion
dependency builder, so removal belongs with that runtime migration. String and
Bytes formatting also remain separate work. No speed work is included.
