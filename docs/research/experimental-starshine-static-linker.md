# Experimental Starshine Wasm-GC static linker

## Status

Implemented on `experiment/starshine-wasmgc-static-linker`. The linker is owned by Dewdrop. The adjacent Starshine-MB checkout remained read-only.

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
- The CLI compile request is version 7. It carries ordered provider/path pairs.
  Exact output cache context includes each provider and the BLAKE3 digest of the
  linked Wasm bytes.

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
- Initial one-export release SHA-256:
  `7cc6b43d6109e117f84c2206da3de8f33df9c23eab49765c4266a182ff1130c8`.
- Current reproducible fixture, with `module_new` and the String-adapter probe
  `module_new_named`, SHA-256:
  `617a2b758bbeb9655cace8a4600b20c573994016da350c72519d0a7ed72123a2`.

The required symbol-injection fallback is therefore not needed with the current
compiler. The Dewdrop-owned guest build tool will use direct `#export_name`
exports and will still decode, validate, inspect exact signatures, optimize,
validate again, and encode deterministically.

## Implemented link architecture

The root Dew module uses synthetic final empty structs for foreign brands. Link
metadata maps stable Dew declaration IDs to those marker type indices and source
constraints. Static imports use module names of the form `link:<logical-name>`.

`src/core_linker` decodes Dew and guest modules, resolves exact exports, binds
empty nominal marker structs to concrete guest GC types, drops marker groups,
allocates dense maps for every Core index space, and deeply remaps types,
instructions, globals, tables, elements, data, exports, starts, and memory
immediates. The instruction remapper has an explicit arm for every Starshine
Core instruction variant.

The linker validates each merged phase. It then runs Starshine's unused-module
element cleanup as a transaction: the cleaned candidate replaces the linked
module only after validation succeeds. Guest exports remain private by default.
The CLI syntax is:

```sh
dew build --link-wasm starshine fixtures/starshine_guest/starshine-guest.wasm \
  -o app.wasm app.dew
```

`CompilerCompilation::emit_linked_binary` exposes the same operation to compiler
driver users. Unresolved `link:<provider>` imports fail with a provider-specific
error.

Memory and table policy:

- Existing Dew memories keep their relative order and occupy the earliest
  available defined-memory indices, so a Dew host/WASI memory remains memory 0
  when the guest has no memory imports.
- Guest and dependency memories remain separate and all explicit and implicit
  memory immediates are remapped. The String adapter gets a private fixed
  one-page scratch memory.
- Tables remain separate. A source `call_indirect` keeps its operand and gets a
  remapped table immediate; it never gets an integer table-base adjustment.

The Dew String adapter recognizes MoonBit's concrete mutable `array<i16>` String
representation. It reads Dew's validated UTF-8 chunked String, counts UTF-16
code units, allocates the exact MoonBit array, decodes one-to-four-byte UTF-8,
and writes surrogate pairs for supplementary scalars.

## Reproducible guest and coverage

`src/starshine_guest` is a `foreign_library` package with direct
`#export_name` declarations. `scripts/build-starshine-guest.sh` builds release
Wasm-GC, validates it with `wasm-tools`, replaces the checked-in fixture through
a temporary file, and removes build output.

Coverage includes parser compatibility, foreign namespace inference and
receiver-free lowering, structured import codecs, exact marker replacement,
all-space instruction remapping, separate memory remapping, the Dew-to-MoonBit
String adapter, missing providers, bounded WASI schemas, CLI/compiler-driver
integration, and linker microbenchmarks. End-to-end output was validated with
`wasm-tools` for both `module_new` and `module_new_named`.

## Baseline tool issue

A root-level `moon info` currently fails before this experiment's changes because
`src/dew_bootstrap` native platform helpers are unbound in the workspace-wide
information build. The first observed errors are
`bootstrap_platform_atomic_write` and `bootstrap_run_process`. Focused package
builds and the export probe work. This baseline issue is recorded so later test
claims do not hide it.
