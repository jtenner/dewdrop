# B-tree step 3: plain lookup and fit writes

Status: step-3 exit checks pass. This is a private root-leaf checkpoint.
Splits, multi-level operations, deletion, inline search, prefix repair,
append hints, cursors, batches and the public map/set facades are pending.
No design departure or design-fact blocker remains. D1-D6 are unchanged.

Branch: `feat/btree-step-3-plain-fit-writes`.
Base: `bee17cd481a4d48f2ed02d895119ee05192defee`.
Design: `5922ea1a12ede3913f97b9b7bdac1f90343240f1`.
Upstream bbtree: `8adae97a0ed97e5c98fa2790312eb0aec9719846`.
The handoff gives the final implementation commit. The separate compiler
probe commit is `9fa305061d`.

All edits and builds ran in
`/home/dev/.t3/worktrees/dewdrop/t3-38b925be`.
The owner's checkout, master, remote refs, other workers' source and the
parent-owned build-status note were not changed. No PR, push or merge was
made. The parent owns acceptance and landing.

## Implementation

The shared engine stays in `std/collections/btree.dew`. Its private state
has a root Option, U32 length, comparator and immutable plan. New maps have
no nodes. Plain maps have no prefix object, metadata array, path, hint or
work-space object. `clear` drops the root and resets length in constant time.
It retains the immutable plan and comparator. It does not remove entries
one by one or clear nodes held separately by a test or snapshot.

`btree_plan` still selects the standard plan. It calls the shared private
plan-policy helper with `force_plain = false`. The private checkpoint
constructor uses that same helper with `true`. This permits forced plain
U64/I64 and text controls without changing comparator evidence or the public
config. No alternate tree, layout, module dispatch or compiler rule is used.

The private search result is a U32: twice the insertion index, plus one for
equality. It needs no object. The known standard numeric path uses scalar
Lt/Eq evidence and branchless lower-bound updates. Other comparators use
early-equality binary search and one full comparator call per probe. A
small reference carrier does not select numeric search. The key column is
selected once per node search; each key read still checks the live count.
The plain branch key-column arm is reusable by step 4; no branch descent is
implemented or claimed here.

Fit insertion uses the existing plain leaf/key-only bodies, typed arrays,
overlap moves and permanent default clear slots. Keys stay at `keys[i]` and
values at `values[i+1]`. The first root has no head. Counts change only after
live slots have been written. A comparator-equal replacement changes only
the value; it retains the stored key. A full root leaf gives a named internal
checkpoint failure before any shift or count change. It never drops a key
or claims to balance.

The shared write helper selects Bool, Unit or old-value policy by its
explicit result type and ordinary trait evidence. Unit is the erased policy
token. Bool and Unit forms do not construct or discard an Option or entry.
The old-value policy reads before replacement and makes the requested
Option. Stored-key/value snapshot reads use the stored key. No Default, Eq,
Hash or inline bound is added to all keys/values. Unit leaves have no value
array, and the caller's Unit value-expression effects remain visible.

Growth checks run after an equality search and before new writes or node
allocation. Replacement remains valid at U32 max. The checked helper tests
the final valid increment and overflow without allocating billions of
entries. Failures name operation, node kind, count and capacity; node failures
also give index and head state. Message objects are made only on failure.

## Tests and commands

Ordinary tests are in `std/tests/btree_plain_fit_test.dew`. The shared
`PRIVATE_BTREE_TESTS` list feeds both normal and Starshine experiment lanes.
The tests compile the exact common source in an ordinary test module.
No public inspector or test-only compiler rule was added.

The root inspector checks shape, count/length equality, capacity, column
lengths, strict comparator order, absent head, zero plain prefix and Unit
erasure after writes. Physical probes check null inactive/default reference
slots and the unused value head. This inspector does not claim the later
multi-level, prefix, cursor or batch invariants.

Coverage includes every fit gap for a 61-key U64 leaf, all shifted values,
full-leaf replacement, exact Unit capacity, empty reads, hits/misses, all
three write results, distinguishable comparator-equal reference keys,
aliases, retained snapshots, clear/repopulate, near-max count checks and
replacement at maximum length. The 800-step independent linear sorted-array
model uses seed 137, signed keys -16..15, clear every 97 steps and mixed
insert/put/set writes. It checks membership, values, key positions, length
and the inspector after each step. It never calls tree search. The complete
operation log is saved with the raw data.

I32, I64, F32, F64, V128, reference, Unit, Option and nested Option values all
run. Float checks retain NaN/negative-zero bits. Present None differs from a
missing key. A direct Unit test checks each caller effect. No carrier is
silently skipped. All positive failures stop the runner.

The exact diagnostic driver checks these messages in addition to the normal
expected-trap tests. An earlier unrelated assertion does not satisfy it:

```text
BTree plain leaf insert: U32 length overflow; count=4294967295 capacity=61
BTree plain Unit leaf insert: full root leaf; step-3 checkpoint requires split support; count=251 capacity=251 index=251 head=false
```

Run the focused checks from this worktree:

```bash
DEW_NATIVE_TEST_PACKAGES=semantic/standard_module_identity_wbtest.mbt tools/test-native.sh
DEW_INTEGRATION_TEST_FILES=src/backend/btree_plans_providers_wbtest.mbt tools/test-integration-native.sh
python3 tools/test-btree-plain-fit.py \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  /home/dev/.t3/worktrees/dewdrop/coordinate-dewdrop-btree-build/_build/native/release/build/jtenner/starshine/cmd/cmd.exe \
  --output .tmp/btree-step-3/final-report
python3 tools/generate_btree_std.py --check
python3 tools/generate_standard_module_identities.py --check
```

The runner measures each compiler, optimizer, assembler, validator and runtime
command separately with `time.monotonic`. It saves stdout, stderr, status and
arguments. It uses the on-disk standard root and disables program caching.
The full native, stress and pinned Starshine suites were not run here.
The parent's scalar inventory and missing-intrinsic generator repair were
not changed, reviewed or rebuilt by this worker.

## Physical allocation and layout evidence

Raw native emission and unchanged O4s are separate controls. O4s uses exactly
`--optimize-level 4 --shrink-level 1 --optimize`. At this pin it does not
promise scalar replacement. No experiment list was promoted to production
and no B-tree pass list was added. Early two-pass/speed-deep diagnostic
outputs are scratch only; none establishes an acceptance claim.

Counters in copies of each module record executed array/struct constructor
instructions, including fixed/data/elem arrays and default structs. Original
modules are timed without counters. These are Wasm constructor counts, not
exact JIT heap allocations, heap bytes or GC-pause measurements.

The checked numeric warm paths have zero tree/path/search constructor
executions. Bool/Unit replacement and fit writes make zero objects. Numeric
get/put make one requested Option result. The all-carrier probe checks the
same zero-private-object result for I32, I64, F32, F64, V128, reference, Unit,
Option and nested Option values. Reference/Option argument objects are made
before the counter reset; storage adds no per-entry wrapper.

Text hit/miss search uses one/two comparator calls in the fixed three-key
case. Each consumed Ordering result still makes one object in both controls.
The direct comparator probe confirms that result cost. Text get adds one
requested Option; text contains and Bool/Unit writes do not. Thus a text
call is not claimed to be wholly object-free. The exact public-result and
comparator-result counts are recorded separately from private scratch and
are checked, not subtracted as an unknown allowance.

Empty construction makes zero arrays and five objects including the
comparator, config, plan, root None and map. First-node numeric construction
has two arrays and nine objects in total; Unit has one array and nine
objects. These construction counts include all setup, not one warm write.
Clear makes one retained root-None state object. It is not a warm point
operation. No node or prefix survives through the map after clear.

The emitted Unit body has one reference field and no value column. The plain
map has nine physical fields: root, count, the compiler's six generic
comparator carrier fields, and plan. The unused comparator fields are map
overhead, not per-entry boxes. There is no prefix/path field. Node storage
keeps the selected step-2 bodies and clear slots.

Raw calls use direct specialization. O4s can merge other helpers into fixed
function-reference calls; that is not a source trait lookup. Raw search bodies have zero `call_ref` instructions. The O4s numeric core
has three calls through fixed key-array/key-read references supplied by its
forwarding function; the text core has none. The report follows the O4s
forwarder before it counts the core. Numeric search
has one loop, one scalar less-than, one shift and two multiplies. Its raw/O4s
body has four/two `if` instructions for control and live/final checks, with
no br_table. Custom text search has one loop and one equality-dispatch
br_table, with three/one `if` instructions. These are static Wasm counts,
not native CPU branch measurements. Full bodies and counts are retained.

## Runtime controls and tuning

The cost driver uses four independent Node processes per variant, three
warmups and six samples per case. Within each process it alternates forward
and reverse case order. It uses 31 even I32 keys, I64 values equal to key/2,
and queries cycling through 0..63. There is no random input seed in this
cost test. Each lookup/contains/replacement sample has 3,000,000 operations.
Each fit sample has 100,000 rounds of 31 insertions using `(i*17)%31`; it
includes one node clear per round and allocates no replacement node.
Timers surround whole loops. Checksums are checked each time.

The direct-array control has the same search inputs and checksum but no map,
node body or live-slot checks; it is a lower bound, not an OrderedMap match.
No full-map, Wago, red-black tree, large-data or cache-line speed claim is
made at this checkpoint.

Reading the key column once per search reduced repeated body dispatch.
The matched before/after raw medians were 25.318/16.267 ns for lookup and
26.904/14.915 ns for replacement; direct controls were 7.524/7.492 ns.
O4s showed the same direction. The matched raw code section fell from
32,708 to 31,178 bytes; O4s fell from 25,221 to 23,983. These runs used the
same probe source and inputs. They were separate runs, not an interleaved
source-version trial, so no exact speedup percentage is claimed. All samples
and source hashes are in `search-tuning.json`.

The final carrier probe has more exports than the tuning probe. Its total
module/code sizes are reported separately below. Module size is not bytes
per map. All sample windows, ranges and limits remain in the raw data; no
best sample is selected as the result.

## Slow builds and compiler limits

The initial native CLI build took 53.872 seconds for 42 tasks. The native
test-generator build took 30.596 seconds for three tasks. Both exceed the
30-second limit and remain open tool-build performance bugs. The CLI build
overlapped the initial native identity lane; neither cost is a controlled
phase profile. They are not hidden in a total.

The generated C files are 81,301,983 bytes for the CLI and 76,620,952 bytes
for the test generator. Both package files select `-Og`. No-work controls
pass in 0.030 and 0.035 seconds. This establishes a dirty-build cost, but
does not prove which compiler or C phase causes it. No build-system fix is
claimed. No Dew source probe, private test compile or optimizer command
approached 30 seconds.

The native tools were built locally, then reused for later on-disk source
probes because compiler/registry semantics did not change. Their hashes and
`DEW_STD_ROOT` are recorded. Later B-tree source changes were mirrored and
checked in the focused native backend lane. No production code depends on
a scratch binary.

The separate [generic Option note](btree-step-3-generic-option-layout.md)
records a general missing-enum-layout defect and a false pattern/expression
diagnostic. A preserving test form passes every carrier without adding a
type-witness constructor. The compiler was not patched and no B-tree rule
was added. Sol/high and read-only Claude Code review evidence, scope and
limits are linked there. The parent must test independently before landing.

## Exit checks and raw records

Empty/root state, plain search, fit insertion, key retention, replacement,
checked counts, result policies, snapshots, Unit effects, the root inspector,
all carrier checks, exact negative boundaries, private allocation checks,
raw/O4s controls, loop costs and mirror checks are complete for step 3.

Raw artifacts are under `.tmp/btree-step-3/final-report/`: commands, stdout/stderr,
original/stripped/instrumented Wasm, WAT, shape/search reports, allocation
sites, exact diagnostics and exactly four numbered sample files per variant.
The script never reads a `cost-*.json` glob that can include a summary.
Earlier failed probes and both review packets remain under
`.tmp/btree-step-3/`. The failure of an earlier zero-total-allocation check
is retained: it wrongly counted requested Options and Ordering results as
private scratch. The final check follows the parent's explicit clarification
of design section 13.2 and keeps those costs visible.

Committed machine records:

* [Final measurements and all raw samples](data/btree-step-3/measurements.json).
* [Matched search tuning samples](data/btree-step-3/search-tuning.json).
* [All 800 oracle operations](data/btree-step-3/oracle-operations.json).

The recorded source HEAD precedes the final report commit. Exact source
hashes identify the tested working-tree inputs; the final commit contains
those same inputs. The remaining tables give the final commands, identities,
costs and size records.

## Final validation and identities

| Check | Result | Wall seconds |
| --- | --- | ---: |
| Native module identities | 3 passed | 10.975 |
| Final native backend cases | 2 passed | 10.636 |
| Public Dew compile | passed | 0.522 |
| Public plan/provider tests | 8 passed | 0.036 |
| Private Dew compile | passed | 7.307 |
| Private raw tests | 24 passed | 0.057 |
| Private O4s optimization | passed | 0.105 |
| Private O4s tests | 24 passed | 0.055 |
| Exact negative diagnostics | 2 passed | 0.034 |
| Final raw carrier probe compile | passed | 1.582 |
| Final carrier O4s optimization | passed | 0.044 |

Both mirror checks and `git diff --check` pass. The initial red compile
failed for the missing engine names in 0.382 seconds. Earlier malformed
source and missing-enum-layout attempts remain failed in their saved logs;
no stale five-test binary is counted as new-test evidence.

Host: AMD Ryzen 7 8845HS w/ Radeon 780M Graphics; Linux-6.12.113+deb13-amd64-x86_64-with-glibc2.41.
Moon: `moon 0.1.20261012 (748b63c 2026-10-12)`. Node: `v24.21.0`, V8
`13.6.233.17-node.53`. wasm-tools: `wasm-tools 1.262.0 (e22db44da 2026-10-13)`.
Starshine source pin: `1b237952167f582abd492aec27adf10c5a6c9e60`. Default Node WasmGC,
no custom flags, native x86_64 execution; no emulation.

Tool SHA-256:

* `dew_cli.exe`: `fc009a79bd5547d625ca222d32b9dfec85aa17ca651e277559fa58a139ec8e07`.
* `dew_test_gen.exe`: `eb239ce2bb5cb150117a9889ae969113f3b4312a1402455697cb62f9e336b8fc`.
* `cmd.exe`: `7b00526a1d7774e9860b45bac6e68035e6d4c20698c6e396896fa4aacb23d790`.

Final common-source SHA-256: `04c428f1551367f587203f2187aa866d95bddc7415b82a054af435e07a271fc0`.
The complete source hash list, tool paths, options and pre-report source
HEAD (`bbcf48129fb1a5a49c6bfbfc723819a5ff7f40d9`) are in the machine record.
The final parser correction follows `return_call` forwarding and keeps
its fixed reference targets. It does not change emitted code: the raw and
O4s hashes equal the prior `handoff` run. All allocation checks still pass.

| Final module | Bytes | Code-section payload bytes | SHA-256 |
| --- | ---: | ---: | --- |
| raw.wasm | 202,690 | 74,956 | `3dc500b1e8171068bcd3ecb94a1a29290c341b9b358a03f9cac605b0d1bf5870` |
| raw-stripped.wasm | 82,568 | 74,956 | `901ddad5308fe84542c09c08846c6d59fdec6b932a53b29f35ce53cd418af60a` |
| O4s.wasm | 48,403 | 43,484 | `765a880a450e1d0addbc2f7311db127ce1e1b9ea7f73aa45375e9855c9cd3ef4` |
| O4s-stripped.wasm | 47,654 | 43,484 | `b83b748350975cb86d852fa5d40f5b9a6040d4bad877ff50f675bb93cd077d68` |

## Final loop costs

Each row has 24 samples. Rates are whole-loop throughput, in millions of
operations per second. Fit includes the documented clear cost. Raw and O4s
are controls; their small differences are not a speedup claim.

| Output | Path | Median ns/op | Min–max ns/op | Median M ops/s |
| --- | --- | ---: | --- | ---: |
| raw | lookup | 15.304 | 15.053–16.505 | 65.342 |
| raw | direct-control | 7.043 | 6.933–7.550 | 141.987 |
| raw | contains | 16.878 | 16.744–17.880 | 59.249 |
| raw | replace-unit | 14.075 | 13.914–15.388 | 71.048 |
| raw | fit-bool | 34.406 | 34.047–35.959 | 29.064 |
| O4s | lookup | 15.817 | 15.581–17.152 | 63.222 |
| O4s | direct-control | 6.974 | 6.886–7.326 | 143.382 |
| O4s | contains | 19.965 | 19.675–20.881 | 50.087 |
| O4s | replace-unit | 14.997 | 14.833–16.535 | 66.681 |
| O4s | fit-bool | 35.603 | 35.179–36.794 | 28.088 |

raw sample windows: 20.799–111.471 ms. O4s sample windows: 20.657–114.060 ms.

The committed JSON keeps every unrounded sample in process/run order.
The `acceptance-repeat` control also passed with the earlier, smaller probe.
No CPU affinity, peak/live heap, retained-byte, GC-pause, cold-code runtime,
large-tree or map-versus-map result is established.

## Changed files

* `docs/research/btree-step-3-generic-option-layout.md`
* `docs/research/btree-step-3-plain-fit-writes.md`
* `docs/research/data/btree-step-3/measurements.json`
* `docs/research/data/btree-step-3/oracle-operations.json`
* `docs/research/data/btree-step-3/search-tuning.json`
* `src/standard_sources/standard_btree_sources.mbt`
* `std/README.md`
* `std/collections/btree.dew`
* `std/tests/btree_plain_fit_test.dew`
* `tools/btree-fit/carriers.dew`
* `tools/btree-fit/diagnostics.mjs`
* `tools/btree-fit/generic-option-valid.dew`
* `tools/btree-fit/generic-option.dew`
* `tools/btree-fit/physical.dew`
* `tools/btree-fit/run.mjs`
* `tools/dew-test/assemble.py`
* `tools/test-btree-plain-fit.py`
* `tools/test-btree-plans-providers.py`
