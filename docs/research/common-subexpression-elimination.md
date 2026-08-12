# Immutable field common-subexpression elimination

Date: 2026-08-12

The whole-program optimizer reuses repeated scalar field extraction from the same immutable direct local when an earlier extraction is already stored in an immutable lexical local. Later direct extraction expressions become ordinary reads of that local. A duplicate immutable `let` is elided and all of its non-captured uses are retargeted to the first local.

Exact nominal-reference fields can now also be cached in an existing source local. Before considering a later nested scalar extraction, the optimizer recursively rewrites its aggregate base from a repeated outer field read to that nominal local; ordinary scalar field CSE can then reuse the inner cached scalar. This turns `outer.inner.value` into the existing `inner` local and then the existing `value` local without a scratch local, `local.tee`, or changed evaluation order.

Retained enum matches now also factor consecutive compatible guarded arms into one physical pattern extraction followed by a nested scalar conditional. The first arm's payload locals become canonical; later binding reads are retargeted through a bounded recursive pattern correspondence that supports tuple and struct payloads, nested tuple/struct destructuring, and same-shaped alternative patterns. Tuple children map by position, struct children by frozen field name, and alternative branches by source order after constructor/type compatibility checks. The variant remains allocated when it escapes through a call, but repeated tag/payload paths across the factored arms disappear. Guards remain source ordered and conditional; a pure nonconstant guard chain must end in an unguarded or constant-true arm. Mismatched alternatives/rest shapes, unknown/catchall relations, effectful guards, captures, and incompatible binding carriers remain conservative.

Mutable base bindings, captured aliases, generic or nominal-unknown references, Unit/Never results, arbitrary calls, allocation, collection reads, and uncertain cross-block control flow remain excluded. Adjacent expression operands are intentionally not assigned new scratch locals: measurements showed that `local.tee`-backed operand CSE reduced code size but made the Node hot path about 1–2% slower. The accepted form reuses storage already required by source code and introduces no scratch local or evaluation-order change.

The original Node and Wago runtime snapshot covers both adjacent field reads, which remain independent, and lexically separated reads, which reuse the first immutable local. Its WAT contains three `struct.get` instructions for four source-level field reads and no `local.tee`. `optimization/nested-common-subexpression-runtime` adds an exact reference chain; four source field reads become two Wasm `struct.get` operations, retaining only the initial `Outer.inner` and `Inner.value` loads.

`optimization/enum-payload-extraction-cse-runtime` covers both guard outcomes for an escaping variant, while its order-trap fixture constructs the retained variant from `unreachable` followed by integer division by zero; Node and Wago observe `unreachable`. The focused WAT budget reduces the retained match from seven `struct.get` and eight `ref.cast` sites to three and four respectively, with one surviving allocation and one tag dispatch. Nested and alternative fixtures cover recursive aggregate extraction and same-shaped constructor alternatives with the same runtime and trap-order contracts.

`tools/benchmark-common-subexpression.py` measured 64 extraction pairs across 10,000 tail-recursive iterations, 1,000 alternating warmed Node 26.3.0 samples, and batches of 10 calls:

| Form | Median | `struct.get` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| immutable lexical CSE | 64.591 µs | 1 | 891 |
| equivalent mutable-base baseline | 64.592 µs | 128 | 2,293 |

The measured runtime ratio was 0.9993x, effectively neutral at this scale, while static field-load sites fell by 127 and the module shrank by 1,402 bytes. A second 64-pair nested-reference benchmark measured 0.062 µs versus 0.163 µs (0.3803x), reduced `struct.get` sites from 130 to 2, and reduced Wasm from 1,769 to 1,113 bytes.

`tools/benchmark-enum-payload-extraction-cse.py` measured retained guarded payload sharing over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls. The direct shared form measured 0.0168 µs versus 0.0167 µs for a deliberately effectful-guard baseline (1.0060x), reduced `struct.get` sites from 7 to 3 and `ref.cast` sites from 8 to 4, and reduced Wasm from 613 to 551 bytes. Nested sharing measured 0.0176 µs versus 0.0177 µs (0.9949x), reduced `struct.get` from 11 to 6 and `ref.cast` from 12 to 7, and reduced Wasm from 681 to 598 bytes. Alternative sharing measured 0.0167 µs versus 0.0166 µs (1.0060x), reduced `struct.get` from 13 to 7 and `ref.cast` from 14 to 8, and reduced Wasm from 757 to 632 bytes. All three timing ratios are within the host-call noise floor; the static reductions are the primary contractual result. Broader CSE should remain bounded by exact alias/effect evidence and retained only when runtime measurements remain neutral or improve.
