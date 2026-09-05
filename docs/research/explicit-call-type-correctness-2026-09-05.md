# Explicit generic calls through self-host specialization

The packed `Into` execution probe exposed three correctness defects:

1. Collection and type resolution retained explicit call types, but call inference
   ignored them. This could leave two same-carrier `Into` targets ambiguous.
2. Signature evidence bound a generic parameter to `Never` even after argument
   assignability correctly treated a diverging argument as producing no value.
3. Callable specialization used the owner's generic span OR the method's span.
   A method with both lost its method parameters and could keep an erased
   reference signature instead of its selected scalar signature.

Call inference now applies explicit types during local/imported candidate trials
and selection, including receiver methods and declared-bound method signatures.
Trials remain transactional. Wrong direct-call type counts have a dedicated
`CallTypeArgumentCountMismatch` diagnostic. Explicit types cannot override
contradictory argument or result evidence. Diverging arguments supply no generic
signature evidence.

Specialization now models the ordered concatenation of owner and method spans.
It does not assume the spans are adjacent. Shape and trait-evidence lookup use
the same slot mapping, including the parameter's module identity. Fragment and
body planning use this mapping too.

Regression coverage includes local/imported calls, bad arity, contradictory
types, method parameters after a separate generic method, disjoint spans,
foreign-module IDs, and span boundaries. The executable packed probe declares a
wrong same-carrier target first (returns 99); the selected target must return 42.
The existing diverging-argument probe remains in the suite.

All 103 hardening tests, 16 invariant-record checks, and 18 emitted execution
probes pass. Cached generation took 2.661 s, linking 5.042 s, and tests 0.317 s.
The initial release test-tool rebuild took 91.419 s, a recorded performance bug.
Log: `/tmp/dewdrop-into-hardening-final2.log`.

The routine native suite passes 768 tests and the complete native integration
suite passes 266 tests. Logs: `/tmp/dewdrop-into-native-all.log` and
`/tmp/dewdrop-into-integration.log`. Clean bootstrap verification is recorded with
the packed conversion migration.
