# Qualified type-query guards

Both guard analyzers read the callee's direct name reference. A qualified
import call such as `@types.is_unit::<t>()` instead uses a qualified HIR
expression whose base is an imported module reference. The normal call checker
resolves its callable from the imported module's scope. Guard analysis did not
perform that lookup. Adding only the direct imported-value reference variant
did not fix this path; all four new Native tests still failed ordinary
inference after their source syntax was corrected.

As a result, a qualified type query did not refine a Unit or trait type in its
true branch, and did not mark a generic query condition as dependent. A valid
selected method in a branch could fail original checking with `NoMatchingMethod`
or `LocalTypeMismatch`. The root agent confirmed this while comparing qualified
and open-import forms of a generic selected-method source case.

The fix adds a shared guard-callee declaration helper in each compiler. For
qualified import expressions it uses the same import-scope lookup as the normal
call checker. It retains the existing unique local/open-import behavior and
rejects overloaded callable sets. Both guard fact collection and dependency
checks use this helper. It does not dispatch on an alias, module path, or source
function spelling. The imported member name is used only for normal scope
resolution, then the checked declaration ID selects the builtin contract.

Four new Native semantic tests and four matching standalone Dew tests cover:

- A qualified Unit query that permits a fixed Unit argument.
- A qualified integer query that defers a selected nongeneric method check.
- A qualified trait query that supplies selected method evidence.
- A qualified Unit query whose true-branch fact must not enter the false branch.

The test module exports query builtins under different source names from an
ordinary `app.queries` module. This checks declaration identity without a
standard-module path rule.

The implementation adds no per-call arrays, maps, or clone work. Native uses
the existing import indexes. Dew checks the cached query-target map before it
scans imported overload candidates, so ordinary imported calls skip that scan.
No speed or memory measurements were made.

Validation: `git diff --check` passed. The initial match-arm-only attempt failed
all four Native cases in ordinary inference; the final shared-lookup correction passed the Native and Dew cases listed below.
The review agent changed source; the root agent ran the shared build lane.

Native command:

```sh
DEW_NATIVE_TEST_PACKAGES=semantic/compile_time_qualified_guards_wbtest.mbt tools/test-native.sh
```

Dew standalone test source:
`self_host/compiler/semantic_compile_time_qualified_guards_test.dew`.


Final checks: all four Native semantic cases passed in 12.974 seconds. All four
Dew cases passed in the complete 91-test transform lane. That lane generated in
7.102 seconds, linked in 1.415 seconds, and executed in 7.713 seconds. Earlier
partial-fix and fixture failures remain described above; this result uses the
full checked qualified-callee lookup.
