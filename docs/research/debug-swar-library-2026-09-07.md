# Packed scalar Debug migration

Preserve the existing `Swar32(unsigned decimal)` and `Swar64(unsigned decimal)`
output. The shared test corpus covers zero, the sign bit, all bits set, distinct
bit patterns, and generic dispatch. The host forces three-byte partial writes.
Error, zero progress, and excess progress must stop writes at the failing call,
after successful compilation and instantiation. They are injected separately
in the prefix, decimal value, and closing bracket.

The source-policy test fails before migration in 0.052 seconds: both Debug
implementations still call the opaque Bytes write builtin for their delimiters.
The original implementation passes 11 output/initial-host-failure checks:
compilation 0.424 seconds, execution 0.029 seconds.

The new Dew helper writes fixed ASCII bytes, uses the existing unsigned decimal
formatter, and uses the checked foreign-write loop for all three parts. No new
builtin, byte wrapper, allocation, or compiler-side layout rule is introduced.
The expanded 17-case corpus is wired into native and self-host runners.
The old write builtin still serves Unit, Bool, and test assertions; it must not
be removed until those callers migrate. No speed work is included.

The new native corpus compiles in 11.599 seconds; all 17 checks pass in
0.028 seconds. The self-host lane passes in 83.621 seconds: 350 tests,
99 exact records, and every shared corpus. Its 17 SWAR checks take 1.444 seconds.
The library lane passes 326 tests and all shared corpora in 32.277 seconds.
Generated checks pass in 21.477 seconds. Broad native, integration,
stress, and clean bootstrap results are recorded in the immediately preceding
physical-local-identity batch; they are not rerun for this library-only change.
