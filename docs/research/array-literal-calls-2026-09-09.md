# Array literal construction through ordinary calls (historical trial)

The [September 14 implementation](array-literal-calls-2026-09-14.md) closes the
binding failures below with private exact imports and ordinary calls in both
compilers. This note retains the original failed trial and its measurements.

The remaining literal emitters construct a wrapper directly from backing,
length, and capacity, without an ordinary constructor plan. The native trial
lowers a source literal into a lexical block: allocate its exact capacity,
push each source element in order, then return the array. These are ordinary
resolved calls; physical code does not choose wrapper fields. A generated
local uses a name with `$`, which source identifiers cannot contain.

The parser still reports the original ArrayExpr. Collection requests a parser-
owned AST transformation, respecting MoonBit's read-only AST boundary.
The self-host equivalent and legacy-emitter removal are not implemented yet.
Name binding, all existing literal contexts, and self-host bootstrap still
need validation; this experiment is not a completed language change.

Measured observations:

- A manual generic call probe returns 42. Its first draft used unsupported
  typed-let syntax and failed in 1.786 seconds; the corrected probe compiles
  in 2.217 seconds.
- The new lowering regression fails on the old implementation in 10.627
  seconds because PlannedArrayLiteral remains.
- The first AST helper draft is rejected at the package read-only boundary
  in 0.756 seconds. Moving AST construction into the parser package preserves
  that boundary. The lowering test then passes in 10.027 seconds.
- The existing product backend corpus fails in 11.682 seconds with
  SPC-301, declaration 18446462654567415826, argument 0, Generic shape.
  Program call specialization only substitutes a top-level generic parameter;
  it does not descend into tuple arguments. The compiler already has a shared
  body-value shape substitution helper that handles both resolved and inferred
  tuple fields. A separate ordinary-call regression is being added before
  replacing the shallow path. The rejection check will not be weakened.

The separate native ordinary-call regression fails in 12.333 seconds, then
passes in 10.753 seconds after using the shared nested body-shape substitution.
All six product/Array backend tests pass in 2.609 seconds. The shared Array
probe builds in 6.505 seconds and passes all 30 execution checks.

The self-host nested-call regression fails with the exact existing SPC-301
record (878 tests pass, one fails) in 102.862 seconds. Its replacement uses an
explicit type work queue, a completed-result cache, and a separate active-node
set. Product fields retain order; shared children reuse results and active
cycles are errors. The first build fails in 36.961 seconds due to assignment
syntax in two match arms; those arms now use blocks. The corrected build is
complete. No rejection condition was removed to make the positive case pass.

The literal transformation has been removed from production source while the
prerequisite is checked independently. The isolated fix also corrects Unit
tuple storage: emission must read the frozen specialized child shape, not the
generic source shape. All 884 self-host tests, 463 exact records, and 276 shared
callback checks now pass. See the
[nested call log](nested-call-specialization-2026-09-09.md). Literal binding and
context checks must still pass before the transformation can replace the old
construction path.

## Binding trial rejected

Four new native checks cover a local value named Array, a literal without an
open Array name, an unrelated user struct named Array, and contextual empty,
nested, and Unit arrays. The baseline passes all four in 11.499 seconds. The
first fixture draft also indexed without importing the index trait; its
unsupported-expression error was corrected by making that case test literal
creation alone.

With the AST call transformation enabled, three checks fail in 11.268 seconds:
the local captures the constructor target, the unopened type cannot resolve,
and the unrelated Array declaration receives the qualified method lookup.
Only the contextual empty/nested/Unit test passes. These failures show that
a generated local name alone is not enough for hygiene: the generated callee
also needs the language literal's bound declaration identity.

The trial is removed again, not shipped with a source-spelling fallback. The
four baseline regression tests remain. The replacement must carry the bound
literal type/constructor into ordinary call planning, independent of lexical
names; removing the old emitter is still open work. The earlier positive
Array and product results do not establish this binding property.

With the rejected transformation removed, all four binding regressions pass
again in 11.755 seconds. This commit adds coverage and records the failed
experiment; it does not change production literal semantics.
