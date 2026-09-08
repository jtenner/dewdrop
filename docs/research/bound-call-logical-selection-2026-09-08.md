# Bound calls require logical implementation selection

The new derived Debug execution corpus found nine missing bound targets when a
generic Debug implementation was present. The old physical-only selector stops
at any generic competitor, even an unrelated one. Applied receiver identities
also became unknown outside explicit compile-time-query callers.

Mark every body with a bound trait call for logical specialization, including
its nested lambda expressions. The existing caller worklist carries that demand
to its callers. Selected private bodies use the shared trait witness search,
which checks applicability, prerequisites, and exact requirement identity and
retains implementation type arguments. No declaration name or physical carrier
selects the implementation. This also works in programs with no query builtin.

The first shared derive run reports twelve body errors in total. Logical
selection removes all nine missing-target errors; the three remaining errors
belong to Unit payload storage. That run takes 54.846 seconds. A small no-query
trait fixture checks both primitive and generic implementation bodies. Its
first test version used an elided field that does not exist on linked function
records; compilation rejects it in 14.302 seconds, and the test is corrected.
The combined hardening lane now passes 365 tests, 108 exact failure records,
and all shared execution corpora, including nine derived Debug checks, in
57.726 seconds. The focused test lives in the existing physical-specialization
test file and needs no new runner registration. Full-lane checks are still
running with the separate derive and Unit fixes. No speed work is included.
