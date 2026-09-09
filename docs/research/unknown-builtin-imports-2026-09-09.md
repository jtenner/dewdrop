# Builtins do not create host imports

Native fragment planning now keeps every non-query builtin on its instruction
path. Unknown names reach the existing `UnsupportedBuiltin` error unchanged;
they do not produce `dew` or WASI host imports. The self-host planner already
uses this rule. Both planners have regression coverage for arbitrary names
and names with the old `wasi_snapshot_preview1.` prefix. Native emission also
checks a returned builtin function, not just a direct call.

Three old native import fixtures now use explicit foreign declarations. They
still check import indices, signatures, and deterministic fragment merging.

The positive foreign-call regression exposed a second defect: scalar-only host
calls exported memory 0 without planning any memory. Reachable foreign host
imports now set the fragment's memory requirement. This preserves the existing
host pointer-interface contract and makes the export refer to real memory.
Static provider imports do not acquire this requirement.

The first test draft had invalid test syntax and single-line Dew bodies; those
were corrected before the behavior baseline. The behavior baseline failed both
tests in 9.392 seconds: an unknown builtin emitted a module, and the explicit
foreign module failed validation with an invalid memory export. Both now pass
in 10.553 seconds. Fragment planning passes 13 tests in 9.650 seconds; backend
fragment sections pass five tests in 0.029 seconds.

Self-host hardening passes 874 tests, 457 exact invariant records, and all
shared execution probes in 99.190 seconds. The full routine native lane passes
all 1,291 tests in 280.656 seconds. Integration passes all 270 tests in 98.140
seconds. Generated checks pass in 20.778 seconds.
Runs over 30 seconds remain timing defects; speed work is deferred.

Unknown unused declarations
are not diagnosed eagerly by this change: rejection is at reachable emission.
The retired runtime function kind and provider bridge still need removal.
