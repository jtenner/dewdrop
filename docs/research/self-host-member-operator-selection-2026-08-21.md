# Self-host member and operator selection

Date: 2026-08-21

## Scope

The Dew self-host inference layer now selects local members and operator-backed syntax after basic constraints and direct call selection.

Implemented behavior:

- local immutable and mutable field access;
- generic field-type substitution from nominal receiver arguments;
- field access on selected call results;
- explicit local struct construction;
- generic struct-construction argument inference;
- object-field target publication;
- missing, unknown, and duplicate construction-field diagnostics;
- inherent method selection;
- implementation-generic and method-generic instantiation;
- `Self` substitution for methods;
- local unit and tuple enum construction;
- generic variant argument inference;
- variant payload kind and arity diagnostics;
- trait-backed binary operator selection;
- generic operator implementation selection;
- canonical `IndexedGet` and `IndexedSet` selection;
- selected field, construction, method, variant, operator, and index targets.

Selection is delayed until basic expression, control, and root constraints exist. Direct calls and constructors run before method and field selection so receiver and expected-result types are available.

## Compiler-shaped safety fixes

This tranche exposed more stack-carried aggregate hazards in optimized compiler-shaped code:

- branch-selected local types were staged before Array writes;
- expression-selection and call-target enum values are built in named locals before storage;
- selected operator writes return immediately after the staged store;
- variant-selection indexes, declarations, and enum values are staged independently.

Production optimization remains enabled.

## Tests

Focused tests cover:

- local and generic fields;
- fields on call results;
- invalid and missing fields;
- generic struct construction and object-field targets;
- construction diagnostics;
- inherent methods;
- implementation and method generics;
- tuple and unit variants;
- payload kind and arity failures;
- trait-backed binary operators;
- generic operator implementations;
- index get and set traits;
- missing operator evidence.

## Remaining work

Imported member and callable selection, struct enum variants, variant and object patterns, implementation coherence, trait obligations and evidence, lambda families, module-value SCC inference, result compaction, and body flow remain before lowering.
