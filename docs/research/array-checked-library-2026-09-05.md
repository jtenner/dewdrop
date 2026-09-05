# Checked Array operations in Dew

`array_get`, `array_set`, and the iterator's `array_iter_next_option` are
ordinary Dew functions. Bounds tests, Bool results, and Option construction
now reside in `std/array.dew`. The registry no longer selects these three
operations by standard declaration ordinal. Their generated source is current.

The physical storage primitives remain unchanged in this batch. Fifteen
legacy Array builtin declarations remain; storage, growth, and iterator
state still need migration. Unused legacy lowering variants/builders also
remain for the later removal pass. This batch is not full completion.

## Correctness checks

- Unit arguments run once, including a rejected indexed write.
- Unit reads and iterator results still distinguish Some from None.
- Scalar and tuple payloads keep their values through reads and iteration.
- Invalid indices trap where required. Unknown fixture case IDs cannot
  silently pass another case.
- The shared native/self-host array corpus now has 17 checks. The existing
  319 library tests and all other execution matrices also pass.
- The debug-emission test now checks Option allocations in the Dew callee
  and a call in the loop. It does not require a compiler-owned inline loop
  expansion.
- The array policy tests check that every migrated operation is a source
  function and that no standard module restores its removed builtin target.

The migration exposed constructor evaluation loss, source-order changes,
stored tuple result unpacking, and a raw-read source-name collision. The
compiler fixes and full validation results are documented separately in
`constructor-evaluation-order-2026-09-05.md`.

All 794 native and 266 integration tests passed. Generated checks and clean
A/B/C bootstrap passed; B/C SHA-256 is
`397d8dccf306cc5318521f73a97b9dff617002fd109390b983317a9208c50b4f`.
The final complete self-host hardening lane passed in 17.928 s, including
161 tests, 27 numeric records, and all execution probes.

## Follow-up source test

Both parsers currently reject a nested anonymous tuple pattern written as
`Some((left, right))`. The tuple execution test uses the accepted equivalent:
`Some(value)` followed by `let (left, right) = value`. Keep the nested-pattern
parser discrepancy visible and add a reduced grammar regression in the
remaining correctness work.
