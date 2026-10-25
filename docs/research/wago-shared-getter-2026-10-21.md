# Share the checked resolver for final field getters

Astra supplied the getter plan and the linked-argument flush proof. Claude supplied independent hot-path research; its separate source-index proposal is recorded in wago-hot-algorithms-2026-10-21.md. GPT-6 Sol with explicit Daybreak Blue reviewed the implementation, tests, partial-flush change and public-parent composition. Harness turn_context records prove the model/mode; a reviewer cannot independently verify its own launch mode. Four review reports and the mode records are in data/wago-shared-getter-2026-10-21/.

## Change

After bounded direct forwarding, replace a complete final cast/field getter with the existing module-shared checked resolver. The source body must have one reference argument, one GP scalar or compact reference result, no declared locals, at most32bytes, and exactly local.get0; nonexact final cast; matching struct.get/get_s/get_u; end. Limit to16sites per caller. Reject EH, custom lowering, nested inlining, interval/vector regions, floating-point/vector results and other body shapes.

The shared leaf keeps its complete handle/domain/space/type/header/span checks. Check high reference bits before passing the low32compact handle. A nullable null dereference keeps the get PC; merged cast/extent failures keep the getter function with unknown PC. R9–R11 are restored by the existing shared leaf before caller trap handling. No raw address escapes the immediate field load. Compact reference results retain their root bit.

Consume one original caller source mask, without creating a callee frame, preparing call root homes or saving/reloading Wasm local/global pins for a collecting call. The leaf cannot collect or call Go. Resolve older trapping operands under caller attribution. Use flushBelow while the argument stays linked; this stages overlapping slots and retains register/local-borrow ownership. Only then pop/materialize the updated argument. Do not generalize the test-field path's detached pop-before-flush sequence.

The first draft forced the argument through a canonical slot. The final version removes that store/load; the simple getter now needs zero spill slots. No ABI or codec version changes; the pre-existing upstream Wago NativeABIVersion9 is retained.

## Measured results

Same hash-pinned compiler.wasm and request.bin as previous full jobs. Normal hosts use the same installed073b2f618stack; only the getter delta differs. No held prefix/type-fact/getter/collector experiment is included. Every full run uses fresh native/result caches, fixed CPU12,14, GOMAXPROCS2, exact native roots, both fixed output hashes and main42 checks. No task-owned build/test/benchmark runs concurrently with timings. Known V8 reference remains4s; no V8 timing was repeated.

Final kernel:8192matching getter reads, six samples per variant in three ABBA rounds, CPU15/GOMAXPROCS1. Median36854.5→26220.5ns/op,28.85% reduction. Each invocation verifies the full sum. This is the supported getter speed claim.

Final full jobs:

| Variant | Seconds | Median |
|---|---|---|
| Installed source control |37.646373,37.663227,38.437673|37.663227|
| Shared getter |37.210207,37.550093,38.139290|37.550093|

The median difference is0.30%, inside the run spread. Each balanced pair is lower for the candidate, but these six runs do not establish a clear whole-job gain. The compiler remains about9.39times the known4s reference. Peak RSS medians1,082,380→1,137,048KiB; samples overlap and differ by about a nursery-size allocation step. Do not hide that memory result.

First draft: kernel37168→27765ns(-25.30%); full medians34.886838→34.935447s, no gain. Retain both drafts; do not compare their absolute times across batches as a speed result.

Actual public Compile admission:3409sites in1140functions. Native code24,516,539→24,704,955bytes (+188416,+0.77%); the first draft used24,760,283bytes. Exact source root metadata callsites56923→53514 and bytes1,983,045→1,887,976, with25794safepoints and maximum77roots unchanged. The removed sites cannot collect; later source masks retain their original order. Static site counts are not dynamic execution counts.

## Validation

Structural red: baseline semantics passed, but no shared getter sites were emitted. Final combined checked focus22.723s; public normal24.247s, checked23.703s, profile23.957s pass. Earlier final-source checked/profile lanes25.113/25.130s pass. The Go compiler also builds the production AMD64 package with tinygo,wago_lean tags in2.508s; this is not an actual TinyGo runtime qualification.

Tests cover fresh and public codec artifacts, normal/forced nursery/Tiny GC, independent and returned compact roots across later allocation, older reference/vector operands, borrowed local arguments under pressure,24live locals, dirty global pins on cold failure, bad handle/header extents/space/high reference bits, trap order/codes/getter function and nullable get PC, packed signs, forwarded calls, rejected nop wrappers,16th/17th-site behavior, source/inline/unwind maps and profiling byte neutrality. Profile source ranges link the getter load to the specific wrapper and source call PC. The existing omitted-terminal retarget guard is unchanged; the new fixture does not independently force that layout case.

Two initial test assumptions were corrected, not production behavior: this fixture reaches the native high-bit guard (CastFailure), and its17thcall uses wrapper ABI under low-level options. Raw failing logs are retained. The final admission harness initially looked for a renamed v2 counter that production did not use; corrected the harness and reran both variants, retaining the failed records. No failure was suppressed.

Full combined normal153.282s, checked143.548s and benchmark-package checked28.005s pass. Pinned spec corpora setup took43.061s. Raw full-suite records are in the data directory. Publication and installation records belong in the final root installation note. User subsequently requested a brand-new Astra whole-GC audit; publication is held until that independent audit is complete.

## Scope and next work

This is a bounded runtime getter improvement. It does not meet the4s full compiler target. The wider deconstruction-prefix experiment stays held; its small full-job difference is inconclusive. Astra confirmed that the proposed array_get_unchecked parent-address reuse is already installed in the trapping-guard plan. A strict no-source-call GC leaf inliner would reach only51new scalar array-read call edges and needs separate inline-reference root typing and native-only emitter proofs; a filter-only change would be unsafe. The remaining larger spans cross actual branches, calls and loops and need an explicit plan.

Public branch is based on PR1008, whose latest2cffbac1commit only removes an unused test wrapper. The getter helper itself is identical to the combined qualifier; the private compiler counter is placed beside the public parent's existing resolver counter. The combined pick must retain the qualified counter layout and all prior safety changes. Documentation and raw evidence travel with the atomic getter commit.
