# StringView ranges and boundaries in Dew

String and StringView slicing now use ordinary Dew functions. Both convert
their input to shared Bytes, call the checked Dew Bytes view, and check UTF-8
boundaries before a raw Core cast to StringView. The checked Bytes range
proves that the relative end addition cannot overflow. No copy or decoding
is needed. The input String/StringView supplies the valid-text contract;
the raw cast itself is not a UTF-8 validator.

The source end is a valid boundary without a byte read. The former runtime
checked every nonzero start, including an empty range at the exact end of a
16-byte V128 array. The new positive regression fails with `array element
access out of bounds` before implementation. Build time is 0.481 seconds;
the failing runtime check takes 0.028 seconds. This is a real behavior fix,
not only removal of compatibility names.

The shared StringView corpus grows from 14 to 26 cases: one/two full vector
ends, nested empty ranges, a full Unicode vector, returned slice functions,
split scalar boundaries, invalid bounds, maximum U32 start, and argument
evaluation order. All 26 native cases pass after implementation. Compilation
takes 10.936 seconds and execution takes 0.024 seconds.

Both native/provider dispatcher entries and the private shared body builder
are removed. The policy check fails five assertions before implementation
in 0.040 seconds. Provider tests move from 19 passes and one failure in
7.299 seconds to 20 passes in 6.761 seconds. Provider commit: `9d9d363ff`.
Public Core FFI types remain unchanged; physical metadata and fingerprints
are refreshed. Provider build takes 10.766 seconds and consumer refresh takes
4.249 seconds. The full native library lane passes in 37.718 seconds.
Self-host hardening passes in 98.161 seconds: 873 tests, 457 exact failure
records, all 26 StringView cases, and the shared runtime corpus. Full native,
integration, generated, and clean bootstrap checks are running. Runs over
30 seconds remain timing defects; no speed work is included.

The full routine native lane passes all 1,288 tests in 222.824 seconds.
Integration passes all 270 tests in 63.253 seconds. The empty standard-source
test package is not counted as evidence. Generated and clean bootstrap checks
are still running.

Generated checks pass in 20.331 seconds. Clean bootstrap passes in 206.441
seconds. Compiler B/C raw and linked hashes match at
`81662b4500bc1c78bb35c324850c85876793f30c955c2d7b36f93915569c5bbf`.

Byte access, builder allocation, growth, copying, scalar encoding, and
finalization remain separate work. This does not close the broad text row.
