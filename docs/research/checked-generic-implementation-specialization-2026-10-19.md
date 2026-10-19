# Checked generic implementation specialization

Before-fix sources:
`examples/transforms/generic_trait_impl.dew` and
`.tmp/transforms-v3/generic-trait-runtime.dew`.
The transform reports unsupported dispatch. The runtime control reports
`StarshineProgramCodeError(SignatureOnlyCall(17179869184001))`.

The Native bound-call planner retains the checked concrete implementation ID,
but its evidence type arguments contain physical shapes only. It invokes the
implementation method materializer without logical types. A generic method
whose body has a type query therefore cannot select a logical instance. The
same branch compares implementation argument count against implementation plus
method parameters, and does not forward method-own checked bound evidence.

The fix keeps the checked implementation and prerequisite tree. It matches that
implementation's logical receiver and trait patterns against the caller's exact
logical receiver and trait arguments. This recovers implementation parameters,
including ones used only by a trait argument. It appends method-own logical
arguments and physical shapes from the checked call span. Method-own checked
bound roots follow the implementation prerequisites in the request. The
materializer then receives the full logical argument list.

No new witness search is used. No type identity is inferred from a Wasm carrier,
source spelling, or module path. A mismatched checked implementation is an
explicit compiler invariant failure. Non-concrete logical callers retain the
existing physical fallback path; query-sensitive methods still require concrete
logical evidence.

The Dew guarded-call resolver already selects generic implementations using an
exact checked witness and requirement declaration IDs. It already carries
implementation and method arguments and verifies their substituted signatures.
The legacy bound helper's conservative generic rejection must not be removed
without a replacement proof. A standalone Dew source diagnostic is prepared to
check whether this case needs any Dew production change after the selected-call
export fix.

Draft regressions cover the reported source, a generic method with its own type
and bound, and an implementation parameter appearing only in a trait argument.
Native semantic tests check linked instances; backend tests validate emitted
Wasm; a transform source test requires output 42. The root agent owns compiler
runs and actual execution. No test or compiler command has yet been run for
this draft.

## Verified source execution

The helper's first Native build failed because `impl_trait_types` stores an
integer, not an Option. The helper now validates the integer before reading its
type. The three semantic cases passed in 12.126 seconds and the three emitted
Wasm validation cases passed in 9.824 seconds. The three CT source cases passed
in 3.746 seconds. The reported example checks both values separately, so a
swapped implementation cannot pass through an unchanged sum.

The Dew suite now includes all three corresponding source cases. All 105 tests
passed after the unrelated default/null fixture correction. Generation took
6.965 seconds, linking 1.376 seconds, and execution 16.695 seconds. Total 59.973
seconds includes a generator rebuild and exceeds 30 seconds. No Dew semantic
widening was needed: its existing checked guarded-call resolver handled owner
bounds, method bounds, and trait-only type arguments.

Native VM 77/77 and default source 4/4 also passed in the same source state.
Logs: `.tmp/transforms-v3/default-generic-{native,dew}-final.log`.
Actual standalone Wasm values and the fresh public request lane remain pending.
The old prepared-diagnostic statements above describe the earlier stage.

## Runtime controls

All three standalone generic implementation programs compile to Wasm, validate
with wasm-tools 1.262.0, and return 42 under Node. The public generic implementation
transform example also compiles and returns 42. The JS CLI SHA-256 is
`818756b86e4e27663e301ef3b619b523633ccebdb07a081f560e53e85b9fac86`.
Exact inputs, output hashes, times and results are in
`.tmp/transforms-v3/frame-runtime-root/current-js/`. This is functional execution,
not a controlled speed comparison. Fresh Dew public requests remain pending.
