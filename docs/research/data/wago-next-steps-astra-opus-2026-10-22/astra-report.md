**Prioritize wider Wago analysis, then remove repeated work in Dew.** Further collector tuning alone will not close the gap.

The qualified median is **28.582 seconds: 7.15× the four-second target**. The saved diagnostic assigns 23.02 of 29.95 CPU seconds to generated code. That includes real compiler work, allocation, calls, and checks. It is not all removable GC cost. The profile also predates the final sort change.

I checked the clean Wago checkout at `44bb8e1bc3b2b175b20600f9870d58d4a1219fef` before reading the evidence. No files changed. No builds, tests, benchmarks, network calls, or agents ran.

1. **Extend proof across functions and control flow. Same pinned Wasm.**

   This is the largest remaining Wago opportunity, but its benefit is unmeasured.

   In `src/core/compiler/backend/railshot/amd64/`, `planGCReadRegion` admits small bodies with no declared locals. `prepareGCValueChecks` clears facts at control boundaries. `gcReadOnlyCallSummary` retains one read-only flag per function; it does not describe returned objects or which arguments escape.

   Add bounded value-flow analysis: track object creation, copies, field reads, and direct helper calls. Use it to replace temporary objects with scalar values and retain proved checks through joins. The census’s zero adjacent projections rejects only the adjacent pattern. It does not cover returned wrappers or uses across helpers.

2. **Remove full-list scans in Dew. Requires new compiler Wasm.**

   Current source still contains concrete repeated work:

   - `self_host/compiler/semantic_impl_index.dew`: `self_host_index_module_implementations_with_imports` scans all imported callables for each implementation. `self_host_imported_requirement_identity` scans them again for each requirement.
   - `self_host/compiler/semantic_imported_semantics.dew`: `intern_function`, `intern_product`, and `intern_applied` scan the type table.

   Build ordered indexes once per operation. Preserve first-match identity, method order, and duplicate assertions. These changes remove program work and its associated reference reads. Their current time share needs measurement; older attribution predates compact headers. Compare newly built control and candidate compilers on the same Wago host.

3. **Consider an internal scalar calling convention before changing all references. Same pinned Wasm is possible.**

   For proved private producer/consumer pairs, pass fields directly instead of creating and resolving a wrapper. Keep ordinary entries for exports, indirect calls, and unknown callers.

   Relevant code is `amd64/call.go`, `gc_struct.go`, and `gc_direct.go`. Existing register calls already support reference shapes; adding reference registers alone is not the missing step.

   A global direct-pointer representation is a larger, unproved option. `native/ref.go` uses compact handles, and moving GC preserves identity through them. Direct pointers would require changes to roots, relocation, equality, and host boundaries. Stable virtual backing alone does not make object addresses stable.

**First experiment: measure broader temporary-object coverage before changing emission.**

- **Scope:** Add a diagnostic analysis for final, scalar-only structs that pass through locals and direct, nonrecursive helpers. Include returned wrappers and branch joins. Record each rejection reason.
- **Proof boundary:** Require all uses to be known. Reject publication to fields, arrays, globals, tables, host calls, indirect calls, identity comparisons, and unsupported control flow. A read-only call is not automatically a nonescaping call.
- **Safety:** Emit unchanged code in this first screen. Any later replacement must preserve operand effects, trap order, allocation charging/failure behavior, and safepoints. Existing `emitNativeDeadStructChargeStub` shows that “no object payload” does not mean “no allocation obligation.”
- **Memory cap:** Proposed limits: 32 MiB shared analysis storage, 2 MiB scratch per worker, and 64 KiB diagnostic counters. Report budget exhaustion explicitly. Retain no new production runtime table.
- **Decision:** Measure dynamic candidate allocations and bytes, helper traffic, rejection reasons, analysis time, and peak memory. Static constructor counts are insufficient. Use fresh native-PC sampling: my read-only attempt found no leaf sample PCs in the saved `cpu.pprof` that mapped into its companion native-code images.
- **Stop:** If coverage stays small or cold, stop this scalar-only branch and move to step 2. Any compiler activity over 30 seconds remains a bug. If coverage is substantial, test one bounded replacement with matched full jobs; accept only measured time gains with correct output and reported RSS.

Keep the rejected address cache, held loop cache, and optional collector workers out of the default path. None has evidence that resolves the remaining gap.
