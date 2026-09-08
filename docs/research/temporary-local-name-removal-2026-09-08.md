# Remove name-based collection temporary locals

## Reproduction

An ordinary function named `self_host_array_pop` caused the self-host emitter to
reserve eleven collection-runtime temporary locals in its caller. A same-length
rename to `plain_user_identity` removed them, despite identical signatures and
bodies. The frozen body plan correctly contained no expression temporaries.

A source-level test checks that ordinary direct calls require no such locals.
A Wasm execution test compiles both names, runs both `main` functions (42), and
compares the complete code sections. Debug custom sections are excluded because
the source names intentionally differ. Both tests fail on the old compiler;
the remaining 551 tests and 202 numeric records pass (84.856 seconds).

## Change

Remove the obsolete collection-local branches from local allocation, total
temporary counts, and per-expression temporary slot calculation. These branches
used `self_host_array_pop`, unresolved `next`, or unresolved `push` spelling as
layout evidence. Delete the now-unused direct-pop predicate and eleven-local
runtime allocation helper. Source calls still use their ordinary linked Dew
bodies. Closure capture-cell bases use the same corrected temporary count.

Hardening passes 552 compiler tests, 202 exact records, the two code-comparison
cases, and all shared probes (86.579 seconds). Generated-file checks pass
(8.010 seconds). The first bootstrap stopped after the B checks without a C
result; that partial run is not counted as a passing fixed point. The restarted
clean bootstrap passes (280.357 seconds). B/C raw and linked outputs share
SHA-256 `776023093046c402731224b5cb39ace5e803f71bd5c06afd48032621ae97ede5`.
Runs over 30 seconds remain recorded speed bugs.

No native compiler, library,
generated FFI, or provider code changes in this batch. Remaining name-based type
and method recovery outside temporary allocation still needs removal. Complete
temporary types and slots still need to be frozen; this change does not claim
that larger obligation is closed. Speed work remains excluded.
