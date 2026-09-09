# Bytes views use declared Dew storage

`bytes_view` is now an ordinary Dew function. A private struct declares its
V128 backing array, start, and logical length. Raw Core casts expose and
reconstruct this representation. The view shares the original array; it does
not copy bytes or validate UTF-8. Range checks use subtraction, and the start
addition has a separate overflow check.

The native and pinned provider `dew_bytes_view` entries and private function
builders are removed. No standard module name selects this representation.
The same declared-field and cast rules apply to user structs. String and
StringView boundary checks and builder storage remain separate open tasks.

Tests add returned view functions, nested raw ranges, empty end ranges,
invalid starts/lengths, maximum U32 input, and argument evaluation order.
The shared Bytes corpus grows from 31 to 37 cases. The policy check fails
four assertions before implementation in 0.036 seconds. The provider test
starts at 19 passes and one failure in 7.069 seconds, then passes all 20
tests in 6.995 seconds.

Provider commit: `ae894762e`. Provider build takes 11.298 seconds; consumer
refresh takes 4.133 seconds. Core FFI declarations retain their public
signatures; provider fingerprint and physical binding metadata are refreshed.
This is a focused provider test result, not a full pinned-provider signoff.
The full native library lane passes in 49.053 seconds, including all 37 Bytes
cases. Self-host hardening passes in 103.561 seconds: 873 tests, 457 exact
failure records, 37 Bytes cases, and the full shared runtime corpus. Runs
over 30 seconds remain timing defects; no speed work is included. Native
link, generated, and clean bootstrap checks are in progress.

Generated checks pass in 20.825 seconds. The focused native link command
selected zero tests in 11.214 seconds because that file belongs to the
include-skipped integration lane. It is not passing test evidence; the full
integration lane will supply that check.

Clean bootstrap passes in 217.959 seconds. Compiler B/C raw and linked output
hashes match at
`28074b7e04ae86ab3d64f5db309358a874c561f5bfef998f9618c2f01de2f186`.
The full native integration lane passes all 270 tests in 87.843 seconds,
including the 41 link tests missed by the earlier focused invocation.
