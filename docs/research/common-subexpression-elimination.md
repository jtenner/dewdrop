# Immutable field common-subexpression elimination

Date: 2026-08-12

The whole-program optimizer reuses repeated scalar field extraction from the same immutable direct local when an earlier extraction is already stored in an immutable lexical local. Later direct extraction expressions become ordinary reads of that local. A duplicate immutable `let` is elided and all of its non-captured uses are retargeted to the first local.

Exact nominal-reference fields can now also be cached in an existing source local. Before considering a later nested scalar extraction, the optimizer recursively rewrites its aggregate base from a repeated outer field read to that nominal local; ordinary scalar field CSE can then reuse the inner cached scalar. This turns `outer.inner.value` into the existing `inner` local and then the existing `value` local without a scratch local, `local.tee`, or changed evaluation order.

Mutable base bindings, captured aliases, generic or nominal-unknown references, Unit/Never results, arbitrary calls, allocation, collection reads, and uncertain cross-block control flow remain excluded. Adjacent expression operands are intentionally not assigned new scratch locals: measurements showed that `local.tee`-backed operand CSE reduced code size but made the Node hot path about 1–2% slower. The accepted form reuses storage already required by source code and introduces no scratch local or evaluation-order change.

The original Node and Wago runtime snapshot covers both adjacent field reads, which remain independent, and lexically separated reads, which reuse the first immutable local. Its WAT contains three `struct.get` instructions for four source-level field reads and no `local.tee`. `optimization/nested-common-subexpression-runtime` adds an exact reference chain; four source field reads become two Wasm `struct.get` operations, retaining only the initial `Outer.inner` and `Inner.value` loads.

`tools/benchmark-common-subexpression.py` measured 64 extraction pairs across 10,000 tail-recursive iterations, 1,000 alternating warmed Node 26.3.0 samples, and batches of 10 calls:

| Form | Median | `struct.get` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| immutable lexical CSE | 64.591 µs | 1 | 891 |
| equivalent mutable-base baseline | 64.592 µs | 128 | 2,293 |

The measured runtime ratio was 0.9993x, effectively neutral at this scale, while static field-load sites fell by 127 and the module shrank by 1,402 bytes. A second 64-pair nested-reference benchmark measured 0.062 µs versus 0.163 µs (0.3803x), reduced `struct.get` sites from 130 to 2, and reduced Wasm from 1,769 to 1,113 bytes. Broader CSE should remain bounded by exact alias/effect evidence and retained only when runtime measurements remain neutral or improve.
