# Next self-hosting blockers — August 16, 2026

## Status after the compiler-library tranche

The Array, FixedArray equality, deterministic Show, integer builder output,
diagnostic rendering, Arena, BLAKE3, explicit UTF-8 codec, and standalone
no-provider linker work is complete.

The path, filesystem, process, SHA-256, UTF-8, Facet adapter, package-codec, and
source-Bytes request tranches are complete. The generated production Starshine
object-model ABI, tokenizer, parser, semantic collection, flat HIR, local and
imported type resolution, alias normalization, signature-level module
interfaces, imported value names, lexical scopes, pattern bindings, loop
controls, lambda captures, deterministic derive expansion, imported semantic
recipes, rollback-capable local unification, the basic per-body inference
core, iterative generic signature instantiation, local direct callable and
overload selection, local fields, struct construction, inherent methods, enum
values, all local enum construction forms, local unit/tuple/struct variant
patterns, operators, indexing, imported generic calls, and imported generic
fields, constructors, variants, patterns, and generic inherent methods are also
complete. Implementation-head indexing, orphan checks, overlap checks, and
duplicate inherent-method checks, full local trait signature conformance,
generic specialization ranking, and coherent local dispatch are complete. The
imported implementation evidence merging is complete. The next compiler work
is prerequisite and generic-bound evidence trees and final lambda/body-job
merging and rebasing. Module-value dependency SCC scheduling, shared-SCC
inference with imported selections, frozen graph import into function solvers,
and successful basic body result compaction are complete.

## 1. P0: compiler host boundary

Implemented on August 17, 2026. `dew.std.path`, `dew.std.fs`, and
`dew.std.process` provide the bounded provider-neutral surface.
`dew.std.fs.wasi` and `dew.std.process.wasi` use Preview 1 Memory32 marshalling;
`dew.std.fs.facet` and `dew.std.process.facet` use the Facet 0.1 GC `array_i8`
profile through a checked-in static-link adapter. Compiler code can now read
arguments and environment values, inspect and modify files, publish atomically,
write separate output streams, and exit through typed errors and explicit
capabilities.

The audited production compiler has 89 direct host calls:

| owner | `@fs` | `@sys` |
|---|---:|---:|
| `src/standard_loader` | 25 | 33 |
| `src/dew_cli` | 2 | 29 |
| total | 27 | 62 |

The exact MoonBit operations are:

- `path_exists`: 11;
- `read_file_to_bytes`: 11;
- `is_dir`: 2;
- `create_dir`: 2;
- `write_bytes_to_file`: 1;
- `get_env_var`: 35;
- `set_env_var`: 21;
- `exit`: 5;
- `get_cli_args`: 1.

The 21 environment writes are not host requirements. The Dew port should replace
them with one explicit immutable `CompilerSessionConfig` passed to loader and
cache code.

### Delivered implementation batch

The launcher preopens one workspace root; compiler paths are normalized relative
paths under that root. Facet callers select an indexed preopen capability; the
Facet ABI does not allocate a mandatory scratch filesystem. See
[`self-hosting-host-modules-2026-08-17.md`](self-hosting-host-modules-2026-08-17.md).

Minimum operations:

- ordered arguments;
- one environment lookup with missing distinct from empty;
- complete bounded file read;
- complete partial-write-safe file write;
- path kind (`missing`, `file`, or `directory`);
- recursive directory creation implemented over `path_create_directory`;
- same-directory temporary write, sync, close, and atomic rename;
- removal of an explicitly owned file or empty directory;
- separate stdout and stderr writes;
- explicit process exit.

Every ordinary failure returns a typed `FsError` or `ProcessError` containing the
operation and stable provider error code. Only broken compiler invariants trap. Files larger than U32
must return an explicit size error.

Process spawning, recursive general-purpose deletion, package download, WAT
rendering, and Node execution remain launcher work.

## 2. P0: source-Bytes bootstrap request

**Current state:** implemented on August 17, 2026.

The private version 1 request now carries ordered logical source paths with exact
source Bytes, exact static-provider Wasm Bytes, dependency interface
expectations, an exact 32-byte bootstrap standard-library identity, an explicit
`CompilerSessionConfig`, compiler fingerprint Bytes, and status-only or output-file
response policy.

The codec enforces a 256 MiB request limit plus module, file, source, dependency,
provider, string, and fingerprint bounds. It rejects invalid tags, invalid UTF-8
names and paths, unsafe logical paths, duplicate records, truncation, and trailing
data. Source and provider payloads remain arbitrary Bytes.

The compiler request path constructs `ManifestFile` values directly from supplied
Bytes. It performs no source or provider file reads, does not mutate environment
variables, and uses an explicit uncached compiler pipeline for the first fixed
point. `tools/check-compile-request.sh` verifies valid Wasm and byte-identical
output from two physical directories while hostile ambient cache settings are
ignored.

See [`../compile-request.md`](../compile-request.md).

## 3. P0: production Starshine foreign ABI

**Current state:** completed on August 18, 2026. The pinned production provider builds with 3,366 concrete exports. Dewdrop selects an exact 32-export compiler subset, generates exact carrier declarations, and uses Starshine's typed `ffi_bridge` array, module, validation, and encoded-byte adapters from commit `664cafba9`. Starshine fixes `a7f0b6b05` and `f9e312013` closed the canonical defined-type equivalence and declaration-only element remapping bugs found by the first production link.

The deterministic BLAKE3 compiler fingerprint covers the pinned submodule revision, SHA-256 digests of the `lib`, `binary`, `validate`, and `ffi_bridge` interfaces, every selected export name and signature, and the exact provider bytes. The linked Dew smoke compiler reads the frozen source-Bytes request through WASI, verifies that fingerprint, parses the bounded `pub fn main() -> I32` smoke source, builds and validates one Starshine module, and writes byte-identical Wasm output in two physical directories. `src/starshine_guest/main.mbt` remains the small historical linker fixture; self-hosting uses the generated `starshine-mb/ffi` provider.

The production backend and linker still contain 8,820 direct Starshine package
references:

| owner | `@lib` references |
|---|---:|
| backend | 7,563 |
| core linker | 1,257 |

They name 671 distinct Starshine members. The remaining foreign package calls
also include five validation calls, three encodes, two decodes, and one module
pass.

The production boundary will mirror Starshine's public object model directly.
The public `lib` interface already provides stable nominal Core Wasm types,
section constructors, index wrappers, instruction constructors, `Module::new`,
and immutable `Module::with_*_sec` helpers. The `binary`, `validate`, and
`passes` packages expose the required module-level operations.

The pinned Starshine submodule now generates and owns the complete raw WasmGC
`#export_name` wrapper package under `starshine-mb/ffi/`. Dewdrop must consume
its export metadata and generate only matching Dew declarations plus typed
bridge helpers where Dew and MoonBit container or error representations differ.
In particular, use small typed array/builders and result inspectors rather than
introducing a second command language.

The generated provider bytes, the pinned Starshine submodule commit and package
interface digests, and every selected export signature must be inputs to the
compiler fingerprint. The build must fail on a missing export, signature mismatch,
validation failure, malformed result bridge, or provider digest mismatch.

## 4. P0 policy: compiler digests and caches

Dew-native BLAKE3 exists, but the MoonBit compiler still has 28 SHA-256 calls and
21 byte-to-hex calls across semantic caches, cache codecs, and the standard
loader.

For the first A→B→C fixed point, disable all persistent caches. This removes
atomic cache publication and cache-schema migration from the critical path.
Compiler and provider fingerprints still use BLAKE3 over exact ordered inputs.

After the fixed point, migrate unreleased compiler cache provenance and payload
checksums to BLAKE3 and add a direct lowercase hexadecimal renderer. Keep
SHA-256 package integrity in the launcher. Do not add a second Dew crypto
implementation only to preserve unreleased cache bytes.

## 5. P0 acceptance harness

There is no A→B→C fixed-point harness yet.

The first harness must:

1. use MoonBit Dewdrop to build linked compiler A;
2. invoke A with the frozen request and caches disabled to build linked B;
3. invoke B with the same logical inputs to build linked C;
4. require exact B/C byte identity;
5. validate A, B, and C;
6. run one tokenizer/parser/compiler smoke build through B and C;
7. run each stage in distinct physical directories to detect absolute-path
   leakage;
8. retain separate stdout, stderr, status, and artifact digests on failure.

The comparison covers final linked compiler bytes. The harness should also keep
unlinked root-module digests so a failure can be isolated to compiler emission or
foreign linking.

## Not blockers

- Product tuples and conventional loops remain optional porting choices. Do not
  promote them to P1 automatically.
- Process launch, package acquisition, recursive traversal/removal, lockfile
  updates, and WAT rendering remain in the launcher.
- SHA-256 package integrity may remain launcher-owned even though Dew now provides it.
- A Dew-native Starshine rewrite is not required.
- Persistent caches are not required for the first fixed point.

## Recommended order

The complete tokenizer and parser port finished on August 20, 2026. It parses the standard library, self-host sources, and successful module fixtures through the frozen in-memory source boundary.

Semantic declaration collection and flat HIR finished on August 20, 2026.

1. Complete body inference: prerequisite evidence trees and final deterministic lambda/body result merging and rebasing.
2. Complete final flow diagnostic ordering, then port layouts, specialization, optimization, and backend phases in dependency order.
3. Add the cache-disabled A→B→C harness.
4. Restore BLAKE3-based persistent caches, including parser-event persistence, after byte identity is stable.
