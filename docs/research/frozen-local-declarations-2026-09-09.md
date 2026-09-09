# Frozen local declarations

Local allocation now requires the saved body plan before doing any work.
It checks the source span, all three parallel local tables, matching carrier
records, slot order, parameter placement, caller specialization, and the
physical local count. Each emitted declaration comes directly from its
physical carrier. FuncRef remains FuncRef rather than becoming EqRef.

The former shape-to-local helper always returned success and mapped missing
or erroneous shapes to EqRef. Unit and Never could also become dummy I32
slots. That helper and the old local-recovery body are removed, along with
13 helpers used only by that recovery path. The removal includes name-based
Map payload and constructor/pattern recovery. Other planning shape selectors
remain separate work.

Five initial negative tests all exposed their intended defect: missing,
conflicting, or changed carrier evidence and truncated value/slot tables did
not trap (60.675 seconds). The first replacement had a shift-operand type
error and invalid single-line block syntax; generation rejected it in 14.491
seconds. Those syntax errors were corrected.

The stricter reader then found two real source cases with an unresolved local
slot after a non-returning initializer. Planning now checks the initializer's
exact body membership and flow record when seeding the local. A binding that
cannot receive a value retains Never flow and has no physical slot. This is
not a late emitter repair. Both raw-array early-return cases and all nine
constructor evaluation cases pass with that fix.

Tests mutate one carrier, slot, count, or table entry and compare all nine
numeric error fields. A focused positive test checks the non-returning
initializer's carrier, missing slot, and zero physical-local count. Existing
callback, capture, scalar, vector, Unit, product, and collection tests cover
normal allocation. Policy checks prevent restoring the removed recovery.

Full heap/nullability proofs and the complete instruction shadow stack are
still open. This change does not claim that all remaining source-shape
selectors have been removed. All compiler lanes are timed; durations above
30 seconds remain timing bugs, with speed work deferred.

Final validation passed: 758 hardening tests, 370 complete numeric records,
and all shared source checks in 59.111 seconds. The native stdlib lane passed
in 26.609 seconds; generated/policy checks passed in 4.078 seconds. Clean
bootstrap, including the preceding tuple-call change, passed in 170.262
seconds. Compiler B/C raw and linked SHA-256 values match:
`35a0f0bd124f49cb79d717ff914c2a469df875a42cf6294ef132f45b1f546c1a`.
