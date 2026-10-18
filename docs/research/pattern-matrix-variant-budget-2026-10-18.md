# Charge pattern-matrix metadata work before collection

The matrix collected enum variants before charging their count. In Dew that
collection scanned all local and imported variants, including unrelated enums,
and allocated the output first. Nested imported enum classification could also
perform an uncharged full collection.

Matrix-only collectors now charge metadata visits before reads and charge the
result before materialization or append. Native collection uses existing owner
spans. Dew collection stops at the budget while scanning its existing arrays;
it retains no extra index. Matrix domains use frozen constructor identities,
with bounded imported-owner lookup, instead of unbudgeted type classification.
An exhausted work counter cannot resume on a later smaller request.

The ordinary complete-match fast path keeps its existing lookup behavior.
Tests use 32 unrelated variants and a small explicit budget to check early
exhaustion. The native control also proves that existing owner spans avoid
unrelated visits. The focused native flow file passed 45 tests in 7.535 seconds. The Dew
flow module passed 39 selected tests in 0.085 seconds after generation in
4.916 seconds and linking in 1.088 seconds. These include the direct budget
tests. The tests prove bounded work, not a whole-compiler memory claim.
