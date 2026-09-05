# Inferred enum layout demands

An array regression inferred `Option<Unit>` from `get` and `pop` without an
explicit result annotation. Native linking had no layout for that application.
It collected enum applications from resolved signatures, but not inferred body
types. The emitted match failed with unsupported expression `-405`.

The linker now collects concrete enum applications from both pools. Both paths
use the same structural deduplication helper. The inferred argument span must be
valid and match the declaration's arity. Generic and erroneous template shapes
are not concrete layout demands. Unit payloads stay erased; no reference carrier
is invented for a Unit expression.

The reduced backend test uses a local `Choice::Present(())`, with no explicit
`Choice<Unit>` signature. It requires zero diagnostics and valid Wasm.

Validation: `tools/test-native.sh` passed 793 tests in 74.397 seconds. The backend
lane took 36.780 seconds, which remains a performance bug. Log:
`/tmp/dewdrop-array-native.log`. The larger array storage and library migration
is separate work and is not claimed complete by this fix.
