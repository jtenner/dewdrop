# Block expressions keep shared type variables

The native inferencer seeded product fields with their child expression type
variables, then replaced block-expression entries with block result types.
The product still held the old, unbound variables. As a result,
`identity(((), value, ()))` reported unresolved expression, local, and generic
argument types even though all three elements were concrete.

Block expressions now constrain the existing variable to their result type.
They do not replace the table entry. This matches the self-host inferencer's
existing rule and preserves dependencies already stored in product types.

The regression checks both flat and nested generic products with Unit elements.
The source that previously produced unresolved-type diagnostics now infers
cleanly. A native runtime fixture also returns exact I64 values through a product
with erased Unit fields, including both I64 limits.

This is a type-inference correction, not a new Unit or tuple representation.

The routine native and full integration lanes passed with this fix. The focused
inference/specialization regressions took 8.148 seconds; the library runtime lane
took 12.394 seconds. Tests with malformed source remain diagnostic failures.
