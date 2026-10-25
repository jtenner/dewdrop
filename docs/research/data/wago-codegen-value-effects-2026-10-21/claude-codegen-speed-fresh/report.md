# Wago AMD64 GC codegen: research report (read-only)

I did not edit, build, test, benchmark or start agents. I read source at `.tmp/wago-local-stack-2026-10-20/wago` (paths below are relative to `src/core/compiler/backend/railshot/amd64/`). I did not write the plan file, because you asked me not to save the report.

**Labels:** **[M]** = measured fact from the docs. **[S]** = source fact. **[I]** = my inference.

## The main problem

- **[S]** Only one address proof (a "certificate") exists for each function: `gc_resolver.go:8` `gcResolvedObject`.
- **[S]** These ops all end it: `block`, `loop`, `br`, `br_if`, `br_table` and every call. The allow-list is in `gc_resolver.go:32-36`, and calls invalidate at `driver.go:206-221`.
- **[S]** Each read-region splice starts with no proof and clears the caller's proof on exit (`inline.go:1094`, `inline.go:1121`).
- **[S]** A full check is about 25 instructions. It makes about 8 dependent loads, with 2 stack spills in the inline form (`gc_direct.go:680-761`, stub at `:443`).
- **[S]** Array reads first flush the whole operand stack (`gc_cast_array_get.go:105`, `gc_direct.go:3084`).
- **[M]** Counter builds ran 1.108B region entries, 957M checked struct reads, 425M reused reads and 577M array reads.
- **[I]** So most repeat checks come from proof lifetime, not from the check code. A better peephole cannot fix that. The fixes below make the proofs live longer.

## Ranked changes

### 1. Loop-carried certificates (my top pick)

- **Where:** `driver.go` loop handling (`0x03` → `opBlock`/`tryRegionLoop`), `gc_resolver.go`, `gc_direct.go:emitDirectGCObjectWithStub`, `emitDirectGCArrayGet`, `emitDirectGCArrayLen`.
- **Work removed:** today a loop body checks the same unchanged local again on every pass. Only a pure `if` keeps the proof.
- **Idea:**
  - Scan each loop body once, from its start PC to its matching `end`. The scan finds two facts:
    - **Closed body:** no call (except approved read regions), helper, allocation, host op, table op, throw, `memory.grow` or atomic wait.
    - **Assigned locals:** the set of locals written by `local.set` / `local.tee`.
  - Pick candidates. A candidate is an unassigned local that is read by a final-type `struct.get`, `array.get` or `array.len` in the body.
  - At loop entry, if a valid proof for that local already exists, keep it pinned through the whole loop.
  - If no proof exists, emit a **probe**. The probe calls the existing shared resolver stub (`gc_direct.go:443`). That stub already returns a status in EDX and never traps. On success, store the address. On failure, store 0.
  - Each read site then does `test home; jz cold_full_resolve`, then uses the address.
  - The cold path is the original resolver, at the original PC. So traps happen in the same order.
  - Array index checks and the `Aux`/size guard stay at every access. Only the handle chain is removed.
- **Coverage:** unknown **[I]**. A compiler workload often calls functions inside loops. Coverage grows with change #3.
- **Cost:**
  - Compile time: one linear pre-pass per function. Store one record per loop (closed flag plus an assigned-local bitset). That is O(loops × locals/64) words, freed after the function.
  - Code: one probe of about 15 bytes per loop and candidate. Each site shrinks from about 25 bytes of call setup to a test/jcc plus a cold block. Net code size could go down.
  - Registers: keep the address in a preserved register (RBP/R12–R14). If none is free, use a private non-root stack home, like the region home (one load per use).
- **Proof obligations:**
  - No Go entry, metadata change or safepoint happens between the probe and any use. This is the "closed native interval" rule in `astrawago-epoch-cache-audit-2026-10-21.md`.
  - The local does not change.
  - The probe extent is at least each site's extent. If not, that site takes the full path.
  - Interrupt polls (`control.go:1801`) must only trap and must never enter Go. Verify this.
  - Exclude `tryRegionLoop` and counted-latch loops at first.
  - Never pin a register that integer control joins write (the RBP lesson).
- **Accept/reject test:**
  1. Static count over the pinned job: eligible loops, sites in them, and the share of those sites at loop top level.
  2. Counter build: count probe successes and site hits. Reject if eliminated checks are below about 5% of the about 1.5B checked reads.
  3. Then run the 3 balanced timing pairs.

### 2. Make read regions transparent, and keep a small multi-entry proof set

- **Where:** `inline.go:1092-1121`, `gc_read_region.go:421-492`, `driver.go:206`, `gc_resolver.go`.
- **Work removed:**
  - Calls like `get_a(x); get_b(x); x.f` each check `x` again. Regions are proven native-only and read-only (`gc_read_region.go` admission). Yet the call op and the region exit both clear the caller's proof.
  - One slot thrashes when code reads two objects in turn.
- **Idea:**
  - For calls planned as regions, skip the invalidation before and after the call.
  - Seed the region's parameter proof from the caller's proof when the argument is the same unchanged local.
  - Then replace the single slot with a table of k=4 proofs, keyed by (local, type, extent).
  - Merge proofs at joins by intersection. Keep the proof on the `br_if` fall-through path. A branch target keeps a proof only if every incoming edge has the same one.
- **Coverage:** **[M]** 6,485 static regions in 1,554 callers. **[I]** The repeat share is unknown.
- **Cost:** tiny compile cost, and a fixed array of about 100 bytes per function. Register pressure is the main risk, so stack homes are the fallback.
- **Proof obligations:**
  - A region contains no store, allocation, helper or safepoint. The admission rules already check this, but re-assert it at the transparent splice.
  - A seeded proof never gets a larger extent.
  - Proofs created inside a branch do not leave its join (keep the current rule).
- **Accept/reject test:** counter build of new reuses per class (region-seeded, cross-region, k-slot hit). Reject if they are under about 3% of checked reads, or if spill bytes grow.

### 3. Module-wide "never collects" summary

- **Where:**
  - `wasm/validation_analysis.go:217-228`: any direct call sets `ValidatedFuncMayCollect`, so the flag only covers one function at a time.
  - `src/wago/gc_frame_roots.go:31-52`.
  - `call.go:2240-2316` (`prepareGCFrameCallsite` → `materializeGCFrameLocalsAt`).
- **Work removed:**
  - Every internal call gets a root mask and writes pinned reference locals back to their stack homes.
  - Every internal call ends all proofs.
- **Idea:**
  - Compute "closed" over the call graph. Start optimistic: a function is closed if all its ops are on an allowed list and all its direct callees are closed. Mark any function that fails as open, and repeat until nothing changes.
  - Calls to a closed callee need no safepoint mask, no root write-back, and keep the proofs that live in stack homes.
- **Coverage:** **[I]** leaf scans, compares and hashes that are bigger than 192 bytes. It also makes more loops "closed" for change #1.
- **Cost:**
  - One pass over all bodies, plus callee lists of about 4 bytes per call. **[M]** About 57K call sites, so roughly 230 KB, freed after planning. **[I]**
  - Root metadata shrinks.
- **Proof obligations:**
  - The shared root-plan builder and the backend must use the same summary, so mask counts still match. The `Exact` checks are the guard.
  - "Never collects" must follow what the backend actually emits, not just opcodes. A slow-path struct.set reference barrier, array copy/fill helpers and extern conversions enter Go, so they are not allowed.
  - Callee register clobbers: use stack homes until a register-clobber summary exists.
  - A trap in the callee unwinds, so it is safe.
- **Accept/reject test:**
  1. Static: closed function count, call sites into them, and root-map bytes removed.
  2. Dynamic: calls to closed callees as a share of all calls.

### 4. Fresh-constructor provenance (checking the previous Claude idea)

- **Where:** `gc_direct.go:1803-1895`. The native struct allocator checks each reference field: tag, handle range and space byte. Typed fields also check space, extent, header type and maybe subtype intervals (about 12 to 35 instructions).
- **Can it be built? Yes, but only in a narrow form.**
  - Mark the operand-stack element that the native `struct.new` result produces.
  - Skip the field check only when that element feeds the parent `struct.new` directly, with only constants or `local.get` in between.
  - A sibling allocation in between can enter Go. Then the "no Go entry" rule from the epoch audit no longer holds, so stop there.
- **Value:** **[I]** small. It saves only allocation fast-path checks, never read checks. The existing dead/forwarding reductions already remove some nested constructors.
- **Cost:** about zero compile cost and smaller code.
- **Proof obligation:** the child handle came from this function's allocation, and no Go entry or host boundary happened after it.
- **Accept/reject test:** a static count of these direct nested reference arguments, then a dynamic count of their executions. Reject if they are under 1% of allocations.

## Top next experiment

Change #1, conservative form:

- Final struct and array reads only.
- Loops whose body is closed with no calls at all (approved regions also excluded at first).
- One candidate local per loop.
- The probe reuses the shared resolver stub.
- The cold path is the unchanged full resolver.
- No change to ABI, codec or runtime.
- Run the static loop count first. If it shows little coverage, do change #2 first instead (cheapest, already measurable).

**Stronger follow-on:** allow read regions and summary-closed callees (#3) inside "closed" loops. Use the k-slot proof set (#2) to carry more than one object per loop.

## Summary

- **[M]** The baseline is 34.42 s (V8 is 4 s). Native code grew 4.51%. The older profile had 80.25% of time in generated code. That is not a measure of which GC ops cost the time.
- **[S]** Proofs end at every loop, block, branch and call. Regions start with no proof.
- **[I]** The likely wins come from longer proof lifetime, not cheaper checks. I give no speed guarantee. Every item depends on coverage that is not yet measured.
