# Ordering and comparator foundation

Date: 2026-08-11

`dew.std.ordering` defines the `Ordering` enum (`Less`, `Equal`, `Greater`) and explicit `Comparator<t>` evidence. `NaturalComparator` is available for types implementing ambient `Lt` and `Eq`; it compares with `<`, then `==`, and otherwise returns `Greater`.

The comparator trait remains outside the ambient preamble so heaps, trees, sorting, and binary search can share one explicit total-order contract without enlarging every module's implicit trait surface. Custom comparators can define domain-specific ordering and reverse/min/max policy remains a collection-level choice.

Comparator implementations used by ordered collections must be deterministic and total: antisymmetric, transitive, and consistent about equality. Natural floating-point comparison does not provide a total order for NaN; ordered float collections must use a future explicit total-float comparator or reject NaN by contract.
