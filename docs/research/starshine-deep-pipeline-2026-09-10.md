# Deeper Starshine pipeline study, 2026-09-10

`--optimize speed-deep` is the new optional 50-pass profile. It passes every
source fixture and all 16 benchmark workloads. On this machine it takes 0.73%
less time and uses 1.70% fewer encoded bytes than the existing 11-pass `speed`
profile. The runtime gain is small. Against the pinned `O4s`, the corresponding
changes are 8.66% less time and 14.21% fewer bytes. The existing `speed` profile
and command defaults remain unchanged.

```sh
tools/dew build program.dew -o program.wasm --optimize speed-deep
tools/dew build --optimize speed-deep --print-passes
tools/dew optimize input.wasm -o output.wasm --optimize speed-deep
```

This extends the [first CLI study](compiler-cli-optimization-2026-09-10.md).
The target is emitted-program runtime first, then module size. These are not
measurements of the self-hosted compiler executing as Wasm.

## Inputs and method

- Input compiler: committed Dewdrop `928eef9a`, SHA-256
  `14908686777956b3b6b9d9e124ed47c0cb58581c5e135670f1fd689bc74f91d6`.
  The separate worktree excludes the user’s ongoing source changes.
- Initial Starshine: `48d6337ce`. Final Starshine: `30c63c455`, native release
  SHA-256 `8c90baa509bf857d5af803852a544e237343c2c8da2d2c7ca53f5104709e76fb`.
- Each source run includes all 461 fixtures: 410 runtime cases checked in both
  Node and Wago, and 51 expected compiler errors. Validation, wrong results,
  wrong traps, optimizer errors, and timeouts remain distinct failures.
- Wago is the locally built runner from [PR #600](https://github.com/wago-org/wago/pull/600),
  which repairs typed-select decoding. Its hash is in each corpus report.
- Five source sweeps evaluated 64 distinct ordered argument lists (70 list
  executions including rechecks after the SSA repair). They cover direct passes,
  early versus late SSA/heap conversion, repeated cleanup, CFG coalescing,
  local subtyping, inlining limits, and shrink levels 0, 1, 2, and stock O4z.
- Final measurements use Node v26.8.1 on an AMD Ryzen 7 8845HS, CPU affinity
  8,10, seven fresh processes per workload, 41 samples, 150 ms warmup per unique
  module, and a common batch calibrated to at least 5 ms on the baseline.
  Each batch checks its result; inputs vary where the program has parameters.
- Equal Wasm bytes share samples. Alias records contain `equivalent_to` and
  a null compile time. The earlier screen measured duplicate instances and is
  retained as discovery evidence; only the shared-sample confirmation selects
  the CLI profile. Two direct-allocation workloads were measured in a second
  run with the same binaries, flags, and settings, then combined with the 14.
- Our compiler, test, and fuzz jobs were stopped during runtime timing.
  Independent user jobs were active during part of the run and were left alone.
  Paired rotation and affinity reduce noise; this is not a dedicated idle host.
  The small improvement needs confirmation on other machines and programs.

The real expanded Starshine O4z queue has 73 slots for the JSON input at this
pin; its order depends on module features. It failed 148 runtime fixtures in
discovery, so it cannot qualify as a correct speed candidate. The pinned O4s
queue has four passes: DFE, Vacuum, ReorderLocals, StripDebug. Neither statement
is a claim about Binaryen’s stock optimization schedules.

## Ordered schedule

All passes use optimization level 4 and shrink level 1, with normal trap rules.
Early module cleanup precedes Heap2Local and SSANoMerge. Inlining then exposes
local cleanup. SimplifyLocalsNoStructure and CoalesceLocals each run once, before
control cleanup: repeating them later caused the faults below. Later waves use
constant, common-expression, dead-code, and control cleanup. Module pruning,
memory packing, local ordering, and debug removal finish the module.

1. `duplicate-function-elimination`
2. `remove-unused-module-elements`
3. `once-reduction`
4. `global-refining`
5. `global-struct-inference`
6. `precompute`
7. `heap2local`
8. `ssa-nomerge`
9. `inlining`
10. `local-cse`
11. `simplify-locals-nostructure`
12. `dead-code-elimination`
13. `coalesce-locals`
14. `vacuum`
15. `code-pushing`
16. `code-folding`
17. `merge-blocks`
18. `remove-unused-brs`
19. `redundant-set-elimination`
20. `local-cse`
21. `dead-code-elimination`
22. `vacuum`
23. `precompute`
24. `inlining`
25. `local-cse`
26. `dead-code-elimination`
27. `vacuum`
28. `code-pushing`
29. `code-folding`
30. `merge-blocks`
31. `remove-unused-brs`
32. `redundant-set-elimination`
33. `local-cse`
34. `dead-code-elimination`
35. `vacuum`
36. `code-pushing`
37. `code-folding`
38. `merge-blocks`
39. `remove-unused-brs`
40. `redundant-set-elimination`
41. `local-cse`
42. `dead-code-elimination`
43. `vacuum`
44. `duplicate-function-elimination`
45. `remove-unused-module-elements`
46. `simplify-globals-optimizing`
47. `directize`
48. `memory-packing`
49. `reorder-locals`
50. `strip-debug`

The exact list is locked by the CLI test and matches experiment
`deep-60-single-local-wave` (the name records its origin; the final list has 50
passes). `cli-speed-deep` is its normal experiment-config alias.

## Measurements

| Profile | Passes | Time / O4s | Time / speed | Total bytes | Code-section bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| O4s | 4 | 1.000000 | 1.086796 | 60,515 | 53,807 |
| speed | 11 | 0.920136 | 1.000000 | 52,810 | 50,064 |
| early SSA/heap | 21 | 0.920630 | 1.000537 | 52,738 | 49,992 |
| long core | 28 | 0.913977 | 0.993306 | 52,061 | 49,315 |
| long SSA/heap | 30 | 0.914238 | 0.993590 | 51,983 | 49,237 |
| long, no coalescing | 29 | 0.913566 | 0.992860 | 52,396 | 49,650 |
| speed-deep | 50 | 0.913402 | 0.992681 | 51,913 | 49,167 |

Ratios below one mean less elapsed time. The aggregate is the geometric mean
of paired per-workload process ratios, with equal workload weight. Resampling
paired process ratios within each fixed workload gives a 95% interval of
0.98436–0.99891 for `speed-deep / speed`. This describes measurement noise in
this suite, not unseen programs. The 30- and 50-pass results are close; the
50-pass candidate also has the smallest measured modules among the survivors.

The size totals count both JSON exports as workload rows. Counting each of
the 15 distinct input modules once gives 44,300 bytes for O4s, 38,760 for speed,
and 38,166 for speed-deep: 13.85% and 1.53% reductions respectively. Across the
16 rows, the code section falls 8.62% versus O4s; debug stripping alone does not
explain the size gain. On the original ten workloads, time ratios to O4s are
0.87762 for speed and 0.86808 for speed-deep. Six small added cases have much
of their cost at the JS-to-Wasm call boundary, which limits sensitivity.

| Workload | O4s ns/call | speed ns/call | speed-deep ns/call | speed-deep bytes |
| --- | ---: | ---: | ---: | ---: |
| array-growth | 1330.9 | 925.7 | 915.7 | 2,930 |
| array-reserved | 1284.7 | 877.1 | 774.2 | 2,930 |
| hash-map | 781.9 | 838.4 | 858.9 | 2,448 |
| ordered-map | 3497.7 | 3750.9 | 3714.5 | 6,398 |
| bytes-hash | 3779.6 | 5612.6 | 5617.8 | 3,109 |
| string-hash | 10434.2 | 5602.4 | 5594.9 | 3,153 |
| enum-payload | 218.5 | 172.9 | 171.9 | 2,542 |
| tail-loop | 3239.2 | 3236.7 | 3236.7 | 71 |
| json-roundtrip | 11104.4 | 9720.3 | 9865.4 | 13,747 |
| json-canonical | 10899.1 | 9539.0 | 9656.3 | 13,747 |
| mutable-cell | 25.9 | 26.0 | 26.0 | 147 |
| temporary-pair | 38.9 | 39.1 | 38.9 | 147 |
| branch-join | 61.7 | 61.7 | 61.6 | 110 |
| closure-loop | 69.9 | 70.0 | 69.8 | 206 |
| local-cell | 25.0 | 25.0 | 25.0 | 131 |
| local-pair | 40.0 | 40.1 | 40.3 | 97 |

Byte hashing still takes about 48% more time than O4s; map workloads also
regress against O4s. The long order is not the fastest choice for every program.

Pass attribution removed Heap2Local or SSANoMerge from the full order on the
16 benchmark inputs. Removing Heap2Local produced exactly the same final bytes
in all 16; removing SSANoMerge changed only the two map modules. Thus the timing
data does not show an added Heap2Local benefit on this suite. The direct local-
pair source is already scalar in the raw compiler’s main function; its remaining
raw struct allocation is in an unused factory. These facts limit what the GC
microbenchmarks can establish. Attribution variants are not new validated CLI
profiles. The full selected order is the one checked on every fixture.

## Optimizer cost

A separate five-round, rotating-order command check reused the 15 distinct raw
benchmark modules and required every output hash to match the runtime-measured
artifact. Sum of per-module medians: O4s 76.94 ms, speed 124.19 ms, speed-deep
1,175.59 ms. The long profile costs about 9.5 times as much optimizer time in
this set. Ordered-map dominates: 14.63 ms versus 821.39 ms; JSON roundtrip is
33.19 ms versus 164.58 ms. Other deep-profile commands take 4.41–30.92 ms.
All measured individual commands remain below one second. This cost and the
small runtime gain are why speed-deep is optional. The ordinary speed profile
and `dew optimize` default stay unchanged.

## Correctness findings

Starshine `30c63c455` fixes the SSANoMerge conditional-operand fault. A closure
write inside an inner result-if was missing from forward LocalGraph. The raw
pass moved the write to a fresh local, left reads on the old local, then replaced
those reads with null. The module validated but trapped on a nonempty loop.
The analysis now visits each normal arm and joins its reaching writes. Native
positive tests and a reduced executable fixture cover the transform. All three
direct SSA failures are fixed; the before-inlining order passes every fixture.

| Order / pass | Remaining finding |
| --- | --- |
| SSA after inlining | 2 failures remain: map runtime and generic-never-match. Before the repair there were 10. |
| Heap2Local after inlining and local CSE | 3 failures. JSON reader changes output; portable I/O fails; a trait dictionary gets a non-null local initialized only inside a value block and then read outside it. Every first failing prefix names Heap2Local. Direct and early Heap2Local pass all 410 runtime fixtures. |
| Second CoalesceLocals after control cleanup | Map and set runtime failures. In the map prefix, passes 0–21 pass and slot 22 fails. CFG coalescing also fails in these longer compositions. |
| Second SimplifyLocalsNoStructure | Nested-pattern failure at slot 20; the preceding 19 slots pass. A deep/wide functional loop exceeds 30 seconds; tracing stops inside this pass. Running the local cleanup phase once removes both failures. |
| Smaller inlining limits | Limits 20 and 80 expose deep/wide-loop and nested-view failures in the longer order. These variants are rejected. |
| OptimizeInstructions | 2 wrong results and 1 wrong trap, separate from 99 exact-reference feature failures. |
| DAE / optimizing DAE | Each has 8 wrong trait-dispatch results. Optimizing DAE also has optimizer/runtime timeouts and an optimizer error. |
| Optimizing inlining | 10 invalid outputs, 3 wrong results, 4 wrong traps, 7 optimizer timeouts, 1 runtime timeout, and 1 optimizer error, separate from 94 exact-reference feature failures. |
| Flatten | 1 optimizer error and 2 optimizer timeouts, separate from 306 exact-reference feature failures. |
| Other direct faults | HeapStoreOptimization: 4 JSON optimizer timeouts; MergeLocals: wrong JSON reader result; PrecomputePropagate: 1 wrong control-flow result and 1 optimizer error; OptimizeCasts: 3 wrong collection/show traps; full SimplifyLocals: deep/wide-loop optimizer timeout. |

The direct-pass counts above are from the discovery revision `48d6337ce`.
Exact reference types / custom descriptors are not enabled in the default Node
used here. Those feature failures need separate checks and are not, by
themselves, proof that execution semantics changed. Wrong results, wrong traps,
invalid output, optimizer errors, and timeouts remain open defects; a passing
selected schedule does not close the failing pass compositions.

The [defect ledger](starshine-deep-2026-09-10/defects.json) contains each failing
fixture, category, input hash, and complete diagnostic. These faults remain open;
the new profile avoids their measured failing compositions. They are also in
Starshine’s active backlog. No module-name or fixture-name guards were added.

## Validation and evidence

- Red-first LocalGraph and SSA tests fail before the fix. The reduced runtime
  fixture fails with the old optimizer and passes 32 plain/bound closure checks
  after the fix, including both predicate outcomes and repeated SSA execution.
- Full native Starshine suite: 10,997/10,997. Final CLI unit suite: 9/9.
  Benchmark/runner tests: 7/7, including a wrong-result check and sample alias test.
- All three revised long orders (28, 30, 50 passes) pass 461 source fixtures.
  The 29-pass order without CoalesceLocals also passes the complete source set.
  All ten final candidate/reference profiles pass all 16 benchmark workloads.
- CLI execution checks cover profile printing, exact order, Wasm build and
  execution, standalone optimization, distinct cache keys and cache hits, test
  execution and listing, metadata retention, WAT output, optimizer identity,
  and failed-output publication. The cold CLI run took 204.641 s; the warm run took 12.885 s. The cold
  build is another open performance fault. Both runs passed.
- Explicit Binaryen 131: 10,000 regular and 10,000 aggregate `ssa-nomerge-all`
  GenValid comparisons have no validation, generator, command, or property
  failures. Canonical differences remain: 2,604 regular and 6,250 dedicated.
  All are smaller. All 40 saved outputs match the old `b92bf0767` binary exactly.
  The saved cases only remove nops or unused local declarations; those inspected
  cases have a measured size win with unchanged executable instructions.
  Unretained differences remain unclassified parity gaps. This is a bounded
  repair, not a full SSA audit; no external-generator lane was requested or run.

Build/test performance faults remain: the Starshine native suite took 274.765 s,
the release build 191.833 s, and the final assertion rebuild 86.217 s. Generated
lanes took 131.931 s and 119.458 s. Source sweeps took 431.133, 372.806, 222.970,
115.461, and 140.293 s. The first benchmark screen took 124.745 s; confirmation
was 251.104 s plus 37.191 s for the two direct-allocation cases. These all exceed
30 seconds. Per-command records also retain individual timeouts and failures.

All orders are in [deep-pipelines.json](../../tools/starshine-experiments/deep-pipelines.json).
The [evidence directory](starshine-deep-2026-09-10/README.md) holds corpus rows,
failure prefixes, all final runtime samples, source/tool hashes, and summaries.
Use the commands in the [runner guide](../../tools/starshine-experiments/README.md)
to repeat a source sweep or benchmark. The fixed compiler hash above is required
to reproduce this exact input corpus; results from other compiler revisions are
a separate experiment.

## Master rebase verification

The 35 local Starshine commits were rebased onto remote master `a1d2f8895` and
pushed directly to master at `6d17355e5`. The only manual conflict was in the
wiki log; both entries were retained. Range review found no changed code patches.
Dewdrop now pins that rebased commit. The release binary SHA-256 is
`8e3b0e5a9c69993c5cb93be49a93138b913258098b049187f6201e2f365e5dd6`.

Local verification passes 11,005 native tests and 32 closure execution checks.
All 461 source fixtures pass for each of O4s, speed, and speed-deep: 410 execute
correctly in Node and Wago, and 51 report the expected compile errors. All 48
outputs across those three orders and the 16 benchmark workloads match the
previously measured modules byte for byte. Optimizer cost was not benchmarked
again; the earlier cost measurements remain tied to their original binary.

Seventeen selected known failures were also replayed with this binary. Every
unoptimized input passes both engines; all 17 optimized cases still fail. These
cover late SSA (2), late Heap2Local (3), repeated CoalesceLocals and SLNS (1 each),
and one case each for MergeLocals, PrecomputePropagate, OptimizeCasts,
OptimizeInstructions, DAE, optimizing DAE, optimizing inlining,
HeapStoreOptimization, full SimplifyLocals, and Flatten. This probe exits 1 and
retains its diagnostics. Passing shipped profiles do not close these bugs.

The native suite takes 340.450 s, release build 199.146 s, full source sweep
76.549 s, and known-fault probe 32.168 s. All four exceed the 30-second performance
limit. Closure checks take 0.467 s; benchmark output comparison takes 1.446 s.
The [rebase evidence](starshine-deep-2026-09-10/master-rebase.json) retains each
fixture result, command timings, full fault diagnostics, and output hashes.
