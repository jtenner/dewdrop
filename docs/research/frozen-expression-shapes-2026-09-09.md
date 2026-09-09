# Physical shapes read frozen carriers

The old canonical-or-inferred shape reader could accept a missing plan or
expression, return Error for unknown/conflicting evidence, and ignore disagreement
between the two saved carrier copies. It could also replace a broad reference
carrier with an inferred scalar when nominal owner and heap evidence were absent.
Five one-mutation tests expose the missing checks: the baseline passes 860 tests
but misses all five required traps in 85.084 seconds.

The replacement reads the shared checked carrier certificate and converts only
that carrier to a shape. Body ownership, expression presence, selected
specialization, concrete evidence, mirrored carriers, and Never flow use the same
numeric checks as other emission reads. The API no longer accepts an inferred
fallback. It does not claim full Wasm heap-type/nullability validation.

Array literal-use readers now use the checked shape instead of recomputing item
types. Match emission also takes its logical result from the frozen plan. Its
large chain of inferred, contextual, variant, binding, and scalar result overrides
is removed, along with four now-unused match recovery helpers. Discarding a known
result still changes the emitted block result to Unit, and proven divergence still
gets an enclosing unreachable instruction. Pattern payload hints and other legacy
container/branch recovery remain separate open work; they are not a result certificate.

The first implementation passes 865 tests, 453 exact nine-field failure records,
and the shared runtime corpus in 84.739 seconds. The seven local/shape policy tests
pass in 0.038 seconds. Expanded checks add selected-specialization failure and
positive Unit, Never, and reference cases. Final hardening passes all 869 tests,
454 exact records, and shared runtime checks in 84.761 seconds. Generated checks
pass in 9.501 seconds. Clean bootstrap passes in 168.133 seconds. Raw and linked
compiler B/C outputs match at SHA-256
`650f2870aa58d8ad4695612d8265a23601e94d27cdca43dec11d6b8b7b250b60`.
Runs above 30 seconds remain timing defects; no speed work is included.
