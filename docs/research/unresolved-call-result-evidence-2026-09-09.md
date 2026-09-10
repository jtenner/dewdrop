# Unresolved call results use type evidence

The self-host result-presence helper treated unresolved methods named `clear`,
`push`, and `set_unchecked` as Unit. Its shape helper also recovered results by
method name and supplied I32 for some `get_unchecked` calls without a nominal
owner. Neither rule proves the result of the selected call.

Five tests start with a valid I64-returning Reader method. They restore the
equivalent unresolved call form from the retained callee syntax. Lowering keeps
the callee ID in the second DirectCall field; that field is not the receiver.
The retained member base supplies the receiver when restoring the syntax.

The first baseline fixture did not restore the consumed callee and failed its
setup check: 896 passed, three failed, 86.678 seconds. The corrected baseline
reproduced all three name-dependent Unit errors: 896 passed, three failed,
86.992 seconds. The failures checked the known I64 result, not an arbitrary trap.

Both result helpers now use the expression's inferred type and the selected
caller's generic arguments before cached shape shortcuts. The shared helper
is renamed to `self_host_linked_inferred_call_result_shape`. Missing type
evidence stays Error; asking for boolean result presence then reports SPC-301
with the exact call context. Two one-field mutations cover those boundaries.
Flow that cannot fall through still produces no result. These are inference
inputs; the separate exact-target and full call ABI checks remain required.

The full hardening lane passes 901 tests, 470 exact numeric records, all 318
shared callback checks, and the other emission/library and semantic probes in
87.413 seconds. Generated-source and policy checks pass in 5.009 seconds.
Runs above 30 seconds remain timing defects; speed work is deferred.

Clean bootstrap passes in 171.636 seconds. Compiler B/C core and linked bytes
match, with raw and linked SHA-256
`c588090e71f4bca9e7f3a19be06ed544f83dd8fe0099f85c0d38d193502d0222`.

Other receiver/name recovery helpers remain open work. This change does not
claim to remove every method-name selector. The provider and FFI are unchanged.
