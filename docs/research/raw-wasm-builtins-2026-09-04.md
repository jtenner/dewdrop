# Raw Wasm builtin migration

## Contract

A builtin denotes one WebAssembly instruction with explicit immediates, or an
explicit unsafe cast. Packed-value convenience functions belong in Dew. Merely
copying library builtin declarations into `std/wasm/intrinsics.dew` is not a
migration. Native and self-host emission must check the same physical contract.

## Equal-carrier casts

`unsafe.bitcast` takes exactly one physical operand and produces exactly one
physical result of the same non-reference Wasm type. It emits no instruction.
It supports integer, floating-point, and vector carriers, but does not turn
`f32` into `i32`: that requires the actual Wasm reinterpret instruction. Reference
casts need heap-type and nullability proofs and are not accepted by this operation.
Unit, Never, missing carriers, and conflicting carriers are not cast certificates.
This is not a numeric conversion: it does not truncate, sign-extend, normalize a
narrow integer, or check a logical value range. Library conversions must express
those operations explicitly before applying a carrier cast.

Native generic inline cast calls now receive concrete specialized signatures.
Previously the specialization planner accepted only functions with Dew bodies.
Native emission reports `InvalidBuiltinSignature` with input and output types.
Self-host emission checks the frozen expression plans before scheduling the cast.
Neither check depends on the Dew function name or on a standard module path.

The preamble exposes `unsafe_bitcast<source, target>`. Its embedded native copy
is generated from Dew by `tools/generate_preamble_sources.py`; all preamble
source copies are now checked by `tools/check-generated.sh`.

## Verification

The initial native cast tests pass (10.218 seconds). They include packed 32-bit,
64-bit, and vector carriers and reject a changed width before Wasm validation.
The first self-host run passed all existing hardening tests and the new executable
packed-cast probe. Test generation took 102.143 seconds, including the native
release C build: this remains a performance bug. The cast execution probe took
0.220 seconds. Additional reference, erased-value, and negative self-host tests
are tracked with the implementation.

The final cast run passed 761 native tests, 94 self-host hardening tests,
16 invariant records, and 15 emitted execution probes. It includes the negative
self-host width test and native reference, floating-point/integer, and Unit
rejections. Logs: `/tmp/dewdrop-cast-native-final.log` and
`/tmp/dewdrop-cast-final-hardening.log`. Native semantic/backend lanes took
17.761/16.287 seconds. The tokenizer lane waited 39.958 seconds while another
native build was active; avoid concurrent native build lanes. Hardening test
generation took 97.650 seconds including the native C rebuild.

## Packed carrier migration

All ten SWAR modules now contain only Dew functions. The same carrier helpers
in all ten SIMD modules are ordinary functions: constructors between carrier
views, reinterpretations, loads/stores, and bitwise and/or/xor. The preamble SWAR
helpers are also Dew functions. Their raw scalar and vector operations use the
actual opcode targets `i32.and/or/xor`, `i64.and/or/xor`, `v128.and/or/xor`, and
`i32/i64/v128.load/store`. Memory immediates remain offset zero with natural
alignment hints; unaligned addresses retain Wasm semantics.

The old `dew_reinterpret`, SWAR identity, SWAR bitwise, and SWAR load/store
handlers have been removed from both emitters. Wasm-module compatibility
spellings for these APIs are ordinary Dew functions, not copied builtins.
The lane generator expresses these helpers directly as library functions;
it has no old-operation-name translation table.

Both compilers validate the 15 raw opcode signatures. The self-host also checks
the frozen body plan at planning and emission. Native forwarding optimization
strips only proved equal-carrier casts, then checks that each parameter is used
once in source order. It uses imported builtin metadata by declaration identity,
not by source spelling. This removes wrapper calls and boxing for these cases.
Wrong or unresolved casts are retained so that the verifier reports them.
Native forwarding uses a dependency worklist for chains of such wrappers. Each
declaration gains at most one proved opcode; only its dependent functions are
requeued. Cycles without a raw instruction remain ordinary functions. This
preserves the existing zero-wrapper contract for typed lane methods. A twelve
function, reverse-ordered dependency test covers convergence.

The self-host applies the same proof before replacing a direct call with its raw
instruction. It checks the frozen call recipe first and retains the physical
function for exported functions and function values. Fragment planning stores
the proof in `direct_builtin` once per declaration; call planning and emission
read that frozen metadata without rechecking the target body. The proof checks body
ownership, parameter-local identity, order, and exact declaration metadata.
It rejects receiver methods, generic wrappers, and repeated or reordered inputs.
An executable emitted probe also checks the Wasm text: the packed mask and raw
memory sequence must contain `i32.and` and no call instruction.

Three Python policy tests cover all 20 modules and reject restoration of old
handlers. Native tests cover exact raw signatures, user-defined declarations,
and single-opcode forwarding. The routine native suite passes 763 tests.
Log: `/tmp/dewdrop-packed-native-all.log`.

The SWAR parity lane passes 61,000 checks in 7.945 seconds. The memory round-trip
snapshot passes on Node and Wago. Its executable instructions are unchanged;
only cast signature entries and the already-existing compiler facts metadata
change in the stored Wasm text. Snapshot tool rebuilding took 93.256 seconds,
which remains a compiler-tool performance bug. The cached self-host forwarding
run passes 95 tests, 16 invariant records, and 16 execution probes in 12.663
seconds.

The final hardening run passes 96 tests, 16 invariant records, and 17 execution
probes, including function-value use and negative argument-order checks. Its
native test-tool rebuild took 90.206 seconds; emission probes took 0.872 seconds.
The routine native run passes 764 tests (semantic: 16.823 seconds; backend:
16.633 seconds). Logs: `/tmp/dewdrop-packed-hardening-final.log` and
`/tmp/dewdrop-packed-native-final.log`. The cached memory snapshot check takes
0.435 seconds. Seven focused native tests also pass in 10.670 seconds, including
native function-value use. The frozen-metadata hardening rerun passes the same
96 tests and 17 execution probes.

The first packed A/B/C bootstrap run validates B and C and reaches byte equality:
`85c3c2bd2c588259aea8220d28f8a5787e932d2953d97c5e79ffe96082eb64f4`.
A takes 37.000 seconds; A-to-B 62.908 seconds; B-to-C 63.843 seconds. These exceed
the performance limit. That run repeated target-body forwarding proofs at call
sites; the final implementation moves them to fragment planning. A final
bootstrap measures that change separately.

With frozen forwarding metadata and the native forwarding worklist, B and C
again validate and are byte-identical:
`f2c2c5073366566f26160ec718c77fe98ac1f554da000ab45ffe8197bef827c1`.
A takes 36.586 seconds; A-to-B 60.221 seconds; B-to-C 63.380 seconds. Moving the
proof avoids repeated body walks but does not resolve the bootstrap performance
bug. Log: `/tmp/dewdrop-packed-bootstrap-final.log`.

The complete native integration lane exposed stale signature/index snapshots and
two stale preamble counts from the new unsafe cast declaration. Those assertions
now include the two concrete cast signatures and the new declaration. The lane
also caught an actual extra-wrapper regression, fixed by the dependency worklist
above rather than relaxing its exact function-count test. Eight focused raw
intrinsic tests pass in 9.345 seconds.
All 266 integration tests pass across the full run and the corrected preamble
rerun. No measured integration file exceeds 30 seconds. The complete library
runtime suite passes all 291 tests in 14.658 seconds after a separate JSON loop
fix; repeated test compilation is byte-identical.

A final flow regression exposed an incorrect raw-operand check for a diverging
argument. `Never` is not a physical operand. The checker now omits the unexecuted
opcode's stack contract only when both the call and an argument have frozen
Never carriers and independently proven non-fallthrough flow. Missing plans and
ordinary concrete carrier disagreements still fail. This regression failed
before the fix; the hardening lane now passes all 97 tests and 17 execution
probes. Log: `/tmp/dewdrop-packed-never-hardening.log`.

The final routine native run passes 766 tests: semantic 17.566 seconds, backend
16.653 seconds, with every package below 30 seconds. Log:
`/tmp/dewdrop-packed-native-complete.log`. Preamble, lane, intrinsic, standard
builtin registry, and standard test source generation checks all pass.

The final full integration rerun passes all 266 tests in one run. The final clean
A/B/C bootstrap also passes after the Never-flow fix. B and C both validate and
have SHA-256
`90ad6b071005c2c2f93123d3d34025aaa18076ce92730fc5d3b828ffa76a1089`.
A takes 31.180 seconds; A-to-B 60.443 seconds; B-to-C 63.874 seconds. These remain
performance bugs, not a claim that the 30-second limit has been met. Logs:
`/tmp/dewdrop-packed-integration-complete.log` and
`/tmp/dewdrop-packed-bootstrap-complete.log`.

## Remaining migration

Audit scalar normalization, conversions, SIMD, memory, and math as well as the
collection and text runtimes. The existing intrinsic generator still copies
opaque operations; it must be replaced with an explicit operation inventory.
Array, Map, Set, ring-buffer, text, and host-call migrations are not complete.
