# Self-hosting source-Bytes request — August 17, 2026

## Result

The first self-hosting boundary is now sealed as the private version 1 compiler
request.

The launcher sends exact ordered source and provider bytes. The compiler creates
its semantic manifest directly from those bytes. No source or provider payload is
materialized as a temporary file.

## Delivered

- Shared model and deterministic codec in `src/compile_request`.
- Strict UTF-8 for names and paths.
- Arbitrary Bytes for Dew sources, Core Wasm providers, and compiler identity.
- Exact module, file, dependency, and provider order preservation.
- Explicit `CompilerSessionConfig` for optimization, diagnostics, test planning,
  preamble policy, cache policy, and cache reporting.
- Exact BLAKE3 identity for the ordered embedded bootstrap standard sources.
- An uncached compiler-driver path that does not inspect or mutate cache
  environment variables.
- Direct request execution in `src/dew_cli`.
- A two-directory smoke check in `tools/check-compile-request.sh`.

## Frozen first-fixed-point policy

The first fixed point supports:

- optimized compiler planning;
- deterministic text diagnostics;
- optional test planning;
- explicit default-preamble policy;
- all persistent caches disabled;
- status-only check responses;
- output-file build responses.

A request cannot ask the compiler to discover packages, read source paths, read
provider paths, download data, launch child processes, or mutate lockfiles.

## Bounds

The request is limited to 256 MiB. It also limits modules, files per module,
total files, source payloads, dependencies, providers, provider payloads, names,
paths, and compiler fingerprint bytes. Decoding rejects unknown tags, invalid
booleans, invalid UTF-8, unsafe logical paths, duplicate records, truncation, and
trailing bytes.

## Validation

The MoonBit codec tests cover deterministic round trips, ordered data, arbitrary
non-UTF-8 payload bytes, invalid versions and tags, truncation, trailing data,
invalid UTF-8, oversized counts, duplicate records, unsafe paths, malformed
fingerprints, and stable standard identity.

The integration smoke runs the same logical request in two physical directories
with ambient cache variables set to enabled. Both outputs validate and are
byte-identical. No cache directory is created.

## Next boundary

The next blocker is the generated direct Starshine object-model ABI. The request
already carries exact provider bytes, so the typed Starshine guest and its digest
can be bound without changing the host discovery boundary.
