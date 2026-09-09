# Direct compile-time queries in global initializers

## Defect and boundary

A global initialized by `if is_unit::<I32>() { answer } else { 42i64 }`
retained a false startup cycle. Native lowering removed the dead expression,
but kept the dependency graph computed during inference. Self-host query
lowering skipped global initializer bodies entirely because they have no
callable declaration record.

Source inference dependencies and runtime startup dependencies have different
jobs. The fix builds a fresh startup graph from selected logical expressions.
It does not edit source inference dependencies or remove source diagnostics.
The self-host folder now processes module-let bodies with empty type bindings.
Both compilers check body identity and owned arenas before scanning reads.

The self-host replacement uses root type IDs from the merged body type arena,
not indices from the earlier module-value solver arena. It preserves all other
module fields. Selected direct reads determine module-local ordering; the
existing selected-call traversal still determines cross-body startup ordering.

## Tests

- Native dead-self-read regression: the original graph keeps its self edge;
  the selected startup graph has no edge or cycle. Linking keeps one initializer.
- Native and self-host selected-self-read regressions: a true query branch
  retains its dependency and cycle diagnostic.
- Shared execution: direct Boolean and numeric query globals, a Unit
  `static_assert` global, and the removed-self-read branch.

## Measured runs

- Native regression before the fix: one intended failure, 9.335 seconds.
- First native fix: one pass, 28.624 seconds.
- Expanded native focused tests: two pass, 11.466 seconds.
- First self-host run: 654 tests, 286 exact records, all shared execution checks
  including 102 query cases pass, 176.872 seconds. Test generation alone takes
  120.597 seconds after the native source rebuild.
- Expanded self-host run: 657 tests, 288 exact records, and all shared execution
  checks pass, 69.400 seconds. The new one-field mutation tests check all nine
  fields for a missing body and an out-of-span root at phase 3. Another test
  checks that rebuilding dependencies leaves the earlier graph and diagnostics
  unchanged.

- Full native lane: 1,258 pass, 189.906 seconds.
- Native integration: 268 pass, 64.122 seconds.
- Library execution: 326 tests and all shared corpora pass, including the 102
  query checks, 35.989 seconds.
- Generated-source and policy checks pass, 17.809 seconds.

- Clean Node bootstrap passes, 183.591 seconds. Compiler B and C have identical
  raw and linked bytes:
  `38d97f6dd61723283f932d243749b5e652501910f3292fa6a0d8ecd588452687`.

Runs above 30 seconds remain speed defects; this change does not include speed
work. The older source SCC builder still needs complete input contracts;
arbitrary indirect-call startup effects and complete link freeze remain open.
