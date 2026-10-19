# Checked original-body types for source transforms

The execution check replaces annotated target bodies with stubs. It cannot
supply types for their original expressions. Reflection therefore checks a
second manifest that keeps clean original bodies. This pass does not emit code.
If that input fails checking, the context receives errors and no type facts.
The transform may still repair the body; normal final checking remains required.

The public API is `ctx.type_of(SyntaxNode) -> Option<TypeNode>`, backed by
`ctx.expression_types` and `ctx.type_errors`. Facts use original file identity,
byte offset, and syntax kind. The public method finds the first offset with a
binary search and checks the same-offset group. Explicit type calls and `is`
syntax use their corresponding checked call and match records. Statements and
patterns have no fabricated expression type.

Structured types retain primitive, nominal, trait, generic parameter, Self,
product, applied, function, and member-projection forms. Alias names are resolved
in this checked view. The declared source-type view remains available separately.
Native descriptors cache arena roots; a request-local module/root identity lets
the driver retain sharing when copying descriptors into its VM. Dew caches arena
roots directly. Both VMs create fresh mutable library arrays, with work and
allocation limits, when they expose the view to a transform.

The native materializer uses a source-offset range lookup per function. Dew
sorts fact offsets with four stable radix passes and uses the same range lookup.
These avoid rescanning every type fact for every annotated function in a file.
The compiler phase cost is outside the per-annotation interpreter report.

Validation before the final source freeze: all 42 Dew module tests passed
(generation 5.528 seconds, link 1.165 seconds, execution 0.108 seconds). Three
native body reflection cases passed in 10.855 seconds. Real Dew source-pool
expansion passed all three public examples in 2.079–2.131 seconds each. The
examples distinguish a call from its same-offset callee, retain generic and
nominal types, and repair an unknown original call. Native VM shared-type tests
stop with visible limits in 1.072 seconds. Final current-source integration,
bootstrap, and review evidence will be added after those checks finish.

Independent review found a Dew limit-path loop that kept visiting and appending
children after the first child failed. The materializer now returns immediately,
before appending that failed value or its parent record. A single linked Wasm
compares old and fixed helpers with identical inputs, alternating order, seven
samples, and ten calls per sample. At width 100,000 and one remaining work step,
the median is 23.344286 ms old and 0.020177 ms fixed per ten calls. The width-ten
control is 0.022682/0.013435 ms. Both versions report 69 allocation-work bytes per
call, which shows that the old post-error array was outside that counter. These
are limit-path timings; they are not normal-transform speed or peak-heap claims.
Raw samples, build identity, harness, and environment are retained under
`.tmp/typed-reflection-review/`; review scope and limits are in
`.tmp/transforms-v3/typed-reflection-review.md`.

The Native driver reuses type descriptions by request-local semantic identity.
The repeated-description cache test passes in 7.570 seconds. The explicit Unit
and loop-break Unit regression also passes (8.432 seconds); the suspected Unit
carrier fault was not reproduced, so no Unit implementation change was made.
A collector with no annotated target skips its extra original-body check.

The public API explicitly imports Option and the numeric preamble. All eleven
compiler transform tests pass with this change, including the two cases with
default imports disabled (20.447 seconds for the file). All 24 method checks
pass with the updated unsafe-cast diagnostic (34.734 seconds). The latter
exceeds the project's 30-second limit and remains a test-lane performance fault;
it is not evidence of a single transform taking that time.

Final feature checkpoint checks: 39 public request examples compile to valid
Wasm and return 42; all 18 rejection requests fail with their expected
diagnostic and no output module. The complete public Dew transform lane passes
54 tests (generation 5.603 seconds, link 1.208 seconds, execution 0.144 seconds).
Expanded-source JSON with work reports passes on the current JS compiler
(1.367 seconds). All four native expression-reflection tests pass in
3.741 seconds. Public requests use the scalar-contract-fixed compiler
`bc7afe18e1f7de771572ec5936ebbb421adaeb673bf4cbb3c3f44f572d928cb0`.

Before that narrow scalar backend fix, the full current transform compiler
self-host check reaches a byte-for-byte fixed point at
`f7877b0ca368363ddd2e3a5fd71c90d9a5405ce40d9c201817a2cb686453d7de`: A source
build 16.706 seconds; A execution 19.111 seconds; B execution 18.630 seconds.
The root task repeats the fixed-point check after the backend catalog update.
The routine native lane passed 1666 of 1670 tests before the last import and
diagnostic updates. Its four failed cases then passed in their owning files;
the new reference-carrier cases and all 50 native VM tests also pass. The
272-case integration lane passed before the final reflection/carrier additions.
These are completion checks; no compiler peak-memory claim is made.
