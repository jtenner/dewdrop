# Explicit erased-adapter function kinds

Both native adapter producers now use `PlannedWasmErasedAdapterFunction`, not
`PlannedWasmRuntimeFunction(b"")`. The emitted signature, target field, and
conversion recipe remain unchanged. Adapters no longer overwrite the empty
key in the old runtime lookup maps. Those unused runtime maps and the retired
runtime kind/provider rejection protocol remained separate cleanup work at
this checkpoint. The subsequent [protocol retirement](runtime-protocol-retirement-2026-09-09.md)
removes them.

Program emission selects the adapter body by its explicit kind. A read-only
semantic lookup supplies its unique, non-elided physical target. Missing,
negative, removed, duplicate, self-referential, or inline-only targets cannot
select the first candidate.
The emitter maps an absent unique target to `MissingFunction` with the adapter
declaration. Standalone module emission rejects this program-only kind.

The version-1 function-kind codec records the new kind with discriminator 10.
Module-cache validation rejects it with an exact diagnostic: a module fragment
has no program adapter target certificate. Codec round-trip and rejection
tests cover this boundary.

The regression baseline reports 44 passes and one expected failure in 23.747
seconds. The initial implementation passes all 45 linker tests in 23.845
seconds. Valid adapter Wasm emission passes in 9.249 seconds, and eight codec
tests pass in 11.372 seconds. An initial backend mutation-test draft correctly
failed to compile because semantic records are read-only outside their owning
package. Target mutations now live in semantic tests; the backend uses the
same read-only target query in production.

The final 45 target/link tests pass in 23.774 seconds. Scoped semantic/backend
interface generation passes in 3.299 seconds. An initial workspace-wide
`moon info --target native` attempt fails in 3.904 seconds because `moon info`
also checks canonical backends and reaches bootstrap platform code outside
these packages; the scoped command is the correct interface-generation lane.

The full routine native lane passes all 1,293 tests in 276.429 seconds.
Integration passes all 270 tests in 90.663 seconds. Generated checks pass in
18.984 seconds. Clean bootstrap passes core, raw, and final B/C comparisons
in 166.342 seconds. Both final compiler hashes remain
`5940d074ae4d8f250bc3e9396a565c1c8be2d39e0b6d7586ac261f8b05b6d74e`,
unchanged from the preceding self-host runtime retirement.
Activities over 30 seconds remain timing defects. No speed work is included.
