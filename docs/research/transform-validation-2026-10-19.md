# Source transform validation checkpoint

The Native and Dew implementations include checked generic frames, applied
annotation root selection, generic implementation method evidence, default/null
value metadata, and rejection of product casts without a checked tuple layout.
The lazy cache owner fix is also included. These checks do not complete the
unchecked larger goals in `docs/transform-features.md`.

## Compiler and public requests

The fresh self-host check passes. Compiler A is
`1b59e1d1ea6762157d2bd0da2da304d6c55eb69524a8060b48fa82eb9523f6aa`.
Compilers B and C are byte-for-byte equal, with SHA-256
`16cdca5f48a89219deb6f7ce0aa33cdb14634502bc0ef165542fe5ee7c980101`.
A source compilation took 19.924 seconds; A and B execution took 22.798 and
22.622 seconds. The complete 82.198-second rebuild exceeds the activity bound.
Raw log: `.tmp/transforms-v3/bootstrap-default-roots.log`.

All 52 public positive requests compile, validate with wasm-tools 1.262.0, and
return 42. All 18 rejection cases produce the required diagnostic. The complete
lane took 221.768 seconds; individual positive compilations took about 3 seconds.
Log: `.tmp/transforms-v3/requests-default-roots.log`.

All 13 root/runtime controls pass after the test runner was corrected for the
request export policy. Eleven original transform controls return 42. Two
separate controls export `main` calling `runtime_only` and return 129. The
request format exports `main`, so the first runner's attempt to call an extra
export was a test setup error. The corrected lane took 41.214 seconds, above
the aggregate activity bound. Log:
`.tmp/transforms-v3/fresh-dew-default-roots-fixed.log`.

## Default and product controls

All ten normal runtime controls pass with the current Native implementation.
The CLI SHA-256 is
`1381dd9bb6d90cb88ea4967e9057153badf80a7eb75d21cf19cb2c9da167d23f`.
The lane took 10.083 seconds. All five product-safety transform cases reject
with the checked tuple-layout diagnostic. The valid ordinary one-leaf tuple
cast still compiles, validates, and returns 42. This lane took 10.180 seconds.
Logs: `.tmp/transforms-v3/products-initializers-raw-runtime.log` and
`.tmp/transforms-v3/products-runtime-controls.log`.

Fresh Dew runtime controls emit nine valid programs. The nullable foreign-handle
case fails with the missing runtime `ref_is_null` opcode and is under repair.
Discarded nonunit product and record reads return 42 in Dew but trap in Native:
Dew uses boxed values and erased local carriers. These differences are recorded,
not counted as runtime parity. Actual field/destructuring boundary controls are
pending before any carrier policy change. Raw identity, samples, logs, and
output hashes: `.tmp/transforms-v3/raw-defaults-fresh-a/`.

## Source tests and limits

The combined source checks pass: 78 Native VM tests, 2 initializer-layout tests,
5 product safety cases, 4 default reference cases, and 5 frame-root cases. All
115 Dew source tests pass. Scoped API generation and all scalar/vector generator
checks also pass. The combined Native and Dew lanes took 37.007 and 36.111
seconds; both exceed the aggregate bound. These are functional checks, not a
controlled speed or heap-memory comparison.
