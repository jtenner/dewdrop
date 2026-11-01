# Wave 1 item 08: lazy iterator adapters

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Branch: `worker/wave1-item-08`. No compiler rules or host APIs change.

## Contract

`iter_map`, `iter_filter`, `iter_take`, `iter_skip`, and `iter_enumerate`
return typed mutable wrappers implementing `Iter`. Construction does no work.
Wrappers share their state through aliases. Each wrapper stops permanently at
its first upstream `None`. Repeated terminal calls do no upstream work.
Map calls its callback once per item. Filter calls its predicate once per
pulled item, in source order, before the outer map sees accepted items.
Take uses a U32 count and does not pull after that count, including zero.
Skip discards at most its U32 count on the first request. Enumerate yields
`IterEntry<t> { index: U64, value: t }`, starting at zero; index wraps as U64.
No wrapper creates an array. Space is constant per adapter, excluding callbacks
and upstream storage. A filter request can scan the entire remaining input.

Example: `iter_map(iter_filter(array_iter(values), keep), transform)`.

## Checkpoint 1

Two new test cases specify laziness, callback order/counts and terminal state.
They require the new API, which is not yet implemented at this checkpoint.
Tests are intentionally red until checkpoint 2. No compiler command run yet.
