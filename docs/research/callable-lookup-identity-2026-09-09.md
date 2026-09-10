# Checked callable lookup

Both compilers previously trusted a non-missing callable table entry without
checking its stored declaration. The native path could index outside its
callable arena; the self-host path returned None for that corrupt entry.
A valid-looking wrong entry could return another function with the same ABI.

Lookup now distinguishes absence from corrupt evidence. A foreign-module or
unknown declaration and the exact missing sentinel still return None. Any
other selected index must be inside the callable arena (ARN-105), and its
stored declaration must equal the requested declaration (ARN-106).

The native lookup uses a checked result and prints all nine numeric failure
fields before aborting. The self-host lookup records the same context before
trapping. Neither path scans for a replacement function. Tests start with two
valid functions with the same return type, then change one table entry.
Negative native indices other than -1 are not missing sentinels.

The self-host baseline passes 876 tests and fails both new negative cases in
101.657 seconds: neither corrupt entry traps. The separate failure-record
check also rejects the missing trap. This is the observed defect, not a test
that accepts an arbitrary trap.

The first native check fails to compile in 1.201 seconds: a helper's `self`
argument selected MoonBit method syntax, and the fixture lacked its required
`raise` declaration. Both are corrected before execution.

The three focused native tests pass in 11.264 seconds. Self-host hardening
passes all 878 tests, 459 exact failure records, and all shared execution and
semantic probes in 110.542 seconds.

Routine native passes all 1,310 tests in 300.207 seconds.

- Integration: all 270 tests pass in 98.058 seconds.
- Library checks pass in 30.542 seconds.
- Generated-source and policy checks pass in 21.644 seconds.

- Stress: all 15 tests pass in 0.361 seconds.

- Clean A/B/C bootstrap passes in 205.736 seconds. Core and linked comparisons
  pass; both raw and linked B/C SHA-256 values are
  `1f74558035da8745842ba50eb9d532f57991bf22a8be1dd81c3762864018934b`.

The provider is unchanged from the preceding runtime-protocol retirement,
whose full pinned suite passed 10,981 tests. It is not rebuilt or modified by
this lookup change.
This change covers selected callable entries;
it does not claim to verify every declaration table or every program-owner
lookup. Runs over 30 seconds remain timing defects; speed work is deferred.
