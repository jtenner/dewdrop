# SHA-256 standard-library implementation

## Scope

`dew.std.integrity.sha256` adds portable one-shot SHA-256 over `Bytes`.
It returns 32 digest bytes as `FixedArray<U8>` in network byte order.

The implementation uses scalar U32 add, XOR, shift, and rotate operations. It
keeps one 64-word message schedule and one 8-word state array. Padding indexes
use U64 so a maximum-length U32 `Bytes` value does not overflow while the final
blocks are addressed.

## Test corpus

The copied corpus is:

```text
fixtures/sha256/SHA256ShortMsg.rsp
```

Source:

```text
https://github.com/pyca/cryptography/blob/46.0.7/vectors/cryptography_vectors/hashes/SHA2/SHA256ShortMsg.rsp
```

The upstream file identifies the data as the NIST CAVS 11.0 SHA-256
short-message vectors. The pyca/cryptography repository is open source under
Apache-2.0 OR BSD-3-Clause. Dewdrop uses the Apache-2.0 option. The copied file
and `THIRD_PARTY_NOTICES.md` record this provenance.

`std/tests/08_sha256_test.dew` runs all 65 byte-aligned vectors, from 0 through
512 message bits. This range covers empty input, the 55-byte one-block padding
limit, the 56-byte two-block padding boundary, and an exact 64-byte input.
