# Transform frame reachability

## Defect

A simple transform failed when unrelated runtime code made 129 nominal
instances of a generic helper. The native CLI reported `transform generic
instance limit exceeded` in 1.151 seconds. The root agent saved the input and
log under `.tmp/transforms-v3/frame-runtime-root/`.

Both compilers used ordinary program roots when they planned transform frames.
This included public runtime functions and all module-value initializers.
Native query demand also scanned every nongeneric body before root selection.
Transform-specific instance and copied-arena limits therefore applied to code
that the transform did not use.

## Change

Frame collection resolves the annotations that expansion will apply, using the
same local-name and import-alias resolver as execution. It maps those entries
to checked transform declaration IDs and supplies them as explicit planner roots.
Unused transform definitions are excluded. Their signatures remain checked. Checked calls, function references, evidence selections, and
module-value reads extend that graph. A module-value read adds its initializer
body; this also retains chains of initializer dependencies. Native query demand
uses the same roots before it creates logical instances. Unread initializer
bodies are excluded from native frame materialization.

The normal runtime planner keeps its existing root rules. The transform limits
remain 128 instances and 1,048,576 copied arena entries. Frame collection uses a
private compile-time context, so its forced generic demand, instance cache,
error state, and copy budget do not change the runtime context.

## Checks

Native and Dew source tests cover 129 runtime-only generic calls, the same calls
with a type query in the generic helper, 129 unread initializer calls, and a
transform that reads a chain of generic module initializers. Existing recursive
generic tests still report the instance-limit error.

The root agent ran the shared test lane. The four native root cases passed in
5.345 seconds. All 102 Dew transform tests passed, including the four root cases
and recursive-generic rejection. Dew generation took 7.766 seconds, linking took
1.438 seconds, and execution took 15.230 seconds. The full measured Dew lane took
29.303 seconds. Logs: `.tmp/transforms-v3/followup-native-rerun.log` and
`.tmp/transforms-v3/followup-dew-fixed.log`.

These measurements establish that the regression cases complete. They do not
measure peak memory or compare normal runtime speed. A fresh compiler bootstrap
and real multi-module requests are pending in the shared build lane. This agent
started no compiler process during the source edit.

## Unused transform follow-up

The root agent confirmed that rooting every valid transform definition still
failed when an unused transform called the 129-instance helper. The request
failed in 1.112 seconds; its log is
`.tmp/transforms-v3/frame-runtime-root/unused-before.log`.

A fifth native and Dew case now checks an annotation resolved through an
explicit import alias. Its module contains a used simple transform and an unused
transform that calls the 129-instance helper. All five native root tests passed in 17.845 seconds. The shared Dew suite
then passed 106 cases (17.790 seconds for execution). Its aggregate lane took
66.012 seconds, including a 34.873-second native generator build. That build
exceeded the 30-second compiler activity bound and remains a performance issue. The resolver retains the usual visibility and ambiguity checks.

The instance and copied-entry budget applies to one planning pass over the union
of applied annotation entries. It is not a separate 128-instance allowance for
each annotation application. This change keeps that existing budget scope.

## Current native CLI Wasm probes

The current JavaScript CLI hash was
`818756b86e4e27663e301ef3b619b523633ccebdb07a081f560e53e85b9fac86`.
The probes ran serially on Node v24.21.0. Nine of ten cases compiled, validated
with pinned wasm-tools 1.262.0, and returned `main() = 42`. Both public runtime
controls also returned `runtime_only() = 129`. The unused-transform case now
compiled and ran. The three generic implementation runtime controls and both
public examples (`default_references.dew`, `generic_trait_impl.dew`) passed.

The unread-initializer case passed transform expansion but still failed full
Wasm emission with `StarshineProgramCodeError(UnsupportedExpression(17179869184000,
6))` in 2.359 seconds. This remains a separate backend failure; this note does not
claim that all ten Wasm probes pass. Successful compiles took 1.285–4.305 seconds.
No Moon build or concurrent compiler process ran during these probes.

Evidence is under `.tmp/transforms-v3/frame-runtime-root/current-js/`: `run.sh`,
`status.txt`, per-case compile logs, `validate-runtime.sh`, `validate-runtime.log`,
`identity.txt`, `validation-identity.txt`, input/output hashes, and `results.json`.
The first validation attempt used an unset mise shim; all nine successful
outputs were then validated and executed with the explicit installed version.
No global tool configuration changed. Fresh Dew compiler requests remain pending.

## Final combined source checks

The current source passes all five Native root tests and all 115 Dew transform
tests. The Native root package took 6.665 seconds. Dew test generation took
7.214 seconds, linking 1.439 seconds, and execution 22.549 seconds. The full
36.111-second Dew lane exceeds the 30-second activity rule. Logs are
`.tmp/transforms-v3/products-initializers-native.log` and
`.tmp/transforms-v3/products-initializers-dew-fixed.log`.

The rebuilt JS CLI hash is
`c3e81fa2108f6d7d36d4127f5f8dc74ca7fd918d032f1d8fae6119aac4d94dac`.
The five root controls and three generic implementation controls compile,
validate, and run with this build. The previously failing unread initializer
control now passes after the separate physical-layout correction. Both public
examples fail cache-pack encoding with duplicate section owners. That new
cache fault is not counted as a passing public request; it is under repair.
The log is `.tmp/transforms-v3/products-initializers-js-runtime.log`.
