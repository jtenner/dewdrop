# Generated declarations and imports

Baseline: `63d0041170`. Transforms can now request generated helper functions,
structs, enums, aliases, implementations, and named imports. Requests use source
API methods on `TransformContext`. Their arrays are normal Dew array values;
source methods append requests using the ordinary collection implementation.

The compiler parses each declaration as exactly one item of the requested kind.
It checks output size and nesting depth before parsing. It renders imports from
validated module paths and aliases. The transformed target still has its own
single-function shape check, so a raw body fragment cannot insert declarations.
The final module passes normal import, name, type, and backend checks. Generated
source does not re-enter annotation expansion. There are no new builtins, host
calls, or runtime dispatch rules for library paths.

Requests from stacked transforms accumulate in source order. Their total bytes
are bounded while collecting output, before the final 1 MiB function-file check.
A transform error is returned before its pending declarations are inspected.
No extra output text is added when a transform emits no declaration or import.

## Checks

Logs are under `.tmp/transforms-v3/`. `declarations-red.log` records the initial
missing-method errors. `declarations-tests.log` passes four native tests for
valid imports, structs, helper functions, methods, multiple-declaration rejection,
wrong-kind rejection, and invalid import aliases. The file took 8.916 seconds.
`declarations-native-2.log` built the initial example in 3.519 seconds.
`dew-declarations.log` covers the Dew interpreter build and tests. Final checks
use `check-declarations.sh`; this runs regressions, a clean self-build, real
compiler requests, the native example, API generation, and source consistency.

Final checks passed: 21 interpreter regressions, four declaration tests, and two
structured-type tests. The Dew interpreter lane passed 12 tests. A clean
self-build passed with B/C raw and linked SHA-256
`bd2cc125184ba902a971cc00ce78a6d1167aa131ee901fca25126fa42f8e2b54`.
A source build took 17.509 seconds; A compiled B in 16.280 seconds and B compiled
C in 16.244 seconds. All 22 real requests returned 42. All 12 rejection cases
retained their expected diagnostics and wrote no output. The final native
example built in 2.150 seconds and returned 42 in 0.029 seconds. Generated-source
and API checks passed. This is functional evidence, not a speed or heap claim.
