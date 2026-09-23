# Starshine refresh, 2026-09-23

## Update

- Previous Dewdrop pin: `de52f1d140323c738836f7fad07ac80b574a91d1`.
- Rebased Starshine commit: `2d66d47a2` on remote `master` at `4038b15de`.
- Generated FFI surface: 4,216 concrete exports and 27 explicit wrappers.
- Dewdrop consumer metadata was regenerated from the final provider binary and
  submodule revision.

## Compatibility changes

The current provider keeps unused MoonBit file-system and `spectest` imports.
The Node Facet runner now supplies fail-visible stubs for unknown host imports.
Any call to one of these stubs throws with the full module and import name.

The self-host specialization planner previously rooted every implementation
method. This pulled the compiler-owned Debug writer and its WASI import into the
next compiler generation. Compiler-owned implementation methods now become
reachable only through normal semantic evidence, which matches the native
planner.

## Validation

- `bun ffi check`: passed in 5.209 seconds.
- Final `bun ffi build`: passed in 11.851 seconds.
- `tools/test-native.sh`: passed in 298.541 seconds.
- `tools/test-integration-native.sh`: passed in 77.333 seconds.
- `tools/check-self-host-bootstrap.sh --fast`: passed in 68.339 seconds. The B
  and C compiler hashes were identical.
- `tools/test-starshine-native.sh`: one exact test failed. The same failure was
  reproduced on the untouched `4038b15de` remote baseline:
  `run_cmd_with_adapter tuple-optimization keeps chained host-copy tail-live0
  source lanes live through downstream tees`. It expects `local.set 15`.

The native, integration, self-host bootstrap, and full Starshine lanes exceed
the repository's 30-second compiler activity limit. Keep these timings visible
as performance defects.
