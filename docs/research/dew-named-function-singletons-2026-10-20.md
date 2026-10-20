# Named function identity in ordinary Dew output

Baseline: `8527472a4d`. Scope: the Dew emitter only. The Native emitter and
compile-time engines already keep one identity for each exact named target.

## Fault and fix

The Dew emitter used `ref.func; struct.new` on every named-function read. Two
reads of the same named function were different objects under `ref.eq`.

The emitter now scans frozen body plans and records each referenced physical
function target once. That target already contains the checked declaration,
specialization, witness selection, and callable ABI. The table does not derive
identity from names, standard module paths, or scalar carrier shapes.

Each entry owns one nullable eqref global, after the source globals. The Wasm
start function fills these globals before it calls source initializers. Named
reads use `global.get`. Captured lambda construction is unchanged. Startup also
exists when these entries are the only reason for startup. Missing entries or
invalid exact targets return visible compiler errors.

## Checks

The fresh baseline compiler and fixed compiler both built from the current JS
CLI, then linked with the pinned Starshine FFI, facet adapter, and time provider.
All compiler commands used `self_host_measure`. No measured activity exceeded
30 seconds. No B/C bootstrap was run in this bounded change.

Seven controls returned 0 before the fix and 42 after it: all four existing
`tools/dew-test/generic-identity/*.dew` files, plain named-function reads with no
source initializer, source startup identity/count, and a cross-module returned
reference. The final startup fixture uses a typed local callback for invocation;
a direct call through the source global callback is outside this fix's source
support. The first draft of that fixture did not compile and is not red evidence.

Four controls pass before and after: a program with no named references, fresh
captured values, explicit receiver-capturing method wrappers, and the public
signature transform example. Each output validates, has no imports, instantiates
once, runs its optional exported initializer at most once, and returns 42 from
two calls to main. Direct bare bound-method values are not claimed by this fix.

Four plan tests pass in
`self_host/compiler/semantic_function_reference_singletons_test.dew`. They cover
canonical I32/U32 sharing versus I8 separation, source/global slot separation,
exact owner metadata, exclusion of captures, and missing/invalid target errors.

The five current Native bound callback tests also pass through the routine
`tools/test-native.sh` lane. The two skipped escaping bounded-reference tests
pass through `tools/test-integration-native.sh --filter '*escaping bounded*'`.
The initial routine filter selected zero tests; those runs are not pass evidence.

Re-run ordinary Dew controls with a freshly built compiler:

```sh
tools/test-named-function-identity.sh PATH_TO_COMPILER_WASM
```

## Cost and evidence

The no-reference output is byte-identical at 687 bytes, with zero globals and
zero start functions. Both capture controls are also byte-identical before and
after. The plain identity output grows from 1013 to 1056 bytes. Its two allocation
sites become two global reads and one startup allocation, with one global and
one start function. The startup control has one start function in both builds;
its cache fill precedes both source initializer calls.

One source-build sample takes 18.245 seconds before and 17.976 seconds after.
Peak source-build RSS is 1,248,844 and 1,260,452 KiB. Linked compiler size grows
from 2,879,085 to 2,881,017 bytes. These single samples do not establish a compiler
speed or memory improvement. Small ordinary request samples are about 1.2–1.4
seconds, with the signature example about 3 seconds. Runtime allocation removal
is established by the emitted instructions, not by a heap-profiler estimate.

Private evidence is under `.tmp/transforms-v5/dew-singletons/`: separate
`before/` and `after/` compiler cores and linked compilers, source and compiler
SHA256 files, command/resource JSON, request bytes, output modules, runtime logs,
and selected WAT files. `before-after.json` contains each program hash, byte
count, raw timing/RSS sample, and selected instruction counts. `build-a.sh`,
`measure.py`, and `test-plan.sh` retain the exact build and test commands.

Linked baseline compiler SHA256:
`a9e41a71c569ce5678ddffd34104e6eee4501f1ac5c6b6f73279cfd446813b1f`.
Linked fixed compiler SHA256:
`f0f5477fd4c53402d162fc4387bb1e54433893a7510f8100bcc73beb17a51f93`.

Claude review was unavailable due to the known weekly quota. It was not retried.
