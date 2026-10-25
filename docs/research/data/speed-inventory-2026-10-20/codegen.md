# Runtime output and code generation speed inventory

Read-only source review, 2026-10-20. No build, test, or benchmark was run.
Dewdrop HEAD: `69ea1cb533edd60353e0a9f49d6169403c92ef41`.
Starshine HEAD: `1b237952167f582abd492aec27adf10c5a6c9e60`.
Line numbers refer to the current worktree. Local edits can be present.

P1 means test soon. P2 means test after the P1 work. Costs below are visible
in source. Proposed speed gains are hypotheses unless a saved result is given.
Saved results use older build identities. They show useful test cases, not
current speed claims.

## 1. P1: Use bulk copies in Array copy, slice, and copy_within

- Evidence: `std/array.dew:199`, `:203`, `:241`. Copy calls slice. Slice uses
  get/push for each item. Copy-within has forward and backward get/set loops.
  `std/wasm/intrinsics.dew:28` already exposes one-to-one `array.copy`.
- Cost: O(n) Dew loop trips, range checks, wrapper reads, and function calls.
  Copy-within also pays two checked accessor calls per item. A Wasm bulk copy
  does the same memory work with one instruction and engine-side bounds checks.
- Work: Keep these as Dew library functions. Check the range once, allocate the
  exact output where needed, then call `wasm_array_copy`. Set count once.
- Impact: Likely high for large arrays, and for runtimes with costly GC helpers.
  Lower code size is likely too. No new allocation is needed.
- Risk: Preserve overlap behavior, independent output backing, reference
  identity, Unit storage, packed narrow types, and trap order.
- Exact validation: Run `python3 tools/benchmark-array-methods.py --iterations
  2000 --samples 41 --rounds 7 --output .tmp/array-bulk-copy.json`. Add a paired
  kernel for lengths 0, 1, 16, 256, 4096, 65536, with I32, U8, Unit, and nominal
  reference items. Include both overlap directions. Measure raw, speed, and
  speed-deep output in Node and Wago; count array.get/set/copy and encoded bytes.
- Status: The old August note claims native bulk lowering. The September
  library migration removed that special path. Current code confirms the loops.

## 2. P1: Use array.new and array.fill for repeated values

- Evidence: `std/array.dew:151` fills a preallocated Array through push;
  `:230` fills through checked set calls. `std/wasm/intrinsics.dew:16` has
  `wasm_array_new`; `src/semantic/raw_array_contracts.mbt:4` has no array.fill
  contract, and the intrinsic facade has no array.fill declaration.
- Cost: O(n) loop trips and count/reserve work for make; O(n) checked setter
  calls for fill. All values are already evaluated once before these functions.
- Work: Construct make's wrapper around `wasm_array_new(length, value)` with
  count/limit equal to length. Add the exact Wasm array.fill intrinsic, contract,
  and emission support, then use it from the normal library function.
- Impact: Likely high for large arrays; fewer instructions and smaller modules.
- Risk: Preserve narrow storage normalization, Unit effects, and empty/bad range
  behavior. Do not add an algorithm builtin or dispatch on a standard path.
- Exact validation: Use the command and carrier/length matrix in item 1. Add
  make and fill-only exports with a dynamic item and a checked checksum. Require
  one array.new for make and one array.fill for nonempty fill after range checks.

## 3. P1: Reserve once and bulk-copy Array extension

- Evidence: `std/array.dew:254` captures source count, then pushes one item at
  a time; it does not reserve once. `:163` doubles capacity when needed.
- Cost: Every source item repeats reserve/access work. A large extension into
  an empty or small target makes multiple backing arrays and copies prefixes
  on the way to the final size. Time stays amortized O(n), but memory traffic
  and temporary heap use are much higher than one reservation and copy.
- Work: Check overflow once, reserve the full source count, copy the old source
  range to the old target end, then publish the new count. Handle self-extension
  using the captured count and the post-reserve source backing.
- Impact: High for flat_map, concat, and bulk input. Lower temporary memory.
- Risk: Self-aliasing, growth publication, count overflow, and reference storage.
  Capacity is observable. Use the existing reserve rule rather than inventing a
  new rule for ordinary push.
- Exact validation: Extend 0/1/16/256/4096/65536 items into targets at 0, 1,
  full capacity, and sufficient capacity. Include self-extension and two wrappers
  with shared backing if such sharing is legal. Batch 262144 copied elements,
  seven alternating rounds, 101 samples. Reuse the Array method harness, plus
  dynamic backing-allocation and copied-element counters.

## 4. P2: Remove the one-slot array allocation when a full Array shrinks

- Evidence: `std/array.dew:1425`. A full Array allocates a blank one-element
  Wasm array at `:1431`, then copies its default slot into the old backing.
  Every `pop` from a full buffer reaches this path through `:65` and `:190`.
- Cost: One GC allocation on the first pop/clear/truncate from a full backing.
  Repeated fill-to-capacity/pop cycles repeat that allocation. Larger clears
  then use O(log n) array.copy calls to spread the blank value.
- Work: After item 2, test direct default-value fill. If default generic values
  cannot be expressed safely, test a one-to-one storage instruction or a
  representation plan that supplies the correct typed default without a heap
  object. Keep the algorithm in Dew.
- Impact: Medium for stack/queue churn and reference-heavy clears; lower heap
  pressure. Do not assume numeric arrays need reference clearing.
- Risk: Correct defaults for scalar, packed, nominal, generic, and Unit storage.
  Cleared references must stop retaining the removed objects.
- Exact validation: One million alternating push/pop operations at capacities
  1, 4, 256; clear/refill at 256 and 65536. Use numeric and nominal-reference
  items. Count dynamic allocations and retained live bytes as well as time.

## 5. P1: Build one cursor/event core for typed JSON decoding

- Evidence: `std/json.dew:774` builds a dynamic JsonMember Array and JsonValue
  tree; `:803` and `:881` parse separate key/value results. The saved exhaustive
  study gives retained parse at 3.928 us/11.401 us for medium/large, versus
  0.753/2.640 us for json-as dynamic and 1.735/3.461 us for json-as typed.
- Cost: Recursive tree allocation, generic collection mutation, and Result
  propagation occur for every value, including fields that a typed caller could
  put directly into its output or skip.
- Work: Add a shared cursor/event engine as ordinary Dew code. Use one pass to
  build a frozen schema directly. Preserve the current generic parse API.
- Impact: High ceiling on schema-heavy JSON and much less temporary memory.
- Risk: Same duplicate-key rule, limits, exact numbers, Unicode, error offsets,
  and schema error behavior. A new public API needs clear ownership rules.
- Exact validation: Extend `tools/benchmark-json-typed-prototype.py` so generated
  fields consume one cursor instead of reparsing slices. Run small/medium/large
  fixtures in `tools/benchmark-json-retained.py --samples 101 --rounds 7`, plus
  one 79-field object and nested arrays. Check exact semantic parity before
  timing. Record allocation counts and peak heap.
- Status: A slice-per-field prototype already lost badly on large input:
  32.767 us versus 15.470 us for compact parse. Do not repeat that design.

## 6. P2: Switch very wide JSON objects to exact hashed duplicate tracking

- Evidence: `std/json.dew:722` scans the prefix for a key. `:840` uses a Bloom
  filter before that scan; validation repeats the same shape at `:1103`.
- Cost: Once Bloom bits fill, many new keys scan much of the object prefix.
  Worst-case duplicate checking remains O(k^2) string comparisons for k keys.
- Work: Test a thresholded exact hash structure only for very wide objects.
  Retain the current cheap path for small objects. Derive the threshold from
  allocations and time, not only operation count.
- Impact: High on wide objects; likely small or negative on normal small JSON.
- Risk: Keep exact duplicate equality, escaped-key handling, and strict limits.
  Extra buckets and entry allocations can outweigh saved comparisons.
- Exact validation: Unique and late-duplicate objects with 8, 16, 32, 64, 128,
  512, 2048, 8192 keys; short/long and escaped keys; parse/validate/roundtrip.
  Seven alternating rounds of 101 samples. Include retained heap and static
  code size. Use the exact-Set experiment in the exhaustive study as the control.
- Status: Unconditional Set was rejected: small parse +12.95%, small validation
  +8.64%, medium parse +2.78%; large validation improved 6.27%.

## 7. P1: Extend private aggregate scalar replacement across calls and loops

- Evidence: `src/semantic/program_optimization.mbt:4688` requires fresh
  construction as the projection base. `:5393` requires a local initializer to
  be PlannedStructNew. `:5441` rejects local uses that are not a direct field
  projection. Calls and loop-state transfer therefore remain barriers.
- Cost: Small private aggregates that only carry fields between known functions
  can still allocate once per call/iteration. Later local field folding cannot
  remove a reference ABI that has already been fixed.
- Work: Start with a private immutable two-scalar parameter/result. Propagate
  component values through known call sites and loop state; materialize only at
  an escaping edge. Add size and specialization budgets.
- Impact: Potentially high for functional loops and parser state; lower GC work.
- Risk: Identity, aliasing, source-order traps, captures, return ABI, code growth.
- Exact validation: Extend `tools/benchmark-component-scalar-replacement.py
  --fields 32 --samples 10000 --batch 100` with a dynamic-input private helper
  and 10000-step aggregate loop. Compare public/escaping controls. Require no
  new struct allocation in the steady-state loop; measure Node/Wago and bytes.
- Status: Fresh/local scalar and exact nominal-reference components, join
  projections, known variant projections, and exact trait flow already work.
  The saved tests show tied scalar cases and 6–13% nominal-wrapper gains. Do not
  list those implemented cases again as new work.

## 8. P1: Broaden private enum/result carriers with measured adapters

- Evidence: `src/semantic/program_optimization.mbt:3572` rejects generic/public
  layouts. `:3589` accepts only one I32 tuple payload; `:3599` rejects struct
  payloads. Current result consumers also require exact bounded match uses.
- Cost: Common private Option/Result shapes with reference, U32, I64, or multiple
  payload fields retain GC construction and match casts across calls.
- Work: Test one closed private multi-value/tag carrier at a time. Keep public,
  foreign, and function-value boundaries behind explicit adapters. Use one
  general rule for user and standard code.
- Impact: High ceiling for error-heavy library APIs and hot success paths.
- Risk: Recursive generic ABI, error edges, result duplication, code size, and
  adapter costs can cancel the gain. Start from isolated private helpers.
- Exact validation: Extend `tools/benchmark-scalar-payload-enum-abi.py --cases
  64 --samples 10000 --batch 100` with U32/I64/reference/two-field results,
  dynamic success/failure ratios 100/0, 99/1, 50/50. Count allocations, casts,
  native code size, and both success and failure time.
- Status: Private unit tags and unit-or-one-I32 packed i64 ABI already work.
  The saved packed test removed 65 allocations and measured 0.5512x runtime.

## 9. P1: Carry exact physical reference types through locals and calls

- Evidence: `src/backend/starshine_code.mbt:1614` inserts storage casts at
  nominal boundaries, including `:1633` and `:1640`. The JSON study counted
  330 static casts; the older map workload counted 40899 and expensive runtime
  helper transitions. Current field CSE does not carry this proof through calls.
- Cost: Repeated proven-safe casts and base loads cost time and code space,
  especially in Wago. Most casts at erased or mutable boundaries remain needed.
- Work: Preserve exact physical type and dominance facts through immutable
  locals and precise call summaries. Remove only casts proved redundant on the
  same value. Use typed scratch locals where this reduces repeated tests.
- Impact: Medium to high on aggregate-heavy code, engine dependent.
- Risk: Nullability, subtype/recursive type identity, mutation, and trap order.
  A text peephole that drops repeated cast spelling is unsafe.
- Exact validation: JSON parse/roundtrip plus `tools/wago-map-bench/bench.mjs`;
  add a 10000-iteration nominal load kernel with/without an intervening mutating
  call. Compare static ref.cast sites, dynamic helper count, time, and native
  bytes on Node/Wago. Include invalid-reference and subtype trap controls.

## 10. P2: Give known closure calls one exact ABI path

- Evidence: `src/backend/starshine_closure_calls.mbt:93` builds direct, erased
  direct, captured, and erased captured alternatives. `:113` loads/casts the
  closure and tests a function signature for each alternative. Each chosen arm
  reloads that pointer at `:56` before call_ref.
- Cost: Up to four emitted argument/call arms and several runtime tests per
  unresolved closure call. Hot Array callbacks can repeat this work per item.
- Work: Where semantic flow proves capture kind and exact signature, emit only
  that arm; otherwise load the pointer once if the typed proof permits it.
  Preserve the complete path for truly mixed flows.
- Impact: Medium on callback-heavy loops; smaller modules and native code.
- Risk: Erased Unit argument evaluation, product results, signature traps,
  mixed capture joins, and generic callback ABI.
- Exact validation: Use the `closure-loop` workload in
  `tools/starshine-experiments/benchmark.py`, extended from 4 iterations to
  10000 dynamic iterations, with exact captured, exact uncaptured, and mixed
  callbacks. Compare raw/speed/deep, call_ref/ref.test/ref.cast counts and bytes.
- Status: Transparent callbacks and exact trait-object flows are already
  directized in bounded cases. Measure a residual indirect call before work.

## 11. P2: Convert self-tail recursion to a local loop

- Evidence: `src/semantic/program_optimization.mbt:8049` rejects reference and
  generic carriers; `:8086` rejects receivers and generics. Accepted sites emit
  return_call, rather than a local loop. `docs/research/tail-recursion.md` records
  128 steps at 0.101 us versus 0.080 us for a functional loop.
- Cost: A tail transfer still carries function-call work each step. Reference
  recursion also retains ordinary calls due to a documented Wago defect.
- Work: Convert proven self-tail calls to simultaneous state-local assignments
  plus a structured loop. First support scalar cases, then exact references.
- Impact: Medium for recursive hot algorithms; constant stack and possible
  speed gain. Avoid claiming return_call alone is faster.
- Risk: Argument swap order, traps, cleanup, captures, local liveness. General
  mutual recursion needs a separate design. Do not lift reference restrictions
  on return_call until the Wago defect is fixed.
- Exact validation: `python3 tools/benchmark-tail-recursion.py --count 128
  --deep-count 100000 --samples 10000`; add 10000/100000-step dynamic tests,
  swapped parameters, nominal reference state, and trap-order controls in both
  engines. Compare loop against call and return_call output, including bytes.

## 12. P2: Avoid needless aggregate reconstruction in erased adapters

- Evidence: `src/backend/starshine_program_adapters.mbt:1651` walks generic
  aggregate fields, recursively adapts nested values, and emits a fresh struct
  at `:1953`. Enum adapters similarly emit constructors at `:1621`.
- Cost: Passing a nested generic value across a genuinely erased boundary can
  walk and reconstruct its aggregate graph, with work proportional to size.
  Some same-physical-shape cases may be avoidable; the cost needs a real probe.
- Work: Add an exact representation-equality proof to reuse a carrier where
  source and target layouts are the same. Prefer private specialization before
  a hot erased edge. Keep conversion for different physical layouts.
- Impact: Potentially high at deep generic boundaries; no gain for plain scalar
  calls that already use physical specialization.
- Risk: Mutable aliases and identity, cyclic structures, boxes, recursive types,
  callback wrappers, and ABI correctness. Blindly skipping adapters is unsafe.
- Exact validation: New paired fixture: depth-1/16/256 immutable generic chains,
  passed through 1000 erased identity/invoke calls with dynamic leaves. Add
  mutable alias and recursive controls. Count reconstructed nodes per call,
  retained heap, time, and specialization/module bytes. Use the existing
  `tools/benchmark-trait-object-escape.py --samples 10000 --batch 100` as an
  already-optimized scalar control.

## 13. P1: Remove speed-profile regressions before adding more passes

- Evidence: `src/dew_bootstrap/optimization.mbt:20` defines speed and `:28`
  defines the 50-pass speed-deep order. The saved deep study still has byte hash
  at about 1.48x O4s and map regressions. Speed-deep saves only about 0.73% more
  runtime overall than speed, at about 9.5x optimizer time for that test set.
- Cost: Inlining and cleanup can create slower engine machine code despite
  smaller Wasm. Repeated whole-module passes add compile cost. The saved study
  removed Heap2Local with no output-byte change in all 16 timed cases.
- Work: Find the first pass/order that causes the byte-hash and map regressions
  on the current pin. Test profitable pass gates from general IR facts, not
  source names. Do not make speed-deep the default on the old mean alone.
- Impact: High for users of hash/map hot paths; lower optimizer cost if redundant
  passes can be skipped. Cross-engine checks are required.
- Risk: Overfitting this small suite; pass-order correctness failures; size/time
  tradeoffs. Current profiles are implemented, so adding them is not new work.
- Exact validation: `python3 tools/starshine-experiments/benchmark.py --pipeline
  O4s --pipeline cli-speed --pipeline cli-speed-deep --rounds 7 --samples 41
  --target-ms 5`. Check aliases in pipelines JSON; use deep-pipelines JSON if
  needed. Prefix-isolate bytes-hash/hash-map/ordered-map and require full corpus
  execution checks before selecting any new schedule.

## 14. P2: Emit frozen function bodies in parallel

- Evidence: `src/backend/starshine_program_assembly.mbt:1019` appends function
  bodies serially, in one loop from `:1020` through `:1114`. Body emission already
  receives a frozen program/link/helper plan and returns an independent Func.
- Cost: Many independent body jobs use one core after planning. This is a clear
  candidate boundary, though no phase profile here proves it dominates.
- Work: Audit reads/mutations, then use bounded jobs for body emission. Merge
  results by frozen function index. Keep section/index planning and diagnostic
  ordering deterministic. Set a memory budget for concurrent instruction arrays.
- Impact: Potentially high compiler wall-time gain on large programs; no direct
  runtime gain. Small programs may lose to job overhead.
- Risk: Hidden shared caches, helper-plan writes, memory amplification, and
  target thread support. Prefer a measured job-size threshold.
- Exact validation: Reuse `src/backend/compile_scaling_bench_test.mbt` inputs at
  1/16/128/1024 independent functions and a full self-host compile. Compare
  1/2/4/8 workers: body-phase time, total wall time, CPU time, peak RSS, and exact
  output hashes over 10 fresh runs. Root measurement lane must choose commands.

## 15. P2: Intern adapter helpers/signatures with keyed maps

- Evidence: `src/backend/starshine_program_adapters.mbt:28` scans every helper
  for each insertion, and `src/backend/starshine_program_assembly.mbt:85`
  scans all previous helpers for a reusable signature. Callback signatures have
  another prior-wrapper scan at `starshine_program_adapters.mbt:946`.
- Cost: O(h^2) helper/signature search, plus repeated type-array comparisons.
  Large generated FFI and recursive generic callback graphs can have many h.
- Work: Build immutable key-to-index maps once. Preserve append order so output
  type/function indices remain deterministic. Cache equivalent signature keys.
- Impact: Medium compile-time and temporary allocation win for large adapter
  sets; likely low for small code. Profile before broad code changes.
- Risk: Incorrect keys that merge distinct modules, directions, substitutions,
  capture kind, or physical signatures. Canonical keys must include all fields.
- Exact validation: New generated graph with 16/64/256/1024 distinct generic
  recursive adapters plus repeated duplicates and mixed module identities.
  Compare helper-plan/type-section times, key allocations, peak RSS, and exact
  Wasm output. Include the full generated Starshine FFI consumer as a real case.

## Measurement support needed for runtime memory claims

`tools/wasm-metrics.mjs:64` counts static allocation sites, not runtime objects,
bytes, live heap, or collections. The JSON study already retained this static
metric. Add opt-in generic emission counters and deterministic query exports in
benchmark builds, with zero instructions or metadata added when disabled. Count
dynamic constructor calls and array capacities. Obtain engine heap/GC data where
available; report its limits. A static site can run a million times, and an
unused factory can contain allocations that never run.

## Avoid repeating these measured losses or stale blockers

- JSON Array-before-Map/Set scratch-local allocation is fixed. The exhaustive
  study retained that fix. Recursive generic visitor tests now link; the larger
  historical failure lacks a reduced current reproducer.
- Unconditional exact Set duplicate tracking loses on small objects (item 6).
- Typed JSON that reparses every field slice loses heavily on large objects
  (item 5). One root-index lookup also failed to beat raw validation/retention
  and grew modules to 20.2/24.8/46.2 KiB. Test repeated nested access before an
  index design; do not sell the old root-only prototype as a speed win.
- JSON SIMD digit validation was unstable: one saved validated-path run gained
  2.51%, another lost 1.54%. The final experiments also rejected unconditional
  builder preallocation, fixed initial Array capacities, cached writer lengths,
  direct String SIMD serialization, and unconditional two-pass output.
- Native Wago cast inlining lowered a historical map run to about 4.77 ms but
  grew native code from 14.6 MB to 22.6 MB. It was reverted. Shared checked stubs
  and producer-side proof are safer candidates than duplicating full checks.
  This is external Wago work, not a Dewdrop source fix.
- Tail-call emission gave stack safety and smaller output, but its saved branch
  test was 1.3115x slower than ordinary calls. Test local-loop conversion.
- More deep optimizer passes are not automatically better. The saved study found
  late Heap2Local output/runtime faults, SSA-after-inline faults, and a second
  local-cleanup wave that exceeded 30 seconds. These are historical repro leads,
  not verified current defects. Run them on the current pin before filing.
- Do not count stripped debug bytes as executable code improvement, emulate an
  architecture and call it native measurement, or use host-call-scale tied tests
  to claim speed gains from fewer GC instructions.

## Main saved evidence

- `docs/research/array-bulk-library-2026-09-05.md`
- `docs/research/json-exhaustive-performance-experiments.md`
- `docs/research/json-final-performance-experiments.md`
- `docs/research/scalar-replacement.md`
- `docs/research/escape-analysis.md`
- `docs/research/scalar-payload-enum-specialization.md`
- `docs/research/tail-recursion.md`
- `docs/research/compiler-cli-optimization-2026-09-10.md`
- `docs/research/starshine-deep-pipeline-2026-09-10.md`
- `docs/research/starshine-execution-pipelines-2026-09-10.md`
- `docs/research/wago-map-set-performance.md`
