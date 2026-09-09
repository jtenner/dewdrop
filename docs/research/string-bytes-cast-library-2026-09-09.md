# String-to-Bytes conversion through a raw cast

The preamble's String-to-Bytes declaration now binds to `ref.cast`. The
existing Dew functions and `String.as_bytes()` keep their behavior. A new
`Into<Bytes> for String` implementation calls the same library function.
String owns valid UTF-8, so this direction does not need byte validation.

Native planning, native runtime emission, self-host runtime emission, and the
pinned provider no longer accept `dew_string_as_bytes`. The provider's unused
wrapper allocator is removed. Typed raw cast recipes now select the target;
neither the source function spelling nor a runtime dispatch entry selects it.
StringView and unchecked Bytes-to-String migration remain separate tasks.

Policy tests initially have five intended failures (0.038 seconds). The
provider has one intended failure out of 21 tests (7.295 seconds), then passes
all 21 after removal (7.509 seconds). The shared library baseline rejects the
new Into call with `NoMatchingMethod` in 22.439 seconds. Provider commit
`0b3db6066` keeps the public Core FFI signatures unchanged. The provider build
passes in 11.307 seconds and consumer regeneration takes 4.191 seconds.

Shared runtime tests cover a returned raw cast function, Unicode slice bytes,
empty input, preserved source text, and the new Into implementation. Existing
assertion tests require the old runtime function to be absent. The full native
lane passes all 1,281 tests in 222.061 seconds, including the new raw cast
contracts and the assertion dependency check. All 270 integration tests pass
in 63.025 seconds. The native library lane passes in 49.608 seconds, including
27 String cases and the new Into call. Self-host hardening passes 821 tests,
414 exact failure records, and all shared cases in 102.225 seconds. Generated
checks pass in 21.080 seconds. Clean bootstrap passes in 231.399 seconds;
B/C raw and linked bytes match at SHA-256
`5a8690de3d52a675f31fb55ecd8b1004f50496de897938ca8f8740ed00db79b2`.
Runs above 30 seconds remain timing defects; speed work is deferred.

An additional native instruction test selects the exact source cast declaration
and checks one non-null `ref.cast` to the Bytes heap, with no allocation or
runtime call. It passes in 10.824 seconds after correcting the test to exclude
unrelated preamble field reads. Only test code changed after bootstrap.
