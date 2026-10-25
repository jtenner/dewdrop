# Current-main warm-cache review

Read-only review, 2026-10-20. No source edit, test, build, or timed process was run.
Reviewed source: `/home/dev/Projects/dewdrop/.tmp/wago-origin-main-2026-10-20/wago`.
Revision supplied by parent: `7997c86c36e05cfba4c4f39cabb026a318f55fc0`.
The parent reports that cold passes in 110.858 s and warm fails in 26.644 s with the same compiler/request/cache home. No fresh numeric invariant record was supplied for this main run, so the older preamble body694 diagnosis must not be treated as re-confirmed on main.

## Result

No confirmed small missing field, initializer, or relocation defect was found within this bounded review.

The source still supports a focused fresh-versus-codec state comparison. It does not support adding AllReferenceLocals to the artifact or weakening the compiler assertion.

## Checked paths

All references below are relative to the reviewed Wago source root.

- `src/wago/codec.go:872-896` writes adapter-return offsets, safepoint IDs/frame sizes/root offsets, and callsite return offsets/frame sizes/stack adjustments/root offsets.
- `codec.go:2331-2410` reads the same fields in the same order.
- `src/wago/code_mapping.go:112-126` preserves the decoded GC root map and import-name map when it resets validation memo state.
- `src/wago/api.go:3664-3695` reads into an owned CodeBuffer, validates metadata, transfers the mapping, then installs the decoded value.
- `code_mapping.go:780-814` transfers that value into the receiver and freezes execution metadata. The success path does not release the transferred mapping.
- `codec.go:899-917` writes every current gc.TypeDesc field, including field layout, alignment, final, and supertype flags.
- `codec.go:799-823` keeps global initializer discriminants/expressions or scalar bits.
- `codec.go:771-782` exports compact active data through activeDataAt; the standard Data list uses :785 onward.
- `codec.go:371-408` writes generic GC helper flags, native GC ABI requirement, dynamic reference flags, register ABI selection, and CPU requirements.
- `codec.go:1085-1188` restores these flags and root maps. Missing EH context anchor is derived from the recorded EH feature at :1099-1104.
- Host slot capacity is rebuilt from signatures and GC type descriptors in `api.go:3360-3428`, with a check against a nonzero fresh value.

## Real fresh/restored differences, not confirmed defects

The current codec still clears compiler-only InternalEntry bits at
`codec.go:514-518`, through `internalEntryOffset` at `globals.go:1180-1181`.

Current main includes more such bits than the old pin:
- direct-prepared variants
- bounded host/native scalar selections
- Go host dispatch tag support
- integer host context support

The Go host dispatch tag is a concrete change in runtime setup:
`globals.go:1184-1188` says only fresh output advertises it, and that untagged dynamic-wrapper fallback supports both generations.
`instantiate.go:838-844` sets tagged caller-context metadata only when the capability exists.
Thus this is a good A/B control, but the source does not establish a defect. The old-pin failure also predates these extra main-only flags.

Likewise `preparedIsolatedTables` and independent-instance policy are deliberately not serialized (`globals.go:1140-1147`). Exact staged GC product enums and native stack/source policy are compile-only sidecars (`code_mapping.go:44-52`). The generic product path is restored explicitly. These omissions must not be called missing semantic metadata without a triggering case.

AllReferenceLocals remains source/codegen-only. The old scan found that finished root maps already contain its emitted effect. There is no runtime consumer that would justify persisting this source list.

## Strongest remaining risk

Unverified: a fresh/restored metadata or instance-context difference changes reference handling, or different allocation/collection history exposes an existing liveness error. Equal native bytes alone cannot distinguish these cases.

The old numeric record identified a scalar expression ID0 during preamble name resolution. A task or HIR child can therefore be bad before the final invariant. Its source is a runtime-created guest object, not a guest object directly restored from the artifact.

## One focused test

In one process, compile the exact compiler Wasm once, serialize it, restore it immediately, and compare fields before either instance starts. Use identical Runtime and InstantiateOptions for both.

Compare raw code digest; Entry and masked InternalEntry; exact/ABI types and signatures; ordered GC type descriptors; ordered globals/data/elements; every finished root-map field; generic GC helper flags; native GC ABI; effective host slot capacity; actual collector setup; and native instance context/dispatch metadata. Re-encoding alone cannot detect a field omitted by the codec both times.

Then execute the same request on fresh and restored instances. If only restored fails, the differing state is a narrow target. If all semantic fields match, trace the first differing preamble resolver root/child/task scalar value across collection boundaries. Keep diagnostics separate from benchmark results.

No production correction is justified by this read-only review alone.

