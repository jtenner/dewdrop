# Anonymous product patterns

## Scope

Finish tuple patterns such as `Some((left, right))` in both compilers.
Keep named constructor payloads distinct from anonymous products. Do not encode
an anonymous product as a named constructor with a missing declaration.

## Contract

- `(value)` groups one pattern; `(value,)` is not a one-field product.
- `()` matches Unit. Other products have 2 through 32 logical fields.
- One `...` can omit fields. The known subject type determines their count.
- Outer expected types reach nested fields before constructor selection.
- Field order and types follow the product type, not a nearby use of a binding.
- Matching evaluates the subject once. Unit fields have no physical operand.
- An arity or subject-type mismatch remains a semantic diagnostic.

The native AST and HIR have separate product pattern variants. The V1 parse
event codec preserves that distinction and product arity diagnostics. Its
content cache key has a new salt, not a new format version.

Native matching reads flattened leaves from the canonical product storage box.
A nested product pattern uses a leaf offset in the same box; it does not box
each nested product again. A direct multivalue subject is stored and boxed once
for the match. This is a correctness implementation, not the final allocation
plan. The self-host emitter uses its existing typed right-nested pair layout.
Each path step follows the logical field shape and the runtime pair descriptor.

The shared probe also exposed a separate lowering defect: a selected short
unit constructor was turned into poison by the name-expression branch. That
branch must preserve the exact selected variant, just as a qualified expression
does. A lowering test checks the retained declaration identity.

The generic payload path now uses specialized field shapes. Whole-payload
carrier evidence applies only to a direct payload binding, not every binding
inside it. Alternative patterns bind the first successful alternative and run
the shared arm guard once. Unit subjects are evaluated without a local store.
Coverage distinguishes a selected short enum variant from a variable binding,
including inside products. A missing enum case remains a diagnostic.

## Checks

- Native parser first failed on the new syntax (1.719 seconds); initial parser
  support passed 291 tests (1.781 seconds).
- Native semantic checks: 4 tests passed, 9.366 seconds. Imported payloads retain
  exact field types and declaration identity.
- Native shared runtime probe: all 17 cases passed, 0.023 seconds. Cases cover
  nested payloads, rest, Unit, literals, alternatives, reference fields,
  whole-product bindings, one-time subject evaluation, one-time guards, and
  generic nested payloads.
- Self-host second hardening run: 303 tests and 64 failure records passed.
  The new emission corpus failed before emission on String equality evidence.
  Its fixture now explicitly opens `dew.std.string`.
- Self-host third hardening run reached lowering and exposed the short unit
  constructor defect described above. This remains a failed run.

Measured slow runs remain speed bugs, outside the requested implementation
scope: first hardening generation 95.194 seconds, first full run 100.891 seconds;
second full run 61.740 seconds; third full run 61.224 seconds. Debug-profile
generation took 21.999 and 21.592 seconds in the latter two runs.

- Final parser checks: 294 tests, 1.674 seconds; includes the 32/33-field limit.
- Full native suite: 984 tests, 123.584 seconds. Semantic work took 73.769
  seconds and backend work took 37.181 seconds; both remain speed defects.
- Integration suite: 268 tests, 49.324 seconds.
- Library lane: 326 tests plus shared execution cases, 15.047 seconds.
- Final self-host hardening: 306 tests, 64 exact invariant records, all existing
  corpora, and all 17 product cases; 61.710 seconds. The product probe took
  1.245 seconds.
- Public interface regeneration: 1.520 seconds, zero errors.

Intermediate failures also exposed missing explicit String/Option fixture
dependencies, short-constructor consumption, Unit root stores, and generic
pair-field carrier mismatches. Those failed runs remain in the local logs;
they were corrected rather than accepted as successful checks.

- Generated-source policy checks: passed, 16.611 seconds.
- Clean bootstrap: A/B/C builds and validations pass; B/C core and linked bytes
  match. Linked SHA-256:
  `adfe92e9f1967c887cdebe608db029d6c1faf00293b560531f5766f83cef3783`.
  A build took 39.203 seconds; A execution 44.077 seconds; B execution
  56.252 seconds. Each remains a speed bug, not a correctness failure.
