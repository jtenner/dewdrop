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
allocation gain is claimed.

Fresh Dew compiler A (`1b59e1d1ea6762157d2bd0da2da304d6c55eb69524a8060b48fa82eb9523f6aa`)
was then tested with the same ten raw-default sources. Nine compiled, passed
pinned `wasm-tools 1.262.0` validation, and ran. The nullable null-test source
failed visibly with `self-host smoke: ref_is_null`; it produced no Wasm file.
The missing Dew runtime instruction mapping is tracked separately in
`dew-null-runtime-emission-2026-10-19.md`.

The Unit, Unit-only product, function, trait, and raw-array discard controls
returned 42. The Unit out-of-bounds control trapped. Those six results match
Native. Discarded record, product, and nested-product reads returned 42 in Dew;
Native traps in those three cases. Dew retains the boxed nullable `eqref` until
an operation narrows or unpacks it. Five extra valid runtime boundary controls
confirmed this: named record and product bindings whose values were unused
returned 42; a record field read, a scalar tuple destructure/use, and a nested
tuple destructure/use all trapped with `illegal cast`. All five emitted
programs passed validation. A sixth boundary control used explicit
`wasm_ref_as_non_null` and failed visibly with `self-host smoke: ref_as_non_null`.
These source controls establish the current carrier behavior. No extra cast
was added to discarded reference results.

The ten fresh-A compiles took 1.3182–1.4998 seconds each (14.2666 seconds total),
with peak compiler-host RSS of 353,652–365,776 KiB. The six boundary compiles
took 1.3861–1.4653 seconds each. These are single Node-host samples. Raw request,
compile, validation, and runtime logs plus exact compiler/fixture identities
are in `.tmp/transforms-v3/raw-defaults-fresh-a/` and
`.tmp/transforms-v3/raw-default-boundaries/`. The preparation and run scripts
are `.tmp/transforms-v3/{raw-defaults-fresh-a,raw-default-boundaries}.py`.
