# Callback results must not use names

Two old self-host shape helpers still recover callback result information from
source spelling. One treats several retired builder names as Unit. Another
looks up the first global callable with the callback expression's source name.
A local callback parameter can hide a global function with a different result
type, so neither lookup is evidence about that call.

New positive source tests require an actual indirect callback with inferred
I64 result. One names its parameter `string_builder_append`. The other names
it `misleading` and also exports an unrelated Unit-returning global with that
name. They check result presence and the backend's selected result shape.

The first test build fails parsing in 42.249 seconds because `is` cannot start
that continued expression line. A local result binding fixes the fixture;
the corrected baseline finishes in 86.702 seconds: 888 tests pass and the
builder-name result-presence case fails. The helper returns false for the
proven I64 callback. The same-named Unit-global shape case passes on the old
code; it is positive coverage, not an independently reproduced failure.

Both name recovery paths are now removed, along with the unused global
callable-by-name search. A checked helper reads the call expression's inferred
type and the selected caller's type arguments. The shared type work queue
handles nested substitution. Owner spans, expression membership, request
indices, and request declarations are checked before use. This is an inference
input, not a frozen physical certificate; the existing target-signature and
full call ABI checks still apply.

Missing type evidence remains Error in shape inference. A later request for
the boolean stack-result property requires concrete evidence and reports
SPC-301 with the call context instead of treating Error as a value. A source
flow that cannot fall through has no result. A one-field type mutation checks
both the preserved Error and the complete numeric record at consumption.

The first implementation run passes 889 tests and 465 exact records, but the
shared callback source fails parsing in a full 86.141-second lane. Its draft
used `1f32`; the corrected literal is `1.0f32`. The expanded shared corpus
builds natively in 1.835 seconds and passes all 288 callback checks. It includes
a same-named F32 global and a builder-named callback in both branch paths,
tested across six I64 values including signed limits.

The next run passes 890 tests, 466 exact records, and all 288 shared callback
checks in 87.437 seconds, but the missing-type preservation test fails. The
backend shape helper returned its cached source shape before reaching the new
callback path. Callback inference now runs before that source-shape shortcut.
The boolean-consumption negative test already reports the exact SPC-301 record.
The corrected ordering passes the full hardening run in 91.396 seconds:
891 tests, 466 exact records, 288 shared callback checks, and all remaining
shared emission/library and semantic probes. Clean bootstrap passes in 192.453
seconds, including the preceding program-owner changes. Compiler B/C core and
linked bytes match. Their raw and linked SHA-256 is
`bff14e9f8e34af0a910e01d2a422d57448a19e35dc2895deae8f37524fcca3ad`.
Generated-source, policy, metadata, and associated CLI checks pass in 5.408
seconds. The pinned provider and FFI bindings are unchanged.
Other name-based method/shape recovery paths are still separate open work.
Runs over 30 seconds remain timing defects; speed work is deferred.
