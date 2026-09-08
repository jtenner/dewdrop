# Runtime trait witnesses in returned lambdas

This is the next correctness case after concrete bound callbacks. The native
reproducer is the lambda form in `bound-trait-function-values-2026-09-08.md`
with `reader` made public. The public erased export receives a runtime trait
dictionary. Its returned lambda must keep that dictionary after the factory
returns. The concrete call from main works; the external runtime ABI does not.

Observed failures are UnsupportedExpression when the concrete lambda instance
elides the base lambda, then MissingFunction if the base lambda is merely kept.
Keeping that base alone is not a fix and was reverted. The prepared native
regression is `.tmp/public_runtime_trait_lambda_wbtest.mbt`; its helper is the
checked-in `bound_trait_callback_check` test helper after the concrete fix lands.
Do not turn a compile failure or arbitrary trap into a passing test.

Update: [export admission](runtime-trait-export-admission-2026-09-08.md) now
withholds the unproved optional erased export and tests successful concrete
emission. Closed lambdas with no runtime dictionary use have exact owner-key
fragments. The actual dictionary capture design below remains unimplemented;
safe admission is not a substitute for that work.

## Current boundaries

- `materialize_compile_time_lambdas` makes per-logical-key lambda functions and
  copies the owner's evidence span. It has no runtime dictionary capture plan.
- Generic root scanning currently materializes all owned expressions using the
  root function as caller, including lambda expressions. A runtime dictionary
  parameter in a root is not the same physical operand in a returned lambda.
- `StarshineProgramEvidenceClosure` already represents function-reference
  wrappers that store runtime dictionaries. Its entry wrapper loads them from
  fields and appends them after visible call arguments.
- That wrapper currently assumes an ordinary function target, with no hidden
  lambda environment or source captures. Its caller lookup also accepts only
  a defined root function, not a lambda owner. Reusing it unchanged is unsafe.
- Runtime evidence operands in `starshine_code.mbt` currently emit `local.get`
  of an integer parameter index. A captured dictionary needs an explicit source
  recipe; the old root's index can alias an unrelated lambda parameter.

## Design constraints for the next change

Select each lambda body with its actual physical caller and owner generic
bindings. Keep exact body/key/expression call records; do not let root and lambda
scans publish different operand recipes for the same call site. Represent each
required runtime dictionary in the closure plan with a checked source in the
enclosing frame and a checked destination capture field. Nested lambdas must
capture from their enclosing lambda, not read the root's old local index.

One possible implementation extends the existing evidence entry wrapper: its
public closure signature remains environment plus logical physical operands;
the implementation function receives its environment, source operands, and
hidden dictionaries exactly once. The wrapper can supply captured dictionaries
after those source operands. Source captures and dictionary fields need one
verified layout. Directized lambdas need a corresponding explicit hidden-operand
recipe, not a silent switch to the wrong closure ABI. This is a design candidate,
not implemented behavior.

Preserve both runtime and concrete instances when they coexist. Cover two
same-named traits, mutable and immutable source captures, nested factories,
Unit parameters, Never arguments, and dictionary lifetime after the factory
returns. Validate exact reference types and every hidden operand, with
one-field negative mutations for source slot, capture field, owner, and target.
Keep runtime algorithm work in Dew and do not add an opaque builtin.
