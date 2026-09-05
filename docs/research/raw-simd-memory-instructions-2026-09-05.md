# SIMD memory instruction contracts

The final SIMD batch replaces partial memory aliases with 72 exact descriptors:
load splats, sign/zero-extending loads, zero-high-lane loads, and lane loads/stores.
Descriptors carry the opcode and lane index; memory arguments use the natural
alignment and zero offset, matching the scalar raw-memory contract. Stores have
two physical inputs and no result.

The native memory-section planner now consults opcode metadata generated from
the same catalog. A source target merely containing `_load` or `_store` no longer
counts as memory evidence. The positive opcode corpus exposed the missing
memory section before this fix; a negative spelling-collision test guards it.

The self-host emitter constructs exact `StarshineMemArg` values through the new
provider FFI constructor. It does not manufacture MoonBit's optional-memory
encoding. The pinned Starshine update `a045f4874` has a focused regression for
alignment and an offset above 32 bits, passing all nine bridge tests; FFI build
passes. Bindings, reference-carrier probes, and the compiler ABI fingerprint are
regenerated together. The Starshine commit skill kept this provider/API unit
separate from its Dewdrop consumer change.

Native validation passes all 362 fixed descriptors and three custom shuffles,
including every one-slot input/result mutation and invalid immediate diagnostics.
The native lane passes 791 tests in 78.552 seconds; rebuild times above 30 seconds
remain performance bugs. The shared byte-level execution corpus covers every
memory descriptor at unaligned and end-of-memory addresses, preserves unrelated
bytes/lanes, and requires out-of-bounds traps without partial writes.

Library execution passes 306 tests and all 432 memory checks in 21.180 seconds.
Self-host hardening passes, including the same 432 memory checks and all 362
fixed SIMD descriptors. Its 113.955-second build remains a performance bug.
Generated-source checks pass in 16.712 seconds.

The clean A/B/C bootstrap passes in 198.603 seconds. Compiler B and C have equal
raw and linked SHA-256:
`b6aeda6d8dace9a6fa0e2054b20709fba40691b6b6799c4fbfdd2fd50cc165ea`.
A and B execution took 68.008 and 72.952 seconds. These long runs remain speed
defects; the fixed point and instruction correctness checks pass.
