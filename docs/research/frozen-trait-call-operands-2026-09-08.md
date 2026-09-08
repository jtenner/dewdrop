# Frozen trait call operands

A valid public generic relay forwards two runtime trait dictionaries to a
private generic callee. They occupy distinct caller parameter slots 2 and 3.
Changing the first operand to slot 3 leaves both indices valid but selects the
wrong dictionary. The old getter accepted the changed recipe (one failed
exact-record test, 9.147 seconds).

Each retained physical call target now owns a copy of its ordered runtime
evidence operands. The copy is independent of the mutable source arena.
Witness creation validates the span and rejects negative indices before
publication. A replay with a different count or operand produces SPC-303 and
preserves the original witness.

The shared runtime-evidence getter checks the selected target, source span,
operand count, and every operand against the saved recipe. Missing or extra
operands produce ABI-703; a changed operand produces ABI-704. A recipe without
a target produces SPC-304; invalid spans produce ARN-101 before reads. The
link boundary verifies all recipes and rejects orphan entries. The direct
emitter repeats the check and returns a phase-7 numeric diagnostic. Other
consumers of the shared getter retain phase-5 diagnostics.

All diagnostics have nine numeric fields. Operand errors identify the ordinal
in detail; malformed spans pack start and length in actual. The public checked
getter returns a structured failure, so emission does not need to trap or
parse a formatted string. The legacy Option getter still records its complete
failure in the abort message.

The first fixed regression passes in 9.259 seconds; six expanded semantic
tests pass in 9.628 seconds. They cover independent storage, changed valid
indices, missing/short operands, bad spans, negative indices, exact target
replay, and orphan recipes. Final focused tests also cover rejected witness
publication. Seven final semantic tests pass in 9.909 seconds. The emitter
test passes in 8.541 seconds and checks the full phase-7 record. Scoped
interface generation passes in 3.746 seconds. Full native tests pass (1,137
tests, 154.915 seconds), integration passes (268 tests, 57.127 seconds), and
the Dew library passes (326 tests and all shared runtime cases, 32.875 seconds).
Self-host passes 450 tests, 137 exact failure records, and all shared runtime
and semantic probes in 146.145 seconds. Clean bootstrap passes in 169.058
seconds; B/C core and linked bytes match:
`577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
Generated source and policy checks pass in 12.721 seconds; all 15 stress tests
pass in 0.341 seconds. Provider and FFI
files are unchanged. Runs above 30 seconds remain speed bugs.

This proves recipe preservation, not complete ABI assignability. Caller-local
bounds and complete dictionary heap/nullability types, function-reference
closures, and escaping runtime lambda dictionary capture remain separate work.
No speed work is included.
