# Raw array default result carriers

Two native backend failures were found with an ignored raw default read.

For `(I32, I64)`, the reader expands a stored tuple box into scalar Wasm
results. The physical linker did not request the scalar box types for this
read when no tuple had been constructed first. Emission failed with
`UnsupportedExpression(..., -421)`. Raw product array constructors, reads, and
writes now request only the scalar box types that their actual leaf types use.
Unit leaves require no scalar box. The runtime read still occurs, including
its bounds check and any tuple unpacking trap.

For `NullableRef<foreign Handle>`, raw reference array storage returns an erased
nullable `eqref`. The local slot has an exact nullable Handle heap. The missing
heap conversion caused a visible Wasm validation error at `local.set`. The
existing precise local-store check now uses the checked local value type to
insert a nullable cast to that exact heap. Null remains valid. A direct
`ref_null` result needs no cast because its bottom heap already fits the local.
This conversion allocates no guest object and adds no call.

Discarded default reads do not all have the same runtime behavior. Functions,
trait values, and raw arrays use erased nullable reference carriers until an
operation narrows them. A discarded read can therefore return null and leave
the enclosing function to return 42. A record local has a non-null nominal
heap, so its binding already narrows the value and traps on a null default.
Nonempty tuple payloads are unpacked into scalar results and also trap on a
null tuple box. A tuple of Unit values has no payload leaves. The fix preserves
these existing physical rules and does not add a blanket non-null check.

Dew uses boxed product values and erased local carriers. It has no matching
native scalar-box demand schedule or exact nullable local-slot type. No Dew
backend change was inferred solely from the native failure. Runtime controls
must be checked before making a separate parity claim.

Native white-box regressions cover exact scalar box demand for scalar, nested,
and Unit-only tuples, plus local and imported nullable foreign heaps. The
standalone `tools/test-raw-array-defaults.py` uses an existing CLI to check ten
actual runtime controls. It records the CLI hash, compiler time, peak RSS,
output size, and actual return or trap result in
`.tmp/raw-array-default-results/`. Before-fix evidence is retained in
`.tmp/transforms-v3/default-controls/`.

The three new native backend tests pass (1.736 seconds). Related outlined
getter tests pass 3/3 (3.989 seconds), and existing product box demand tests
pass 3/3 (0.981 seconds). Raw output is in
`.tmp/transforms-v3/followup-native-rerun.log`. The shared runner first stopped
on an unrelated generic helper compile error; that first run is not counted
as passing backend validation. All ten actual runtime controls pass. The shared JS CLI rebuild took 3.939
seconds. Each source compile took 1.0826–1.1350 seconds; the complete runtime
harness took 11.389 seconds. Peak compiler-host RSS was 368,324–374,440 KiB,
and emitted programs were 714–793 bytes. These are single functional samples
from the JS compiler host, not a native host memory comparison. Exact hashes
and raw samples are in `.tmp/raw-array-default-results/identity.json` and
`samples.json`; wrapper logs are
`.tmp/transforms-v3/{followup-js-build,raw-default-runtime}.log`. The native
backend results match the controls described above. No comparative speed or
allocation gain is claimed. A current Dew runtime control is still pending.
