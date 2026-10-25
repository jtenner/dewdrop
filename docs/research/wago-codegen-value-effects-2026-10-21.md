# GC code generation: caller value and effect analysis

## Result

A fresh Astra researcher and a fresh Claude researcher independently recommend making checked reference facts survive more of the caller's data flow. The next pass should remove repeated handle/space/type resolution, then repeated stable field loads, then repeated checks across safe loop iterations. Merely increasing the current read-helper size limits does not address the missing value identities and effects.

This is research and diagnostic evidence. No new production optimization, PR, speed gain, or install is claimed in this report. Installed Wago remains `local-gc-40cfab8d8`, source commit `40cfab8d8ec32ca3eff1cd178fa746cb2eeb82b0`. Its last qualified full-job median is 34.424798 seconds against the known V8 four-second reference. V8 was not rerun.

The user's updated tradeoff permits more Wago compilation work and compiler memory for faster GC execution, while asking to keep peak RSS low. The proposed design uses per-function scratch and compact module summaries rather than retaining a module-wide value graph.

## Independent researchers

- Fresh collaboration agent `/root/astra_codegen_speed_fresh`, explicitly selected `gpt-6-astra`, fresh context, source first. It inspected the complete installed branch, then the evidence. A follow-up received the exact-head attribution and refined its first experiment. No edits, builds, benchmarks, network calls or sub-agents.
- Fresh Claude CLI research session `0b95f6f4-2547-41ca-95c9-3eb6cc8c427c`, actual model `claude-opus-5-5`. Read/Glob/Grep only; fresh report followed by a resumed evidence review. Reports, requests, result metadata and model evidence are saved below. Initial report took 327.058 seconds; follow-up 99.779 seconds. Actual reported cost totals approximately $4.01.

Both agree on caller-level reference value facts, then call effects and lazy loop reuse. Claude corrected three initial proposals after the new evidence: do not start with call-free loops alone; use lazy first-use checks rather than an eager loop-entry probe; keep call effects separate from root-mask removal. Constructor-only freshness is secondary pending coverage counts.

## New exact-head evidence

A separate diagnostic host uses the exact installed source commit, the unchanged managed-isolation patch and the pinned compiler/request. It adds Go CPU profiling and native source/site maps; no helper counters or generated instruction changes. Build: 8.322 seconds; preparation including build: 9.949 seconds. This host is not installed.

The diagnostic job completed in 37.3297 seconds, 37.5793 user CPU seconds, peak RSS 1,258,404 KiB. This is a sampled diagnostic run, **not** a matched latency result. The profile retains 38,512,674 bytes of native metadata; its memory use must not be presented as a production RSS result. Output Wasm and cache hashes match, validation passes, and output `main` returns 42.

Go CPU samples: generated code 29.94 / 37.54 seconds (79.75%); `CollectMinor` 4.84 seconds cumulative (12.89%). Dead nursery handle reclamation, `finishSparseMinorEvacuation`, is 1.85 seconds flat / 2.01 cumulative. Collector tuning alone cannot account for the gap.

The leaf-PC probe has 1,848 samples, 1,090 in native code, no recorded probe errors, no lost profile metadata. Probe stops total 92.628 ms. It is a brief ptrace leaf probe, not a hardware event profile or stack profile.

Earlier opcode summaries left many per-function native stubs under a function name without an instruction span. Root added a **metadata-only compiler overlay** that records exact per-function emitter ranges. It does not change machine code. Recompilation took 0.467789 seconds and produces native SHA-256 `5f3a7b1c1c2be27dee30b225df83a7934f8fdc5b8eb8dfb7046f2eedab566c33`: identical to both the sampled saved artifact and the qualified final read-region build. Root admission remains exact: 25,794 safepoints, 50,438 callsites, maximum 77 roots, 1,803,076 metadata bytes. The tool including `go run` took 6.465 seconds; its build/compile process tree peaked at 514,620 KiB, not a production compiler baseline.

All 53,993 recorded ranges lie within their function bounds. There are no duplicate final-stub ranges from retried function compilations. The innermost matching emitter gives this attribution:

| Native code location | Samples | Share of native leaf samples |
| --- | ---: | ---: |
| Final cast/struct-field address resolver | 402 | 36.88% |
| Type-test/first-field leaf | 209 | 19.17% |
| Other generated code | 171 | 15.69% |
| Native struct allocation | 102 | 9.36% |
| Other per-function GC stubs | 88 | 8.07% |
| Defined cast leaf | 58 | 5.32% |
| Native array allocation | 37 | 3.39% |
| Defined test leaf without field fusion | 21 | 1.93% |
| Reference write leaves | 2 | 0.18% |

The first two rows account for 56.06% of sampled native locations. **This is neither eligible reuse coverage nor removable time.** A first validation of a newly produced object still has to run.

The extracted native bytes were disassembled. In the hottest import-identity and indexing functions, many samples sit at `test r10d,r10d` directly after loading `NativeHandleSpaceOffset` from the handle entry. Other samples sit on the dependent space descriptor, header/type and extent checks. The large sample count on the test is consistent with waiting for the preceding load; it does not establish that the test instruction itself has high latency. Removing repeated resolution is the target, not deleting that liveness check unconditionally.

## Concrete code generation gaps

Paths are relative to `.tmp/wago-local-stack-2026-10-20/wago`.

1. `src/core/compiler/backend/railshot/amd64/gc_direct.go:842`, `emitNativeFinalCastStructFieldAddress`, always flushes and calls its resolver. It does not consult `gcResolved`. `gc_struct.go:748`, `tryFuseFinalCastStructGet`, routes normal fused casts and field reads there. Thus the existing resolver cache is not a general fact consumed by all relevant physical emitters.
2. `gc_test_field.go:145` creates an address proof for the successful test/first-field prefix and drops it when that prefix finishes. A later cast/read of the same object cannot generally use that successful check.
3. `gc_resolver.go:8` stores one same-local/type/extent/address proof. Its provenance helper at line 76 recognizes borrowed locals. A checked parent load returning a child reference has no persistent child value identity.
4. `inline.go:1094` creates independent proof state for each read-region splice and clears mutable caller facts at exit. Identical value chains in successive splices cannot generally share proofs.
5. Ordinary control edges, loops and calls end proofs. `hints.go` shape flags do not provide separate transitive summaries for host entry, moving allocation, writes, global observation and register clobbers.

A concrete unchanged-Wasm example is `intern_function` at `.tmp/wago-next-gc-perf/read-regions/compiler.wat:185826`. Its scan repeatedly follows `local0 -> struct3631.field0 -> struct4281.field1` for length and indexed access. `span_matches` at line 185521 repeats stable chains through read-only helpers. These names are evidence locations, never optimization selectors.

Array wrapper fields are mutable. The same base local does not prove the same child/backing field. Loading a child from a checked parent also does not prove that the child handle is valid. Each child needs its own first full validation.

## Ranked implementation path

### 1. Caller-level value facts and checked-read reuse

Build a compact reference event stream for each function: local versions/copies, field results, cast/read groups, tests, control edges and effects. Assign value IDs. This is a reference-focused analysis, not a replacement numeric backend.

Track object/instance domain, logical type facts, checked address, covered extent and effect epoch separately from loaded-field value facts. Seed a proof at the **original executed** successful cast/read, or on the true edge of a test. Consume it from the normal fused emitter on later equivalent reads. Keep current root-mask consumption and safepoints.

Start with acyclic regions and already covered extents. Allocate a cache home only when a static producer/reuse edge exists. Prefer a private non-root home when no safe preserved register is free. Joins retain facts available on every incoming edge; an arm-created proof cannot become an entry proof for another arm. Use an undo log or persistent overlays instead of copying complete fact maps at every branch.

Next support larger later fields by retaining the validated handle size and checking both handle and object-header extent at the later original site. Never make the first check stricter. Then give immutable or write-proved field results stable IDs and share those facts across admitted read-region splices. A field result starts with unknown object validity; parent validation never substitutes for child validation.

**Gate:** emit a static map of dominating validation, later reuse sites, effect kills, saved resolver calls and cache traffic. In a separate counter run, count only eligible reached reuse sites, split by local, checked test, field-derived child and effect kill. Reject if dynamic reuse is small or home traffic removes the full-job gain. Do not use all 611 sampled locations as the predicted saving.

### 2. Transitive call effects and lazy loop invariants

Keep a compact module call graph and effects for allocation/backing movement, host entry, heap/global writes, global reads and physical clobbers. Solve recursion conservatively. Imports, indirect/cross-instance calls and unknown physical lowering stay unknown. A callee that cannot collect may still change fields or clobber registers.

Use those summaries to carry proven values and addresses across harmless calls and loop backedges. Keep the first executed validation in place; initialize a private validity home lazily, and clear it at invalidating effects. Keep every needed array index and accessed-extent check in source order. Do not prevalidate an unused array tail. A cold allocating loop exit can end a proof region without disqualifying an earlier read-only search path.

Keep root masks unchanged in the first version. Omitting masks is a separate shared-planner/backend change and must not be inferred from a no-host or no-write bit.

**Gate:** count candidate loop iterations and repeated checks that actually survive all calls/writes. Check loop poll, trap, EH, re-entry, private-home and register-merge behavior. Compare saved resolver work, spills, native bytes, Wago compile time and process peak RSS with full fixed-job time.

### 3. Constructor/return provenance and virtual wrappers

Native constructor reference-field validation has its own hot samples. Logical facts from proved allocations/casts could avoid rechecking a live, correctly typed constructor argument; field/array loads and parameter types alone are not such proofs. Keep ordinary helper fallback checks initially. Count qualified fields before adding specialized stubs or masks.

Partial inlining and escape analysis could remove local option/wrapper allocations and later dead-handle work. This has potential RSS benefit, but requires preserving failure/accounting and exact roots for virtual reference payloads. The existing pointer-free dead-charge contract cannot simply be applied to a reference-bearing wrapper. Materialize or reject at escaping identity, host, global, table, array or unknown call uses.

Failed `ref.test` ladders remain another use of the value analysis: reuse actual type/category on effect-free false edges, preserving each later target's original canonical equality/interval semantics. Their static count alone does not place them ahead of the resolver path.

## Static coverage and memory experiment

A loose census scans all 7,012 local functions in the saved WAT. It is **not** an eligibility proof: it does not prove dominance, aliasing, backend helper selection, physical clobbers or dynamic execution.

- 2,886 source loops.
- 39 loops without calls, listed allocations or writes.
- 220 loops when transitively read-only source callees are allowed.
- 1,855 source functions pass that rough transitive screen.
- 1,819 functions have repeated same-local/type cast/get shapes; 18,456 extra static occurrences.
- 1,398 functions have repeated same-local test shapes; 6,306 extra static occurrences.

This supports doing value and effect analysis rather than a no-call-loop-only optimization. The census deliberately treats names as display labels; operation and call relationships drive all counts.

Root tested two storage strategies for this research tool. Keeping all function body strings takes 0.883 seconds and 136,836 KiB peak RSS. Streaming bodies and retaining only call/loop summaries takes 1.591 seconds and 26,348 KiB. Counts agree. That is an **80.7% reduction in this diagnostic tool's peak RSS**, not a Wago optimization or a runtime-memory claim. It is a concrete example of the requested time/memory trade: spend another linear pass, release body state, keep only small global summaries.

For the compiler pass, use fixed-width events and one reusable arena per worker; reset after each function. Keep compact summaries across functions, not whole-module SSA. Limit simultaneous analysis bytes so large functions reduce worker concurrency. Record arena high-water, compilation time, native bytes, spills, allocations and whole-job peak RSS for each implementation stage.

The first streaming census exposed empty functions whose closing parentheses occur on the header line; the parser now handles that case. Early partial named-function counts were not used as final coverage. Root also checked `/proc/self/status` VmHWM and reran both tools as subprocesses: an inherited process-lifetime `getrusage` high-water value was unsuitable for the initial comparison. Final reports retain both metrics, which agree closely in the controlled runs.

## Evidence and validation

[Reports, profile summaries, scripts, attribution overlay, disassembly and model evidence](data/wago-codegen-value-effects-2026-10-21).

The large-artifact manifest gives paths and hashes for the raw native code, profile maps and diagnostic executable. These large files remain local rather than being copied into the research data. All diagnostic source changes are in an archive/overlay outside the installed checkout. No workload timings ran alongside builds or tests. Fresh output/hash validation, exact-root admission and native-code identity pass; production Go tests were not repeated for read-only research. The installed source still has only its original ARM64 edit, and both installed files retain their verified hashes. The upstream watch reported no new safety commits at the final check.
