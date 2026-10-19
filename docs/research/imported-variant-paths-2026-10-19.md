# Imported constructor paths in the Dew compiler

The self-host transform request exposed a constructor-resolution bug. A call to
`@ast.ExprNode::Binary(...)` selected the correct constructor, but the checker
kept provisional unsupported-expression flags on `@ast` and `@ast.ExprNode`.
The later gate rejected those namespace prefixes as poisoned expressions.

The fix walks each prefix of a successfully resolved constructor path and clears
its provisional flag, as the native compiler already does. It does not clear
errors for an unresolved path or a namespace used as an ordinary value. The walk
uses constant extra memory and no new collection.

The focused Dew test file passes 24 tests. The new cases check an imported tuple
constructor and unit value, a wrong payload, and a namespace used as a value.
Generation took 8.440 s, linking 1.622 s, and execution 0.085 s. These are functional
checks, not runtime speed measurements. Logs are in `.tmp/imported-constructor-fix`.
The full bootstrap and real imported transform request are checked with the
feature completion record.

## Imported records

The request rejection checks found the same error for `@ast.FnNode::{...}`.
The record constructor had an exact imported struct type and valid fields, but
the struct-only branch poisoned the target without clearing the temporary
unsupported-expression flags on its namespace path.

Both local and imported record selection now use the same constructor-path
helper as enum selection. The helper runs after exact owner resolution. It only
consumes the written target path. Field type, missing field, and invalid target
errors remain active. A contextual record literal has no separate target, so
its value type stays intact. The walk uses constant extra memory.

Four added tests cover a qualified imported generic record and a contextual
record, a wrong field type, a missing field, and a bare record type used as a
value. The negative tests require the specific field or expression diagnostic.

The fixed source passes all 28 selected short inference tests. The saved
pre-record-fix source passes 27 and fails the new valid-record test with
`unsupported expression at 59`. The old source was supplied as one temporary
compiler input; the working source was not reverted.

Fixed-source generation took 8.615 s, linking 1.724 s, and execution 0.084 s.
The baseline took 8.383 s, 1.768 s, and 0.094 s. These single runs check
correctness and the 30-second compiler activity limit. They do not establish a
runtime speed change. The test module used the existing debug native test
generator and link fixture with the current Starshine FFI and facet adapter.
Logs and test exit status files are in
`.tmp/imported-record-fix/{fixed,baseline}`.

## Exact imported record kind

Final review found that `imported_declaration_is_struct` treated a resolved type
with no variants as a struct. That rule also matched foreign types, empty enums,
and type aliases. Clearing their namespace errors exposed this earlier gap in
the type-kind gate.

The gate now reads the exact frozen `source_kind` through the import scope's
existing `binding_for_declaration` lookup. Only `StructDecl` permits ordinary
record construction. The change removes the variant scan and adds no metadata,
table, collection, or allocation. Enum case construction still uses its exact
variant selection path.

New tests require `InvalidConstructionTarget` for an imported foreign type,
empty enum, and primitive alias. A positive test keeps imported empty structs
constructible. These cases also cover module-level values. Imported module-value
inference now retains the existing import scope, so it can use the same exact
kind check as function bodies. All three callers pass the scope. The only
remaining `None` scopes are the two inference entry points without imports;
the shared module-value input adapter preserves its caller's scope.

Existing generic and contextual record tests remain active. The extended test
module also includes imported semantics, lowering, and array-call tests.
All 67 tests pass with the fix. With the saved old kind gate, 64 pass
and all three new rejection tests fail because the required diagnostic is
absent. This compares the semantic gate; it does not claim that the old public
compiler could emit every invalid target successfully.

Fixed-source generation took 8.781 s, linking 1.672 s, and execution 0.098 s.
The old gate took 8.622 s, 1.597 s, and 0.096 s. These are single functional runs,
not evidence of a runtime speed change. Inputs used the existing debug native
test generator and link fixture, current Starshine FFI, and facet adapter.
Logs and test exit status files are in
`.tmp/imported-record-kind-fix/{fixed,baseline}`.
