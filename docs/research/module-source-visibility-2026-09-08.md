# Source visibility is independent of module spelling

A module containing public `Visible`/`shown` and private `Hidden`/`hidden`
was frozen under several paths. Changing only its path to `dew.std.custom`
published all four names. The focused native regression failed in 9.087
seconds with the exact extra names. Ordinary modules and the four hard-coded
text facade exceptions had different publication rules.

Both interface builders now publish declarations from their source `pub`
markers. The native callable interface also reads source visibility instead
of physical-root metadata. An intermediate run exposed that distinction:
type-query builtins disappeared from imports when the interface reused the
planner's withheld-root visibility. The cached-interface test now reports the
actual error instead of trapping inside `unwrap`; source-based callable
publication restores the type-query imports. The focused query and visibility
tests then pass (3 tests, 10.133 seconds).

The library now spells out 1,459 previously implicit public declarations in
49 source files. This is an API declaration migration, not a change to their
runtime algorithms. Existing private helpers in the four text facade modules
stay private; their extra String/FixedArray source file stays unchanged too.
The lane generator emits explicit public functions and instruction declarations.
The other affected source providers are regenerated from their Dew files.
Builtin policy checks still count and validate every declaration with or
without `pub`; their required counts and instruction contracts are unchanged.

New tests cover public/private types and functions under ordinary paths,
`dew.std.custom`, an old exact exception, and a path below that exception.
Native callable tests also cover both sides of the reserved module-ID boundary
and the largest 32-bit module ID. Self-host interface tests use the same
source visibility cases. The existing public-let inference tests now use a
path-free predicate.

This removes interface publication special cases, not all module selection,
implicit dependency, physical-root, or optimizer policies. In particular,
`compiler_owned` root/optimizer filtering remains a separate migration; it
must not be interpreted as source privacy. Provider and FFI files are unchanged.

The first hardening run exposed one old fixture that declared its imported
preamble function privately. That fixture now uses `pub`. The interface test
file was also absent from the hardening runner; the runner now includes all
12 tests in that file, not just the new case.

Validation: native 1,148 tests (164.412 seconds), integration 268 tests
(65.771 seconds), the expanded visibility pair (0.084 seconds), library 326
tests plus all shared runtime cases (40.568 seconds), self-host 462 tests and
137 numeric trap records plus all probes (56.650 seconds), and generated
checks (12.964 seconds). The clean bootstrap passes in 172.770 seconds;
B and C both have SHA-256
`b68c33fb33cb7e1a37b456275f12c8b78c298b063c978254977bed97967f1371`.
Runs above 30 seconds remain speed bugs. No speed work is included.
