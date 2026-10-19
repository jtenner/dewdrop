# Compile request source pool

## Defect and source selection

A Dew transform can generate an import after the initial request manifest has
been built. The bootstrap request fixture previously packed only a fixed list
of standard modules. Imports outside that list could not find their source.
Putting every standard module in the manifest would also parse and check unused
modules.

Version 1 compile requests now have a separate `source_pool`. It holds the same
module/file records as `modules`, but does not make those modules active. The
native uncached pipeline and the Dew request pipeline follow leading imports
from active modules, append matching pool modules, and follow their imports.
Initial module order remains fixed. Unused pool bytes are not parsed or checked.
Wildcard imports follow the existing descendant match rule.

Dew resolves the closure before transform source checking and after expansion.
The initial selection can defer the two transform API modules until ordinary
API source injection. The strict selection reports the missing module and the
source file. Newly selected modules can also have transforms. Expansion repeats
only when selection appends a module, and is bounded by the pool module count.
Intermediate output retains callable transform declarations while target
annotations are removed. A final strip pass removes those declarations without
executing old targets. API reuse requires the exact recorded module index and
canonical module, file, path, and source bytes; reserved API names in a pool are
invalid. Selection does not read host files or call a second Wasm instance.
User modules and standard modules use this same Dew resolver.

## Wire format

The optional extension follows `compiler_fingerprint`:

1. Source pool module count, as little-endian U32.
2. For each module: name string, file count, and files in their given order.
3. For each file: logical path string and source byte string.

Strings and bytes keep the existing U32 byte-length prefix. EOF directly after
the fingerprint means an empty pool, so old requests still decode. New encoders
write the count even when the pool is empty. The total module, file, source, and
request bounds cover both active and pooled records. Duplicate module names
across these lists are invalid. The root must be in the active module list.
Source bytes stay opaque during decode, including unused invalid UTF-8 bytes.

## Packing selected sources

The bootstrap fixture preserves its existing core module list and file order.
It packs all other modules from the canonical standard source registry in the
pool. The source-to-module name rule is shared in `standard_sources` rather than
copied in the two fixture tools.

`self_host_bootstrap_fixture --standard-root ROOT` reads `ROOT/std/...` paths
while it packs the request. With no option, it uses explicit embedded bootstrap
sources. `--pool-module NAME SOURCE...` packs user modules for later selection.
Interpretation uses only the packed bytes. The native request CLI resolves all
pooled modules through the generic manifest resolver, including registered
standard modules with custom logical file paths or extra files. Selected
standard records keep their canonical module IDs. The native collector does not
add a fallback copy or scan the fallback source for a module already present.
The compiler API dependencies use this selection before source checking.

`std/string_fixed_array.dew` belongs to `dew.std.string`, as in the native source
collector. The shared registry metadata now records that grouping. The fixture
therefore keeps this extension with the string module instead of an unused,
unregistered `dew.std.string_fixed_array` pool module.

The new native optional pool parameter exists only on the uncached pipeline.
Existing callers default to an empty pool. Cached compiler entry points are not
changed, so no existing cache key can omit newly accepted pool bytes. There is
no new source-override state in `StandardLibrarySources`. Explicit standard
records use normal manifest cache keys. The interface source fingerprint hashes
the module ID, module name, and every exact file path and source payload. Cache
module origin is determined by the manifest prefix, not the reserved ID range.

## Checks

- Request codec: 10 tests pass in 0.589 seconds (including the later bounds review). Tests include source-pool opaque
  byte round trips, deterministic ordering, duplicate names, root membership,
  and old requests without the optional extension.
- Native source pool: 8 tests pass in 17.356 seconds, including the package test
  executable rebuild. They check transitive imports, transform-generated user
  imports, unused invalid UTF-8 exclusion, and a visible missing-module error.
  They also cover late modules with their own transforms and late targets that
  call an earlier imported transform. The fifth test checks exact API source
  provenance: wrong positions, file paths, or source bytes are rejected. The
  next two tests check arbitrary standard file paths, extra files, user
  dependencies, unused invalid standard source, and an explicit standard prefix
  before the root module. The eighth test starts with only the app module.
  Injected AST imports select a pooled standard array module with custom file
  paths and an extra file before checking. Only the two compiler API module
  positions receive trust; the selected pool module does not.
- Logs are `.tmp/request-source-pool/codec.log` and
  `.tmp/request-source-pool/native.log`.
- Native CLI and request packer type checks pass in 5.204 seconds.
- Package API update passes in 5.285 seconds.
- The all-source Dew check passes for 216 files in 11.917 seconds.
- `self_host/compiler/request_test.dew` has seven resolver, API-source, and bounds
  checks after the independent bounds review. These cover selected
  source bytes and stable root order, transitive selection, unused invalid
  source, missing and deferred imports, wildcard descendants, and exact tracked
  compiler API bytes.

The test times include compiler and harness work. They are not isolated loader
benchmarks and do not establish an allocation or memory-use gain.

## Real native request CLI checks

`python3 tools/test-compile-request-sources.py DEW_CLI FIXTURE` runs five real
requests without a Moon build. Each output validates and executes with
`main() = 42`. It also checks that no cache directory is created.

| Case | Time (s) | Peak RSS (KiB) |
|---|---:|---:|
| Ordinary control | 0.6051 | 30,636 |
| Pooled standard module, custom logical path | 2.2684 | 45,172 |
| Pooled standard module, extra source file | 2.2451 | 41,140 |
| Late standard module with its own transform | 2.3109 | 45,052 |
| Explicit standard module before the root | 0.7599 | 36,064 |

These are single whole-process samples on x86-64 Linux. The check binary used
Moon's generated debug C, compiled by GCC with `-O0 -g0` in 21.064 seconds. It is
not a release performance result. The normal native release and debug builds
both reached a 25-second check cap while compiling the 72–77 MiB C file; their
completion time was not measured. No runtime speed or allocation gain is
claimed.

Raw commands, request/output hashes, samples, compiler and fixture hashes, and
environment identity are under `.tmp/compile-request-sources/`. The check binary
is `.tmp/request-source-pool/dew_cli.exe`; the CLI and C build logs are under
`.tmp/request-source-pool/`. The generated C SHA-256 was
`49b92b942d6aed949ea10ebc8387c96c94fa188bc352f4427fe83880db36d8e5`.

`src/semantic/standard_module_identity_wbtest.mbt` passes all three tests in
9.717 seconds. These include an all-standard explicit round-trip check for IDs,
file order, and source bytes, plus a check that every registered source path maps
to a canonical module identity.

The root review also exported the staged tree, without the later syntax/VM
changes, into `.tmp/pool-staged-check`. Its native source check passed in 6.529
seconds. Its eight source-pool tests passed in 22.863 seconds, including the
separate cold test build. Logs are `.tmp/request-source-pool/staged-check.log`
and `staged-native.log`. This checks that the bounded commit stands on its own.
