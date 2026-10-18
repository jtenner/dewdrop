# Self-host index lookups, 2026-10-18

## Linked function queries

The physical body planner previously scanned every linked function to find an
exact logical function index. Result carrier and nominal-result queries ran
these scans next to each other for each call. Parameter and declaration queries
used the same scan.

The linker appends each function with `function_index: functions.length()`.
The planner now reads that slot directly. Each query keeps its former
missing result for out-of-range indices, including the missing-index sentinel.
The shared helper checks bounds and the stored slot identity. A wrong identity
reports ARN-106 with the declaration, expected slot, actual slot and fragment.

The successful helper returns the existing record. It does not construct an
`Option`, copy the record or build an index. Failure records are constructed
only on the failure path. The retained data structures are unchanged.

## Same-build query measurements

`semantic_index_lookups_test.dew` contains the old declaration scan and the new
production lookup. Both run in one test Wasm binary with the same function
records. Each sample makes 8,192 queries, using `(iteration * 17) % length` to
visit every slot equally. Both include fixture construction and must return the
same checked checksum. Fixture records include imports, specializations,
lambdas and different module/fragment owners.

The benchmark uses separate Node processes for each path and size. Wasm
compilation, instance creation and three warm-up calls are outside the sample
timer. Seven calls are measured per case. `--no-liftoff` selects the optimizing
Wasm compiler from the start; `--expose-gc` permits collection before and after
each sample. This avoids tier changes inside the measured calls.

| Linked functions | Old scan, median | Checked slot, median |
| --- | ---: | ---: |
| 128 | 1.707 ms | 0.027 ms |
| 512 | 6.849 ms | 0.027 ms |
| 2,048 | 30.317 ms | 0.058 ms |

These are query microbenchmarks, **not complete compiler gains**. The old path
does O(queries × functions) work. The new path does O(queries) work. The final
sample command took 2.119 seconds. No measured compiler activity exceeded
30 seconds.

The host was Linux x64, AMD Ryzen 7 8845HS, Node 24.21.0 and V8
13.6.233.17-node.53. The test binary is 2,420,720 bytes with SHA-256
`851acbd78b99df8ab7e21b6831cc03673eff9972990b04f9bdd368bdc8481c8b`.
The native generator and linker were reused. Their exact hashes and the hashes
of every compiler, test and standard-library input are in the build record.
Inputs were copied before generation so concurrent source edits could not
change the build while it was being read.

## Memory evidence and limits

At 2,048 functions, the old/new worker peak RSS was 123,540/118,088 KiB. Median
V8 used-heap growth across a sample was 812,752/145,824 bytes. Both paths had a
median post-collection heap change of 160 bytes. The new query adds no retained
arrays, maps or records.

RSS includes Node, compiled code and fixture storage. Heap growth is not a
total allocation count: collection can occur during a sample. These values do
not prove a whole-compiler memory reduction or allocation-free compiler.
The binary contains both paths, so its total size is not a before/after compiler
code-size comparison. There is no ARM or native Dew runtime result.

The initial default-tier samples showed tier changes on the direct path. They
are retained as supporting data and were replaced by the fixed-tier run above.
There may also have been a short overlapping native test during that initial
run. The final run used the reserved quiet slot.

## Checks

All nine focused Dew tests pass. They compare every returned record field with
the old scan at sizes 0, 1, 17 and 2,048; require a moved function to trap; and
check all four missing-query results on a real linked program. The six measured
checksum cases also run as ordinary tests.

Generation took 4.349 seconds, time-provider preparation 0.004 seconds, linking
1.084 seconds and test execution 0.101 seconds. The test runner supplies traps
for unused host imports; an actual call to one fails the test.

Two initial test-source attempts used unsupported inline brace blocks. After
those were fixed, generation passed. An unset `wasm-tools` shim and unused
provider imports were then resolved with an explicit installed mise version
and the runner's existing unused-import option. These failed attempts are not
counted as passes. Shell syntax, JavaScript syntax and whitespace checks pass.

```sh
mise exec wasm-tools@1.262.0 -- bash tools/test-self-host-index-lookups.sh
node tools/benchmark-self-host-index-lookups.mjs \
  .tmp/self-host-index-lookups/tests.wasm 7
```

Set `DEW_SELF_HOST_REUSE_TOOLS=1` to use already built native tools. The default
script builds them first and prints each activity's time. The routine native
lane remains unchanged. Full bootstrap and integration results are separate
validation; the focused query measurements do not replace them.

Evidence:

- [Fixed-tier raw samples](data/self-host-index-lookups-2026-10-18/function-samples.json)
- [Initial tiered samples](data/self-host-index-lookups-2026-10-18/function-samples-tiered.json)
- [Build identity](data/self-host-index-lookups-2026-10-18/function-build-identity.json)
- [Build and test log](data/self-host-index-lookups-2026-10-18/index-tests.log)
- [Final sample command time](data/self-host-index-lookups-2026-10-18/function-samples-timing.txt)

## Field metadata and callable result queries

The second change removes the outer type-table scan from field nominal-type
and field container-owner queries. Linked types are appended with
`type_index: types.length()`. A shared checked lookup reads that existing slot
and returns the existing type record. A moved record reports ARN-106 with the
expected slot, stored slot and fragment. Out-of-range field queries still
return zero. The inner field and enum-payload scans and all their rules remain
unchanged. This change does not make the full field query constant time.

Declared callable result-shape queries now use the existing declaration-owner
lookup, then the checked `callable_by_declaration` slot lookup. They keep the
stored result shape, resolved-type fallback and final absence for an error
shape. The existing owner lookup retains its module-ID fallback path; the
change removes the scan of every callable. It adds no stored index.

`semantic_metadata_index_lookups_test.dew` preserves the three old query bodies
as test oracles. Its linked fixtures have two source modules, 64 or 256 record
types, scalar and nominal fields, generic enum payloads, a generic function and
a foreign call. Every physical field and callable in the smaller fixture is
compared against the old scan. Bounds, moved type slots, damaged callable
indices, resolved result fallback and error-result absence have separate tests.

All 21 focused tests pass: nine from the function-query change and 12 from this
change. Generation took 4.648 seconds, time-provider preparation 0.004 seconds,
linking 1.082 seconds and execution 0.227 seconds. The first metadata test source
used unsupported comma-separated record fields; these were corrected before
the passing build.

The metadata benchmark uses one binary with both old and new queries. Fixture
building and expected-checksum generation run in module initialization, outside
the sample timer. Each field sample makes 8,192 pairs of nominal-type and owner
queries. Each callable sample makes 8,192 result-shape queries. Query order is
`(iteration * 17) % count`. Three warm-up calls and seven measured calls use the
same fixed optimizing tier, collection controls and process-memory reporting as
the function benchmark.

| Query group | Fixture record types | Old scan, median | Indexed query, median |
| --- | ---: | ---: | ---: |
| Field nominal and owner pair | 64 | 9.521 ms | 4.475 ms |
| Field nominal and owner pair | 256 | 32.224 ms | 16.679 ms |
| Callable result shape | 64 | 0.524 ms | 0.180 ms |
| Callable result shape | 256 | 1.915 ms | 0.269 ms |

Each row covers 8,192 iterations. The field rows contain two queries per
iteration. These are query timings, not whole-compiler gains. Field time still
grows with the inner layout scans. The final quiet sample command took
8.333 seconds; every worker has a 30-second timeout.

Peak process RSS remained close: at 256 records, the old/new field workers
used 138,984/137,564 KiB and the callable workers used 138,992/136,972 KiB. The
64-record field worker was slightly larger on the new path. These values do
not support a process-memory gain. At 256 records, median V8 sample heap growth
for fields was 6,993,320/758,920 bytes; median retained change after collection
was 384 bytes for both paths. Callable sample heap growth was 801,968/735,416
bytes. Heap growth is not a count of all allocations, particularly when
collection runs during a call. No extra retained index was introduced.

The second test binary is 2,441,068 bytes with SHA-256
`9ebe33152fdf8b24112f0ed1f50faf975e564ef4595f110c01b7ee66dc7461dd`.
The raw report also records the benchmark harness hash. This binary contains
both query versions and additional tests, so its size is not a before/after
compiler code-size result. Host and runtime versions match the function-query
run. These measurements are not native Dew execution or an ARM result.

```sh
node tools/benchmark-self-host-index-lookups.mjs \
  .tmp/self-host-index-lookups/tests.wasm 7 metadata
```

Evidence:

- [Metadata raw samples](data/self-host-index-lookups-2026-10-18/metadata-samples.json)
- [Metadata build identity](data/self-host-index-lookups-2026-10-18/metadata-build-identity.json)
- [Metadata build and test log](data/self-host-index-lookups-2026-10-18/metadata-index-tests.log)
- [Metadata sample command time](data/self-host-index-lookups-2026-10-18/metadata-samples-timing.txt)

## Declared field layout slots

The third change removes the remaining ordinary-field layout scan. It applies
only to `WasmStructField(source_field)`. The physical planner writes this role
and its matching source declaration together for struct fields and named enum
fields. The query checks that they agree and that the source field, lowering
module and layout table have the same module identity. It then reuses the
existing checked `type_layouts.field(source_field)` lookup.

That lookup validates the module-local slot and exact stored source field ID.
Its diagnostic record is now constructed only when that identity check fails.
The failure contents are unchanged. The new caller guards also construct their
records only on failure. No extra map, array or stored record is added.

Tuple payloads and synthetic roles retain the preceding paths. Named enum
fields can use the direct lookup because they have the exact source-field
role. Generic struct and generic named-enum fields use the same declared
`layout.type_` as the old scan. There is no new shape assumption, cast or value
adapter.

The test fixture now also includes a generic struct and generic named enum
field. The existing old-query comparisons still pass. New tests check ordinary,
generic, named-enum and tuple roles; missing and synthetic fields; mismatched
physical source IDs; wrong module and layout owners; and a different stored
source field. All 31 focused tests pass. Generation took 4.627 seconds,
time-provider preparation 0.004 seconds, linking 1.095 seconds and execution
0.235 seconds.

The new `field_layout` benchmark contains both the preceding type-slot-only
queries and the new queries in one binary. It uses the existing linked fixtures,
with setup outside the timer, three warm-up calls, seven samples and the same
fixed-tier and collection controls. Each sample makes 8,192 pairs of nominal
and owner queries. The original scan remains the independent checksum oracle.

| Fixture record types | Type slot only, median | Type and field slots, median |
| --- | ---: | ---: |
| 64 | 4.580 ms | 0.627 ms |
| 256 | 17.150 ms | 0.688 ms |

These numbers measure the incremental field-query change. They do not measure
whole-compiler gains and are not combined with the earlier tables to estimate
one. The quiet sample command took 4.124 seconds.

At 256 records, old/new sample heap growth was 1,288,408/1,286,272 bytes, with a
median post-collection change of 384 bytes on both paths. Peak process RSS was
139,052/139,260 KiB. These values show a similar footprint within this probe;
they do not support a memory reduction or an exact allocation count.

The third binary is 2,449,188 bytes with SHA-256
`b1b557e73be842df0fd1a977aac2f653542bb7e463fbb517823a063e8fed1376`.
It contains both paths and more tests, so its size is not a compiler code-size
comparison. Source, tool and harness hashes are saved with the raw results.
The host and runtime match the earlier probes. No native Dew or ARM runtime
claim is made.

```sh
node tools/benchmark-self-host-index-lookups.mjs \
  .tmp/self-host-index-lookups/tests.wasm 7 field_layout
```

Evidence:

- [Incremental field raw samples](data/self-host-index-lookups-2026-10-18/field-layout-samples.json)
- [Field build identity](data/self-host-index-lookups-2026-10-18/field-build-identity.json)
- [Field build and test log](data/self-host-index-lookups-2026-10-18/field-index-tests.log)
- [Field sample command time](data/self-host-index-lookups-2026-10-18/field-layout-samples-timing.txt)
