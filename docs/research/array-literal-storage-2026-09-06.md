# Array literal storage certificates

Two tests exposed different failures in native Array literal emission:

- Generic shape evidence selected reference storage and emitted valid-looking
  instructions. The direct negative test returned `Ok`, not the required
  `UnsupportedExpression(body, -417)` diagnostic.
- I8/U8/I16/U16 literals allocated wide i32 storage. Ordinary Array methods used
  the packed raw-array type. Growing or reading a literal trapped with an
  illegal cast.

Literal backing now uses `wasmgc_raw_array_storage_carrier`, the same checked
contract as ordinary raw array instructions. Packed widths remain packed;
Generic, Error, Never, and nested invalid product evidence cannot become Ref.
Unit still has a null storage marker without acquiring a logical operand.

The literal emitter no longer takes the old runtime operation number, optional
shape, or unused wrapper/index locals. Its scalar-literal task has only its
actual inputs. Unused Option construction and reference-storage classification
helpers are removed; literal-only scratch allocation no longer reserves two
unused locals.

The shared Array corpus now has 29 checks. The new case constructs all four
packed integer Array types, grows each, and reads both original and added values
with signedness intact. It runs with the native and self-host compilers. The
direct negative test obtains real resolved Generic/Error/Never shapes and
checks the exact rejection result.

This is not the complete literal migration. Array wrapper construction still
needs a declared constructor recipe and an exact target, instead of the old
three-field wrapper assumption. That task remains open in `agent-todo.md`.

| Check | Result | Seconds |
| --- | --- | ---: |
| Direct evidence rejection and existing Array backend cases | 3 passed | 8.729 |
| Full native backend | 91 passed | 36.758 |
| Stdlib and shared execution | 325 tests and all shared checks passed | 19.607 |
| Self-host hardening | 230 tests, 29 invariant records, all shared checks passed | 51.209 |
| Generated checks | passed | 8.766 |
| Clean A/B/C bootstrap | identical B/C bytes | 158.442 |

The full backend, hardening, and bootstrap runs exceed 30 seconds and remain
performance bugs. B/C SHA-256 is unchanged:
`3fefd2b01aee879f8db1ee13db2d3bef9d047307fd908faa3dec62a0fbb8d0c9`.
