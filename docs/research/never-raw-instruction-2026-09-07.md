# Never: raw unreachable instruction

Both compilers now accept `builtin stop() -> Never = "unreachable"` and emit one
Wasm instruction. The preamble and generated Wasm facade use that target. The
old `dew_unreachable` alias is removed, including source fixtures.

The native opcode signature has no parameters and no physical result. This also
keeps the declaration on the inline path instead of making a `dew.unreachable`
host import. The self-host signature retains Never flow. Its verifier no longer
reads argument zero before it checks a known zero-argument signature; the
single-source lookup now belongs only to the unsafe-bitcast branch.

Tests check the exact instruction, zero host imports, module validation, and
self-host emission with an empty operand list. The existing shared Never tests
and all numeric invariant trap records exercise the new target.

The first native test failed with `UnsupportedBuiltin` (8.773 seconds). Changing
only emission exposed the planner's accidental host import. The new link check
covers that failure too. Initial fixture syntax and stale alias declarations
were corrected before the final run; no failing result counts as a pass.

Final measured checks:

- Native opcode/link regression: passed, 18.851 seconds for the filtered lane.
- Stdlib execution: 326 tests and all shared corpora passed, 22.811 seconds.
- Self-host hardening: 238 tests, 29 exact failure records, and all shared probes
  passed, 58.856 seconds. This run also includes the pending Array fixture update.
- Generated sources and CLI fixtures: passed, 15.777 seconds.

The hardening run remains a performance bug because it exceeds 30 seconds.
