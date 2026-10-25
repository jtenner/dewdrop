# B-tree step 2: plans and key providers

Status: step-2 exit checks pass. No map engine or balancing is implemented.
No design-fact blocker remains. Departures D1-D6 are unchanged.

Branch: feat/btree-step-2-plans-providers.
Original base: 5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb.
Design: 5922ea1a12ede3913f97b9b7bdac1f90343240f1.
Upstream bbtree: 8adae97a0ed97e5c98fa2790312eb0aec9719846.
The final handoff gives the exact step-2 commit. Transplant that commit only.
The branch was not rebased after the parent changed its integration base.

All work ran in /home/dev/.t3/worktrees/dewdrop/t3-78c50516.
The owner's main checkout, master, remote branches, and other workers' files
were not changed. No PR, merge, or push was made. The parent-owned
docs/research/btree-build-status.md is unchanged.

## Delivered scope

The common module is std/collections/btree.dew, selected as
dew.std.collections.btree. It contains config validation, immutable plans,
the five inline traits, the opaque packed prefix, standard provider impls,
private node bodies, typed storage, packed metadata, allocation and clear
helpers. The module registry, wildcard selection, stable module IDs, and
bootstrap source follow the existing rules. No compiler semantic or backend
rule was added for trees.

Configs enforce power-of-two leaf budgets of at least 1024 and branch budgets
of at least 64. U64 arithmetic bounds budget calculations. Capacity search
uses the formulas from design section 3.4, a minimum of 12, a maximum of 1023,
and the window-strip limit. Tag selection uses the same budget multiple and
allows a loss of at most one entry. Minimum occupancy, edge split counts,
and the batch cutoff are derived from the result. No native capacity is
copied into the library.

Default checks give plain U64/U64 capacities 61/61, inline U64/U64 54/48,
and tagged String/U64 39/40. The first inline cutoff is 38,912 for U64/U64
and 28,672 for String/U64. The tests also cover small branch budget multiples,
the largest U32 power-of-two budget, Unit erasure, and 54 carrier/width plans.
These are modeled payload budgets. They do not specify heap page sizes,
GC headers, reference widths, or alignment.

NaturalComparator supplies U64 and sign-bit-flipped I64 encodings.
StringComparator, StringViewComparator, and BytesComparator use ordered bytes,
zero padding, saturated length tags, suffix comparison, and padded prefix
comparison. Tests cover UTF-8 view edges, arbitrary bytes, empty and trailing
zero bytes, huge offsets, signed extremes, and tags at the length limit.
Optional evidence without InlineKey is a named compile-time error.
The custom width is read once in btree_plan. Standard trait and carrier
queries select direct typed bodies. The probe has no call_ref lookup.

Nodes have private count, prefix length, head state, and an immutable body
reference. Array references in the selected body are immutable. Plain leaves
use keys[i] and values[i+1]; inline leaves use pair/column position i+1.
Inline heads use position zero. Plain head keys are rejected because their
home is an ancestor. Inline branches contain only children and metadata.
Live reads check count/head state. Failed live reads report node kind, count,
capacity, index, operation, and head state.

Inline leaves select one same-type array, common U32/U64/V128 arrays,
one-block or two-block V128 pairs, heterogeneous typed columns, or a key-only
Unit form. Scalar float bits use typed vector lanes. No invalid scalar
float/integer bitcast is required. Bool raw pairs write 0/1. Narrow signed
loads restore their logical width. Tests cover all six physical carriers,
same-type references, distinct references, Option and nested Option, Unit
keys, erased Unit values, and the caller's Unit value effect.

Every typed column has a permanent default slot or pair. Access guards keep
paired reads and writes out of it. Moves use overlapping array copies and
clear vacated source slots. Clear copies defaults without reading them as
user values. Large clear runs copy an expanding cleared run, so the number
of copies grows logarithmically. Retired nodes clear keys, values, heads,
children, windows, tags, and control state.

Metadata uses one WasmArray<V128> per inline node. Width-specific scans use
unsigned 16/32-bit comparisons and sign-flipped signed 64-bit comparisons.
Every reduction has a live mask. Unused windows are maximum lanes. Tag bytes
and padding never enter ranks. Packed moves make no per-window objects.
The prefix has four mutable V128 fields and one U32 count. Word reads handle
unaligned offsets and short tails without a new byte view.

## Repeat the focused checks

Run from this worktree:

~~~bash
source tools/self-host-common.sh
self_host_measure 'native CLI build' moon build --target native --release -j 8 src/dew_cli
self_host_measure 'native test generator build' moon build --target native --release -j 8 src/dew_test_gen
DEW_NATIVE_TEST_PACKAGES=semantic/standard_module_identity_wbtest.mbt tools/test-native.sh
DEW_INTEGRATION_TEST_FILES='src/backend/btree_plans_providers_wbtest.mbt src/semantic/standard_preamble_wbtest.mbt' tools/test-integration-native.sh
python3 tools/test-btree-plans-providers.py \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  --output .tmp/btree-step-2/final
python3 tools/generate_btree_std.py --check
python3 tools/generate_standard_module_identities.py --check
~~~

The probe runner times each compiler, assembler, validator, and runtime
command with time.monotonic. It saves exact arguments, stdout, stderr, exit
status, and elapsed time. A positive failure stops the run. Each of the four
negative evidence cases must exit 1 with the required diagnostic.

The ordinary Dew files are under std/tests/btree_*_test.dew. Public tests
import the registered module. Storage tests compile the exact common source
in an ordinary probe module so they can inspect private state. The normal
stdlib runner includes that separate test binary. No public test API was
added. Test providers are ordinary source declarations in
tools/btree-plans/providers.dew: Dew excludes test-only impls from associated
optional evidence in ordinary library functions.

Final focused native checks passed:

* Module identity: 3 tests, 9.141 seconds.
* New compiler/backend integration file: 2 tests, 8.131 seconds.
* Standard preamble and wildcard integration: 24 tests, 1.860 seconds.
* Ordinary Dew runtime files: 8 public tests and 12 private tests.
* All four optional-evidence misuse cases report the required compile error.
* Bootstrap mirror, identity mirror, and Python syntax checks pass.

The probe's exact final source-compile and runtime times are in commands.json.
Raw physical compilation is below one second; the combined private test
compile is below four seconds. No probe compile exceeded 30 seconds.
The parent owns the full native gate after transplant. This step does not
claim a full native suite on its changed source.

## Raw physical and allocation evidence

Artifacts are at:

/home/dev/.t3/worktrees/dewdrop/t3-78c50516/.tmp/btree-step-2/final/

identity.json records the base, source HEAD at run time, exact source hashes,
tool hashes and versions, CPU/OS, engine mode, and module hashes and sizes.
The run occurs before the handoff commit; the recorded input hashes can be
checked against that commit. physical.wasm and physical.wat are the original
raw output. physical-stripped.wasm removes custom sections for a separate
code-size record. Instrumented copies have an -inspect suffix.

gc-shapes.json checks the actual emitted types:

* The node has three mutable i32 controls and one immutable body reference.
* The selected Unit key body has one reference field and no value column.
* The inline branch body has exactly two fields: an eqref child array and
  a V128 metadata array. It has no full-key field or array.
* The packed prefix has four mutable V128 fields and one mutable i32 count.

Allocation counts below are executed instructions in an instrumented copy,
not just reachable allocation sites. Node calls receive an existing plan.
Plan calls below also construct their probe comparator and default config.
The fourth inline-plan object is the temporary `BTreeInlineWidth` enum returned
by `inline_width()`. It is included in the count.

| Operation | Arrays | Struct/enum objects |
| --- | ---: | ---: |
| Plain leaf | 2 | 3 |
| Same-type inline leaf, including String/String | 2 | 4 |
| Common U32 inline leaf | 2 | 4 |
| Mixed U64/F32 inline leaf | 2 | 4 |
| String/U64 inline column leaf | 3 | 5 |
| String/Unit inline leaf | 2 | 5 |
| Keyless inline branch | 2 | 3 |
| Plain plan plus probe config/comparator | 0 | 3 |
| Inline plan plus probe config/comparator | 0 | 4 |
| Prefix from existing key/provider | 0 | 1 |
| Clear, paired read/write loop, SIMD/scalar rank loops | 0 | 0 |
| Window from existing key/provider | 0 | 0 |
| Escaping compare result | 0 | 1 |

Inline leaf array counts include metadata. The Unit leaf has a key array
and metadata, with no value array. Its extra key-only wrapper is counted.
The escaping comparator result is the requested Ordering enum object.
It is not hidden as a zero-allocation result. No tree/path temporary or
per-window object is allocated in the checked loops.

The inspector holds references to the backing arrays across clear.
All old head, regular-entry, and child references become null. Permanent
default slots stay null. Paired numeric default slots remain zero in the
Dew tests. Metadata lengths match the exact rounded strip sizes.

Three source choices were needed for the good path to have zero allocation:

1. Build assertion messages only on failure. The first clear probe found
   four String wrappers from successful assertions.
2. Use mutable scalar loop locals. The first 1,000-turn paired probe made
   2,002 tuple-state objects. The final loop makes none.
3. Select access helpers by fixed carrier evidence before reading storage.
   This removes unrelated storage arms from each selected access body.

These changes keep the selected shapes. No compiler rule or departure changed.

The original raw probe and stripped module sizes, exact hashes, raw samples,
and final medians are recorded in the machine-readable files in this folder.
The runtime probe uses four independent Node processes, three warmups, and
six samples per path per process. A/B and B/A order alternate. Inputs are
fixed: 54 windows, queries from 0 through 63, and fixed loop counts. No
random generator or hidden seed is used. Timers surround whole loops.
The original module is timed; counters are used only in a separate copy.


Original short-window smoke samples (24 per path; nanoseconds per operation):

| Path | Median | Min | Max | Median M operations/s |
| --- | ---: | ---: | ---: | ---: |
| pair | 1.251 | 1.207 | 1.358 | 799.432 |
| pair_control | 0.244 | 0.237 | 0.291 | 4099.117 |
| simd2 | 10.917 | 10.481 | 14.187 | 91.597 |
| scalar2 | 94.950 | 91.967 | 118.798 | 10.532 |
| simd4 | 20.427 | 17.828 | 36.580 | 48.955 |
| scalar4 | 131.631 | 128.454 | 162.955 | 7.597 |
| simd8 | 32.960 | 31.962 | 38.193 | 30.340 |
| scalar8 | 129.999 | 127.405 | 141.765 | 7.692 |

One rank operation scans all 54 windows. One pair operation writes and reads
one value. The controls use the same counts and checksums. These rates are
for the whole timed loops, not host calls around each key. Samples show noise,
especially width Four; the full ranges are retained.
Review found a JIT tier step in these samples, after repetition 2. Their
sub-millisecond windows are too short for a steady-state speed claim. These
historical numbers are smoke checks only. The scalar control reads the same
packed strip with lane extraction; its ratio does not compare SIMD with a
plain typed-array scan.

This is primitive cost evidence, not a B-tree throughput comparison.
The direct-array control can fold stores/loads and gives a lower bound.
Paired access still pays for its storage reference and live/default checks.
No actual GC heap bytes, GC pause times, page alignment, large-tree memory,
full-map throughput, or later engine behavior is claimed.

## Slow commands and build limits

The cold native CLI build took 38.906 seconds for 42 tasks.
The first CLI registry update took 32.375 seconds for 9 tasks.
The exact-source CLI build took 34.487 seconds for 9 tasks. The exact-source
test-generator build took 30.517 seconds for 3 tasks. All four over-limit
commands are open native tool-build performance bugs. They are not hidden in an
aggregate test time. The next registry CLI build took 29.914 seconds;
generator builds took 27.342, 29.576, and 26.148 seconds.

The generated CLI C file is 81,261,341 bytes. The CLI C flags include -Og.
Task counts and the large generated file are evidence to keep for profiling.
They do not prove a phase cause. No native build-system fix is claimed.
All build logs are at .tmp/btree-step-2/build-*.log. The final exact-source
builds have separate times in those logs. Both no-work controls pass in
0.030 seconds. Thus the slow cost is in dirty tool builds; there is no
measured phase cause yet.

Host: native x86_64, AMD Ryzen 7 8845HS, Linux 6.12.113+deb13-amd64.
Moon 0.1.20261012, commit 748b63c; Node v24.21.0;
wasm-tools 1.262.0. Node uses default WasmGC settings, with no custom flags.
No cross-compilation, emulation, or Wago runtime result is used here.

## Ordinary compiler issue and valid source form

tools/btree-plans/generic-return.dew is a small known-failing compiler
reproducer. It puts can_bitcast<V128,t> before F32/F64 type_equal return
branches. The compiler reports BodyConstraintDiagnostic / LocalTypeMismatch
at line 7. The last measured run exits 1 in 0.188 seconds.
tools/btree-plans/generic-return-valid.dew puts the concrete float guards
first. It compiles to an 862-byte module in 0.249 seconds.
These probes are not positive tests that catch a failure and call it a pass.

Read-only source review and an independent Claude Code Opus/high review found
the same cause. src/semantic/compile_time_guard_refinements.mbt processes
pending_guarded_joins in child-first order. An inner concrete result can be
checked before the outer generic result reaches it. The self-host source
has the same order. Reversing that order is a suggested ordinary compiler
fix, not a tested fix in this step.

The storage uses the valid guard order. It preserves the same bit operations,
arrays, and body shapes. No compiler fix is needed to complete step 2.
The failing probe and logs preserve the separate issue for later compiler
work. Claude used normal auth, read tools only, no --bare, and no shell,
MCP, or edit tools. Its prompt, stdout, stderr, and exit status are under
.tmp/btree-step-2/claude-generic-return/. It did inspect the requested scope.
It did not run tests or inspect binary Wasm. The native probe results are
separate evidence.

## Exit criteria and next work

Config, formula, optional evidence, standard provider, storage selection,
packed metadata, Unit erasure, node allocation/clear, focused compiler tests,
and physical/allocation checks are complete for step 2.

No plain lookup engine, fit insert, balancing, map/set facade, prefix repair,
cursor, or batch engine was started. The next stage is step 3 from this
committed foundation. The parent must transplant only the step-2 commit and
run its own checks before acceptance.

## Final build identity

Native CLI SHA-256: 2ab0af90e7c032f456a15b3a3d29ece16a6f38842142783be883480eb371846d.

Native test-generator SHA-256: 830a6a203602146679d4743ce2a97a93a6984bb3ad224c4daab6d1ac5f5499fa.

Original physical module: 62,467 bytes; SHA-256
0d61e6e60a3f57f2d59275159b37dbd8cde4194f1c907c3d96778f79a055778d.

Stripped physical module: 26,937 bytes.
These sizes include the probe exports and selected standard helpers. They
are not the cost of one tree instance. No matched code-size gain is claimed.

## Parent integration review

The original worker commit is `59aab429906362eb62ace42989f65316ced9e6d9`.
Only that commit was rebased onto current integration. Its replay is
`4e5fa46fa9e208c47407a0abff07bdef684d1fab`, merged for parent validation at
`b4410a710263c5d3a612bf203a8c0a4f34b2e18b`.

Independent Sol/high and Claude Code Opus/high reviews found no functional
storage/provider defect or required design departure. The parent confirmed
and fixed the repeated-output harness failure: raw samples now come only
from `cost-0.json` through `cost-3.json`, never `cost-summary.json`.
The allocation recorder now covers `array.new_fixed`, `array.new_data`,
`array.new_elem` and `struct.new_default` too. A separate parent check counted
all 44 fixed-array instruction sites; none ran on the measured success paths.
The reported success-path counts were unchanged.

The generated-source gate now checks the B-tree mirror. The stdlib and
Starshine experiment runners share the private-test list and compile those
tests as one ordinary module with the exact common source and providers.
The generated standard-sources interface was refreshed.

Parent cost runs use 50,000,000 pair operations and 1,000,000 rank operations
per timed sample, with the same four processes, three warmups, six samples,
alternating order, fixed inputs and checksums. The original short-window
samples above remain historical evidence. Fresh parent raw files are kept
under `.tmp/btree-integration/step-2/` and are not edited by hand.

The `-Og` flags are visible at `src/dew_cli/moon.pkg:21`. The parent measured
the worker's generated C file as 81,261,341 bytes and saved the paths/flags
in `.tmp/btree-integration/step-2/build-cost-source.json`. Neither fact proves
the phase cause of the slow builds.

New and cleared inactive tag bytes need not have the same numeric value:
live masks exclude them. They contain no GC references. Their differing fill
values do not change a rank or key result. The selected layout is unchanged.
Raw escaping Ordering results allocate. Non-escaping comparator consumption,
wrapper cost, shift/clear speed and final production-pipeline behavior remain
explicit measurement work for later engine steps; no zero-allocation warm
lookup or production B-tree speed claim is made by this foundation.

Claude read the changed source/diff and selected raw evidence. It could not
read binary Wasm, compute hashes, or verify Git HEAD (that read was denied).
Sol and the parent independently checked the exact diff, source hashes and
runtime evidence. No authentication failure was reported. Claude's partial
raw-file coverage is listed in its saved report at
`/tmp/dewdrop-btree-step2-review-59aab429/claude.stdout`.

## Changed files

- docs/research/btree-step-2-plans-providers.md
- self_host/compiler/semantic_standard_module_ids.dew
- src/backend/btree_plans_providers_wbtest.mbt
- src/semantic/module_system.mbt
- src/semantic/standard_module_identity.mbt
- src/semantic/standard_preamble.mbt
- src/semantic/standard_preamble_wbtest.mbt
- src/standard_sources/registry.mbt
- src/standard_sources/standard_btree_sources.mbt
- std/README.md
- std/collections/btree.dew
- std/tests/btree_capacity_matrix_test.dew
- std/tests/btree_metadata_test.dew
- std/tests/btree_node_storage_test.dew
- std/tests/btree_plans_providers_test.dew
- tools/btree-plans/generic-return-valid.dew
- tools/btree-plans/generic-return.dew
- tools/btree-plans/physical.dew
- tools/btree-plans/providers.dew
- tools/btree-plans/run.mjs
- tools/dew-test/assemble.py
- tools/dew-test/run.sh
- tools/generate_btree_std.py
- tools/standard-module-identities.json
- tools/test-btree-plans-providers.py
- tools/test-integration-native.sh
