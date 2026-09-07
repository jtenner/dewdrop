# V128 Debug migration

## Contract and tests

Preserve `v128(0x...)` with 32 lowercase hexadecimal digits, high lane first.
The shared corpus checks zero, all bits set, each isolated lane, distinct lane
patterns in both orders, and generic Debug dispatch. The host forces three-byte
partial writes. Three invalid-host cases require exactly one host call and a
runtime trap after successful compilation and instantiation.

The source-policy regression fails before migration: seven subtest failures,
0.045 seconds. Its diagnostics name the offending file and runtime operation,
without printing complete compiler source files.

The original implementation passes all ten checks: compilation 9.730 seconds,
execution 0.023 seconds. The bridge boundary regression fails before removing
the old operation in 7.028 seconds (12 passing tests, one expected failure).

## Implementation

V128 formatting is now an ordinary Dew function. Two private builtins read
lane zero and lane one through their exact Wasm instructions. The float batch's
bounded hex writer writes the high lane first, then the low lane. The integer
batch's foreign-output loop handles partial writes. No allocation is needed.

Both native and pinned bridge copies of the V128 formatter and its old
hex-digit builder are removed, together with dispatch and self-host runtime
classification. The public bridge interface is unchanged.

All 13 bridge tests pass after removal in 6.717 seconds. The bridge change is
committed as `04ac2784c`. New native Dew compilation takes 10.389 seconds; all
ten output/host checks pass in 0.022 seconds. Provider rebuild: 10.894 seconds;
consumer regeneration: 4.162 seconds. The full hardening lane passes in
71.317 seconds: 325 tests, 75 exact failure records, and all shared corpora.
The V128 corpus passes ten self-host checks in 1.268 seconds. The full library
lane passes in 28.840 seconds (326 tests and all shared corpora).

The generated-source lane passes in 17.586 seconds. The broad final native,
integration, stress, Starshine, and bootstrap checks remain due after the next
implementation batches; the previous float batch's full results are recorded
separately. Runs above 30 seconds remain speed bugs. No speed work is included.
