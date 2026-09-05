# Immediate-free SIMD instruction contracts

The first SIMD batch replaces 150 `dew_v128_*` compiler aliases with canonical
Wasm instruction names. This covers vector bit operations, splats, arithmetic,
comparisons, shifts, reductions, and floating-point operations. Public Dew
function names are unchanged. The preamble, typed lane modules, embedded
sources, and `dew.std.wasm.intrinsics` are generated from the updated sources.

`tools/wasm_simd_intrinsics.py` records each opcode, its single Starshine
instruction, its ordered inputs, and its result. A shared generator produces
the native emitter, both compiler signature tables, and validation fixtures.
These entries contain no library algorithms and no standard-module identities.

Raw instruction signatures now carry an input array, not `first` plus an
optional `second`. Both validators check every input. In particular,
`v128.bitselect` requires three V128 values, and vector shifts require V128
followed by I32. Existing scalar, memory, conversion, and unsafe-cast contracts
remain checked. Reference bitcasts are still rejected.

The native lane passes 789 tests, including all 150 generated SIMD cases. The
new test changes each physical input and result slot separately and requires
`InvalidBuiltinSignature`; it also validates the unmodified Wasm module.
The first rebuild took 93.410 seconds, with semantic and backend packages over
30 seconds. These remain measured performance bugs.

The self-host lane passes all 150 opcode compilation/validation cases, the
three-operand and shift negative cases, and the existing hardening and execution
checks. The first C rebuild took the complete lane to 123.768 seconds; the
150 source probes themselves took 0.072 seconds. Library execution passes all
296 tests and the conversion, memory, arithmetic, math, product, and callback
matrices in 18.508 seconds. Complete generated-source checks pass in 16.078 seconds.
Lane immediates, shuffles, cross-lane conversion instructions,
and partial vector memory operations remain the next SIMD batch; they are not
claimed complete here.
