# Experimental Starshine Wasm-GC static linker

## Status

Implementation experiment started on `experiment/starshine-wasmgc-static-linker`.
The linker is owned by Dewdrop. The adjacent Starshine-MB checkout is read-only.

This experiment links Core Wasm-GC modules directly. It does not use WIT, WITX,
the Component Model, the canonical ABI, JavaScript strings, or `externref`
adapters for foreign GC values.

## Provenance

- Dewdrop source commit: `970fccc89a6b64ba861037d4656a1edce5d13c18`.
- Dewdrop MoonBit dependency declaration: `jtenner/starshine@0.1.1`.
- `moon.work` resolves that package to the adjacent `../starshine-mb` workspace
  member.
- Adjacent Starshine-MB commit: `da15411f5bc171f2f16a69d6a8667789b26100b6`.
  The checkout already had unrelated uncommitted work and was not modified.
- Starshine package version at that checkout: `0.1.1`.
- Latest remote default branch observed through `git ls-remote` on 2026-08-15:
  `master` at `ecb3946c7c51bc146b5acca8736b37f33a327603`.
- MoonBit compiler: `moon 0.1.20260713 (75c7e1f 2026-07-13)` with
  `rr_moon_mod` and `rr_moon_pkg` enabled.
- wasm-tools: `1.251.0 (a1a178a02 2026-05-28)`.

No Starshine dependency update is required. The resolved 0.1.1 workspace package
already supplies the concrete `@lib.Module` type, binary decoder and encoder,
validator, pass registry, transactional hot pipeline, and the active module
cleanup passes needed by this experiment.

## Dewdrop boundaries inspected

- `src/compiler_driver/compiler_driver.mbt` freezes collect, analyze, lower, and
  program-link plans in `CompilerCompilation`. Before this experiment it only
  exposed binary emission.
- `src/backend/starshine_program_assembly.mbt` already has the useful module
  boundary `emit_starshine_program_module(...) -> @lib.Module`. Binary emission
  validates and encodes that module.
- Parser declaration dispatch treats `foreign impl` only as module-local orphan
  trait implementation evidence. The new string-literal form must be dispatched
  separately and must not add unrelated fields to `ImplDeclaration`.
- Semantic collection uses stable `DeclId` values whose high 32 bits identify
  the Dew module. This is suitable for nominal foreign brands.
- Frozen interfaces preserve resolved nominal declaration identities and are
  the cache boundary for public cross-module types.
- Program-level Wasm-GC linking in `src/semantic/program_physical_link.mbt`
  already plans recursive Dew type groups and dense program index spaces, but it
  does not merge separately decoded Core Wasm modules.
- Backend imports were selected from packed builtin names. WASI names were split
  during assembly. Static linking needs a structured module/field/kind identity
  before assembly.
- Existing WASI staging is a fast, bounded one-page implementation for only
  `fd_read` and `fd_write`. It uses offsets 0..65535 and exports memory only when
  those paths are reachable. The generic bridge must preserve this fast path.
- The CLI compile request is version 6. Exact output cache context currently
  includes Dew dependency-interface fingerprints, but not linked Wasm artifact
  hashes or a post-link profile.

## Starshine APIs inspected

Host Starshine means the MoonBit package used by the Dewdrop compiler. Guest
Starshine means the separately compiled Wasm-GC module linked into Dew output.
The generated Dew program must call guest definitions; host Starshine is only a
compiler implementation dependency.

The resolved package provides:

- `@lib.Module::new` plus immutable `with_*_sec` section assembly helpers;
- `@binary.decode_module(Bytes) -> Result[@lib.Module, DecodeError]`;
- `@binary.encode_module(@lib.Module) -> Result[Bytes, EncodeError]`;
- `@validate.validate_module(@lib.Module)` and traced validation;
- recursive type groups as `SingleRecType` and `GroupRecType`;
- typed index wrappers for every Core Wasm index space;
- `@passes.run_hot_pipeline`, `HotPipelineOptions`, registry lookup, and the
  complete registry through `pass_registry_all()`;
- active dead/unused/duplicate passes named `dead-code-elimination`,
  `dead-argument-elimination`, `dae-optimizing`,
  `duplicate-function-elimination`, `duplicate-import-elimination`,
  `remove-unused-brs`, `remove-unused-names`,
  `remove-unused-module-elements`, and
  `remove-unused-nonfunction-module-elements`;
- `strip-debug`, plus the current `shrink`/O4z preset;
- candidate validation and rollback in module passes and hot-function batch
  writeback. Trace messages include validation rollback and invalid-lower skips.

Starshine's remove-unused and duplicate passes contain broad index-remapping
logic. Most helpers are package-private, so the Dewdrop linker must own an
exhaustive remapper or use a future public Starshine remapping API. A default
instruction branch that silently preserves unknown indexed instructions is not
acceptable for the linker.

## Concrete MoonBit GC export proof

A temporary package at `.tmp/starshine-export-probe` used:

```moonbit
#export_name("module_new")
pub fn module_new() -> @lib.Module {
  @lib.Module::new()
}
```

with:

```text
pkgtype(kind: "foreign_library")
```

Commands:

```sh
cd .tmp/starshine-export-probe
moon build --target wasm-gc --debug
moon build --target wasm-gc --release
wasm-tools print _build/wasm-gc/debug/build/jtenner/starshine-export-probe/probe/probe.wasm
wasm-tools validate --features all _build/wasm-gc/release/build/jtenner/starshine-export-probe/probe/probe.wasm
```

Result:

1. MoonBit permits the concrete result signature when the function is `pub`.
2. Debug Core Wasm exports `module_new` as function 0 with
   `(result (ref $...starshine...lib...Module))`.
3. Release Core Wasm exports function 0 with `(result (ref 60))`; type 60 is the
   concrete Starshine `Module` GC struct type.
4. The value is not lowered to `externref`.
5. The compiler does not reject it as an FFI stub type.
6. The export keeps the wrapper alive in debug and release builds.
7. Debug name metadata retains an exact deterministic wrapper symbol before
   stripping.

Artifact observations:

- Debug wrapper artifact: 7,394 bytes.
- Release wrapper artifact: 1,560 bytes.
- Release SHA-256:
  `7cc6b43d6109e117f84c2206da3de8f33df9c23eab49765c4266a182ff1130c8`.

The required symbol-injection fallback is therefore not needed with the current
compiler. The Dewdrop-owned guest build tool will use direct `#export_name`
exports and will still decode, validate, inspect exact signatures, optimize,
validate again, and encode deterministically.

## Initial link architecture

The root Dew module uses synthetic final empty structs for foreign brands. Link
metadata maps stable Dew declaration IDs to those marker type indices and source
constraints. Static imports use module names of the form `link:<logical-name>`.

The pure Core linker receives already decoded and validated `@lib.Module`
values. It resolves exact exports, binds each marker to one symbolic provider
source type, plans recursive groups, allocates dense remap arrays, clones all
sections, replaces static imports with final direct function indices, validates,
and then runs the selected post-link profile.

Memory policy:

```text
memory 0   host/WASI scratch memory when needed
memory 1   Dew private memory when present
memory 2+  dependency private memories
```

Tables remain separate. A source `call_indirect` keeps its operand and receives
a remapped table immediate; it never receives an integer table-base adjustment.

## Baseline tool issue

A root-level `moon info` currently fails before this experiment's changes because
`src/dew_bootstrap` native platform helpers are unbound in the workspace-wide
information build. The first observed errors are
`bootstrap_platform_atomic_write` and `bootstrap_run_process`. Focused package
builds and the export probe work. This baseline issue is recorded so later test
claims do not hide it.
