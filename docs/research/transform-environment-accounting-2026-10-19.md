# Dew transform environments and work accounting

## Problem and bounded change

The full `examples/transforms/text_operations.dew` source passed Native, but the
Dew source interpreter stopped at its 100000-step limit on `text_answer`. The
source contains two annotations; it was not split again for this fix. Both the
100000-step and 4194304-unit allocation-work limits remain unchanged.

Dew lexical environments used reverse-scanned binding arrays. Each read charged
one step per inspected binding. Scope copies charged one step per binding;
Native charges one scope step and 16 allocation-work units per distinct name.
Successful alternative patterns appended the copied outer bindings again. Dew
also charged the pattern entry twice and built charged String proof keys during
execution. Native uses indexed names and checked source-site keys without those
lookup fees.

The fix uses a name map with copy-on-write scope snapshots. A scope keeps its own
name map after a declaration changes it. Existing mutable binding cells remain
shared, so closures see assignments but keep the names captured before a later
shadow declaration. Read-only scopes do not copy all map entries. Logical scope
accounting remains one step plus 16 units per distinct name, including a step for
an empty scope. Alternative patterns merge bindings by name.

Checked file-site maps use a U64 key: a plan-local file ordinal in the high
32 bits, and the checked source offset in the low 32 bits. The file registry
includes the module owner, so equal paths in different modules do not collide.
Frame proof selection and missing-proof errors are retained. String keys remain
for import and reflection metadata that are not checked file sites. The extra
pattern-inner and annotation-key lookup fees were removed. No new host call or
unsafe identity cast was added.

## Evidence

Private inputs, source snapshots, harnesses, raw samples and hashes are in
`.tmp/transforms-v4/text-accounting/`. `baseline-sources.json` records the saved
production inputs; `build-identity.txt` records the environment and direct
executables. These executables were not rebuilt for the Dew checks:

- Native generator SHA256: `773df059fd1cf063ea8dfeec536e52806e806e9c1b08abf57845072d45e6e366`.
- Native linker SHA256: `3e5c2c72ad5a392a7d1ce750c064a384cea0c88f6a1b93fae2f147e3ec4970b7`.
- Linux x86_64, Node v24.21.0; baseline repository commit `d9c3e44518978fca25a2db0947f99c8a5c76aa53` plus the root agent's pending function-identity work.

A private instrumented source snapshot stopped at the original limit. It counted
16031 lexical binding inspections, 1038 record-field inspections, 1997 scope
calls, 4637 copied scope cells, 192 duplicate pattern-inner charges, 15417 charged
proof lookups, 829320 proof-lookup allocation-work units, and 1635 source metadata
checks. Total allocation-work at failure was 2101611. Instrumentation kept both
limits; it was not used for speed comparisons. Its generation/link times were
6.486/1.324 seconds. This measures categories at the first failure, not a complete
execution or a proof that name lookup dominates CPU.

Exact current annotation reports for the unchanged public source are:

| Annotation target | Native work | Dew work | Native allocation-work | Dew allocation-work |
| --- | ---: | ---: | ---: | ---: |
| `text_answer` | 78686 | 83981 | 1330423 | 1553833 |
| `builder_answer` | 60169 | 64354 | 1001482 | 1150414 |

Native reports came from the current JS CLI, SHA256
`e2e1d957163cff4471b8b5411c16eaccdb646740bf906d06c6ab41caaae5e917`,
using `build --emit expanded --root example.app --module example.app
examples/transforms/text_operations.dew`. The private Dew report fixture uses the
same guest source and `ct_expand_checked_with_reports`; it checks that both
functions become `42i32`. Logs are `native-text-reports.log` and
`final-controls.log`. Allocation-work is an interpreter budget estimate, not
measured heap allocation.

### Runtime and memory samples

`measure.py` uses a new process for each run and records wall time, child user and
system CPU, and Linux peak RSS. No `/usr/bin/time` was available. Three
uninstrumented runs selected only the full text test in each artifact:

| Artifact | Result | Median wall seconds | Median user CPU seconds | Median system CPU seconds | Median peak RSS KiB |
| --- | --- | ---: | ---: | ---: | ---: |
| Saved array environment | work-limit failure, 3/3 | 1.4084 | 2.2103 | 0.1773 | 334668 |
| Indexed snapshot environment | pass, 3/3 | 1.3803 | 2.2295 | 0.2068 | 347100 |

These runs perform different amounts of guest work: the old run stops early.
The new artifact also contains private report, regression and benchmark helpers.
They do not establish a whole-workload speedup, lower memory use, or production
code-size improvement. RSS includes Node, compilation and the full Wasm module;
it is not the live guest heap size. Raw per-process samples are
`{baseline,current}-text-{0,1,2}.{json,log}`. Saved/current Wasm hashes are
`ec25e269946f1f918761b481470cf7dae8d478188a4a5f7d69931520a769aeb5`
and `c5d1bf64aaad388e6f7ea7cb585f913330d54dac62403c8cb4640b83630b2636`.

A separate same-build control contains old and new environment operations in one
Wasm module. Both modes build the same cell array and name map, and check the
same checksum. Each sample performs 20 calls of 512 operations; there are two
warmup calls and three samples. Each call stays inside the original limits.
These short samples still include JIT and GC noise:

| Operation and scope width | Old median ms | New median ms | Old median CPU ms | New median CPU ms |
| --- | ---: | ---: | ---: | ---: |
| Lookup, 1 name | 1.735 | 1.839 | 3.645 | 3.969 |
| Lookup, 128 names | 9.376 | 3.115 | 13.159 | 5.071 |
| Read-only scope, 1 name | 1.920 | 2.314 | 5.666 | 5.089 |
| Read-only scope, 128 names | 12.312 | 3.963 | 15.451 | 10.820 |

The controls support lower cost for wide-name lookup and read-only snapshots.
They do not show a gain for single-name scopes or measure write-heavy scopes.
New binding writes detach and copy a shared map. The old/new 128-name scope
processes peaked at 78088/71932 KiB, but one process per case cannot establish a
heap-memory gain. Harness and all samples: `environment_bench.dew`,
`bench-run.mjs`, `environment-samples.json`. There are no production counters.

## Tests and commands

- `DEW_NATIVE_TEST_PACKAGES=compiler_driver/transforms_environment_wbtest.mbt tools/test-native.sh`: 1/1 passed, 10.868 seconds, no observed Moon lock wait.
- `bash .tmp/transforms-v4/text-accounting/build.sh current`: direct native generation 6.535 seconds, direct link 1.529 seconds. Both measured with `self_host_measure`.
- `node .tmp/transforms-v4/text-accounting/report-run.mjs --wasm .tmp/transforms-v4/text-accounting/current.wasm --allow-unused-host-imports`: 27/27 passed, 2.306 seconds wall, 3.529 seconds user CPU, 0.230 seconds system CPU, 419368 KiB peak RSS. This includes all selected controls and guest compilations.

The five registered Dew regressions cover shared mutable cells, nested and later
shadows, eight nested successful alternatives without duplicate names, proof
owners across modules/files/frames, missing-proof diagnostics, work/allocation
failures, and a checked guest closure through a shadow scope. The Native driver
checks that same guest program. `tools/test-transforms.sh` registers the new Dew
test file. The full shared suite and fresh compiler requests belong to the root
agent's next build lane; these selected results do not claim those checks passed.

## Remaining accounting differences

The full canonical-accounting task is not complete. In particular:

1. Dew `ct_scalar_binary` still charges one step and
   `32 + machine.file_path.byte_length()` allocation-work before looking up its
   checked operator proof. Native `scalar_binary` has no matching lookup fee.
2. Dew record fields still use the old charged linear binding-array lookup;
   Native uses a map. The profile counted 1038 such inspections before failure.
   This fix only indexes lexical environments, not record storage.
3. Source function cache state changes call accounting in both implementations.
   Outer call dispatch charges `32 + argc * 16`. A cold Source target then
   charges 16 per parameter while building its environment and enters the block
   directly. A cached Source target enters `source_call`/`ct_source_call_frame`,
   which charges `32 + argc * 16` again and has no matching per-parameter charge.
   Function caches persist between annotations; globals reset. Cold/warm controls
   and a shared ledger are still needed.
4. Other metadata and binding-resolution loops need a complete cross-compiler
   ledger. The measured full text difference remains 5295 steps/223410
   allocation-work units; the builder difference is 4185/148932. Do not assign
   these whole differences to one unmeasured category.

No limit was raised, no failing test was hidden, and no standard-library runtime
algorithm was replaced by source-name dispatch. The performance evidence is
bounded to the measured controls above.

## Full shared check

Root ran the full transform lane after this fix:130/130 Dew tests pass.
Generation6.971s, link1.397s, test run28.196s. Total76.113s includes the cold
native release generator build and exceeds30s. Evidence:
`.tmp/transforms-v4/text-accounting/shared-final.log`. Native VM80/80, checked
identity4/4, and text1/1 pass in the accompanying7.002s lane. The separate
Native capture regression passed1/1 in10.868s.
