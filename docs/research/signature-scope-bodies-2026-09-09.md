# Required signature scope bodies

Every linked defined function, lambda, and initializer must have a source body
when callback signatures are collected. The function and lambda paths previously
treated missing bodies like imports and omitted their scopes. The initializer
path trapped through an anonymous assertion.

All three paths now report BOD-610 with phase 7, the module, declaration, source
body when present in the link, and a missing-value record. For a missing lambda,
the root body is genuinely unavailable: its field stays at the U64 missing
sentinel, while the declaration comes from the fragment and detail retains the
lambda ID. This avoids fabricating source ownership.

Each negative test first checks a valid link and the full scope count, then
clears one source body arena. Host probes check all nine failure fields. The
first run exposed a syntax error in the test's inline conditional (38.464 seconds);
after correcting the test, the baseline passed 827 tests and failed the two
missing-trap cases in 95.715 seconds. The fix passes 829 tests, 420 exact records,
and all shared runtime checks in 95.462 seconds.

The preceding callback-target commit passed clean bootstrap. This small follow-up
has not yet had a separate clean bootstrap; the next emitter batch must include
it. Runs above 30 seconds remain timing defects, not a reason to weaken checks.
