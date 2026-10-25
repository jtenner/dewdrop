# Warm artifact source check

Date: 2026-10-20. Read-only source check. No builds or tests were run.
Source: `/home/dev/Projects/dewdrop/.tmp/wago-transform-host/build-y_uuvb8q/wago`.
References below are relative to that source root.

## Reported reproduction

The parent measured a passing cold full compile and a failing cache hit with the same source/request. Cold native compile was about 0.696 s and instance setup about 0.915 s. Warm module load was about 0.023 s. Both warm serial and warm parallel guest modes hit the compiler invariant before the transform worker phase. These are parent observations, not runs made by this scan.

## New liveness patch is compile-only

`tools/wago-transform-host/patches/gc-frame-reference-liveness.patch` adds `GCFrameRootPlan.AllReferenceLocals`. The list keeps a local typed as a collector reference even when local liveness removes its frame root.

- The list is filled before native codegen in `src/wago/gc_frame_roots_linux_amd64.go:162-168`.
- `shared.GCFrameRootPlan.TracksLocal` reads it at `src/core/compiler/backend/railshot/shared/gc_frame_roots.go:317-326`.
- amd64 native codegen calls TracksLocal at `src/core/compiler/backend/railshot/amd64/gc_struct.go:842`; ARM64 at `arm64/gc.go:938`.
- The runtime does not receive this compile plan. API compilation flattens the completed plan into `compiledGCFrameRoots` at `src/wago/api.go:2048-2070`.

Therefore the absence of AllReferenceLocals in the codec is expected. It is not evidence of a missing runtime root. The effect of the field is already in native bytes and finished offset maps.

The patch includes fresh-versus-codec GC tests:
`src/wago/gc_reference_read_amd64_test.go` and
`src/wago/gc_shared_reference_pressure_amd64_test.go`.
This scan did not run them.

## Runtime root maps appear symmetric

Writer: `src/wago/codec.go:783-806`.
Reader: `src/wago/codec.go:2210-2290`.
Both carry:
- adapter return offsets
- safepoint ID, frame byte count, and root offsets
- callsite return offset, frame byte count, stack adjustment, and root offsets

Both paths intern identical root-offset vectors. The cold path interns in api.go:2061/2065; the reader interns at codec.go:2254/2288.

The writer calls `validateCompiledGCFrameRoots` before write (codec.go:385).
The reader installs the decoded map and calls the same check (codec.go:1068-1075).
`installCompiledFinalizer` explicitly retains the decoded root and import-name maps
(`src/wago/code_mapping.go:94-108`).
`genericGCFrameRoots` finds that memo map at code_mapping.go:464-469.

No confirmed lost root-map field was found.

## Known cold/restored differences

1. The codec strips all direct-prepared marker bits from InternalEntry
   (`src/wago/codec.go:447-451`; masks at `src/wago/globals.go:1133-1154`).
2. It drops `preparedIsolatedTables` (`globals.go:1127-1130`).
3. It drops `independentInstances`, native stack capacity, and source quotas because they are runtime policy. Runtime instantiation supplies policy through options. In particular, `src/wago/instantiate.go:1540-1543` overrides the independent-instance flag when options include it.
4. Exact staged GC product enums are compile-only; codec reconstructs the generic helper execution flags (`codec.go:350-382, 987-1066`; `code_mapping.go:42-50`).
5. The cold metadata owner groups sidecars in one allocation (`code_mapping.go:53-77`). Decoded metadata has separate sidecar allocations.

Items 1/2 are a useful control but lower priority for this failure than a broad decoded-state comparison. Their normal consumers are PreparedFunction and prepared host entry selection (`prepared_function.go:150-170`; `instance_native_context.go:457-478`). The CLI uses `instance.Invoke`, and failure occurs before managed worker setup. A GC module with imports also does not qualify for the fully isolated prepared path.

## Checked omissions which are rebuilt

`syncHostSlots` is not written directly. However `src/wago/api.go:3883-3951` derives it from imported signatures and GC descriptors. It rejects a nonzero cold value that differs from the derived value. The same path sets a decoded zero value. Wide-host-frame codec coverage exists at `src/wago/gc_wide_host_frame_amd64_test.go:49-61`.

Register ABI disabled, dynamic funcref escape, and func-ref context header flags are written at codec.go:369-376 and read at :988-992.

GC type fields, including field kinds and offsets, element kind, size/alignment, reference flag, final flag, and supertype fields are written at codec.go:809-827.

Active/passive data bytes and global initializer discriminants have matching writer/reader paths (codec.go:695-733 and :1908-1997). No concrete data-loss case was found there.

## Next diagnostic controls

Do these only in the parent's private diagnostic copy.

First, compare a fresh Compiled with its immediate in-memory codec round trip, before invoking either one. Keep the same process, runtime options, request bytes, and source. Record:
- code byte length and SHA-256 (must match)
- Entry and decoded InternalEntry offsets (ignore the known marker removal)
- ordered GC descriptor hash, type/value-type hash, imported/local signatures
- ordered globals, active/passive data and element hashes
- GC root-map counts and hashes, including every field above
- helper product flags, native GC ABI, syncHostSlots, needsFuncRefContextHeader, dynamicFuncrefEscape
- effective runtime instance policy and actual collector config
- native module/instance context offsets after setup

A canonical metadata re-encode can supplement this check, but cannot reveal a field that the codec omits on both passes. Compare the source fields too.

Then use short, separate controls:
1. On a freshly compiled module, clear the direct-prepared marker bits and preparedIsolatedTables before publication. If it fails, the changed entry path is involved.
2. If it passes, run fresh and decoded modules in the same process with the same runtime/instance options. This removes process-start and cache-file selection differences.
3. Obtain the actual compiler invariant's failure payload. The saved warm log only names `self_host_assert_compiler_invariant_with_failure` and an unreachable trap. It does not name the failed assertion or show its input.

Do not add missing AllReferenceLocals to the artifact as a speculative fix. The runtime has no use for it, and no measured root-map difference currently supports that change.

