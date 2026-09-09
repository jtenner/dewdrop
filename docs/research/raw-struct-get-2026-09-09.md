# Raw struct reads

The first storage step is canonical `struct.get <field-index>`. The index is
the physical Wasm field index, not a source name or a standard-module ordinal.
A function fragment retains its declared nominal or primitive owner and its
field immediate. Taking the intrinsic as a function value keeps this metadata.
The version-1 fragment codec retains it too.

The implementation is present in both compilers. It currently targets
unpacked scalar fields. Packed reads and reference-valued fields need their
own complete storage/heap contracts; they must not be accepted as eqref guesses.
The primitive struct schemas are language ABI metadata, not runtime algorithms
selected by a standard-module name. The source field read maps to `struct.get`;
the reference ABI adapter casts to the exact selected heap before that opcode.

Native baseline: three positive fixtures incorrectly produced imports, and
failed in 174.806 seconds. Initial implementation passes the native lane,
including those fixtures (193.448 seconds). Checks during implementation found
missing enum cases, an accidental test-pattern rewrite (restored), and backend
attempts to construct read-only semantic enums (replaced with a local scalar
contract enum). Check runs were 3.482 and 3.373 seconds.

The first negative-test lane failed to compile the new test loop and its error
formatting (134.656 seconds); both test issues are corrected. Negative contract
tests must check the exact `InvalidHeapIntrinsic` reason, not merely any error.

The first self-host fixture omitted the required module entry point. All three
tests failed at that fixture guard (148.122 seconds), not at a raw read. The
fixture now includes a separate valid `main`. The corrected baseline failed
at the three intended emission boundaries (60.094 seconds). The initial
self-host implementation passes all hardening checks (59.347 seconds).

Further checks cover direct calls and function values in the shared execution
corpus, plus one-field changes to the saved receiver, heap, and storage. In
particular, an I32 result alone is not proof that an unpacked field remained
unpacked: a packed I8 field has the same stack carrier.

All runs above 30 seconds are timing bugs. Speed changes remain out of scope.

The saved packed-storage mutation failed for the intended missing trap
(59.776 seconds). Storage comparison now uses the exact storage kind, not
only its stack carrier. Receiver, heap, nominal owner, and storage are checked
even when the operand cannot return. The first shared execution fixture used
invalid one-line struct syntax; its missing-root failure was a fixture error,
not a linker fix. The follow-up lane (61.150 seconds) used that old request.

Final native tests pass: 1,273 (187.575 seconds). The library lane passes,
including all 11 raw GC execution cases (35.562 seconds). Final self-host
hardening passes: 801 tests, 401 exact nine-field failure records, and all
shared execution cases (60.689 seconds). The seven source-negative contracts
check their exact diagnostic reasons. Three saved-plan mutations check code
714 at the emitter with the complete caller context.

Scoped public-interface checks pass (3.294 and 3.292 seconds). A workspace-wide
interface request used an unsupported backend for the platform CLI and failed
with 17 unbound platform hooks (3.813 seconds); no platform code was changed.
The generated-source lane passes (11.656 seconds). Its first cold run failed
because Moon build warnings entered the exact CLI diagnostic comparison
(16.781 seconds); the expected Dew diagnostic itself was unchanged. The CLI
fixture driver still needs an explicit build step outside that comparison.

No standard-library runtime operation has been removed by this change yet.
Remaining text operations, generic heap wrappers, and reference contracts are
still open. Clean bootstrap verification remains due with the next storage
migration.
