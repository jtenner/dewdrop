# Program callable owner checks

The checked local callable table is not enough when its enclosing program
owner lookup is corrupt. `self_host_program_specialization_program_callable`
currently returns None when the selected owner index is outside the lowered
module arena. If the index names the wrong stored module, the local lookup
also returns None because it correctly rejects a foreign declaration.

Those are not ordinary missing declarations. The program wrapper must check
the selected module index before reading it (ARN-101), then compare the
stored module ID with the declaration's decoded owner (ARN-106). A lookup
with no owner entry still returns None. No scan or replacement target is
permitted after a corrupt owner was selected.

Tests begin with a valid one-module program and verify its exact callable.
One test adds an owner entry beyond the module arena. Another changes only
the selected owner ID. Both require all nine numeric failure fields; an
anonymous or unrelated trap is not accepted. An unknown-owner positive case
keeps the absence behavior explicit.

The baseline finishes in 101.515 seconds with 885 passing tests; both new negative cases fail:
neither corrupt owner traps. The exact-record harness independently rejects
the missing exception. All other shared probes pass. The wrapper now checks
the selected owner before it calls the checked local lookup. The corrected
full hardening run passes in 93.403 seconds: 887 tests, 465 exact records,
276 shared generic callback checks, and all other shared emission/library
and semantic probes. This change does not alter provider bindings. The clean
bootstrap result for the preceding nested-call fix is not a new bootstrap
check of this subsequent owner guard. Runs over 30 seconds remain timing
defects; speed work is deferred.

This is the self-host program
callable boundary; it is not a claim that all program module tables or the
native program index have been fully checked.
