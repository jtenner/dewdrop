# Checked specialized-call consumers

The direct emitter already checked retained target witnesses, but the shared
`specialized_call_function` getter still trusted its table index. Changing a
valid map entry to another query instance of the same declaration reproduced
a wrong selection through that getter. The unchanged getter, extracted into a
checked-result helper, failed the exact-record regression in 9.139 seconds.

The shared getter now checks the witness too. It checks table bounds before
reads and compares declaration, structural instance key, physical function
index, and table index. An indexed call without its witness, or a witness
without its indexed call, produces SPC-304. Invalid bounds produce ARN-101;
target disagreement produces ABI-701. All nine numeric fields are retained,
with phase 5 and caller module/body/expression context. A missing witness has
no trusted target declaration, so that record uses declaration zero.

Both lookup maps are checked before a clean link plan is returned. Each later
shared getter read repeats the check. The direct emitter retains its separate
phase-7 check. An absent probe that is not a recorded call still returns None;
this map-consistency check is not a proof that every source expression has a
call recipe. Missing emitted generic calls remain diagnosed by the emitter.

Six focused tests cover valid and absent probes, mismatched key sets, bad
indices, same-carrier instance substitution, wrong declarations, and changed
saved indices. Negative cases start from a valid link, change one field, and
check the complete record. Bounds/key/index cases also check the link-boundary
verifier. The first expanded run passes in 11.918 seconds; the final focused
run passes in 11.719 seconds. Full native tests pass (1,129 tests, 160.908
seconds), integration passes (268 tests, 56.926 seconds), and the Dew library
passes (326 tests and shared runtime cases, 32.987 seconds). Self-host passes
450 tests, 137 exact failure records, and all runtime/semantic probes in
145.776 seconds. Clean bootstrap passes in 169.156 seconds; B/C core and
linked bytes match:
`577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
Generated-source and policy checks pass in 13.011 seconds; all 15 stress tests
pass in 0.340 seconds.
No speed work is included; runs above 30 seconds remain speed bugs. Provider
and FFI files are unchanged.

Hidden evidence operands still need their own frozen recipe and checks. Other
raw table reads and singleton/function-reference selection remain separate
audit work; this change covers consumers of the shared specialized-call API.
