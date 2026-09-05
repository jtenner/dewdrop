# Discarded match results

The clean bootstrap after `59c6be5` stopped while compiler A emitted compiler B:
`self_host_emit_linked_i32_expression`, subject 156320, arm expression 156321,
expected Unit, actual I32. A three-line discarded scalar match reproduced the
same failure in the source probe, without rebuilding the full compiler.

The match task previously used one result shape for two different contracts:
the logical arm result and the emitted control block result. Discarding a match
sets the latter to Unit, but does not change the former. The task now carries
both. Arm and binding-payload checks still compare the logical result. The Wasm
control block uses the emitted result.

Discard scheduling now owns non-control drops in one place. Control expressions
discard their children; scalar expressions, calls, and references each receive
one drop if their frozen plan produces a value. The block scheduler no longer
adds a second drop. This also covers direct scalar match arms and discarded
conditional alternatives, which do not pass through a block item scheduler.

The hardening lane passes 127 tests, 25 numeric failure records, 162 focused
execution checks, and all 66 shared callback checks. New source cases cover a
discarded scalar match, one observable arm effect, an unused match binding, a
discarded conditional, and a mutable tuple binding captured by a closure.
The previous lane failed on the scalar match with the same Unit/I32 error as
the bootstrap. A fresh clean bootstrap is being checked separately.
