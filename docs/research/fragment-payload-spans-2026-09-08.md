# Fragment payload ownership

Both self-host payload helpers used a shared-array index without proving that
the requested ordinal belongs to the selected payload. The storage helper also
added start and ordinal before checking bounds; the exact-owner helper returned
false for a missing global index. Parallel type/shape lengths were unchecked.

The six new self-host tests start with two valid one-field variants, I64 and
I32. The positive test passes. All five negative tests fail on the old helpers
because no trap occurs (424 pass, five fail; 54.887 seconds). They cover reading
the next payload, owner lookup across payloads, wrapped addition, an invalid
span hidden as false, and a missing parallel shape entry. No arbitrary trap is
accepted as a pass. The fixed tests will also check complete numeric records.

Both self-host helpers now use one checked relative payload index before reading
an array. They carry the variant ID into the failure record and check parallel
arrays, subtraction-form span bounds, then the ordinal, in that order. The old
unchecked getter and the missing-index-to-false path are removed. Native payload
shape comparison, dependency collection, and physical field construction use the
same contract. This does not replace resolved-type validity or
the separate generic-field boxing/storage certificate checks.

Records use phase 4, the source module and variant, no body/expression, and:

- ARN-103: expected type-array length, actual shape-array length, detail 1.
- ARN-101: expected arena length, actual span length, detail `(1 << 32) | start`.
- FRG-403: expected payload length, actual ordinal, detail payload start.

Native negative machine integers retain their unsigned 32-bit bit patterns in
the U64 failure fields. Successful checks return the safe shared-array index.

Implementation and validation are complete for these payload readers. Speed
work is excluded; the broader arena and physical-evidence audit remains open.

## Checks

- The first native compile caught a diagnostic formatting error: this record
  derives Debug, not Show (0.812 seconds). It now uses the same explicit debug
  record formatter as the native body-arena checks.
- Both native tests pass (9.827 seconds). They check complete records for
  cross-payload access, negative indices, empty spans, negative/overflowing
  spans, and mismatched parallel lengths, plus valid first/second payloads.
- Full self-host hardening passes all 429 tests, 124 complete failure records,
  and every execution corpus (145.187 seconds, including cold native rebuilds).
- Full native passes all 1,098 tests (151.238 seconds).
- All 268 integration tests pass (57.410 seconds).
- Clean self-host bootstrap passes (171.069 seconds). Compiler B/C raw and
  linked SHA-256 all match:
  `8bbd0e4862324ca4823a4df227ee869b5629f80d7d5fcf3000097cfed92f6982`.
- The library lane passes 326 tests and all execution corpora (32.817 seconds).
- Generated checks pass (12.633 seconds); all 15 stress tests pass (0.345 seconds).
- Provider code and generated FFI bindings are unchanged.

Runs exceeding 30 seconds remain speed defects. No slow test was removed.
