# Generic function values must retain trait evidence

The same-name trait regression exposed another valid source that native
specialization rejects as `UnsupportedProgramGenericCall`. A generic function
`forward<t: Read>(value: t) -> I64` calls its bound method. A generic factory
`reader<t: Read>() -> fn(t) -> I64` returns `forward`; its caller fixes `t` to
I64. The function value must retain the concrete logical trait witness, just as
a direct call does. Minimal reproducer:

```dew
trait Read {
  fn read(self) -> I64
}
impl Read for I64 {
  fn read(self) -> I64 {
    self
  }
}
fn forward<t: Read>(value: t) -> I64 {
  value.read()
}
fn reader<t: Read>() -> fn(t) -> I64 {
  forward
}
pub fn main(value: I64) -> I64 {
  let callback = reader::<I64>()
  callback(value)
}
```

The first shared fixture rejects two such factories in 8.327 seconds. That
fixture now uses explicit lambda bodies to isolate the emitter name-fallback
removal from this separate function-value specialization gap. This is not a
passing negative test. Preserve the rejected source and fix both compiler paths
before closing the call-target/call-recipe work. Returning a generic lambda
that calls `forward(value)` also loses the target: native emission reports
`MissingFunction` in 0.389 seconds. The isolated emitter fixture therefore
uses non-generic callback factories; the direct generic bound calls still
select between two same-named requirements.

## Implementation and checks

Native sensitivity now starts at bound direct/operator calls and follows the
existing reverse call graph, including function-reference edges and lambda
owners. Thus returned generic functions and lambda layouts use exact logical
instances, as in the self-host compiler. This does not re-resolve a bound call
by its method name. An attempted forced source recheck lost the original trait
requirement after substituting I64, producing CT-041/AmbiguousMethod for the
two same-named traits (8.867 seconds). That change was removed; the original
selected requirement remains authoritative.

The link verifier now resolves function-reference evidence with the exact
caller fragment and specialization, as the materializer does. A template's
runtime witness can be concrete in the selected caller. Genuine runtime
capture records must match body, caller key, expression, and target, not just
module and expression. Missing evidence still reports a link diagnostic.

The first Moon test helper omitted its Unit return annotation; compilation
rejects it in 0.246 seconds. After correction both positive tests fail on the
old code (8.533 seconds). Logical sensitivity fixes the lambda test; the old
evidence check still rejects the function reference (9.284 seconds). Both pass
with substituted evidence (9.463 seconds), and after removing the inappropriate
source recheck (9.489 seconds). The shared fixture now retains both rejected
forms, with two same-named traits and six I64 boundary values each. Compilation
passes in 8.794 seconds. Full native and shared execution checks are running.

The unchanged self-host artifact also passes both minimal source forms and all
five I64 values for each in 0.395 seconds. No self-host compiler change is needed
for this defect. No speed work is included.

Full native tests initially pass (1,081, 152.652 seconds), and all 84 shared
callback cases execute correctly in native (0.023 seconds) and self-host (full
emission lane 33.065 seconds). Integration exposes eight regressions in 58.060
seconds: making every bound call require a concrete type removed valid runtime
dictionary exports. The original tests remain unchanged. The context now keeps
two independent requirements: pure-query sensitivity forbids runtime erasure;
logical witness demand selects concrete bodies when available but preserves
the explicit runtime dictionary ABI otherwise. All 45 trait-link integration
tests pass again (16.589 seconds), as do the two original callback tests (9.237).

A public function-value factory also passes. A new public *lambda* factory
case is still unsupported: change `fn reader` in the lambda source above to
`pub fn reader`. Its external runtime dictionary must be captured by the
returned lambda, independently of the concrete main call. Current emission
reports UnsupportedExpression (four-test run: three pass, one fails, 8.660
seconds). Retaining the base lambda alone instead yields MissingFunction
(9.605 seconds); that incomplete change was removed. This needs a separate
physical closure/evidence capture recipe, not a name lookup or missing-target
fallback. The source remains recorded here and the executable regression is
prepared for that next bounded change. Do not close the hidden-operand work
while this case remains unresolved.

The final focused set passes all three supported cases (9.764 seconds). Final
native passes 1,082 tests (158.187 seconds); integration passes all 268 tests
(57.059 seconds); library passes 326 tests and all execution corpora, including
84 callback cases (31.433 seconds); generated checks pass (17.103 seconds).
Hardening passes 415 tests, 114 exact invariant records, and all execution
corpora in 141.115 seconds. Clean bootstrap passes in 162.453 seconds. B/C raw
and linked SHA-256 match:
`f16ccd8bfe0406e0f1b81146cfc4718b4016bb88ad9af842c3d9ffbb7231c62a`.
Stress passes all 15 tests in 0.380 seconds. The pinned provider is unchanged
from its 10,991-test passing run.
The public runtime-lambda
capture case is tracked separately in `runtime-trait-lambda-captures-2026-09-08.md`;
it is not counted as a passing test or as completed functionality.
