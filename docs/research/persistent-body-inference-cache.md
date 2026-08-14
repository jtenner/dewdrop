# Persistent module body-inference cache

## Status

Implemented as a bounded first executable-semantic artifact: one complete
`InferredModuleBodies` result per collected module. This tranche intentionally
keeps imported-signature translation and body name resolution fresh, then reuses
only the deterministic inference/evidence arenas after validating them against
the current collected HIR.

The module boundary was chosen before per-declaration jobs because current lambda
capture inference imports types from enclosing body and earlier lambda jobs, while
module values are inferred through source-ordered SCCs and then merged into one
module arena. Caching complete modules avoids introducing unstable rebasing or
partial dependency protocols. Per-body reuse remains a later refinement once
module-value and lambda-capture fingerprints are explicit.

## Artifact identity

Artifacts live at:

```text
.dew/cache/body-inference/v3-<key>.dbi
```

The V3 key domain invalidates earlier artifacts after bare pattern-variant resolution was extended through imported expected enum types. V2 previously invalidated pre-method-alias artifacts after transparent-alias qualified dispatch and method-local bound evidence changed.

`DEW_CACHE_DIR` replaces the complete `.dew/cache` root. `dew clean` therefore
removes these artifacts with the other project-local caches.

The V3 key is SHA-256 over:

- a private schema/domain marker;
- the default-preamble policy;
- logical module path;
- exact module source digest, including stable module ID, manifest-ordered file
  paths, and exact file bytes;
- the module's transitive frozen `interface_fingerprint`.

The interface fingerprint commits to local public signatures and coherent
implementation evidence plus the reachable imported public-interface graph.
Consequently, a private dependency body change whose public interface remains
unchanged preserves a dependent module's body key, while any relevant public
signature/evidence change invalidates it. The changed module itself always gets a
new key because its exact source digest changes.

## Payload and validation

The semantic package serializes `InferredModuleBodies` as deterministic JSON
behind a private payload magic. Exact arrays include:

- module-value SCC/type results;
- implementation index and diagnostics;
- body and lambda result/type spans;
- expression, local, capture, block, pattern, and control types;
- construction/member/call/operator/map targets;
- trait-object coercions and recursive evidence forests;
- diagnostics in deterministic merge order.

The cache envelope stores independent SHA-256 digests for the key, exact source,
interface provenance, and payload checksum. Lookup rejects unsupported versions,
truncation, malformed UTF-8/JSON, schema mismatches, checksum failure, provenance
failure, module identity mismatch, body/lambda identity mismatch, and HIR arena
length mismatch. These are visible cache errors, never silent misses.

Publication uses the same native same-directory atomic writer as parser-event and
workspace-interface artifacts. A missing key is the only ordinary miss.

## Controls and reporting

Body inference reuse is independently controlled by:

```text
tools/dew check --no-body-cache ...
DEW_BODY_CACHE=0 tools/dew check ...
```

`--cache-report` prints:

```text
body inference cache: hits <n>, misses <n>
```

or:

```text
body inference cache: disabled
```

The compiler host request is V3 because it now transports the body-cache policy
explicitly between the Python bootstrap host and MoonBit compiler process.

## Determinism and invalidation

Fresh and cached inference feed the same immutable `AnalyzedProgramModule`
construction and all later lowering, optimization, specialization, physical
linking, validation, and encoding phases. Module execution order remains the
frozen dependency-SCC order; only the inference calculation within each module
is replaced by a validated artifact.

Permanent validation covers payload round trips, envelope provenance/checksum
failures, source/interface key sensitivity, cold/warm reports, disabled mode,
fail-visible corruption, and byte-identical cached/uncached Wasm. The benchmark
`tools/benchmark-body-inference-cache.py` measures a generated multi-module
workload across cold, warm, private-body-change, and root-body-change builds.

A representative native run with 192 generated private functions measured a
warm median of **140.943 ms**, a one-module private-body change at **153.630 ms**,
and a root-body change at **147.956 ms**. The first cold invocation took
**68,846.424 ms** because it included native compiler build/startup work; it is
not a steady-state compilation threshold. Warm builds reported **5 hits/0
misses**; each changed build reported **4 hits/1 miss**, and the changed cached
Wasm was byte-identical to a body-cache-disabled build.

## Remaining work

- Split the module artifact into module-value SCC and declaration/lambda job
  artifacts only after exact capture and evidence dependencies are fingerprinted.
- Define deterministic rebasing for layout and WasmGC fragment artifacts.
- Schedule independent module/body work in parallel and merge diagnostics and
  artifacts in manifest/source order.
- Add compiler allocation and peak-memory measurements to cache benchmarks.
