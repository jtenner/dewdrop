# Warm artifact investigation

Date: 2026-10-20.

## Ownership and state

Dedicated worktree: `/home/dev/Projects/dewdrop/.tmp/wago-investigation-2026-10-20/codec`.
Branch: `codex/wago-warm-codec`.
Base: `7997c86c36e05cfba4c4f39cabb026a318f55fc0`.

The existing GC reference-liveness safety patch is applied as an uncommitted prerequisite. Its paths are unchanged from `tools/wago-transform-host/patches/gc-frame-reference-liveness.patch`. It is not a candidate codec diff. The isolated-worker patch has not been applied because the current comparator does not instantiate workers or execute the guest.

Only the new `src/wago/codec_dew_diagnostic_test.go` is authored for this investigation. It is a local diagnostic, not an upstream candidate test. Nothing has been committed or pushed.

## Confirmed defect

Main7997 loses all four start-function fields in its compiled-artifact codec:
- HasStart
- StartIsImport
- StartLocalFunc
- StartImportIdx

Source facts:
- `src/wago/compile_metadata.go:392-399` sets start fields from the Wasm start section on fresh compilation.
- `src/wago/codec.go` has no reference to any of these fields. The metadata writer starts at :286 and the reader at :965.
- The decoded Compiled starts as zero state and no load step reconstructs a start function.
- `src/wago/instantiate.go:1953` runs the start only when HasStart is true. Local start uses :1980-1983; imported start uses :1959 onward.

The exact reproducer `.tmp/transform-workers/run-rvr6ozve/compiler.wasm` has 2,723,633 bytes and Wasm start function index 7227. This was read with a direct section/LEB byte parser; no compiler, build, or test ran. There is no name entry for this synthetic function.

Thus this exact compiler will lose its start on a main7997 cache hit. The source defect is confirmed. A control that keeps the start must still show that this is the complete cause of the observed long warm failure.

## Existing upstream fix: do not duplicate

The parent identified open [Wago PR 948](https://github.com/wago-org/wago/pull/948),
head `7cb262b5ea2ee548889b5633695bf15cbbec43ec`.
Its read-only diff is saved at
`.tmp/wago-investigation-2026-10-20/pr948.diff`.

The PR already:
- writes/reads all four start fields
- validates absent/negative/out-of-range/nonvoid start metadata
- invalidates old artifact format
- adds `TestCachedStartFunctions` for local and imported starts
- adds `TestCompiledCodecRejectsInvalidStartMetadata`

The PR also contains many GC performance changes and the liveness safety patch. A full-PR passing run would be useful, but a main+start-only control is the cleanest test of this one cause. There is no reason to make a duplicate start fix or PR.

The earlier bounded source review did not check start fields. Its statement that no small field defect was found is superseded by this exact check.

## Queued comparator test

The new diagnostic compiles the exact compiler once with p8/core3/explicit bounds, serializes/restores it in the same process, then compares source and decoded metadata without invoking a guest. It includes all four start fields and prints their values explicitly. It also compares code, active/passive data, types, signatures, globals, root maps, helper flags, and native GC ABI.

It skips if DEW_WAGO_COMPILER is not provided. With the explicit path below, every compile/load/error/difference remains a visible diagnostic failure. The recursive byte path compares by bytes/hash, not per-byte test logging.

Proposed command, supplied to parent before execution:

```bash
cd /home/dev/Projects/dewdrop/.tmp/wago-investigation-2026-10-20/codec
DEW_WAGO_COMPILER=/home/dev/Projects/dewdrop/.tmp/transform-workers/run-rvr6ozve/compiler.wasm go test ./src/wago -run '^TestDewCodecMetadataDiagnostic$' -count=1 -v
```

No Go build/test or guest benchmark has been run by this agent. The parent controls the CPU lane and should time this command, capturing stdout, stderr, status, and elapsed time outside production source.

## Link to the earlier expression-zero invariant

The reproducer declares 3,675 globals. Its start is separate from the exported `_start` (function1215) and `main` (function1216), so invoking `_start` does not by itself establish that the Wasm start section ran.

The Dew resolver has module-level task-tag lets0..7 in `self_host/compiler/semantic_body_name_resolution.dew:31-38`. `execute_task` tests the tag globals at :2005-2020. If start initialization leaves these globals at zero, a control task with its scalar argument0 can be treated as visit-expression0. For example the while-expression scheduler pushes enter/exit-control tasks at :1660/:1666 and the first control index is0. This matches the shape of the earlier bad expression0 record, but mapping those exact tag globals in the artifact has not yet been proved. It remains a causal lead until the start-preserving control passes.

## Next check

Use PR948's existing start test or its start-only subset in a separate diagnostic worktree, invalidate old artifacts, and repeat the exact Dew cold/warm request. Preserve the existing liveness/isolation prerequisites and compiler/request hashes. If both pass with the same output hashes, this explains the warm failure. A separate performance PR should then contain only a new confirmed cost that is not already in PR948.

