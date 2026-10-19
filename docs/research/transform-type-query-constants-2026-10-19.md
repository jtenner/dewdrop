# Checked type-query constants in transforms

A source call that the compiler proves to be a constant supplies that checked
constant to the interpreter. The VM does not select a type-query algorithm from
a module path or source spelling. It consumes Bool, U32, names-array, or Unit
results from normal type checking. Each names-array use creates fresh VM array
storage. Existing compilation errors remain errors before interpretation.

Branch folding can replace an individual query node with poison after folding
a parent expression such as `is_unit<Unit>() && true`. Both compiler paths now
save the original validated query result before pruning. Only original,
non-generic instances enter this table. A specialization must not overwrite an
original expression with the result for one logical type instance.

The Dew lowerer now recognizes a checked imported namespace as a static query
callee. It normalizes a proved static assertion callee before pruning removes
namespace selectors. A runtime receiver does not pass that proof.

The normal checked native example passed 5/5 execution cases in 13.619 seconds.
The real Dew type-query request passed in 1.668 seconds. It exercises concrete
primitive, tuple, layout, field-name, variant-name queries, a static assertion,
and independent mutable arrays from repeated field-name queries. Generic query
execution still requires binding interpreter helper calls to logical type
instances; this change does not claim that larger feature.

Evidence is under `.tmp/transforms-v3/`: `query-native-test.log`,
`dew-query-current.log`, and the saved `type_queries.bin` request. The source
example is `examples/transforms/type_queries.dew`.
