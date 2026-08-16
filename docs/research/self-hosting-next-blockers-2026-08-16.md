# Next self-hosting blockers — August 16, 2026

## Status after the compiler-library tranche

The Array, FixedArray equality, deterministic Show, integer builder output,
diagnostic rendering, Arena, BLAKE3, and standalone no-provider linker work is
complete.

The next work is not another broad standard-library batch. It is the runtime and
bootstrap boundary needed to run a Dew compiler, plus the production Starshine
foreign ABI.

## 1. P0: compiler host boundary

Ordinary Dew source still exposes only `fd_read` and `fd_write` through
`dew.std.wasi`. It cannot read arguments or environment values, open paths,
inspect files, create directories, rename files, remove owned cache entries, or
set an exit status.

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

### Required implementation batch

Add a compiler-owned `dew.std.host` module backed by bounded WASI Preview 1
bridges. The launcher preopens one workspace root; compiler paths are normalized
relative paths under that root.

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

Every ordinary failure returns a typed `HostError` containing the operation and
stable WASI errno. Only broken compiler invariants trap. Files larger than U32
must return an explicit size error.

Process spawning, recursive general-purpose deletion, package download, WAT
rendering, and Node execution remain launcher work.

## 2. P0: source-Bytes bootstrap request

The current private compile request is version 7. It contains source file paths
and static-link provider paths. This still makes the self-hosted compiler repeat
host discovery and file reads, and it carries cache policy through environment
mutation.

Freeze a new request before porting the CLI:

```text
version
command and output kind
root module
ordered modules {
  module name
  ordered files { logical path, source Bytes }
}
ordered dependency interface expectations
ordered static providers { logical name, exact Wasm Bytes }
selected standard sources or exact bootstrap standard identity
explicit CompilerSessionConfig
compiler fingerprint Bytes
output path or response mode
```

Required bounds include total request bytes, module count, files per module,
individual source bytes, provider bytes, string bytes, and trailing-data
rejection. UTF-8 is strict for names and logical paths; source bodies and Wasm
remain arbitrary Bytes.

The request must not contain package-discovery instructions. The launcher owns
manifest resolution, package integrity, source ordering, and provider selection.

## 3. P0: production Starshine foreign ABI

The static-link mechanism is implemented, but the production guest ABI is not.
`src/starshine_guest/main.mbt` currently exports only `module_new` and
`module_new_named` for linker coverage.

The production backend and linker still contain 8,820 direct Starshine package
references:

| owner | `@lib` references |
|---|---:|
| backend | 7,563 |
| core linker | 1,257 |

They name 671 distinct Starshine members. The remaining foreign package calls
also include five validation calls, three encodes, two decodes, and one module
pass.

Two designs are possible:

1. Generate hundreds of exact foreign exports and Dew declarations mirroring the
   Starshine object model.
2. Define a small versioned command-tape ABI over packed byte arrays. Dew owns
   deterministic operation order; the compiled guest executes Starshine
   construction, validation, decode/encode, and the required linker operations.

Use option 2. It keeps the typed foreign surface small, avoids one cross-module
call for every instruction node, and makes the exact ABI easy to fingerprint.
The tape must have bounded counts, strict tags, exact integer widths, no native
pointers, typed error envelopes, and byte-identical repeated output.

The compiled guest bytes, tape schema version, and every declared export
signature must be inputs to the compiler fingerprint. The build must fail on a
missing export, signature mismatch, malformed response, validation failure, or
provider digest mismatch.

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
- SHA-256 remains necessary for package integrity only; the launcher can own it.
- A Dew-native Starshine rewrite is not required.
- Persistent caches are not required for the first fixed point.

## Recommended order

1. Freeze the source-Bytes request and explicit `CompilerSessionConfig`.
2. Implement `dew.std.host` and its WASI bridge tests.
3. Freeze and generate the Starshine command-tape foreign ABI.
4. Build a linked smoke compiler that reads one request and emits one module.
5. Port tokenizer and parser against in-memory source Bytes.
6. Port semantic and backend phases in dependency order.
7. Add the cache-disabled A→B→C harness.
8. Restore BLAKE3-based persistent caches after byte identity is stable.
