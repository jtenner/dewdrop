# Nominal callback ABI checks

The valid `reader::<Item>()` runtime regression trapped in `ref.cast`. Its
generic target used `(eqref) -> eqref`, while the caller expected
`(ref Item) -> ref Item`. The old dispatcher treated any failure to match the
precise direct signature as proof that the callback had a closure environment.
It then cast a plain callback to an environment-first function type.

## Native fix

Fragment planning now retains two explicit ABI forms where reference erasure is
needed: precise and erased, each with direct and environment-first signatures.
The precise signatures remain unchanged. Erasure changes only GC-reference
operands/results to nullable eqref, never raw function references. Scalar types,
Unit erasure, and operand order remain unchanged. The version-1 fragment codec
stores both lookup tables; arena validation checks their lengths and indices.

A separate callback emitter consumes a named call plan. It tests exact Wasm
function types before selecting direct versus captured calling conventions.
Every selected path uses a typed cast and `call_ref`; an unrelated pointer still
fails. Nominal result casts remain explicit. The target runs once and only one
copy of the logical argument schedule executes. This adds branches only where
precise and erased reference signatures differ; it adds no closure allocation.

The generic signature lookup also stops equating all reference carrier codes.
A nullable eqref request cannot select a nominal, fixed-array, or function-ref
signature merely because all were previously assigned code 5.

## Validation

- 788 routine native tests and 266 full integration tests pass.
- 66 callback execution checks pass, including direct/captured nominal callbacks,
  generic nominal callbacks, I32/I64 tuple order, nested products, Unit fields,
  I64 limits, and a side-effecting Unit argument between scalar arguments.
- Two signature-plan tests retain precise originals and reject raw function-ref
  erasure. Two backend tests verify exact matching and call-site error context.
- All 296 library tests and the scalar/memory/arithmetic/math/product matrices
  pass. The complete library lane took 12.952 seconds.
- Generated source and CLI checks pass in 15.578 seconds. Focused planning and
  dispatch checks took 8.273 and 8.547 seconds. All routine package lanes stayed
  below 30 seconds.

The same source was then run through the self-host compiler. It exposed a
separate linker defect before emission: lambdas reuse their root declaration ID,
but the plain-function index inserts them as ordinary named functions. Its
assertion reports `one declaration has two plain linked functions`. The shared
callback oracle is retained for the self-host follow-up; this native batch does
not claim that differential callback check or a new clean bootstrap has passed.
