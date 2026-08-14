# Compiler performance review — August 14, 2026

## Scope

This review profiled the native compiler, persistent semantic caches, verified
whole-build cache, and representative one-module and 96-module incremental
workloads. Correctness, deterministic diagnostics, byte-identical outputs, and
fail-visible cache corruption remain mandatory; no durability or validation
checks were removed to obtain the measurements below.

## Findings

MoonBit release benchmarks show that ordinary semantic work is already cheap:

- basic inference over 256 functions: approximately **0.809 ms**;
- full basic-body pipeline over 256 functions: approximately **2.65 ms**;
- 256 direct calls: approximately **0.539 ms**;
- 256 generic calls: approximately **0.548 ms**;
- 17-way overload selection across 256 calls: approximately **0.686 ms**.

The JSON `InferredModuleBodies` artifact can be hundreds of kilobytes even when
the inference it replaces takes less than a millisecond. Reading, parsing,
validating, or rewriting those artifacts therefore dominated the work they were
intended to avoid. A 96-module chain made the problem especially visible because
100 small module artifacts were decoded independently.

The verified build-output cache had a separate bottleneck. Every hit rediscovered,
resolved, and restatted more than 700 compiler and standard-library files before
accepting an already memoized compiler fingerprint. Profiling attributed about
71 ms of an 86 ms invocation to compiler-fingerprint validation and regeneration.

## Changes

### Body-cache admission

Complete-module body inference is now opt-in through `--body-cache` or
`DEW_BODY_CACHE=1`. Declaration-family mode remains opt-in and implies the module
cache policy through `--body-family-cache` or `DEW_BODY_FAMILY_CACHE=1`.
`--no-body-cache` disables both.

This does not remove either executable-semantic cache format. It changes default
admission so the fast fresh inference path is used unless a workload owner has
measured a benefit. The verified whole-build cache remains enabled by default and
still bypasses compilation for exact repeated builds.

Family lookup now:

- builds one fingerprint map instead of scanning every bundle entry for every
  current body;
- precomputes declaration source ranges in file order instead of rescanning every
  declaration and method for every family;
- avoids duplicating ordinary family-enabled modules into the much larger
  complete-module cache;
- retains an existing context bundle on a partial miss instead of serializing and
  atomically rewriting the whole bundle for one changed declaration.

The last policy intentionally treats the bundle as a reusable baseline. A changed
family may infer again on another body-cache-only request, while unchanged
families continue to hit. The default verified output cache handles exact repeated
requests before this layer.

### Whole-build compiler fingerprint

The compiler-source fingerprint memo advanced to V3. The fast path now:

1. walks only the compiler-relevant path classes to obtain an exact sorted path
   list;
2. compares that list with the memo, detecting additions and removals without
   relying on directory timestamp resolution;
3. validates regular-file size, modification time, and change time with direct
   `stat` calls;
4. validates a checksum over the complete memoized manifest and fingerprint;
5. rehashes exact file contents whenever any path or metadata differs.

This preserves exact source hashing on every invalidation while avoiding repeated
`Path.resolve`, recursive glob, and file-content work on ordinary hits. Malformed
or incomplete memos are rebuilt rather than trusted.

## Measurements

All values are native wall-clock measurements from this checkout. Compiler-build
startup outliers were excluded by rerunning after the release compiler was warm.

### 96-module workspace chain

| Path | JSON body cache opt-in | Fresh inference default | Improvement |
| --- | ---: | ---: | ---: |
| cold caches | 2,168.577 ms | 1,008.709 ms | 53.5% |
| warm interfaces/parsing | 1,113.782 ms | 330.611 ms | 70.3% |
| private dependency edit | 1,114.196 ms | 333.639 ms | 70.1% |
| public dependency edit | 1,468.334 ms | 332.052 ms | 77.4% |

Outputs remained byte-identical. The default path is between **2.15x and 4.42x**
faster on this small-module workload.

### Parse-event workload

Isolating parse-event reuse with body caching disabled changed the measured
128-file workload from 248.878/156.646/165.604 ms to
189.847/118.919/118.872 ms for cold/warm/one-file-change builds. These are
23.7%, 24.1%, and 28.2% reductions while preserving the same parse-event hit and
miss behavior.

### Declaration-family opt-in path

For 192 private functions, one private edit still produced one miss and reused all
194 other ordinary root families across the library and root modules. The private
edit improved from **170.610 ms** to **154.463 ms** and a root-body edit improved
from **163.585 ms** to **147.540 ms**, roughly 9.5–9.8%. Fresh inference remained
faster at **104.839 ms**, so family persistence correctly remains opt-in.

### Verified whole-build hit

| Path | Before fingerprint fast path | After | Improvement |
| --- | ---: | ---: | ---: |
| verified output-cache hit median | 88.465 ms | 43.832 ms | 50.5% |
| ordinary compile median | 100.160 ms | 98.705 ms | — |

The final hit is 0.4441x the ordinary compile time. Ten samples produced
byte-identical 422-byte Wasm outputs and one verified build artifact.

## Remaining work

- Replace semantic JSON artifacts with a compact format before considering
  default admission again.
- Add phase timing, allocation, and peak-memory reporting so cache admission can
  use representative evidence rather than source-size guesses.
- Profile verified-output destination publication separately; atomic write and
  `fsync` are now a visible portion of the remaining hit time and must not be
  weakened without an explicit durability decision.
- Extend measurements to larger generic/evidence-heavy external packages where
  body inference may be expensive enough to justify persistent semantic reuse.
