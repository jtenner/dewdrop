# Self-host index lookups, 2026-10-18

## Linked function queries

The physical body planner previously scanned every linked function to find an
exact logical function index. Result carrier and nominal-result queries ran
these scans next to each other for each call. Parameter and declaration queries
used the same scan.

The linker appends each function with `function_index: functions.length()`.
The planner now reads that slot directly. Each public query keeps its former
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
