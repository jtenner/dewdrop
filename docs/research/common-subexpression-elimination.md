# Immutable field common-subexpression elimination

Date: 2026-08-11

The whole-program optimizer now reuses repeated scalar field extraction from the same immutable direct local when an earlier extraction is already stored in an immutable lexical local. Later direct extraction expressions become ordinary reads of that local. A duplicate immutable `let` is elided and all of its non-captured uses are retargeted to the first local.

Mutable base bindings, captured aliases, reference/generic/Unit/Never results, arbitrary calls, allocation, collection reads, and uncertain cross-block control flow remain excluded. Adjacent expression operands are intentionally not assigned new scratch locals: measurements showed that `local.tee`-backed operand CSE reduced code size but made the Node hot path about 1–2% slower. The accepted form reuses storage already required by source code and introduces no scratch local or evaluation-order change.

The Node and Wago runtime snapshot covers both adjacent field reads, which remain independent, and lexically separated reads, which reuse the first immutable local. Its WAT contains three `struct.get` instructions for four source-level field reads and contains no `local.tee`.

`tools/benchmark-common-subexpression.py` measured 64 extraction pairs across 10,000 tail-recursive iterations, 1,000 alternating warmed Node 26.3.0 samples, and batches of 10 calls:

| Form | Median | `struct.get` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| immutable lexical CSE | 64.591 µs | 1 | 891 |
| equivalent mutable-base baseline | 64.592 µs | 128 | 2,293 |

The measured runtime ratio was 1.0000x, effectively neutral at this scale, while static field-load sites fell by 127 and the module shrank by 1,402 bytes. Broader CSE should wait for explicit alias/effect summaries and should be retained only when runtime measurements remain neutral or improve.
