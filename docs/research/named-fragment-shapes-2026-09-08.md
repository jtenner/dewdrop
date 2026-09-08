# Named function fragment evidence

Previously, `self_host_wasmgc_append_function` lacked the concrete-shape guard
used by lambda signatures. The low-level `self_host_wasmgc_value_type` maps unhandled shapes,
including Generic and Error, to nullable eqref. `append_shape` directly treats
products as references without checking their leaves. These are still distinct
from the corrected specialization canonicalizer, which preserves Generic/Error.

Tests in `semantic_named_fragment_shapes_test.dew` replace only a valid
named parameter's shape with Generic, Error, or a product containing Error.
All three tests fail on the old builder because no trap occurs (430 pass,
three fail; 54.995 seconds). The new boundary reports SPC-301, phase 4, with
the source module, callable declaration/body, and parameter ordinal. Results
use ordinal `4294967295`. Generic/Error reason codes are 1 and 2, matching the
existing specialization-shape checker. Nested product leaves are checked too.

The builder now distinguishes non-emitted generic templates from actual
physical signatures. An unreachable or generic base fragment is elided by
`append_function`; it retains its logical signature but publishes no physical
signature values. Lambda materialization already checks live physical shapes. Keep
declared generic field boxing separate: an explicit erased field certificate is
not permission to accept missing function ABI evidence.

Receiver identity is preserved. Current code intentionally retains the receiver's
source shape instead of replacing an owner reference with a type argument.
Any generic receiver change needs a declared-type proof, not positional shape
guessing. Include named results, nested products, imports/builtins, elided bases,
and normal nominal/generic method receivers in the eventual tests.

The first guarded run catches 13 existing trait tests (54.514 seconds): these
are signature-only trait declarations with no emitted function, not concrete
physical signatures. They now retain logical metadata without publishing
physical values, as do compile-time-only declarations. This is an explicit
function-kind rule, not a source-name exception. The new guard's three exact
records already pass in that run (127 total).

Expanded tests cover concrete parameters/results, Generic/Error results,
product leaves, elided generic bases alongside exact I64 instances, and a bad
parameter span. All 438 tests, 131 exact records, and shared execution corpora
pass (54.744 seconds). A further positive test checks that a trait requirement
keeps its logical receiver while publishing no physical signature. The final
hardening run passes all 439 tests, 131 records, and every execution corpus
(54.866 seconds). The first clean bootstrap catches a verifier mismatch for the
unused preamble intrinsic `i8_load` (53.257 seconds): the result verifier compared
an elided fragment's now-empty physical signature with its logical return type.
It now checks retained physical functions only, including runtime intrinsics.
There is no intrinsic-name exemption. A regression passes explicit unreachable
inputs through the real fragment builder and verifies both the omitted signatures
and continued rejection of a retained function's corrupt result. The fixture's
root module retains all declarations, so simply declaring unused functions did
not exercise this input. The initial fixture also referenced a helper outside
the hardening lane; both fixture mistakes were fixed. Final hardening passes
440 tests, 131 exact records, and all execution corpora (55.005 seconds).
The clean bootstrap passes in 167.730 seconds. Compiler B and C both hash to
`28e144f2f944e8b2a12ca4916eee61526731faec000226d1e2ae4a565bc28de5`.
Generated checks pass in 4.065 seconds. Runs above 30 seconds remain recorded
speed bugs; this batch makes no performance changes. Native implementation and the pinned provider
are unchanged in this batch; the preceding native/integration/library lanes
passed 1,098/268/326 tests. Other storage/capture boundary
checks remain separate work; this does not claim to finish the complete audit.
