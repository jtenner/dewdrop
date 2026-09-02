# Dewdrop Starshine compiler facts v1

Date: 2026-08-31

Upstream frozen-v1 baseline: `5e46650e2ebef15efc0c8349751d371e53b48dc0` (`feat: freeze and consume compiler facts v1`). Dewdrop's submodule uses `c1923457dffe8cec9033f732d7e56ed7c2e6cf21`, which adds the existing self-host bridge compatibility commit, the typed Dewdrop compiler-facts bridge, and a stable self-host FFI surface on top of that baseline.

## Purpose

Dewdrop attaches Starshine's typed `compiler.facts` version-1 section after final Wasm indexes and function bodies are complete. Dewdrop does not copy the wire encoder and does not make a second metadata format.

The producer uses `jtenner/starshine/representation`, `OptimizationFactsBuilder`, `CompilerFactCustomSection`, and `Module::with_compiler_fact_custom_section`. Canonical body sites come from `@binary.compiler_fact_module_opcode_sites`, which uses Starshine's production encoder.

## Trust boundary

Dewdrop reports `ClosedModule`, not `ClosedProgram`. Exports are host-callable. Raw host-callable parameters do not receive source-only narrow integer assertions. Imported functions receive a broad conservative effect upper bound. Producer identity is diagnostic only.

Only a module built directly by Dewdrop is suitable for Starshine `TrustAssertions`. Arbitrary external Wasm must keep Starshine's default ignore policy.

## Current production

| Starshine fact family | Dewdrop source | Emission condition | Current consumer |
| --- | --- | --- | --- |
| ProducerInfo | `moon.mod` compiler version | Every linked program | Diagnostics |
| WorldFacts | final import/export boundary | Every linked program | Serialized |
| IntegerFacts / KnownBits | resolved primitive signatures | Internal parameters and all results where the source primitive is proved | Future range optimization |
| FloatFacts | final f32/f64 constant bits | Exact constant class is mechanically known | Future float simplification |
| ReferenceFacts | final `ref.func`, `ref.null`, and GC allocation opcodes | Structural proof | Exact-call materializer for function targets; future cast refinement |
| Function target sets | final `ref.func` and proven singleton closure flow | Complete singleton only | Exact-call materializer |
| EffectFacts | one canonical final-body scan plus direct-callee fixed point | Every final function; unknown operations widen to all effects | Future effect-aware passes |
| ParameterFacts | resolved callable signature and final local-use scan | Function has a source callable/body | Future escape/use consumers |
| ResultFacts | resolved callable result | One physical result with a provable value domain | Future refinement |
| FunctionBoundaryFacts | final exports and `ref.func` scan | Every final function | Future call-graph consumers |
| SignatureFacts | one implementation owns a final signature | Safe value facts exist; call sites remain incomplete | Future signature refinement |
| FieldFacts | final physical layout roles and mutability | Immutable field or exact enum tag | Future field propagation |
| GlobalFacts | final initializer and linker singleton plan | Defined global exists | Future global refinement |
| ExpressionFact | exact function reference, null, or allocation result | Canonical result site exists | Exact-call materializer / future refinement |
| CallSiteFacts | proven singleton target flow and signature match | `call_ref` target is exact | Starshine apply-compiler-facts |
| AllocationSiteFacts | final GC allocation opcode and physical kind | Nominal final type index exists | Future heap optimization |
| SourceProvenance | linked semantic function identity | Site belongs to a planned source function | Diagnostics |

## Deliberately absent or sparse

Float classes beyond exact constants, vector lane facts, closed type populations, arbitrary closed field contents, table completeness, fresh-result aliases, nontrivial no-escape allocation proofs, identity-unobserved, thread-confined, bounds facts, no-wrap facts, exact division, scoped relations, profiles, branch probabilities, likely-target hints, and loop-trip hints remain absent unless Dewdrop gains a direct proof source.

`None` always means unknown. Empty closed sets are never used as unknown. Unknown instruction effects widen to the full v1 effect mask.

## Index and site policy

Function facts use final absolute Wasm indexes, including imports. Type facts use `PlannedProgramWasmGCLink::physical_type_index`. Elided entities are skipped. Helper functions are counted from the final code section, not from an earlier linker count.

Dewdrop never computes LEB sizes. It resolves instruction identities from Starshine's canonical module opcode map after all bodies and helpers exist. Facts are attached last. Binary emission then encodes, decodes, and validates the fact-bearing module, and requires typed fact-section equality.

## Self-hosting

The self-host compiler uses a compact high-level Starshine FFI bridge: `ffi_bridge::module_with_dewdrop_compiler_facts`. The bridge constructs typed representation objects inside Starshine and exposes no bytes or enum tags. It emits producer/world records plus conservative function effects and boundaries. The native compiler emits the richer semantic and site facts described above. Every self-host generation attaches a valid fact section before validation and encoding.

## Audit and metrics

`starshine_compiler_fact_family_audit()` classifies each frozen-v1 family. `StarshineCompilerFactSummary` exposes counts and measured generation time to white-box tests without printing normal compiler output. Metadata size is measured as the encoded size difference between the fact-bearing module and the same typed module with its compiler-fact section removed.

Measured native white-box fixtures on 2026-08-31:

| Fixture | Core Wasm | Facts bytes | Functions/effects | Key facts | Fact generation |
| --- | ---: | ---: | ---: | --- | ---: |
| scalar `main` | 40 B | 107 B | 1 / 1 | 1 result range, 1 signature | 21 us |
| Bool/I8/U8/I16/U16 signatures | 152 B | 391 B | 5 / 5 | 5 ranges, 3 known-bit records, 5 signatures | 55 us |
| exact function singleton | 179 B | 322 B | 4 / 4 | 1 exact call, 2 function-target sets, 4 non-null facts, 2 exact heap facts, 1 allocation, 1 global | 68 us |
| struct allocation | 68 B | 186 B | 2 / 2 | 1 allocation, 1 non-null exact heap fact | 34 us |

A combined representative module was 210 B after custom-section stripping and 1,065 B with facts. This high percentage is expected for tiny modules and is visible so trivial per-opcode facts can be removed if larger artifacts show similar growth.
