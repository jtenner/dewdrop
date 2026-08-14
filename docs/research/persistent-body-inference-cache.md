# Persistent module and declaration-family body-inference cache

## Status

Implemented as two deterministic executable-semantic cache layers:

1. the default complete-module cache stores one `InferredModuleBodies` result;
2. an explicit declaration-family cache can recover unchanged root-body jobs when
   the complete-module key misses.

A declaration family is one non-module-value root body plus every nested lambda
whose `root_body` is that body. Nested lambdas remain atomic with their root
because capture types are imported from root locals and earlier parent-lambda
jobs. Module values continue to infer in deterministic dependency-SCC order and
are never independently restored by this layer.

The semantic inference engine already isolates root and lambda jobs behind
solver resets and merges them in source identity order. The family cache exposes
that existing boundary, normalizes job-owned IDs for persistence, restores a
mixture of cached and fresh jobs, and feeds the ordinary deterministic merge.

## Complete-module artifact

Complete module artifacts remain at:

```text
.dew/cache/body-inference/v3-<key>.dbi
```

The V3 key is SHA-256 over:

- the private schema/domain marker;
- default-preamble policy;
- logical module path and stable module ID;
- manifest-ordered source paths and exact bytes;
- the transitive frozen interface and implementation-evidence fingerprint.

An exact module hit remains the first lookup because it avoids module-value and
individual job assembly entirely. A private body edit changes this key and may
then fall through to declaration-family lookup when that layer is enabled.

## Declaration-family bundle

Family artifacts for one ordinary workspace or external-package module are
stored together:

```text
.dew/cache/body-inference-families/v1-<context-fingerprint>.dbf
```

One atomic bundle avoids hundreds of small file opens and publications. Entries
are sorted by their 64-hex family fingerprint and contain the normalized root job
plus source-ordered nested-lambda jobs. Compiler-owned `dew.std.*` modules retain
complete-module caching only; their generated/distributed sources do not use
family bundles.

The context fingerprint commits to:

- default-preamble policy, module path, and stable module/body/declaration IDs;
- the location-independent frozen body-evidence fingerprint, including concrete
  semantic IDs and resolved private/public signature structure;
- transitive imported interface and implementation evidence;
- the complete interned name table;
- ordered body identities and kinds;
- ordered lambda parent/root ownership;
- exact source bytes for every module-value declaration.

Changing module values, signatures, generic bounds, overload identities, name-ID
allocation, lambda ownership, or visible evidence therefore selects a different
bundle. Source locations are intentionally excluded so inserting expressions in
one private body does not invalidate later unchanged public or private bodies.

Each family entry additionally commits to the exact declaration source range.
The range begins at the declaration location and ends at the next declaration in
the same file or at end of file. Editing one function or method therefore changes
that family fingerprint while preserving independent families under an unchanged
context.

## Normalization and deterministic merging

`BodyInferenceJobResult` is now a serializable package boundary. Before a family
is stored, the compiler normalizes:

- call-expression IDs;
- function-value call-target expression IDs;
- expression and pattern IDs embedded in diagnostics;
- expression/pattern constraint-origin IDs;
- absolute source offsets, relative to the owning declaration.

Lookup validates ownership and every root/lambda arena length, type graph,
applied/function type span, selection/type-argument span, call span, trait-evidence
span/index, coercion index, and job-local expression reference before rebasing IDs
and offsets into the current collected HIR. Invalid artifacts return a visible
cache error rather than indexing malformed arrays.

Fresh and restored jobs enter the same `merge_body_inference_jobs` path. Forward,
reverse, and shuffled root-job orders produce equal family artifacts and exactly
equal `InferredModuleBodies`. Cached diagnostics and nested lambda captures are
covered across changed preceding expression ranges.

## Payloads and fail-visible publication

Complete-module and family payloads use private deterministic JSON schemas behind
separate magic headers. The family bundle envelope binds the context provenance
and payload checksum. Lookup rejects unsupported versions, truncation, malformed
UTF-8/JSON, checksum/provenance mismatch, wrong module ownership, duplicate or
unordered entries, incompatible body/lambda owners, malformed type graphs, and
arena mismatches.

Both layers use same-directory atomic publication. Missing files or missing
family fingerprints are ordinary misses; malformed existing artifacts are never
silently ignored.

## Controls and reporting

Complete-module reuse remains enabled by default and is controlled by:

```text
tools/dew check --no-body-cache ...
DEW_BODY_CACHE=0 tools/dew check ...
```

Declaration-family persistence is deliberately opt-in:

```text
tools/dew check --body-family-cache ...
DEW_BODY_FAMILY_CACHE=1 tools/dew check ...
```

The compiler host request is V4 so the Python host transports the family-cache
policy explicitly to the MoonBit compiler process.

Without family reuse, `--cache-report` prints:

```text
body inference cache: module hits <n>, module misses <n>, family disabled
```

With family reuse enabled it prints:

```text
body inference cache: module hits <n>, module misses <n>, family hits <n>, family misses <n>
```

`--no-body-cache` disables both layers.

## Validation

Permanent coverage includes:

- complete-module and family payload round trips;
- bundle sorting and duplicate rejection;
- exact source, module-value, lambda-family, signature, and evidence key changes;
- one-body invalidation with unchanged later-body ID/offset rebasing;
- nested-lambda capture reuse;
- cached diagnostic expression and absolute-offset rebasing;
- forward, reverse, and shuffled mixed hit/miss merging;
- malformed type-graph and owner rejection without aborting;
- envelope provenance/checksum failures and visible CLI corruption failure;
- byte-identical family-cached and body-cache-disabled Wasm;
- cold, warm, private-body-change, and root-body-change benchmark reporting.

A representative native run on August 14, 2026 generated 192 tiny private
functions. Editing one function produced **193 family hits and 1 family miss**,
with byte-identical output. The family-enabled build measured **174.689 ms** while
a body-cache-disabled median measured **109.100 ms**; warm exact-module reuse
measured **157.792 ms**, and a compiler-warm cold-cache build measured
**225.209 ms**.

These measurements show that deterministic granular reuse is correct but the
current JSON artifact path is not a performance win for tiny, cheaply inferred
functions. Family caching is therefore opt-in rather than a default regression.
Future default admission requires compact encoding and representative workloads
where avoided inference exceeds decode/rebase cost.

## Remaining work

- Define a compact family-artifact encoding and an evidence-based admission
  policy before enabling family persistence by default.
- Define deterministic rebasing for layout and WasmGC fragment artifacts.
- Schedule independent module/body work in parallel and merge diagnostics and
  artifacts in manifest/source order.
- Add compiler allocation and peak-memory measurements to cache benchmarks.
