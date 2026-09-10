# Raw Array getter function values

## Reproduction

A generic `array.get` builtin returned by an ordinary factory was rejected with
`UnsupportedProgramGenericCall(28114, 120748710559746, 200)`.
The test declares its own empty generic `Slots<t>` type. No standard module
name is needed. The baseline failed in 9.110 s.

## Implementation

The native fragment plan now retains an `array.get` operand recipe. Its element
shape is specialized from the selected request and is included in the version-1
fragment codec. The outlined wrapper checks the exact raw-array carrier,
the index type, and the physical result count and types. Packed signed and
unsigned reads remain distinct. Unit storage is read and dropped; products
use the existing storage unboxing path.

The first executable wrapper exposed another defect: callback branches passed
an erased reference to a non-null typed raw-array parameter. Wasm validation
reported the mismatch at `call_ref` (8.357 s). Callback argument casts now use
the selected signature and logical argument widths. Unit does not shift later
physical parameters. The original test passes validation (8.923 s).

This implements generic `array.get` function-value wrappers. It does not yet
provide wrappers for every raw Array opcode or every parameterized heap
instruction. Native result adapters for non-erased nominal result signatures
also remain separate work; they are rejected rather than treated as eqref.

## Additional checks

- Native backend baseline with the wrapper/callback change: 148 passed,
  79.128 s. This exceeds the 30-second activity limit; speed work is deferred.
- Ten factory-only signatures (I8/U8/I16/U16/I32/I64/F32/F64/Unit/nested
  product) pass real Wasm validation, including full source diagnostic checks:
  two tests, 12.171 s. The first string fixture incorrectly used UTF-16 bytes;
  it now explicitly encodes UTF-8. Emission alone had hidden the parse error,
  so the test retains the complete source-diagnostic check.
- An initial self-host run passed the existing 891 tests (98.135 s), but did
  **not** include the new test file. It is baseline coverage, not coverage of
  the new feature. The file is now explicitly in the hardening test list.
- With the file included, the self-host test fails: `outlined builtin needs
  an explicit instruction stack contract`. The 891 existing tests pass.
  Shared callback cases now also include raw getter I64, Unit, and nested
  product calls. That shared probe fails at the same missing stack contract.
  The complete baseline run took 101.558 s.

The self-host implementation now retains the specialized element shape in an
outlined heap recipe. It checks opcode, concrete storage, both signature spans,
operand count/types, and result count/type with numeric failure records before
emission. It casts the erased input to the recipe's exact storage heap, then
emits the signed, unsigned, or full read. Unit drops its storage marker. Products
retain the self-host boxed ABI.

## Validation

- Native getter tests: 3 passed, 13.129 s. A valid wrapper is checked before
  changing only its index type or result type. Both errors match all nine
  fields of the numeric failure record (ABI-705 and ABI-709).
- Native fragment codec tests: 10 passed, 11.567 s, including signed, unsigned,
  Unit, and product getter recipe round trips.
- Native shared callback build: 8.249 s. Runtime: 312 checks passed, 0.031 s.
  Getter cases cover I64 values outside I32 range, Unit, nested products with
  Unit fields, and signed/unsigned packed truncation and extension.
- Self-host: 896 tests and 469 exact numeric records passed; 312 shared
  callbacks passed (1.031 s), along with the remaining hardening probes.
  Total 94.150 s. New negative tests cover index type, result type, and Error
  element evidence. The first self-host implementation had a source formatting
  error (38.842 s); after correction the first green run took 98.646 s.
- Full native lane before the additional Never edge-case fix: 1,326 passed,
  297.847 s (822 semantic and 150 backend tests). The zero-test
  `standard_sources` package is not included in that count.

## Non-returning callback arguments

Review of the new argument mapping prompted a separate edge-case test. With an
explicit Never parameter, the old emitter produced both the later argument and
`call_ref` after the non-returning evaluation. The test failed on the actual
emitted function text (8.947 s), even though Wasm validation passed. Callback
planning now stops at the first evaluation whose flow cannot fall through,
including callee evaluation. The prefix uses the existing ordered-evaluation
path, with no call instruction or later argument emitted (9.247 s).

The ordinary `fn(I32, I32) -> I64` form initially failed even earlier: callback
inference used strict unification rather than the existing expression
assignment rules. That produced a LocalTypeMismatch for Never versus I32
(9.175 s). It now uses the same assignment helper as ordinary calls. The test
requires no source diagnostics, valid Wasm, no call, and no later constant;
all three callback tests pass (9.895 s). A shared raw-getter callback probe also
returns from its first argument before any Array operand or call is needed.

The full integration lane passes after the Never fixes: 270 tests, 98.662 s.
The first shared Never fixture used an unsupported bare block in an argument;
both parsers correctly rejected it as an invalid object literal. The full
self-host run still passed 896 tests and 469 records but failed that source
probe (94.159 s). The fixture now uses an ordinary if expression whose two
branches return. Native build: 0.472 s; all 318 callback checks pass. The
corrected self-host probe run reuses the same current, checked compiler module.
All emission probes pass (39.026 s), including all 318 callback checks
(0.928 s). Native callback execution takes 0.023 s. Generated files and policy
checks pass (19.125 s). Scoped native interfaces regenerated in 3.597 s.
Clean bootstrap passes in 169.520 s. B and C core/linked outputs validate and
match. Their raw and linked SHA-256 is
`bca677af2000c68e0c9b2539b477cf4351bc0ad800e2c6cc1b3f067fd11d1b05`.
Runs over 30 seconds remain recorded timing defects; no speed work is included.
