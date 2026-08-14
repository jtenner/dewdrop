# Persistent type-layout and WasmGC-fragment caches

## Status

Implemented as one explicit opt-in planning-cache policy. The MoonBit compiler
can persist and restore:

1. backend-neutral `PlannedModuleTypeLayouts` values;
2. baseline module-local `PlannedModuleWasmGCFragments` values before
   whole-program generic specialization mutates them.

The cache is disabled by default. Enable it with:

```text
tools/dew check --plan-cache ...
DEW_PLAN_CACHE=1 tools/dew check ...
```

`--no-plan-cache` disables both layers. `--cache-report` prints layout and
fragment hit/miss counts.

## Artifacts and keys

The default native path stores type layouts in `LAYT` sections and baseline
WasmGC fragments in `FRG0` sections inside one
`.dew/cache/packs/v1-<graph>.dwp` file. `--no-cache-pack` retains the legacy
`.dew/cache/type-layouts/` and `.dew/cache/wasmgc-fragments/` files for migration
and comparison tests.

The layout entry key commits to the default-preamble policy, logical module path,
stable module ID, exact ordered module source, transitive frozen
interface/implementation-evidence context, and compiler producer fingerprint.

The fragment entry key commits to the module identity and exact source plus one complete program
context. That context includes root-module selection, production/test planning
options, every module path and stable ID, exact source digests, frozen interface
context, and body-evidence fingerprints. A program edit therefore invalidates
all baseline fragment artifacts. This is deliberate: whole-program optimization
can change module-local reachability, callback directization, trait flows, and
wrapper elision. Reuse is accepted only where the current deterministic identity
contract proves that the optimized module input is unchanged.

Type-layout artifacts can still hit independently for unchanged modules after a
private edit in another module.

## Binary schemas and rebasing boundary

Both payloads keep their bounded canonical binary schemas. By default they are
placed in 16-byte-aligned pack entries with full BLAKE3 provenance and payload
checksums. Legacy mode keeps the shared `DEWART\0\1` kind-8 and kind-9
envelopes.

The codecs use canonical varints, fixed little-endian IDs and offsets, explicit
checked enum/Boolean/option tags, strict UTF-8, bounded arrays and bytes, and
trailing-data rejection.

Layout records retain stable semantic IDs, source offsets, resolved type IDs,
field/variant spans, and value shapes. Fragment records retain only module-local
type, signature, function, trait, closure, and specialization arenas. Imported
and runtime function maps are rebuilt deterministically from decoded function
records rather than serialized in map order.

Cached fragments are baseline plans only. Lookup rejects artifacts containing
whole-program specialization shapes, evidence, or ABI keys. Final program type,
signature, function, global, and initializer indices are never cached; the stable
physical linker assigns them fresh. This keeps rebasing explicit and prevents a
module artifact from freezing program-global indices.

## Validation and failure policy

Lookup validates envelope kind, version, provenance, payload checksum, module
identity, planning mode, arena lengths, spans, local lookup tables, physical and
signature indices, trait dictionary/method references, function references, and
specialization evidence graphs. Missing files are ordinary misses. Existing
malformed, mismatched, truncated, or corrupt files fail visibly and do not fall
back silently.

Publication uses the existing flushed, fsynced, same-directory atomic writer.
Cold, warm, and private-edit builds are compared with cache-disabled builds for
byte-identical Wasm.

## Performance

Release-native microbenchmarks for one generated module with 256 structs and 256
functions measured:

| Operation | Mean |
| --- | ---: |
| fresh type-layout planning | 26.09 us |
| type-layout binary encode | 82.69 us |
| type-layout binary decode and validation | 97.21 us |
| fresh WasmGC fragment planning | 594.95 us |
| WasmGC fragment binary encode | 91.67 us |
| WasmGC fragment binary decode and validation | 153.25 us |

Fragment decode is about 3.9 times faster than fresh fragment planning. Layout
planning is already cheaper than persistence, so layout caching is a correctness
and reuse boundary rather than an isolated speed win.

`tools/benchmark-planning-cache.py` generated 512 structs and 512 functions. A
warmed native run measured:

| Build mode | Median/result |
| --- | ---: |
| cold planning cache | 156.915 ms |
| warm planning cache | 126.308 ms |
| planning cache disabled | 110.594 ms |
| warm/disabled ratio | 1.1421x |

The run produced four layout artifacts totaling 48,889 bytes and four fragment
artifacts totaling 115,050 bytes. The legacy warm filesystem path was 14.21%
slower than fresh planning. Phase-level planning reuse therefore remains opt-in.

The later unified pack keeps these entries for incremental misses but adds an
exact successful-program section. On the implemented 100-module startup
benchmark, that exact section avoids all planning and semantic decoding and is
substantially faster than both legacy phase files and fresh compilation. See
[`unified-aligned-cache-pack.md`](unified-aligned-cache-pack.md).

## Validation coverage

Permanent coverage includes:

- canonical layout and fragment round trips and byte-identical re-encoding;
- generic specialization and runtime-trait evidence payloads;
- invalid tags, truncation, trailing bytes, arena mismatch, and baseline-only
  fragment rejection;
- key sensitivity to source, interface, root, and planning mode;
- cold/warm CLI hit and miss reporting;
- disabled-by-default behavior;
- visible layout and fragment corruption failures;
- byte-identical cold, warm, private-edit, and cache-disabled Wasm;
- isolated release microbenchmarks and the generated end-to-end benchmark.
