# Remove the unused runtime-function protocol

Native plans no longer contain `PlannedWasmRuntimeFunction`. The three runtime
lookup tables and their public lookup methods are removed. Both native and
provider empty text-runtime body files are deleted. Erased adapters retain
their explicit kind and target checks from the preceding change.

The version-1 codec rejects retired function-kind tag 2 with the exact error
`artifact.kind at byte 1: unknown Wasm function-kind discriminant`. It cannot
revive an old runtime request from cache. Import lookup maps are still rebuilt
from the decoded function table; no replacement runtime map or sentinel is
introduced.

The provider removes RuntimeFunctionBuilder and its three public methods.
Its seven Core bridge behavior tests remain unchanged. All 13 retired-name
rejection groups, with 100 names, move to native compiler tests. They now
check exact `UnsupportedBuiltin` errors at real emission instead of calling
a provider API that always returned false. A new provider API test verifies
the generated public interface has no runtime-builder protocol.

Existing algorithm policy tests inspect the live emitter/provider bridge
after the empty files are deleted. A new policy checks that the removed files,
kind, dispatcher, and lookup tables remain absent in source and public APIs;
missing source files are not silently treated as empty text.

Measured checks:

- Native policy baseline: 21 failures in 0.049 seconds; two tests pass after
  native removal in 0.043 seconds.
- Codec baseline: eight pass and one expected failure in 11.307 seconds;
  all nine pass after removal in 11.187 seconds.
- Native interface generation: 3.249 seconds.
- Updated native staging rejection: one pass in 8.242 seconds; write rejection:
  one pass in 0.023 seconds. Generated checks at this checkpoint: 19.022 seconds.
- Provider API baseline: one expected failure in 0.025 seconds; one pass after
  removal in 0.009 seconds. Interface generation: 0.729 seconds.
- Provider Core bridge: seven pass in 6.037 seconds. The 13 migrated native
  rejection groups all pass in 8.160 seconds.

The provider commit is `8d82581f5`, including its generated concrete exports.
The first provider build takes 9.385 seconds and consumer refresh 3.981 seconds.
After including the generated export files in the provider commit, the final
build takes 9.356 seconds and refresh 3.945 seconds. The provider exports 4,185
concrete functions; the consumer still selects 473. Remaining Core signatures
are preserved semantically; physical heap metadata and fingerprints are refreshed.

Broad checks so far:

- Library checks pass in 36.492 seconds, including 53 Bytes and 47 String
  execution checks.
- Self-host hardening: 875 tests, 457 exact failure records, and all shared
  execution and semantic probes pass in 86.167 seconds.
- Routine native: 1,307 tests pass in 283.998 seconds. The 13 migrated
  rejection groups increase the native count while leaving their coverage
  intact.

- Integration: 270 tests pass in 99.360 seconds.
- Generated checks initially fail in 0.463 seconds because the WASI source
  policy also scanned negative tests for the rejected opcode. It now permits
  opcode names in test fixtures while still banning the old body helper
  everywhere. A second run fails in 1.849 seconds at a remaining split-path
  read of the deleted provider file. That check now reads the live bridge.
  The complete generated lane passes in 12.621 seconds.

- Pinned provider: 10,981 tests pass in 287.468 seconds. Its count drops by
  exactly the 13 rejection groups moved to native compiler tests; none of
  their 100 input names are lost.

- Stress: all 15 tests pass in 0.358 seconds.

- Clean A/B/C bootstrap passes in 210.199 seconds. Core and linked comparisons
  pass; B/C raw and linked SHA-256 are both
  `dfc316cd64f3efae3d0568efd413a2a22c1454bbe0b50d79e2e47ca6f7075502`.
All runs over 30 seconds remain timing defects; speed work is deferred.
Source-identity/Array layout recovery, full ABI/shadow-stack closure, solver
checks, and phase snapshots remain separate audit work.
