# Self-host semantic lowering completion

Date: 2026-08-21

The Dew compiler now produces a complete semantic lowering artifact for every HIR form currently emitted by the self-host parser and collection pipeline.

Completion work adds:

- local, lambda, and imported nominal identities;
- body and lambda local/capture plans with backend shapes;
- exact functional-loop control and transfer targets;
- local and imported module-value reads;
- selected operator calls;
- direct-call and constructor target consumption;
- local and imported builtin-call classification by exact builtin identity;
- local and imported lowering entry points;
- local and imported trait implementation evidence roots;
- deterministic flow diagnostic publication.

Builtin calls intentionally retain their exact compile-time builtin byte identity in the lowering artifact. The specialization/backend planner can map that identity to concrete WasmGC operations without runtime dispatch. This avoids duplicating the large generated standard builtin registry inside semantic lowering while preserving the same selected operation.

The lowering artifact owns or references all data needed by specialization: type layouts, module initialization, function ABI plans, merged type graphs, type arguments, shapes, calls, selections, patterns, locals, captures, flow, evidence, source offsets, and child arenas.

Trait prerequisite trees and declared generic-bound evidence are still an inference/evidence publication task. Lowering now carries the evidence arenas that the current inference phase publishes; later evidence completion does not require another lowering redesign.
