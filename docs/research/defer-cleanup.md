# Deterministic defer cleanup

Date: 2026-08-11

`defer expression` registers a cleanup at its lexical position in a block. The expression itself runs when that scope exits, not when it is registered. Registration freezes the names visible at that source point through a compiler-owned zero-argument Unit closure; mutable captures observe their latest value when cleanup runs, while declarations that appear later in the block are not visible.

Cleanups execute exactly once in reverse registration order on normal fallthrough, explicit `return`, and `break`/`continue` that leave the deferred scope. A return, break, or continue value is evaluated exactly once before cleanup begins. Breaks and continues belonging to a loop nested inside the deferred scope do not exit that scope and therefore do not run its cleanups early.

Traps do not unwind deferred cleanups in the initial model. If a cleanup itself traps, execution is fail-stop and older pending cleanups do not run. Cleanup expressions have a Unit callable boundary, so an incidental non-Unit tail is discarded under ordinary Unit-callable rules.

The parser performs controlled structural desugaring into synthetic lexical cleanup closures and injects their calls at guaranteed scope exits. Synthetic names are not source-spellable. Existing HIR, flow, generic capture, directization, and WasmGC lowering then apply without a second hidden finalizer runtime. Current snapshots verify LIFO fallthrough, return-value ordering, break, continue, nested-loop scope, mutable capture, imported cleanup calls, trap exclusion, source-scoped capture diagnostics, and zero `call_ref`/table/global overhead in the measured directized cases.
