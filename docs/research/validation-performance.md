# Full validation performance

## Scope

`tools/check.sh` intentionally keeps broad validation coverage: formatting and
generated-source checks, native/WasmGC/JavaScript/classic-Wasm MoonBit tests,
CLI/package/cache/ABI smoke tests, standard-library tests, UTF/SWAR/WASI parity,
and all deterministic Node/Wago module snapshots.

The optimization goal is lower wall time without removing targets, fixtures,
duplicate-compilation checks, runtime engines, or deterministic output.

## Parallel MoonBit target tests

MoonBit serializes commands sharing one target directory through
`_build/.moon-lock`. Starting the four target test commands concurrently against
the default directory therefore only adds waiting.

Full validation now assigns each backend a persistent target directory under:

```text
.tmp/dew-check-moon-targets/<target>
```

The native, WasmGC, JavaScript, and classic-Wasm test commands run concurrently
up to `DEW_CHECK_TARGET_JOBS`. The default is the online processor count capped
at the four available targets. Each command writes a private log; after all jobs
finish, `tools/check.sh` prints those logs in the fixed target order. Failures
remain visible, and output order does not depend on completion order.

`tools/check.sh --quick` retains the ordinary single native test command and
default MoonBit build directory for the smallest incremental loop.

The JavaScript target runs through a private `node` shim that supplies an
8,192-KiB stack by default. The 512-level nested-object parser/inference stress
fixture otherwise exceeds Node 26's default JavaScript stack after the semantic
package grew, despite retaining the same source workload. This changes only the
validation host limit: the fixture depth and all assertions remain intact.
`DEW_CHECK_NODE_STACK_SIZE` accepts a positive integer override.

## Prebuilt parallel snapshot runner

The module-snapshot runner previously launched `moon run` for both compilations
of every fixture. It now:

1. builds the release native `module_snapshot_gen` executable once;
2. invokes that executable directly;
3. gives each fixture a temporary private interface cache;
4. processes independent fixtures concurrently;
5. buffers results and emits them in sorted fixture order.

The default snapshot worker count is `min(8, CPU count)`. `--jobs` or
`DEW_SNAPSHOT_JOBS` overrides it. Per-fixture caches avoid concurrent cache
writers and prevent an inherited `DEW_CACHE_DIR` from contaminating snapshots.
The two compilations of one fixture share its private cache, retaining the
miss-versus-hit reproducibility check.

## Release UTF parity generator

The UTF parity generator compiles and links a large generated Dew workload. The
debug native generator spent most of the full-check wall time in compiler work.
The harness now runs `src/utf_parity_gen` as a release native executable. It
still generates all 971 cases and executes the same 17,471 independent parity
checks.

## Measurements

Measurements below were taken on August 8, 2026, on the 16-logical-CPU
development host. They are local wall-time observations, not contractual
resource budgets.

```text
workload                                      before      after
four MoonBit target suites, warm              88.856 s   42.266 s
216 Node/Wago snapshots                       36.206 s    6.021 s
UTF parity generator, warm debug/release       47.989 s    6.722 s
full check after snapshot change / final      179.376 s   57.030 s
```

The 179.376-second full-check measurement already used the faster snapshot
runner but still ran MoonBit targets sequentially and used the debug UTF
generator; the complete improvement over the original all-sequential workflow is
therefore larger than that row alone shows. From that intermediate point, the
measured incremental full-check wall time fell by about 68%. A clean checkout can
spend additional one-time time compiling the isolated target directories and
release UTF generator; those outputs remain cached for later runs.

## Invariants

The faster workflow preserves:

- all four MoonBit compilation/execution targets;
- the complete test counts for each target;
- exact failure logs for every target even when another target fails;
- two compiler invocations per snapshot fixture;
- byte-identical repeated successful Wasm output;
- identical repeated failed diagnostics;
- Node and Wago Core 3 runtime comparison;
- Wasm validation and exact WAT comparison;
- all UTF/SWAR/WASI parity cases;
- deterministic target and fixture output ordering.
