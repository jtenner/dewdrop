# Self-host compiler performance

Date: 2026-09-04

## Measured baseline

`tools/check-self-host-bootstrap.sh --fast` measured compiler A execution at
72.583 seconds. This is a compiler performance bug because it exceeds the
30-second project limit.

The warm native gate completed in 17.179 seconds. After rebasing the Starshine
submodule onto its updated remote, the dependency rebuild made the same gate
take 36.061 seconds. The backend lane took 17.510 seconds and the compiler
driver lane took 8.084 seconds. The cold aggregate is also a tooling
performance bug because it exceeds the 30-second project limit.

## Direct function ownership lookup

`self_host_linked_function_declaration_module_matches` scanned every linked
function for each call candidate. The program link planner already stores each
function at its logical function index.

The lookup now uses one checked array access. It checks both the unsigned
array bound and the stored index identity before it accepts the module owner.
The change adds no map and no retained memory.

Measured compiler A execution after the change:

- before: 72.583 seconds;
- after: 67.300 seconds;
- reduction: 5.283 seconds, or 7.3 percent.

## Next index

Expected nominal and expected carrier recovery repeatedly scan every later
expression in a body. Some queries also scan every call argument or every
block item. The next module should build one body-scoped reverse-use index.

The index must use compact parallel `Array<U32>` storage. It must keep all
uses, preserve parent and argument order, distinguish direct ownership from
transparent block wrappers, and reject cross-body edges. This changes repeated
parent discovery from O(expressions × arguments) to O(actual uses) after one
linear build.

Do not add the index until constructor correctness reaches a fixed point. A
topology index must preserve the current proof edges before it replaces the
scans.

## Binaryen lane

`tools/check-self-host-bootstrap.sh --fast --binaryen` applies pinned local
`wasm-opt` settings to A, B, and C. It measures optimization time and raw and
optimized sizes. Run this lane after the unoptimized B → C fixed point passes.
