# Large native array cancellation invariant review

Date: 2026-10-20. Read-only review. No source edits, tests, builds, or benchmarks.
Source root: `/home/dev/Projects/dewdrop/.tmp/wago-origin-main-2026-10-20/wago`, main7997 plus required safety patches.

## Result

A bounded recent-tail search followed by the original forward search is safe if it changes only how the matching list index is found and keeps the existing stable copy-and-shrink deletion and all other cancellation code.

For a valid active reservation, its handle identity cannot have an older duplicate in nurseryHandles. Under that invariant, the new search selects the exact same index as the old search. This gives stronger equivalence than treating nurseryHandles as an unordered multiset.

No source path was found that creates a valid older duplicate of the active unused large reservation handle, including normal failed-collection recovery.

## Identity ownership proof

References below are relative to the source root.

1. `src/core/runtime/gc/native/native_alloc.go:277` takes h through newHandle with a free entry. newHandle pops that identity from freeHandles before returning it (`alloc.go:198-212`), or creates a new identity (:214-226).
2. `native_alloc.go:278` appends h once to nurseryHandles and :279-288 publishes its one-handle reservation.
3. The free entry is owned by this reservation. Other Go/struct allocations cannot select h because it is absent from freeHandles. They can append other identities after h, so a literal last-element-only assumption is insufficient.
4. Replacing a large reservation calls discard first (:255). A canceled unused reservation returns its identity exactly once (:302-304), deletes its ledger occurrence, clears the whole state (:324), and increments the epoch (:325-329). Repeating cancellation cannot return it a second time because Count is now zero.
5. A consumed reservation is not returned by this path because unused requires Cursor==0 and handle.space==spaceFree (:302). Its live handle remains under collector ownership.
6. Checked handles only add generation retirement/increment to newHandle (`alloc.go:203-208`). Exhausted free identities are discarded before an identity is returned. Generation logic does not duplicate the reserved h.

This assumes the collector's normal serialized-use contract and internally valid free/nursery lists. Direct arbitrary test mutations of those lists are not valid states.

## Failed collection

Both collection entries cancel native batches before fallible marking/promotion:
- full: `collect.go:15-16`
- minor: `collect.go:44-45`

Their later failures do not resurrect the reservation state or reappend its identity. Minor failure clears nursery marks/restores dead accounting (:98-101); promotion destination/commit failure rolls back old-space destinations before publishing handle changes (:423-456). No reserved h is recreated there.

Struct cancellation returns unused identities then removes them from the nursery list:
- exact tail trim: `native_alloc.go:395-420`
- full compaction fallback: :422-426

The fallback exists specifically to remove free ledger entries before later reuse after an interrupted collection. Compaction excludes spaceFree entries (`collect.go:856-905`). Existing injected-failure coverage checks that canceled free identities are unique (`failure_debug_test.go:266-317`).

Full collection sweeps the handle table then compacts the nursery list (`collect.go:144-165` / `major_blocks.go:85-112`). Minor finalization simultaneously returns dead handles and removes their nursery list entries (`collect.go:175-211, 222-264, 271-309`). This does not give newHandle a live nursery identity already present in a valid ledger.

## If an older duplicate exists anyway

A duplicate h while its current reservation is active is already an invalid ledger state. The original forward deletion would remove the first h and leave another h; the tail deletion would remove the recent h and leave the old h. Both return h once and leave a stale occurrence that can become a duplicate live entry on later reuse.

Do not claim that these corrupt states have identical list order. They do not. A tail probe cannot preserve first-match behavior for arbitrary duplicates without reading the earlier prefix or carrying additional state. The safe argument is uniqueness of the owned identity, not a claim that duplicates are harmless.

The new code should keep the old fallback when h is not found in the bounded suffix. It must also keep the old no-match behavior if the full scan has no match, rather than returning another identity or changing the physical rewind logic.

## Order and physical ownership

nurseryHandles is a dense identity list. Collection reachability is handle-based, but traversal order feeds promotion plans, destination allocation order, and locality:
- promotion plans: `collect.go:378-405`
- destination planning and commit: :458-510, :513-586

Therefore do not use swap-delete or reorder a suffix as part of this small optimization. Stable copy-delete with the same unique index leaves the entire resulting list byte-for-byte identical.

Publication order is not always physical nursery order; `compactNurseryHandles` explicitly derives the maximum live extent rather than trusting the last handle (`collect.go:859-879`).

Keep all original operations outside lookup unchanged:
- freeHandles append happens once
- nursery rewind only when nurseryBump equals ChunkEnd (:313-315)
- throughput free uses the original reserved physical extent/class (:318-321)
- state reset and nonzero epoch advance (:324-329)

The stale uint32 backing slot outside the new slice length cannot hold a Go pointer; the original copy-delete already leaves this same backing tail.

## Existing unrelated edge to keep separate

A struct cancellation fallback can compact all free nursery entries while a separate unused large reservation exists. This can remove the large reservation's ledger entry even though its state is still active: prepare struct batch, prepare large reservation after it, then a Go allocation that cancels the non-tail struct batch. The fallback compacts the whole nursery list and excludes the still-free large identity.

This source-level sequence concerns a missing reservation entry, not an older duplicate, and is pre-existing. It needs a focused test before being called a confirmed runtime defect because later helper/native preparation may cancel or replace the large reservation before use. The proposed tail lookup with unchanged forward fallback does not introduce or fix it. Do not fold an unrelated lifecycle change into the lookup patch.

## Focused tests to retain

- h is last: matches old final ledger exactly.
- h is within the suffix with a struct reservation or normal Go allocations after it.
- h is outside the suffix: forward fallback keeps exact original result.
- h already consumed: no recycling/removal.
- nursery and throughput-backed physical reservations: exact rewind/free behavior.
- repeated cancellation: one freeHandles occurrence and one epoch transition per call as in current code.
- failed minor promotion followed by handle reuse: no duplicate free/nursery identities.
- checked generations near retirement: cancellation/reuse preserves unique identities.

For this patch, compare complete nurseryHandles and freeHandles sequences against the old implementation, not only set membership.

