# String pattern equality

## Inference

String literal patterns now use ordinary `Eq::eq` candidate selection when the
trait is in scope. Collection records the implicit trait and method names, so a
module need not contain an explicit `==` or `.eq` expression. These names are
used for semantic lookup, not as physical type or function identity.

The selected declaration and type arguments use the existing operator evidence
arena. Its key is the literal expression ID. The literal remains String-valued;
the implicit comparison has a separate Bool result constraint. Both operands
have the literal's String type, already constrained against the pattern subject.

Only string pattern expressions enter the operator queue. A sparse map marks
them before the expression walk, which preserves the self-host compiler's
arena-ordered merge of method, operator, and field work. Ordinary string values
do not acquire implicit calls. The native scratch map is cleared between bodies.

Tests cover local and imported implementations, an imported trait with no
explicit operator spelling, and exact missing-implementation diagnostics. The
initial native test failed with `NoInferredCallTarget` before the implementation.

## Still required

This is the inference part of the String migration, not its emission change.
Preserve the selected target in lowering; root and specialize the implicit call;
build its subject/literal operand recipe; and verify that recipe before emission.
Then replace `dew_string_equals` with ordinary Dew equality and remove all late
runtime-name lookups, including nested patterns. Missing or ambiguous trait
scope must become an explicit diagnostic when the legacy path is removed.

The literal's physical carrier must not be changed to the comparison's Bool
carrier. The pattern subject is a cached value, not a second evaluation of the
source expression. A pattern call therefore needs its own operand source kind.

## Validation

- Three focused native tests pass (8.277 seconds, including compilation).
- The first self-host hardening run passed all tests and shared probes (64.210
  seconds). This exceeds the 30-second compiler activity limit and remains a
  performance bug.
- Final native lane: 936 tests pass (128.308 seconds). Semantic tests took
  78.861 seconds and backend tests took 36.988 seconds; both exceed the limit.
- Final self-host hardening: 236 tests, 29 exact invariant records, and all
  shared library and emission probes pass (63.729 seconds). This also exceeds
  the limit. No compiler-B/C bootstrap was run for this inference-only step.
