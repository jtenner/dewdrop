# B-tree step 4: plain splits and append hint

> R1 update (2026-10-26): Joshua removed the B-tree measurement hold and
> transferred this step through `ba9c30dc6` to `fix/burn-dewdrop-r1`.
> Fresh raw/O4s tests and reference-work negative controls pass there. Historical
> measurement notes below remain historical. See [the split landing record](btree-step-4-split-landing.md).

For correctness-only verification, with tools built from this checkout:

```sh
python3 tools/test-btree-plain-splits.py \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  _build/native/release/build/jtenner/starshine/cmd/cmd.exe \
  --correctness-only
```

This runs the private/public tests and structural cleanup checks in raw and O4s
forms. It also proves that disabled reference-work checks miss the exact slot-0
and slot-16 diagnostics. It does not run the measurement lanes.


Status: row 4 is complete as a private checkpoint. Raw/O4s tests, native checks,
constructor bounds, cleared slots and runtime controls pass. No design-fact
blocker or new departure remains. D1-D6 are unchanged. Deletion, inline
search/prefix repair, cursors, batches and map/set facades are later stages.

Branch: `feat/btree-step-4-plain-splits`.
Exact base: `e102287f61dd75e70e18a5be34c2301e60a1726d`.
Exact engine/benchmark head: `affce9b2ce1315d09ad9ec84169279e114366bb4`.
Final test/checker head: `adbd76687798e5e8c81672ac818cc7cd5a54e1f6`.
The final handoff gives the later record commit. Tested source hashes identify
the same implementation bytes; the measurements were made before that source
commit while HEAD was `0acfa5767aca63b57fa17d6ca977b6c70a1dd92d`.

Design authority: `5922ea1a12ede3913f97b9b7bdac1f90343240f1`.
Upstream authority: `8adae97a0ed97e5c98fa2790312eb0aec9719846`.
Bound worktree: `/home/dev/.t3/worktrees/dewdrop/t3-a53e5c96`.
No master edit, push, PR, merge, parent-status edit or other-worktree edit was
made. Read-only accepted native tools and a copy of their build cache were
reused. The parent owns acceptance and landing.

## Engine and ownership

The existing engine in `std/collections/btree.dew` keeps the selected plan,
node bodies and result policies. Values stay in leaves. Plain separator keys
have one ancestor home. The value for separator i is the head in the leftmost
leaf below child i+1. Reads and replacements use that walk when they need the
value. Contains can stop at the key. Equal queries retain the stored key.
Leaf heads are uncounted; map length equals the sum of all node key counts.
There are no sibling links, parent pointers, stored fences or copied minima.

The first search saves no path. A hit changes only its value; a fitting leaf
gets the new entry directly. Only a full target starts a second search with
a bounded path. The second search supplies the fresh result. Each full node
splits its C existing keys before insertion, with the selected M/A/j rules.
Keys, values, heads and child edges move together. All vacated reference
slots, including the promoted source, are cleared from permanent defaults.
No default slot is an overflow entry. There is no sibling redistribution.
Root growth replaces the private root reference normally.

The structural commit is shared across Bool, Unit and old-value policies.
Bool/Unit make no discarded Option. A requested old value is read before
replacement, including a leaf head. Plain maps have no prefix object.

The lazy work object holds 15 typed path references and 15 U32 edges, plus
one hint slot and a permanent default node slot. The node array has 17 slots.
Path references are cleared when popped or when propagation stops. No path
object exists before a full target. The hint contains only a leaf reference;
there is no cached key or count. Only a new-maximum splitting write whose
path took all last edges installs it. Hint use clears its slot before user
comparison and restores it only after a successful append. Equal, smaller,
full and other mutating paths invalidate it. Reads retain it. Taking and
restoring the hint make no new object. Clear detaches root and work, including
the hint, in constant time. Normal GC then owns reclamation.

Identity tests use typed source `ref.eq`, without IDs or an identity table.
The compiler, registry, intrinsic catalog and production optimizer flags are
unchanged. The standard bootstrap mirror matches the ordinary Dew source.

## Correctness evidence

Final ordinary private tests: **40 pass in raw and unchanged O4s**. Public
plan/provider tests: **8 pass in raw and O4s**. Native identity tests: **3 pass**.
Selected native backend tests: **1 storage and 2 plan/provider cases pass**.
Both mirror checks and `git diff --check` pass. The shared
`PRIVATE_BTREE_TESTS` list includes the new file for normal and Starshine lanes.
No full pinned Starshine, workspace-wide, stress or release gate is claimed.

Coverage includes:

* All 62 modeled U64 leaf gaps; every leaf gap for capacities 12..65, 127,
  255 and 1023; every full-parent edge for capacities 12..24, 31, 39, 40, 61, 64 and 82.
  Default-budget forced-plain U64/U64 sorted and permuted trees of 4,096
  entries also split branches and match the independent array model.
* Six sorted-array model runs with seed 137, 6,500 writes and 4,000 possible
  keys, both comparator directions, sorted/reverse/random input and mixed
  12/13 capacities. Every mutation checks all live keys/values, length and
  the inspector. Each run grows at least three branch levels.
* Reference-key identity and retained snapshots for 400 keys at leaf and
  ancestor homes; Bool/Unit/old-value policies at heads; aliases and clear.
* I32/I64/F32/F64/V128/reference/Unit/Option/nested Option values, exact float
  bits, caller Unit effects, and no Default or witness-object requirement.
* New-key U32 overflow before edits or work allocation, regular and separator
  replacement at maximum length, path overflow and workspace reuse.
* One search for fit, two for a full target, one comparison for hint append,
  hint install/read/restore/invalidation/full reuse and clear release.

The logical inspector checks unique node ownership, count/capacity/minimum
occupancy, strict whole-tree order and child fences, equal leaf depth, column
shape, head ownership, plain prefix state, the global length equation, empty
work depth and rightmost hint identity. Its seen-node array starts at 16 and
grows with visited nodes. A damaged global length does not size its storage.
Seven exact source failures cover overflow/path/count/head/length/occupancy;
an unrelated trap cannot pass those cases.

Physical inspection in copies checks every inactive/default key, value and
child slot, including moved/promoted sources, and all released path slots.
It runs after each of 2,000 reference mutations, all 62 reference leaf gaps,
and final 10,000-entry sorted/reverse/permuted trees of leaf depth 3. Six
intentional corruptions check exact failure text for promoted/default keys,
promoted values, moved children, duplicate node homes and unequal depth.
A separate arithmetic check passes all **524,722** capacity/gap combinations
from C=12 through 1023. This checks formula/occupancy consistency only.
The sum equalities are algebraic identities; it does not call the Dew engine
and does not add runtime movement coverage.

## Red and green record

The first valid split test compiled in 6.687 s and failed at the old full-leaf
checkpoint. The engine compiled in 8.657 s and all split gaps passed; the old
expected full-root trap then correctly failed. It now checks Unit root growth.
A source-format error and two test expectation errors remain in raw logs:
the first random input did not force a third level, and a hint check stopped
one write before a split. No failure was hidden or treated as a positive pass.

The first physical split failed its allocation bound: a tuple match made one
extra `array.new_fixed`. Nested direct body matches remove it. The later
probe-only assertion message also allocated on success; a failure-only guard
fixes that probe. Both raw/O4s constructor bounds and all old warm probes pass.

## Commands and compiler time

Run from this bound worktree with the exact tool paths in the machine record:

```bash
DEW_NATIVE_TEST_PACKAGES=semantic/standard_module_identity_wbtest.mbt tools/test-native.sh
DEW_INTEGRATION_TEST_FILES='src/backend/btree_storage_primitives_wbtest.mbt src/backend/btree_plans_providers_wbtest.mbt' tools/test-integration-native.sh
python3 tools/test-btree-plain-splits.py \
  /home/dev/.t3/worktrees/dewdrop/t3-38b925be/_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe \
  /home/dev/.t3/worktrees/dewdrop/t3-38b925be/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  /home/dev/.t3/worktrees/dewdrop/coordinate-dewdrop-btree-build/_build/native/release/build/jtenner/starshine/cmd/cmd.exe \
  --output .tmp/btree-step-4/final
python3 tools/btree-splits/check-arithmetic.py .tmp/btree-step-4/split-arithmetic.json
python3 tools/generate_btree_std.py --check
python3 tools/generate_standard_module_identities.py --check
```

The final inspector and post-review test changes were rechecked with the same runner's
`--tests-only --output .tmp/btree-step-4/review-tests`. Production engine and
benchmark bytes did not change. The manual public O4s command and validation
are also saved. O4s is exactly `--optimize-level 4 --shrink-level 1 --optimize`.
No experiment pass list was used. The prior root-leaf harness and its cases
remain supported; only obsolete checkpoint/shape expectations changed.

Every compiler/optimizer/assembler/validator call has its own wall time,
arguments, stdout, stderr and exit status. The longest compiler activity here
is below 30 s. The final test compile is 18.296 s; raw tests are 18.255 s;
O4s is 0.347 s and optimized tests are 21.115 s. The physical compile is
4.968 s and O4s is 0.109 s. Final native identity is 9.674 s; backend files
are 16.716 s and 1.268 s. Positive failures stop the runner.

The inherited dirty-build bugs remain open: step-3 native CLI 53.872 s,
test generator 30.596 s, and the recorded cold Starshine CLI 269.899 s.
These were not repeated or newly explained. Compiler/registry semantics
match the reused native tools. `DEW_STD_ROOT` points here and
`DEW_PROGRAM_CACHE=0`; later native checks use the current embedded source.
No Starshine CLI was rebuilt. The prior general Option layout/diagnostic
bugs remain documented in [the step-3 note](btree-step-3-generic-option-layout.md).
All required carriers use the tested return-to-caller form. No compiler
special case or unused witness was added.

## Constructor and layout cost

The recorder covers array.new/default/fixed/data/elem and struct.new/default.
Only copies are instrumented. Runtime samples use original modules. Counts
are executed Wasm constructors, not exact native heap allocations or bytes.

All measured warm fit/replace/contains/read/hint paths execute zero private
tree/path/search constructors, in both variants and every value carrier.
Numeric Bool/Unit calls execute no constructors. A requested get/put Option
adds its one API object. Text providers still make their observed Ordering
results: one for the fixed hit probe and two for its miss probe. Those are
counted separately. Whole-call object freedom is not claimed for these APIs.

| Numeric structural change | Arrays | Structs | Required state |
| --- | ---: | ---: | --- |
| First leaf + new root | 6 | 9 | Two nodes, first-use work, root Option |
| Later leaf split | 2 | 3 | One node; work reused |
| Leaf + parent + new root | 6 | 10 | Three nodes, root Option; work reused |
| Non-root parent split | 4 | 6 | Two nodes; work reused |

Each node has its selected arrays, body payload, enum and wrapper. First-use
work has two arrays, one wrapper and its retained Option. A new root also
replaces its existing Option ownership envelope. No result/path/split tuple
is an extra retained or temporary allocation. Raw and O4s bounds match.

The selected Unit body has only its key array. The plain map has ten physical
fields: root/count/work, six compiler comparator carrier fields and plan.
The lazy work reference is the only new map field. Empty construction has
zero arrays and six structs, one more None state than the prior five. Clear
makes two None-state objects, one more than before, and
leaves no root/work/hint reference through the map. Tests may retain outside
references. No peak/live heap, retained-byte, GC-pause, alignment, cache-line
or exact bytes-per-entry claim follows from these constructor/layout checks.

## Runtime controls and code size

Final data uses Node **v24.22.1**, V8 **13.6.233.17-node.58**, default WasmGC,
no custom flags or emulation, on native x86_64 Linux 6.12.113, glibc 2.41,
AMD Ryzen 7 8845HS. Earlier trials used Node v24.21.0/V8 node.53 and stay
separate. There is no runtime gain claim across engine versions. Final
baseline/current trials have the same version before and after the run.
Moon is 0.1.20261012 (`748b63c`); wasm-tools is 1.262.0 (`e22db44da`).
Starshine is pinned at `1b237952167f582abd492aec27adf10c5a6c9e60`.

There are four fresh Node processes per variant, three warmups and six
samples per case. Case order alternates within each process; process launch
order also alternates. All 816 measured samples, raw windows, checksums and
order remain in the record. There is no CPU affinity or forced GC. No exclusive measurement lease was
obtained. The standing lease rule arrived after the timed runs; no further
timing run was started. These are uncontrolled local samples, with no claim
of a quiet host. Any new coordinated timing needs a coordinator lease. Large-tree
measurements have substantial noise; no best sample is selected.

Root-leaf controls use the accepted baseline source, the same compiler and
matched exports/inputs: 31 even I32 keys, I64 values, 3M point operations or
100K rounds of 31 fit writes. Fit includes one node clear per round. The
array control is a lower bound, not an OrderedMap comparison. Multi-level
controls use 4,096 and 1,000,000 keys, 1M operations per point sample and
100K keys per build sample. Build permutation uses a U64 product; query
multiplication intentionally wraps U32. Half of lookup queries miss. Timers
surround whole loops, not each key. All input rules and checksums are saved.

| Root-leaf median ns/op | Prior raw | Current raw | Prior O4s | Current O4s |
| --- | ---: | ---: | ---: | ---: |
| Lookup | 16.853 | 17.553 | 17.348 | 18.759 |
| Direct control | 7.709 | 7.674 | 7.669 | 7.622 |
| Contains | 18.067 | 12.757 | 21.255 | 13.755 |
| Unit replace | 15.421 | 15.840 | 16.204 | 16.646 |
| Fit Bool | 36.633 | 38.691 | 38.340 | 38.586 |

The fixed shared-engine cost is measured. Original raw Wasm instruction
counts add about 44.58/op for lookup, 75 for replacement and 72 for fit.
The direct-array count is unchanged. The shared body must distinguish a
branch/head destination, and writes must check the hint before user code.
These checks add work without another search or private allocation. A
separate early-hint gate was inconclusive because per-process engine identity
was not pinned. It was not adopted.
Wasm instruction counts are not CPU branch or instruction measurements. The
observed contains reduction has no established native/JIT cause; the table
is a measurement, not a causal performance claim.

| Multi-level median ns/op | Raw | O4s | Raw min–max | O4s min–max |
| --- | ---: | ---: | --- | --- |
| 4,096 half-hit lookup | 54.846 | 53.767 | 52.792–59.460 | 52.577–59.819 |
| 1M half-hit lookup | 600.717 | 615.104 | 458.809–688.971 | 542.357–678.890 |
| 4,096 replacement | 52.856 | 51.415 | 51.153–57.656 | 50.761–52.249 |
| 1M replacement | 629.678 | 634.130 | 518.988–751.538 | 555.019–694.741 |
| Sorted build with hint | 27.235 | 27.211 | 26.201–32.876 | 26.791–32.534 |
| Sorted explicit drop-hint control | 78.455 | 76.727 | 76.030–90.516 | 75.449–81.254 |
| Permuted build | 144.013 | 143.652 | 134.659–164.223 | 139.114–184.414 |

The multi-level config is deliberately `(1024,64,64)`, forced plain, with
leaf capacity 82 and branch capacity 13. It is not default-config speed.
The 4,096-entry tree has leaf depth 2, 92 nodes and 83 leaves. The 1M tree
has leaf depth 5, 19,625 nodes and 17,679 leaves. These shapes were read
from a copy with only raw array getters added; timing uses original modules.

Each rate is total loop throughput; ns/op and M ops/s are reciprocal scales.
The JSON keeps operations and elapsed time so neither is hidden. The
explicit drop-hint control includes its clearing cost; it is not an exact
causal speedup estimate. These results establish this checkpoint's costs,
not full release, red-black map, delete/churn, cursor or batch performance.

Sharing structural commits reduces matched raw code from 162,239 to
145,392 bytes, and O4s from 94,604 to 82,592 bytes. These are source-policy
code-size savings, not a runtime claim across engines. The prior root-only
code is smaller (74,956/43,484 bytes) because it has no balancing. Matched
probe compile times are 1.960/3.289 s for prior/current. The private-suite
compile grows from the recorded step-3 7.3 s to 18.296 s, with much more test
coverage; this is not a matched compiler-speed comparison. Emitted
function counts for prior/current root controls are 520/669 raw and 390/472
O4s; they are not an exact source-specialization census. Numeric search keeps
the standard branchless path; custom/reference comparison keeps early equality.
Raw emission has no indirect comparator/policy call. O4s may use fixed
function-reference forwarding. No unresolved runtime type-query call is used.

## Exact identities

Common source SHA-256:
`07cf77b1797b3eef02e3564802426663f763f8c84cced2f205a6ef8a0a9b9724`.
The record gives every changed source hash and every tool/module identity.

* CLI: `fc009a79bd5547d625ca222d32b9dfec85aa17ca651e277559fa58a139ec8e07`.
* Test generator: `eb239ce2bb5cb150117a9889ae969113f3b4312a1402455697cb62f9e336b8fc`.
* Starshine CLI: `7b00526a1d7774e9860b45bac6e68035e6d4c20698c6e396896fa4aacb23d790`.

| Full probe | Module bytes | Code bytes | SHA-256 |
| --- | ---: | ---: | --- |
| raw | 369,651 | 161,865 | `a98ca3dc07a3fe87e36b882914622f747c9ca6eadcc201baef635967275b9bf9` |
| O4s | 100,283 | 92,114 | `69360ee3e53e494f6f78e23b29eb0c31675289d865059066e92f33e0b19a487c` |

The stripped baseline hashes equal the accepted step-3 controls:
`901ddad5308fe84542c09c08846c6d59fdec6b932a53b29f35ce53cd418af60a`
(raw) and `b83b748350975cb86d852fa5d40f5b9a6040d4bad877ff50f675bb93cd077d68`
(O4s). Matched current root-leaf stripped hashes are
`90ef9317858e77ea84ece9521e27836df8ae4ebe026b25336ea7cd4eb41937f7`
and `5b2b3ee7360298023625c32b7857367817def71838d946096021d9238406e930`.
Module size is not map heap size.

## Review and records

Read-only Sol/high analysis confirmed the original split tuple allocation
and no second temporary on that numeric path. It did not review the fix,
whole compiler, all carriers or performance. The fixed constructor bounds
were checked independently in raw and O4s.

The first Claude Code Opus/high attempt hit its session limit without reading
inputs. A later normal-authentication read-only review inspected the scoped
engine source, tests, diff, harnesses and summary evidence. It found no
confirmed engine defect. It found report/traceability and coverage gaps.
The report is partial: it did not read binaries, WAT or raw sample files;
some supporting files were read only as diff hunks or with grep. A Git HEAD
read outside this worktree was denied. No credential bypass was attempted.
The full read/unread list is saved; a zero exit code is not full coverage.
A narrow follow-up used the intended Git worktree folder with the same
read-only restrictions. The denied HEAD read then succeeded. It inspected
the added tests and responses and found no blocking defect. It did not read
binaries, WAT or raw samples. Final records clarify the remaining head-label,
prior-tool command and arithmetic-scope points; raw records are preserved.

I verified the findings against source and records. The final report replaces
the stale interim text, states empty/clear and baseline compile/code-size
costs, and gives the non-default runtime config and shape. Git blob hashes
verify the measured engine/probe bytes against the reviewed commit. The old
39-test record matches that commit; the earlier 38-test record differs only
in test/diagnostic files. Post-review tests cover the larger split-bias regime,
default-plan branch growth and the new-key overflow message through the write
API. The arithmetic checker is now committed and timed. The changed old
physical driver and exact-message tool were run successfully. The full
ordinary stdlib assembler/run.sh and full pinned Starshine suite were not
run; only the focused shared private lane is claimed. Comparators/providers
must not mutate or reenter the map, as the design requires; no busy flag was
added. Gate timing is marked inconclusive. The parent owns a full independent
review and landing.

Raw commands, streams, statuses, original/stripped/instrumented Wasm, WAT,
site maps, samples and review packets are under `.tmp/btree-step-4/`.
Essential committed records are:

* [Measurements, samples, constructor counts and identities](data/btree-step-4/measurements.json).
* [Source tuning and original allocation failure](data/btree-step-4/tuning.json).
* [Review scope, reports and limits](data/btree-step-4/reviews.json).

No new compiler or design bug blocks row 4. The inherited compiler bugs and
unmeasured heap/GC/CPU limits above remain explicit. The parent must review
and land this branch; this worker did not push or merge it.

## All changed files

* `docs/research/btree-step-4-plain-splits.md`
* `docs/research/data/btree-step-4/measurements.json`
* `docs/research/data/btree-step-4/reviews.json`
* `docs/research/data/btree-step-4/tuning.json`
* `src/standard_sources/standard_btree_sources.mbt`
* `std/README.md`
* `std/collections/btree.dew`
* `std/tests/btree_plain_fit_test.dew`
* `std/tests/btree_plain_splits_test.dew`
* `tools/btree-fit/diagnostics.mjs`
* `tools/btree-fit/record.py`
* `tools/btree-splits/carriers.dew`
* `tools/btree-splits/check-arithmetic.py`
* `tools/btree-splits/control-instructions.mjs`
* `tools/btree-splits/diagnostics.mjs`
* `tools/btree-splits/physical.dew`
* `tools/btree-splits/run.mjs`
* `tools/dew-test/assemble.py`
* `tools/test-btree-plain-fit.py`
* `tools/test-btree-plain-splits.py`
