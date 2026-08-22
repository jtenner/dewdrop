# Self-host bare-return flow fix

Date: 2026-08-22

The full bootstrap advanced beyond body inference and trapped in body-flow analysis. `SelfHostHirBlockItem::ReturnItem` stores `4294967295u32` when a source `return` has no value. `block_flow` passed that sentinel to `expression_flow`, which subtracted the body expression start and indexed outside `expression_flows`.

`expression_flow` now treats the optional-expression sentinel as neutral fallthrough flow. `block_flow` then sequences that neutral flow with the return flow, producing the same result as a value-return without attempting an expression lookup.

A regression test covers a `Unit` function containing only a bare `return`.

Validation:

- native tests: 730/730 passed;
- self-host semantic tests: 227 passed;
- parser corpus: 640 files passed;
- semantic corpus: 629 files passed;
- self-host smoke passed.

The full bootstrap now finishes body-flow analysis and reaches physical compiler emission. Its next trap is an out-of-bounds physical-plan lookup in the Starshine module emitter before compiler B is written.
