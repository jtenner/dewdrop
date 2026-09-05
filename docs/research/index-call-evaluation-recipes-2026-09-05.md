# Frozen index call recipes

The expanded real-library test exposed three gaps:

1. Candidate probes used type equality, rejecting Never even though selected
   index calls already allowed it as an assignment.
2. Self-host call recipes omitted index keys and stored values. Index writes had
   no seeded physical target. Result-only verification missed this.
3. Index emission bypassed erased Unit calls and left reference storage markers
   on the stack. Native generic index calls tried to use non-returning operands.

Both compilers now use assignment compatibility when probing index keys and
stored values. Never does not supply evidence for a generic parameter. Self-host
local and imported probes use the same rule.

The self-host planner seeds exact index-write targets and records receiver,
key, and value evaluations in source order. Only stack values enter the operand
recipe. A non-returning receiver or argument stops the schedule and suppresses
the call. Both index reads and writes now undergo operand verification.

A shared frozen-call scheduler checks the selected target and runs the saved
schedule once. Erased index reads/writes use it instead of raw array shortcuts.
Native direct and tail calls retain only the argument instruction prefix through
the first non-returning argument and emit no call instruction.

The shared real-library oracle has 12 checks, including Unit index reads/writes
with side effects and non-returning indices on both Array and a user-defined
generic type. A reduced native test covers non-returning keys and stored values.
The imported trait arena bug found by this source was committed separately.

Validation before clean bootstrap:

- 794 native tests: 63.756 seconds (`/tmp/dewdrop-array-index-native.log`).
- 319 library tests and all execution matrices, including 12 array/index checks:
  13.868 seconds (`/tmp/dewdrop-array-index-native-runtime.log`).
- 161 self-host tests, 27 exact invariant records, and all execution probes:
  18.374 seconds (`/tmp/dewdrop-array-index-target-hardening.log`).
- 266 integration tests: 44.952 seconds
  (`/tmp/dewdrop-array-index-integration.log`).
- Generated sources and policy: 18.487 seconds
  (`/tmp/dewdrop-array-index-generated.log`).

The native backend test lane took 32.918 seconds. Cold native generator rebuilds
took over 100 seconds. These remain visible performance bugs.

Clean bootstrap passed in 190.338 seconds. B and C, both raw and linked, have
SHA-256 `670d74b546b05a262412fbe6092dce682e157ae92b8f86f67a942b4a0e782db4`.
Log: `/tmp/dewdrop-array-index-clean-bootstrap.log`. A build and A/B execution
still exceed 30 seconds.
