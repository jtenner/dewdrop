# One-use object address through a trapping guard

Read-only proposal after the final cast/array-read candidate. No implementation,
new timings, or changed runtime policy. The active Wago-only full compiler
qualification has priority. The known V8 result is context; do not rerun V8.

Source inspected: Wago qualification tree `.tmp/wago-cast-array-qualification`,
including the combined safety changes and final array-read fusion. The earlier
profile and `.tmp/wago-v8-target/compiler.wat` describe the pre-fusion compiler.

## Finding

There is a useful, narrow opportunity. The profiled `array_get_unchecked` does:

```wat
local.get index
local.get wrapper
ref.cast (ref Wrapper)
struct.get Wrapper count
call integer_greater_or_equal
if (result eqref)
  unreachable
  unreachable
else
  local.get wrapper
  ref.cast (ref Wrapper)
  struct.get Wrapper backing
  ref.cast (ref ElementArray)
  local.get index
  array.get ElementArray
end
```

The predicate function body is exactly two i32 local reads, i32.ge_u, end. It is
already inlined in the profiled native body. The wrapper's first read requires
24 physical bytes; the backing read requires20. Successful first resolution
therefore proves enough extent for the second read, with no earlier speculative
larger-extent check. Wrapper and backing array are different objects: this can
remove the second **wrapper** resolver, not the backing-array resolver. Combined
with the implemented array fusion, this could reduce this body from four
resolver calls originally, to three now, to two. That is a site-count statement,
not a full compiler speed prediction. Profile PCs shared by resolver tails do
not identify each caller's exact time contribution.

## Why existing reuse does not cover it

`gcResolvedObject` stores local identity, type, validated extent and a pinned GP
register. It owns no stack slot. `gcResolvedRegister` selects an unused register
from RBP/R12/R13/R14, excluding all allocated/local-pinned/reserved registers.
`setDepthTypesWithGCRoots` explicitly retains this pin during stack canonicalization.

The fused final struct-field leaf returns the object base in RAX, but its caller
loads the field without seeding this certificate. Even if it seeded one:

- `driver.go` clears it on source call, before the inline decision. `emitPlain`
  clears it again before `callOp`.
- `gc_pure_if.go` accepts only void ifs, and rejects unreachable and every GC
  instruction. The example is a result if with a trapping arm.
- `prepareGCResolvedFB` excludes ref.cast/ref.cast_null. The second cast would
  clear it before the fused field read.

The existing pure-if proof requires both arms to preserve one entry fact. Merely
adding opcodes to its whitelist would break that proof. The trapping arm also
sets `unreachable`; `opElse` restores the entry stack/local state. A surviving
pointer must have a register lease throughout emission of that arm. Saving a
certificate in a Go variable and restoring it after its register was freed is
not safe.

## Recommended bounded experiment

Use one generic peephole that owns the short prefix from the first fused field
read through the second read. Avoid a general control-flow fact or call-survival
rule. Match semantics and decoded instructions, never library names or ordinals.

1. Start with a borrowed, unchanged caller local and a successful dynamic cast
   to a final struct followed by a supported field read. Require no custom
   instruction maps, no EH, no inline reader/local remap, and reachable code.
2. Inspect at most64source bytes/32operations, with at most16attempts/function.
   Do not reset this budget on intermediate uses. Initially accept the exact
   comparison shape: a local numeric two-parameter leaf that is already selected
   for inlining and has two local.get instructions plus one integer comparison.
   Resolve that decision with the same target/base/recursion policy as callOp.
   Reject imports, wrappers, unavailable inline slots, disabled inlining, and
   every actual native/host call. A call-free signature alone is insufficient.
3. Require a zero-parameter if with at most one result. Initially require the
   then arm to contain only unreachable (and optionally bounded duplicate
   unreachable/nop bytes), followed by else. The surviving arm must begin with
   the same borrowed local, same final cast target, and supported field read.
   No nesting, branches, writes, helpers, polls, allocations, or other operations
   may occur before this second read. Reject opposite orientation initially.
4. Require the second field's checked required extent to be no larger than the
   first. Do not precheck a later larger field at the first access. Both cast-null
   forms can be sound because a completed first field read proves non-null, but
   start with the forms tested explicitly and retain full original trap order.
5. Seed only if the complete match succeeds and a genuinely free cache register
   exists. Copy the first resolver's returned object base before loading its
   field. Do not evict another live value to create this lease.
6. Emit the already-selected comparison inline, consume its original exact-root
   call mask once, and use normal control stack/entry-local bookkeeping. Preserve
   the explicit unreachable trap at its source point. The else edge is dominated
   by the first resolver. Consume the saved address for the second field, then
   release it immediately, before the backing-array cast/read or any later edge.

One implementation shape is a prevalidated short emission plan that calls the
existing inline/control emitters and consumes the source prefix through the
second read. It needs explicit reader-PC/profile/checker bookkeeping and must
consume the original call mask exactly once. Another is a one-use certificate
keyed to exact source PCs, with narrow exemptions at all three invalidation
seams. The prefix plan is preferable if it avoids duplicating call selection or
leaving a persistent exemption in the main opcode dispatcher. Do not restore a
fact after ordinary invalidation has made its register available.

## Lifetime, roots, registers and traps

The raw address never becomes a Wasm operand or a root-map entry. The original
compact local remains in its normal local/register home. No collecting helper,
real call, loop poll, or host reentry is admitted. Integer comparison inlining
adds no reference locals or safepoint; bindInlineParams uses disjoint reserved
callee-local indices. The existing runtime collector-domain lease excludes
concurrent collector movement in this native span. Go GC may run concurrently;
retained backing ownership, not absence of Go GC, is the relevant condition.

The trap arm cannot resume. Its generated cold tail must retain the existing
pin/global writeback rules. The surviving edge must keep the cache register
reserved while opElse resets stack/local state; this is not an ordinary join of
two live pointer definitions. Release the lease at the second load, so no raw
pointer can survive the if result merge, allocation, or later call. Current
result merging may use a fixed register; the cache pool must remain disjoint.

The profile's wrapper already pins its two parameters in R12/R13, leaving a
plausible free RBP/R14 lease for this short interval. That does not prove absence
of added spills. Record actual selected registers, live stack depth, spill counts,
frame bytes and code bytes. A no-free-register case must take ordinary lowering.
A dedicated pointer stack slot is unnecessary for this first experiment.

## Required evidence before inclusion

Add a strict failing admission test for the exact generic shape, then differential
runtime/checked/codec tests for both outcomes. Include a wrong/null first object,
first field traps, null backing after a successful wrapper read, changed locals,
larger second field, different type/local, imported/noninlined comparison, nested
or result-producing trap-arm operations, actual calls/allocations/stores before
reuse, tight scan budgets, and no-free-register pressure. Do not mask missing
rewrites or pins with skips. Check GC root-plan call counts under the inline
path and the fallback path, and retain PR1006 cold restores plus PR1009 cache
retirement. Include a compact reference result followed by forced collection.

Measure a wrapper lookup and pressure/negative controls against the current
array-fusion candidate. Then require a matched Wago full compiler result. Keep
both source/binary identities and all samples. This is a stronger opportunity
than type-only reuse at this site, but the effect on the whole compiler remains
unknown until measured. No implementation is authorized by this note alone.
