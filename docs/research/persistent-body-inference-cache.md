# Persistent module and declaration-family body-inference cache

## Status

Implemented as two opt-in deterministic executable-semantic cache layers:

1. `--body-cache` stores one complete `InferredModuleBodies` result;
2. `--body-family-cache` enables that policy and can recover unchanged root-body
   jobs when the complete-module key misses.

Both are disabled by default because measured end-to-end keying, I/O, validation, and
publication cost more than fresh inference on current one-module and 96-module
workloads. Exact verified whole-build output reuse remains enabled by default.

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

The default native path stores complete modules as `BMOD` entries in one
`.dew/cache/packs/v1-<graph>.dwp` file. `--no-cache-pack` retains the legacy path:

```text
.dew/cache/body-inference/v1-<key>.dbi
```

The version 1 semantic key is SHA-256 over:

- the private schema/domain marker;
- default-preamble policy;
- logical module path and stable module ID;
- manifest-ordered source paths and exact bytes;
- the transitive frozen interface and implementation-evidence fingerprint.

When body caching is enabled, an exact module hit remains the first lookup because
it avoids module-value and individual job assembly entirely. A private body edit
changes this key and may then fall through to declaration-family lookup.

## Declaration-family bundle

Family artifacts for one ordinary workspace or external-package module are
stored together as one `BFAM` pack entry. `--no-cache-pack` retains the legacy
path:

```text
.dew/cache/body-inference-families/v1-<context-fingerprint>.dbf
```

One atomic bundle avoids hundreds of small file opens and publications. Entries
are sorted by their 64-hex family fingerprint and contain the normalized root job
plus source-ordered nested-lambda jobs. Compiler-owned `dew.std.*` modules retain
complete-module caching only when that layer is enabled; their
generated/distributed sources do not use family bundles. Ordinary modules using
family mode are not duplicated into the much larger complete-module cache.

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

Complete-module and family-bundle version 1 payloads use canonical direct binary
schemas inside the shared checksummed artifact container. Family fingerprints
are raw sorted 32-byte digests followed by fixed offset/length index records and
concatenated bounded family sections. Lookup binary-searches the index and
decodes only the selected section. Unsupported versions, truncation,
non-canonical values, invalid UTF-8/tags, checksum/provenance mismatch, wrong
ownership, duplicate/unordered entries, malformed type graphs, and arena
mismatches fail visibly.


Both layers use same-directory atomic publication. Missing files or missing
family fingerprints are ordinary misses; malformed existing artifacts are never
silently ignored. Family lookup constructs one fingerprint map and declaration
source ranges are precomputed in file order. A partial miss retains the existing
context bundle rather than serializing and atomically rewriting the entire bundle
for one changed declaration; the bundle acts as a reusable baseline while exact
repeated requests are handled by the default whole-build cache.

## Controls and reporting

Complete-module persistence is opt-in:

```text
tools/dew check --body-cache ...
DEW_BODY_CACHE=1 tools/dew check ...
```

Declaration-family persistence is also opt-in and implies the body-cache policy:

```text
tools/dew check --body-family-cache ...
DEW_BODY_FAMILY_CACHE=1 tools/dew check ...
```

Without either option, `--cache-report` prints `body inference cache: disabled`.

The compiler host request is version 1. Family-cache, planning-cache, aligned
pack, and exact-program policies are transported explicitly to the MoonBit
compiler process.

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
functions. Editing one function produced **194 family hits and 1 family miss**
across the library and root modules, with byte-identical output. Map lookup,
precomputed source ranges, baseline-bundle retention, and avoiding duplicate
module artifacts reduced that edit from **170.610 ms** to **154.463 ms**; a root
edit fell from **163.585 ms** to **147.540 ms**. A body-cache-disabled median still
measured only **104.839 ms**, family-warm reuse measured **147.674 ms**, and a
compiler-warm cold-cache build measured **205.725 ms**.

These measurements show that deterministic granular reuse is correct but the
thin end-to-end cache path is not yet a performance win for tiny, cheaply inferred
functions. Family caching is therefore opt-in rather than a default regression.
The compact encoding now passes isolated speed and size gates. Future default admission still requires representative heavy-inference workloads where avoided inference exceeds complete keying, I/O, validation, and rebase cost.

## Remaining work

- Define a compact family-artifact encoding and an evidence-based admission
  policy before enabling family persistence by default.
- After Dewdrop is self-hosted and Dew supports parallel computation, schedule
  independent module/body work concurrently and merge diagnostics and artifacts
  in manifest/source order.
- Add compiler allocation and peak-memory measurements to cache benchmarks.
