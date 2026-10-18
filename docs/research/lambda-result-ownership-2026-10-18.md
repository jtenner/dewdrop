# Lambda result ownership — 2026-10-18

## Confirmed fault

A fresh compiler C rejected the combined new-feature runtime probe before body
planning:

```text
program representation function result carrier mismatch ... name=option_checks ... expected=i32 actual=ref planned=i32 ... fragment_slot=11
```

Lambda fragments retain their enclosing function's declaration ID. Their result
signature belongs to the lambda. The representation checker looked up the parent
callable by that shared ID and compared the parent's declared result with the
lambda's ABI. A parent returning Bool with a lambda returning String therefore
failed. A reduced valid source has the same fault:

```dew
pub fn run() -> Bool {
  let callback = fn() -> String {
    "value"
  }
  callback()
  true
}
```

The old check also skipped generic owners. Tests that corrupted a specialized
lambda's scalar or Unit ABI were accepted. Skipping all lambda checks would leave
that fault in place.

## Change

`self_host/compiler/semantic_program_link_plan.dew` now dispatches lambda
fragments to an explicit result check. It selects the specialization-local
lowering module, checks the lambda's dense ID and identity, resolves its own
result shape under the specialization request, and checks that the shape is
concrete. It then compares that result with the lambda fragment's ABI.

A mismatch reports `program representation lambda result carrier mismatch` with
module, owner declaration, lambda ID, specialization, expected carrier, and
actual carrier. Named functions retain their existing declared-result check.
The existing lambda body/result checks still run after this early gate.

The new lookup is O(1) per lambda. The checker builds an error string only on
failure. It adds no user-program runtime code and no retained index. No runtime
speed or allocation gain is claimed.

## Tests and exact evidence

`self_host/compiler/semantic_lambda_result_owner_test.dew` contains five focused
tests. Valid cases cover Bool parents with reference lambdas, reference parents
with I64 lambdas, I64 parents with Unit lambdas, and generic-owner lambdas
specialized to I64, a reference, and Unit. The tests also run physical body
planning on the valid cases.

Mutation cases change a reference lambda ABI, a specialized scalar lambda ABI,
a specialized Unit lambda ABI, and a named function ABI. Each test checks that
it changed the intended fragment and requires the specific lambda or named
result diagnostic. The full self-host test lane discovers this `_test.dew` file.

Before the fix, two tests passed and three failed: the valid mixed parent/lambda
case was rejected, the corrupted reference lambda used the wrong parent
comparison, and corrupted specialized lambdas were accepted. After the fix,
all five pass. Prebuilt test generation took 4.762 seconds, provider generation
0.014 seconds, linking 1.209 seconds, and execution 0.077 seconds. No shared
MoonBit build directory was changed by this focused lane.

The fresh pre-fix C also compiled a patched compiler from its matching source
request with only this production file changed. Generation took 15.501 seconds;
the normal provider link took 0.993 seconds. That patched compiler passed the
old representation gate on the unchanged full feature probe. It then reached a
separate emission fault: `nested literal pattern has no physical comparison
recipe`, reduced independently to nested negative integer literal patterns.
This lambda validation does **not** claim that the full probe returned 42 or
that a new complete A/B/C fixed point passed. Those checks follow the separate
pattern fix.

Exact red/green output, timings, patched compiler identities, subsequent probe
failure, and source SHA-256 hashes are in
[`data/lambda-result-ownership-2026-10-18/validation.json`](data/lambda-result-ownership-2026-10-18/validation.json).
