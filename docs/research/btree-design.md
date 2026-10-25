# Dewdrop B-tree design, based on bbtree

Status: complete design for implementation; no implementation in this change.
Owner decision: 2026-10-25. bbtree is the design authority. Runtime speed comes
first, then memory use. This document replaces the earlier reconciliation as
the implementation brief. Its decisions are not optional experiments to defer
until after a plain B-tree ships.

## 1. Source record and scope

The source studied is
[`XiangpengHao/bbtree`](https://github.com/XiangpengHao/bbtree/tree/8adae97a0ed97e5c98fa2790312eb0aec9719846),
commit **`8adae97a0ed97e5c98fa2790312eb0aec9719846`**. The clone used for this
review was `/tmp/dewdrop-bbtree-source-20261025`. All upstream statements below
refer to this commit, not a moving branch or the older design notes alone.
Code wins where a historical note describes an earlier choice.

The main evidence is the README, `design/00-init.md` through
`design/12-batch-api.md`, the decision log `design/03-decisions.md`, and:

| Subject | Upstream source under `bbtree/src/` |
| --- | --- |
| Key contract and plans | `inline_key.rs`, `node_config.rs`, `tree/node/node_plan.rs` |
| Storage | `tree/node/layout.rs`, `page.rs`, `slots.rs`, `leaf.rs`, `internal.rs` |
| Search and windows | `tree/search.rs`, `tree/node/inline_key_search.rs`, `inline_keys.rs`, `hash_tags.rs` |
| Prefix changes | `tree/shared_prefix.rs`, `tree/prefix.rs`, `tree/node/inline_keys.rs` |
| Writes and repair | `tree/insert.rs`, `remove.rs`, `node/siblings.rs`, `node/mod.rs`, `root.rs` |
| Iteration | `tree/walk.rs`, `node_stack.rs`, `unsync/map/iter.rs`, `iter_mut.rs`, `into_iter.rs` |
| Bulk operations | `tree/batch.rs`, `build.rs`, `cut.rs`, `unsync/map/batch.rs`, `from_entries.rs`, `append.rs`, `extract_if.rs` |
| Public collections | `unsync/map/mod.rs`, `unsync/map/entry.rs`, `unsync/set/mod.rs` |
| Concurrency | `map/mod.rs`, `map/range.rs`, `tree/latched/`, `tree/node/latch.rs`, `design/09-concurrency.md` |
| Checks | `unsync/map/tests/`, layout and inline-key unit tests, `design/08-fuzzing-verification.md` |

In this table, abbreviated node filenames are relative to `tree/node/`, and
abbreviated map iterator filenames are relative to `unsync/map/`.
The visualization and blog notes describe the same core, not another layout.
The market survey and `99-brainstorm.md` do not set implementation rules.
`design/15-index-file.md` and `16-bbtree-store.md` concern separate file/store
products. File offsets, leaf annexes, record compaction, persistence and their
key-size limits are not part of this in-memory collection.

Dewdrop reference state:

* Repository base: `2698dff678cda71f8ef505e3a53d768af0bda73e`.
* `research/btree-stdlib-design` resolves to that same commit. Its worktree
  was clean, and its tree contains no B-tree research document. There is no
  recoverable first-design document at that branch head to reuse.
* `research/btree-design-reconciliation` at
  `bd5c65dacd1fd1f72cfc6b5de8efb681b94f8b6f`, file
  `docs/research/btree-design-reconciliation.md`, supplies Dew-side constraints.
* `research/btree-stdlib-design-r2` at
  `d8222eff8d198d5664325e171d96556b5d7a259b`, file
  `docs/research/btree-design.md`, is a reference, not the selected tree.
* Current rules: [AGENTS.md](../../AGENTS.md), [std/README.md](../../std/README.md),
  [collection mutation and iteration](collection-mutation-and-iteration.md),
  [compile-time queries](../compile-time-types.md), [ordering](../../std/ordering.dew),
  [Array](../../std/array.dew), and [FixedArray](../../std/fixed_array.dew).
* Private node identity is supported by the existing
  [ref.eq instruction](ref-eq-builtin-2026-10-19.md) and
  [generic raw builtin specialization](generic-raw-builtin-specialization-2026-10-19.md).
  No identity counter or compiler extension is required.

Reuse explicit comparators, reference aliasing, generic carrier support,
snapshot entries, Unit specialization, and ordinary-library implementation.
Reject the earlier fixed 32-way tree, half-full minimum, copied separators in
every branch, forward-only cursor, serial-only final batches, deferred inline
tree, and deferred set. They are not the owner-selected design.

The first delivery is one mutable, single-threaded `BTreeMap<k,v,c>` and a thin
`BTreeSet<k,c>`. One engine has a plain node plan and an inline node plan. The
same balancing, head-entry rules, walks and batch commit logic serve both.
Do not change the existing `OrderedMap` or `OrderedSet` backend in this work.
No serialization format, shared-memory map or storage engine is implied.

## 2. Tree model: keys have one home

All values live in leaves. Every leaf except the globally leftmost leaf has a
**head entry**: the entry for the separator immediately before that leaf in
tree order. The head is not counted in that leaf's regular-key count.
Each branch with `n` separators has `n + 1` children. All leaves have the same
depth. There are no parent pointers, sibling links, or stored fence keys.

There are two distinct key layouts. Do not turn either into a conventional
tree that copies each right child's minimum into a parent.

| Node | Plain plan | Inline plan |
| --- | --- | --- |
| Leaf regular key `i` | Full key `keys[i]`; value `values[i+1]` | Full key `keys[i+1]`; value `values[i+1]`; window `windows[i]` |
| Leaf head | Only `values[0]`; full key belongs to an ancestor | Full key `keys[0]` and value `values[0]` |
| Branch separator `i` | Full key `keys[i]` | Only `windows[i]`; **no full key or key reference** |
| Branch edge `i` | Child `children[i]` | Child `children[i]` |

The key/value column names in this table describe logical access. A paired
inline leaf projects these accesses from one physical pair array (section 3).

In the inline plan, a branch separator's full key is the head of the leftmost
leaf below its child `i+1`. To read it, take that child, then child 0 at each
branch, then read the leaf head. A tie may need this walk. Do not add a cached
key reference to every branch separator. In the plain plan, a branch hit
already has the key, but its value requires the same head-leaf walk.

For `L` leaves there are `L-1` separator entries across the whole tree. Thus:

```
map length = sum(leaf regular counts) + L - 1
           = sum(key counts of ALL nodes)
```

For example, one branch separator `20`, a left leaf with `[10,15]`, and a right
leaf with head `20` and regular keys `[25,30]` represent five entries. In the
plain tree the only full `20` is in the branch. In the inline tree it is in the
right leaf head. Its value is in that leaf in both trees.

The head has no separate window or tag in the leaf's search strip. A search
that matches a separator goes to its head directly. Range and iterator code
must visit heads once; it must not skip them or count them twice.

The map owns a root reference, a U32 entry count, its comparator, an immutable
layout plan, shared-prefix state, an optional last-leaf hint, and lazily made
work space. An empty new map has no nodes. Deleting the last entry may retain
one empty root leaf, as upstream does. `clear` releases all map-held node and
work-space references. Node reclamation then belongs to the garbage collector.

## 3. Physical layout in Dewdrop

### 3.1 What the native layout does

Upstream uses aligned native pages. Default leaves are 1,024 bytes. Inline
branches use 512 bytes; plain branches use 1,024 bytes. A page grows to the
smallest permitted multiple that can hold at least 12 regular keys. Capacity
is at most 1,023. The inline strip is also bounded by
`max(1024, configured_page_bytes) / window_width`. Leaf page size is a power of
two of at least 1,024; branch page size is a power of two of at least 64.

The plain header is small (count and head state); the inline header occupies
8 bytes, and a latched header 16. A plain node stores key and trailing-slot
columns. An inline leaf stores its dense window strip first, optional one-byte
tags next, then native key/value pairs. Its key and value often fit in one
cache line. An inline branch stores windows and child pointers only. Pointer
tags encode node kind. The root page is large enough to change node kind in
place and also retains the tree's shared prefix. A multi-page node is aligned
to the required page/type alignment, not necessarily to its total byte size.

Useful native 64-bit layout checks (regular capacities, not total entries):

| Native key/value and strategy | Leaf capacity | Branch capacity | Branch children |
| --- | ---: | ---: | ---: |
| Plain `u64/u64` | 63 | 63 | 64 |
| Auto inline `u64/u64`, widths 2/2 | 55 | 49 | 50 |
| Auto heap `String/u64`, widths 8/4, tagged leaf | 24 | 41 | 42 |
| Generic inline branch, width 8 | depends on value | 31 | 32 |

These are upstream layout results, not Dewdrop capacities or memory measurements.

### 3.2 Selected GC representation

Dewdrop cannot put arbitrary GC references in an untraced byte page. Use
private typed `WasmArray<t>` columns, created with `wasm_array_new_default`.
Use existing one-to-one Wasm array and SIMD instructions through ordinary Dew
helpers. Do not add a compiler B-tree intrinsic, host runtime tree call, or
module-name dispatch. `size_of` and `align_of` describe raw encodings; they do
not describe GC heap objects and must not size these nodes.

Use a private mutable node wrapper for count and prefix plus a tagged body
with four logical forms: plain leaf, inline leaf, plain branch, inline branch.
An inline leaf's body selects paired or separate-column storage as described
below. Unit leaves have forms with no value column. Body fields are immutable references
to mutable arrays. Do not put all possible columns on every node. Enum bodies
and node wrappers can be separate GC objects: count both in measurements.
Keep all fields private; if a helper type must be public for a module
signature, its representation must still be private.

Storage for regular capacity `C`:

* Plain leaf: `C+1` key slots and `C+2` value slots.
* Inline leaf with separate columns: `C+2` key slots and `C+2` value slots,
  plus packed metadata. A paired leaf has `C+2` pair positions instead.
* Plain branch: `C+1` separator slots and `C+2` child slots.
* Inline branch: `C+2` child slots plus packed metadata; **no key column**.

The extra slot at the end of each typed column is a permanent default slot.
Never read it as a `k`, `v`, or child. Clear an unused reference slot by copying
from this default slot with `wasm_array_copy`, without constructing a default
user value or an `Option` per slot. Live-slot access checks the count and the
head state before the array read. Splits happen before insertion; these extra
slots are not overflow entries. Overlapping array copies shift live runs.
Clear vacated source slots after a move, including head moves, child moves,
merge retirement, and work-space release. A retired node must not keep a
second live reference to every entry it used to hold.

Preserve paired inline-leaf storage wherever current carriers permit it:

1. If `k` and `v` are the same exact type and `v` is not Unit, use one
   `WasmArray<k>` with `2*(C+2)` slots. Pair position `q` has its key at
   `2*q` and value at `2*q+1`. This works for identical reference types too.
2. For distinct types that both have plain scalar/vector carriers, pack
   pairs without references. If both can be safely bitcast to the same
   U32, U64 or V128 carrier, use two consecutive elements of that carrier.
   Otherwise use a V128 array with one 16-byte block per pair when both
   carriers fit in 8 bytes, or two blocks when either carrier is 16 bytes.
   In a mixed 4/8-byte pair, put the key in the low 64-bit lane and value in
   the high lane, with unused bits zero. For a 16-byte carrier pair, put the
   key in the first block and value in the second, zero-extending a smaller
   carrier's bits. Recover float bits by the existing unsafe numeric bitcast,
   not a numeric conversion. Bool uses bits 0/1; narrow integers extend to
   their i32 carrier and recover their original logical width on load.
   Guard bit reinterpretation with logical type queries and `can_bitcast`;
   a GC reference must never enter this raw representation.
3. For other heterogeneous types, use the separate typed key/value columns.
   These include a String key with a scalar value, or two distinct reference
   types. Dew has no inline heterogeneous GC pair in a homogeneous array.

Use one extra default **pair** in paired storage. Clear/move its components
with raw array copies, at element indices scaled by the fixed pair stride.
The leaf head is pair 0 and regular key `i` is pair `i+1`. Packed metadata is
unchanged. No key/value struct object is stored per entry. Upstream's paired
storage is thus kept for U64/U64, String/String, and mixed scalar pairs; the
forced separate-column cases are D1. Array elements are adjacent, but their
base address and cache-line alignment are still engine-defined. Public
`BTreeEntry` snapshots may allocate at the API boundary.

For `v = Unit`, select a leaf body without a value array with `is_unit::<v>()`.
Do not assume `WasmArray<Unit>` takes zero bytes. Preserve evaluation of the
caller's value expression before discarding its result. Ordinary guarded
specialization must remove value reads, writes and allocations. Unit keys
still use their normal typed key column; only the value column is erased.

### 3.3 Packed windows and tags

Store metadata in one `WasmArray<V128>` per inline node. A window is the first
2, 4, or 8 bytes of the provider's U64 word, treated as an unsigned integer.
Window `i` occupies bytes `[i*w,(i+1)*w)` in the logical metadata strip. A tagged
leaf puts its `C` bytes of tags immediately after `C*w` window bytes. Round the
whole strip to 16 bytes. Branches have no tags.

Use lane replace/extract helpers with constant lane numbers, selected by a
small switch. Use packed unsigned comparisons for 16/32-bit lanes. For
64-bit less-than, flip the sign bit of both operands and use signed
`i64x2.lt_s`; equality needs no flip. The stored numeric lane is the high part
of the big-endian window, not a host-byte-order reinterpretation of the key.
Neither GC array layout nor a key reference can be treated as a linear-memory
address for `v128.load`.

Fill unused **window slots** from `len` to `C` with the maximum lane value.
Mask all lanes outside the live count when reducing comparisons. In the last
vector, bytes after the window area may be tags or padding: they must never
contribute to a rank. This also handles an all-ones query window correctly.
Move and shift windows/tags with packed helpers; do not materialize a temporary
object for every window or tag.

### 3.4 Capacity plan and size accounting

Keep upstream's payload-budget shape and its minimum and maximum capacities.
The public config has `leaf_bytes`, `inline_branch_bytes`, and
`plain_branch_bytes`, with defaults 1024/512/1024 and the power-of-two limits
above. These are **modeled payload budgets**, not guaranteed heap page sizes.
This distinction is part of the API documentation.

Define a planning slot size `S(t)`: 4 for i32/f32-carried scalars (including
narrow integers and Bool), 8 for i64/f64, 16 for V128-carried values, and an explicit
8-byte planning estimate for references. These are carrier classes, selected
with existing type queries in Dew, not source-name tests in the compiler.
`S(Unit)` is 4 for a key and 0 for an erased value. Composite GC values cost one
reference slot here; their reachable objects are accounted for separately.
Use `R=8` for a modeled child slot and `H=16` for modeled node control payload.
Neither number claims an engine's actual object header or reference width.

For each candidate `C`, use the following byte costs, including clear slots:

```
P(C,w,tags) = 16 * ceil(C * (w + tags) / 16)   # tags is 0 or 1
plain leaf    = H + (C+1)*S(k) + (C+2)*S(v)
inline leaf, columns = H + (C+2)*(S(k)+S(v)) + P(C,w,tags)
inline leaf, paired  = H + (C+2)*E + P(C,w,tags)
plain branch  = H + (C+1)*S(k) + (C+2)*R
inline branch = H + (C+2)*R + P(C,w,0)
```

Here `E` is 2*S(k) for same-type pairs, twice the common scalar carrier size
for a common-carrier pair, 16 for a mixed 4/8-byte pair, and 32 when either
carrier in a mixed pair is 16 bytes. The Unit value plan uses the column
formula with S(v)=0 and no value array. Paired padding is charged to capacity;
it is not free. This preserves adjacency without hiding its memory cost.

First find the smallest multiple of the configured budget that can hold
12 keys without tags. Then choose the largest `C` at most 1023 that fits and,
for inline nodes, obeys `C*w <= max(1024, configured_budget)`. For a provider
with tags, also compute a tagged capacity in that **same** budget multiple.
Use tags only if tagged capacity is at least 12 and loses at most one regular
entry. Otherwise use the untagged plan. Upstream fits tags in native padding
or gives up an entry; this is the corresponding GC payload test. Native
padding offsets themselves cannot be preserved (D1).

Initial modeled examples: plain U64/U64 gives 61 leaf keys and 61 branch keys;
inline U64/U64 gives 54 leaf keys and 48 branch keys; String/U64 with 8-byte
reference estimates gives 39 tagged leaf keys and 40 branch keys. A set may
have a larger leaf capacity because it has no value column. Derive thresholds
from each actual plan. Never copy native `55/49` into a Dew constant.

Keep the plan immutable for a map's lifetime. Read custom width/config once
at construction. Select width-specific outer helpers rather than make an
indirect provider call or width switch at each search lane. For standard
providers, check that monomorphization folds trait-presence and carrier tests.
Do not promise that a general custom width method is a compile-time constant.

Measure arrays, wrappers, metadata padding, map fields, path work space, key
objects, values and GC retention separately. Tune the byte-model estimates
only with recorded engine evidence, and regenerate capacity/threshold tests
with any change. The layout formulas are an initial reproducible policy, not
permission to replace bbtree's node plan with an unrelated fixed fanout.

## 4. InlineKey in Dewdrop

### 4.1 Contract

Upstream's `InlineKey` returns a U64 window at any byte offset in an ordered
encoding. The first byte is the most significant byte. Past the encoding's
end, bytes are zero. When all bytes before an offset agree, unequal windows
must order the keys the same way as the full comparator. Ties need a full-key
check. In particular, an empty byte string, zero bytes, and trailing zero
bytes can have identical padded windows without being equal keys.

The encoding must be stable while the key is in the map, including when a key
is moved. Comparator-equal keys must have equal windows and equal hash tags.
A constant-zero window provider is valid but slow. Do not infer equality from
the inline word, a tag, or a common prefix. Never read past a key's byte length
to build a window.

Dew uses explicit `Comparator<k>` evidence. Put the encoding evidence on that
same provider type `c`; attaching it to `k` alone would be wrong for reverse,
case-folded, or field-based comparators. The public trait signatures are:

```dew
pub enum BTreeInlineWidth { Two Four Eight }

pub trait InlineKey<k> {
  fn inline_key_at(self, key: k, offset: U32) -> U64
  fn inline_width(self) -> BTreeInlineWidth
}
pub trait InlineKeyHash<k> {
  fn inline_hash_tag(self, key: k) -> U8
}
pub trait InlineKeyCompareFrom<k> {
  fn compare_from(self, left: k, right: k, equal_bytes: U32) -> Ordering
}
pub trait InlineKeyPrefix<k> {
  fn compare_prefix(self, key: k, prefix: BTreeInlinePrefix) -> Ordering
}
pub trait InlineKeyLength<k> {
  fn inline_encoding_length(self, key: k) -> U32
}
```

These are design signatures, not new code supplied by this change. Width is
constant for a provider instance. Optional traits require `InlineKey<k>` to
be present; assert this at compile time. Probe them with
`implements::<c, InlineKey<k>>()` and equivalent guarded calls. A comparator
without `InlineKey` gets the plain plan. No registry, runtime type-name test,
unsafe cast to an assumed standard key type, or compiler special case is used.

Rust has associated constants and default methods; current Dew traits do not.
Trait presence replaces `HAS_HASH_TAG` and `HAS_CMP_FROM`. `inline_width`
replaces `WIDTH`. Ordinary helpers supply the defaults: full comparison for
ties, window-by-window comparison to the padded prefix, and a 64-byte initial
prefix limit. `InlineKeyLength` permits standard finite encodings to start
with fewer than 64 bytes. This does not limit key length. A custom provider
need only implement `InlineKey`; the other four are optional optimizations.

`compare_from` may skip exactly the padded bytes proved equal, then must return
the full comparator's result, including a real-length tie break. It is not a
license to skip an unequal byte. `compare_prefix` compares the key's first
`prefix.byte_length()` padded encoding bytes with the supplied prefix, not
full key length. `BTreeInlinePrefix` exposes `byte_length() -> U32` and
`window_at(offset: U32) -> U64`, with the same zero-padding and big-endian
numeric-word rules. Its fields and mutation helpers are private to the engine.
All provider methods must be pure, stable and non-reentrant with respect to
the map. No method may mutate a stored key or the comparator's ordering.

### 4.2 Standard providers and widths

| Comparator/key | Leaf/branch windows | Tag and tied-key comparison |
| --- | --- | --- |
| `NaturalComparator` / U64 | 2/2 | No tag; full integer comparison |
| `NaturalComparator` / I64 | 2/2 | No tag; sign-bit-flipped encoding, full comparison |
| `StringComparator` / String | 8/4 | `min(byte_length,255)` tag when layout permits; compare bytes after tie |
| `StringViewComparator` / StringView | 8/4 | Same byte rules within the view |
| `BytesComparator` / Bytes | 8/4 | Same byte rules |
| Other comparator/key with `InlineKey` | Requested width in both kinds | Optional tags and comparison helper |
| Width Eight plus `InlineKeyCompareFrom` | 8/4 | Branch windows must be rehydrated before export |
| No `InlineKey` evidence | Plain/plain | Full comparator |

Use big-endian bytes of U64. For I64, flip bit 63 before taking those bytes.
At offset 8 or later, return zero; guard the offset before shifting because
Wasm masks shift counts. String providers use UTF-8 bytes, matching existing
byte ordering, not Unicode normalization or locale order. A tag of 255 only
means length at least 255, not an exact length. Narrow integers do not get an
inline plan merely because Dew can encode them: upstream Auto leaves them
plain. Floating-point keys need a valid total comparator and remain plain
unless that comparator supplies its own encoding.

Upstream Auto also recognizes Rust U128/I128 and fixed byte arrays of lengths
16, 20 and 32. Dew has no corresponding scalar 128-bit integers or fixed
length in the `FixedArray<U8>` type. Do not infer those plans from a V128
carrier or a runtime array length. A user-defined ordered key/provider can
supply windows. This is D2, not a reason to omit the standard plans above.

### 4.3 Search within a node

Count windows less than and equal to the query across the whole capacity
strip with SIMD. Let `a` be the number less and `b` the number equal, with live
lane masks applied. Full-key candidates are the contiguous interval
`[a,a+b)`. If `b=0`, `a` is the insertion/child position. A tie in an inline
branch obtains its full separator key by the head-leaf walk in section 2.

Plain search and a tied run use binary search. Upstream uses a branchless
search for cheap, non-dropping keys up to 16 native bytes and early-equality
binary search for other keys. In Dew, use the cheap branchless form for
scalar numeric keys with the standard comparator; use early-equality search
for reference/custom comparisons. Do not interpret a small reference carrier
as proof that its comparator is cheap. Test final code and branch counts.

An exact leaf lookup with one candidate confirms the key. With several
candidates and tags, filter by equal tag: zero matches means miss; one means
one confirmation; two are checked from the upper candidate, then the lower
only if the query sorts below the upper. With three or more tag matches, use
binary search on the **original contiguous tied interval**. It is incorrect
to binary-search tag matches as if the holes were ordered by tag. Insertion
positions and range bounds always preserve key order; tag rejection alone
does not give an insertion rank.

For standard byte keys, a tie proves equality through `prefix + stored_width`
padded bytes. Compare the remaining bytes and lengths. A four-byte branch
tie proves four bytes, not eight. Upstream's fixed native byte-array equality
fast path has no automatic Dew counterpart; custom providers can still make
their full comparison cheap.

## 5. Prefix state and its repair

A node's prefix length `p` describes encoding bytes shared by its **ancestor
fences**, not just the current keys in that node. The lower fence is the
nearest ancestor separator to the left; the upper fence is the nearest one to
the right. The lower fence's entry is included on the right side of its
separator. The upper fence is outside that subtree. Fences are found from
the descent path and are not copied into nodes.

For two fences, take their zero-padded longest common prefix, capped at 65,535.
For root or edge nodes with a missing fence, use the tree's shared prefix.
Keep `child.p >= parent.p`; a branch refit is capped by the minimum prefix of
its children. Refit children before their parent. Windows start at `p`.

The shared prefix stores at most 64 bytes. The first key initializes it to
`min(encoding_length,64)` if length evidence exists, otherwise 64 padded bytes.
Before inserting a key, shrink the shared prefix to what it shares with the
new key. Move both border spines back to the new length using the old prefix
bytes. Ordinary deletion does not grow it. The next insert into an empty map
initializes it again. A query first compares with this shared prefix once:
if it lies outside, exact lookup misses and a bound can choose a tree extreme.

Represent `BTreeInlinePrefix` with four private mutable V128 fields and a
U32 byte count in one GC object. Select/extract words with ordinary lane
helpers. A prefix callback receives this existing object; do not allocate a
byte view for each query. The plain plan has no prefix object. The inline plan
creates it with the first node, retains it across ordinary deletion, resets
it on the next first insert, and releases it on clear. Do not use 64
`WasmArray<U8>` elements and call that 64 bytes: those elements have i32
carriers in the current library. The packed fields still have a GC header,
which must be included in memory results.

Compute a fence LCP in eight-byte words: XOR, count leading zeros, divide by
8, and stop at the first unequal byte or at 65,535. Bound all arithmetic in
U32/U64. All-zero custom encodings must terminate at the cap. Equal padding
does not imply full-key equality, and a short key ending in zero is a required
test case.

To move an old window from offset `p` back to `q <= p`, let `d=p-q`, and let
`fill` be a word at `q` from the old common prefix or separator. Treat narrow
stored windows as a U64 high part with zero low bits:

```
d == 0: old
d >= 8: fill
otherwise: (fill & ~(U64_MAX >> (8*d))) | (old >> (8*d))
```

Take the high bytes needed by the destination. The explicit `d>=8` branch is
required; a Wasm shift by 64 does not produce zero. A prefix that grows needs
fresh windows from every live full key. For a branch this can walk to leaf
heads. When a four-byte branch window moves to an eight-byte leaf slot, read
the complete word from its full key **even if the prefix offset is unchanged**.
Do not manufacture the missing low four bytes as zero.

Repair order is part of correctness:

1. **Insert without split:** shrink the shared prefix first if needed. Node
   fences do not otherwise change. Compute the new window at the node's `p`.
2. **Split:** both halves start with the old prefix. Move the promoted window
   back to the parent's prefix. Insert the new item. Refit changed children
   and then parents to the new fences, after counts and head placement are
   final. A new root has the shared prefix.
3. **Merge:** first move both children back to the parent's prefix using the
   separating key's window. Merge through the separator, then refit the
   surviving child and its affected borders.
4. **Borrow:** move the receiving child's windows back to the parent prefix;
   move the donor's promoted separator window back as well. Refit both
   children after rotation. A narrower branch export needs rehydration.
5. **Replace/delete separator `s`:** find its successor `s'` first. Before
   removing `s`, shorten the right border of the subtree to its **left** to
   `max(parent.p, min(old_p, LCP(s,s')))`. Then replace the separator/head.
   After removal repair, refit the left border of the subtree to its
   **right**, and all changed children and donors, from the bottom up.

The last rule is easy to miss. A new fence can shorten a prefix on the left
even though the left subtree's entries did not change. Updating only the
right child's minimum is not sufficient. Prefix changes may temporarily be
conservative during a repair; completed public operations restore the exact
fence-derived lengths, subject to caps and the shared-prefix rule.

## 6. Insert, split, remove and merge

### 6.1 Thresholds

For a node kind's regular/separator capacity `C`, define:

```
M = max(floor(C / 8), 4)              # minimum non-root key count
A = min(2 * M, floor(C / 2))         # small half for an edge split
```

The minimum is **not half capacity**. Leaves and branches can have different
capacities and thus different `M` and `A`. A root leaf may hold 0 through C
regular entries. A non-leaf root holds at least one separator; collapse it
when that count becomes zero. No tombstones or delayed whole-tree rebuilds.

Search once without a saved path. A hit replaces only the value and keeps the
stored key. A leaf with room takes the new entry directly. Only a full target
starts a second descent that records a path; use the result of that descent,
not a stale insertion index from the first search. Propagate splits upward.

Split a full node of `C` existing keys **before** putting the new key at
insertion index `i`, where `0 <= i <= C`. Choose the existing separator index:

```
i == 0: j = A - 1
i == C: j = C - A
otherwise: j = floor(C / 2)
```

Left keeps existing regular keys `[0,j)`. Right keeps `(j,C)`. Existing key
`j` becomes the separator; for a leaf its value becomes the right head. In
the inline plan its full key also becomes the right head. In a plain leaf
its key moves to the parent. A branch split moves child edges consistently:
left keeps `j+1` children and right gets `C-j` children.

If `i <= j`, insert into left at `i`; otherwise insert into right at
`i-j-1`. Final regular counts are respectively `(j+1,C-j-1)` or `(j,C-j)`.
For native `C=55`, `M=6`, `A=12`: an ascending insert leaves 43 regular keys
left and 12 right, plus the right head. A descending insert gives 12/43.
For Dew's initial inline U64 leaf `C=54`, `M=6`, `A=12`, ascending gives
42/12. Do not redistribute into a sibling before splitting: upstream does
not do that in the studied implementation.

Root growth makes a new branch with the two children and one separator.
Dew replaces its GC root reference; it does not copy nodes into a stable raw
root page. Root identity is private. No public cursor can depend on it.

Private node/map identity checks use a source-declared one-to-one `ref.eq`
binding with typed reference operands. This is already supported by both
compiler paths; it is within the repo's builtin rule. Keep this instruction
separate from key equality, which always uses the comparator. Do not add a
node ID, global identity counter or identity table.

### 6.2 Sequential append hint

Preserve upstream's last-leaf hint. Install it only after a splitting insert
of a new maximum whose recorded path took the last edge at every level.
The hint contains only the rightmost leaf reference, not a cached key or count.
On a later insert, first check room, shared-prefix agreement, and that the
new key is strictly greater than the leaf's last key. If valid, append there.
Clear the hint before invoking user comparison/encoding code, then restore it
only after success. An equal, smaller, full-leaf or other mutating path clears
it. Read-only operations retain it. Do not add an append check to every level
of an ordinary descent. Batch rules below also preserve this path.

### 6.3 Delete and repair

Search records the path needed for repair. A miss does nothing. Remove the
entry physically. A non-root node needs repair when its count is less than
`M`; a single ordinary removal can lower it to `M-1`.

Choose the left sibling if one exists, otherwise the right sibling. Do not
choose whichever sibling has more keys. For this chosen pair:

```
if left.len + 1 + right.len <= C:
    merge into LEFT, through the parent separator
else:
    borrow exactly ONE entry/edge through the parent separator
```

Merge comes before borrowing, even if the sibling could spare a key. On a
merge, the right head and parent separator become a regular entry of left;
append the right regular entries and remove the separator/right edge from
the parent. For branches, concatenate left children, the separator, and
right children in the usual key/edge order. Clear the retired right node.

For a left-to-right leaf borrow, the left leaf's last regular entry becomes
the new parent separator and right head; the old right head becomes right's
first regular entry. For a right-to-left borrow, the old right head becomes
left's last regular entry, and right's first regular entry becomes the new
head/separator. In plain nodes, move full separator keys through the parent;
in inline nodes, full keys stay in leaf slots. Branch rotation also moves the
one adjacent child edge across the separator. Since a merge did not fit, the
donor can spare the one entry. Use prefix repair from section 5.

A separator deletion removes its value from a head leaf. Promote that leaf's
first regular entry to replace the deleted head/separator, then repair the
leaf as needed. Keep enough path information to finish updating the original
separator even if local underflow stops below it. Structural deletion must
not leave a full key in two places. A merge can cause parent underflow and
continue upward; a single borrow stops the occupancy repair. Prefix repair
can still be required elsewhere on the saved path.

When the root has zero separators, replace it by its only child, repeatedly
if required by a bulk operation. Preserve the shared prefix and clear stale
hints. Ordinary `clear` drops the root rather than calling remove N times.

### 6.4 Work space, limits and traps

Upstream uses a fixed native stack of 24 path slots (maximum depth 23). Dew
has a U32 length limit. With minimum four regular keys, a tree of leaf depth
`h>=1` has at least `2*5^h - 1` entries. Depth 13 can fit U32; depth 14 cannot.
Use 15 path slots (14 levels plus a growth slot), with an assertion on every
push. A path consists of typed node references and U32 edge indices, not an
object per path element. Lazily allocate reusable map work space for slow
inserts, removals and bulk writes. Clear its node references on completion;
retain only the bounded storage. Point lookups and non-splitting inserts must
not allocate a path. Iterator paths belong to the iterator, not this work space.

Use U64 or checked arithmetic for byte formulas, counts before narrowing,
batch lengths and intermediate sums. At U32 maximum length, an existing-key
replacement remains valid; a new distinct key traps before changing the tree.
An outside-prefix query already proves absence and can perform this check
before shrinking the prefix. Otherwise search for equality before committing
a growth or prefix change. Bound config arithmetic before allocating.

Comparator/provider/callback traps are not Rust unwind-safe transactions.
Do comparisons and user decisions before structural edits where possible.
If a trap occurs during a structural edit or allocation, a host must discard
all aliases to that map before it resumes Dew code. Do not claim rollback or
catch-and-continue guarantees. Local assertions must name the node kind,
count, capacity, operation and failed assumption. The normal API must not
hide a failed repair by returning a miss.

## 7. Batching is part of the first delivery

### 7.1 Public contract

Upstream's unsync `get_many` takes an array of key references and returns an
array of optional value references in the same order. `insert_many` returns
the old values in input order. They are synchronous calls. Private async
search lanes overlap memory requests; there is no background task or thread.
Upstream limits its fast stack/mask executor to 64 lanes and has a larger-N
path. It prefetches the next needed window line, edge/header, candidate entry,
or heap bytes. Single-key operations do not pay for that machinery.

Dew uses runtime-length `FixedArray` inputs and outputs; it has no Rust const
generic `[T; N]` arrays. The required methods are:

| Method, after `self` | Result | Meaning |
| --- | --- | --- |
| `get_many(keys: FixedArray<k>)` | `FixedArray<Option<v>>` | Same length/order; duplicate queries remain separate |
| `contains_many(keys: FixedArray<k>)` | `FixedArray<Bool>` | Avoid value/Option results for existence-only work |
| `insert_many(entries: FixedArray<BTreeEntry<k,v>>)` | `FixedArray<Bool>` | Per input, true if a new key was added |
| `put_many(entries: FixedArray<BTreeEntry<k,v>>)` | `FixedArray<Option<v>>` | Per input, the previous value, as upstream insert_many |
| `extend(entries: FixedArray<BTreeEntry<k,v>>)` | `Unit` | Same writes and order, with no old-value result array |
| `extend_iter(input)` | `Unit` | Generic `Iter<BTreeEntry<k,v>>`; bounded buffer |

Empty batches return empty outputs or Unit without making tree nodes.
Length one uses the scalar path. Writes have exactly the result of scalar
writes in input order, including duplicate keys and retained key objects.
They must also produce the same node contents, counts, prefixes and tree
shape as scalar insertion with the same config. A batch is not a transaction.
Do not sort or deduplicate it, pre-split leaves, or shrink prefixes for future
input keys before their turn. Read-only batches cannot mutate membership.
The caller must not change an input array, its key encodings, or the map from
inside comparison/provider code while a call is active.

`get_many` returns snapshots under Dew's value/reference semantics. If a
value is a mutable object, its reference is copied, not deep-cloned. A missing
key with `v = Option<t>` is distinct from a present `Option::None` value.
Bool and Unit write forms must use a result policy that avoids constructing
discarded `Option<v>` or entry wrappers. `put_many` is allowed to construct
its requested public results.

### 7.2 Scheduler and cutoffs

Use an ordinary Dew state machine for each lane, held in typed columns. No
async language extension, host coroutine or runtime scheduler is needed.
One round advances each live lane through its next dependent read: current
node/window scan, candidate/child selection, child or head descent, and final
key confirmation. Carry the query index, current node, phase, candidate
range, prefix/window state, and final destination in those columns. A lane
that follows a separator's head must preserve its original branch/index.
Do not turn the control record into an allocated object on each advance.

Use at most 64 active lanes, with a U64 live mask. Guard the 64-lane mask case
instead of shifting by 64. Process longer public inputs in consecutive
chunks. Reuse bounded, lazy map-owned batch work space; clear node/key/value
references when the call ends. The output array is per call. Keep this work
space absent from maps that never batch. Account for its retained high-water
size. There is no standard Wasm software-prefetch instruction; use ordinary
typed loads and interleave independent searches. Do not insert a host call
to pretend to prefetch. D5 records this unavoidable performance difference.

Upstream's initial serial cutoff is:

```
T = max(1, floor(1_048_576 / leaf_page_bytes))
    * (floor(7 * leaf_capacity / 10) + 1)
```

Use the selected modeled leaf budget multiple as `leaf_page_bytes` in Dew.
Serial paths apply for fewer than two inputs, a leaf root, or map length below
T. Native defaults give T=39,936 for inline U64/U64 and T=17,408 for tagged
String/U64. The initial Dew plans give 38,912 and 28,672. These are startup
policies inherited from the cache-size model, not measured Dew crossovers.
Keep a test-only switch to force scalar or lane execution on a small tree.
Measure crossovers and bounded lane counts (4, 8, 16, 32, 64) before release;
record any threshold change with raw results. Do not remove the lane design
on the strength of a small-tree benchmark alone.

For `extend_iter`, retain upstream's buffer of 16 entries above the cutoff;
process a partial tail serially. If 16 modeled key/value slots exceed 4 KiB,
use the serial stream. The input's yielded snapshot wrappers and referenced
payloads are not claimed to fit in that 4 KiB. Streaming input is never
collected without bound. The stable-sort builder in section 9 is a different
operation with different duplicate-key semantics.

### 7.3 Predicted write destinations

Predict destinations against the current tree using read-only lanes, then
commit in input order. Each prediction is one of:

* `Leaf(node, saved_len, index, found)`: a regular leaf hit or insertion gap.
* `Separator(node, separator_index)`: an existing branch separator/head hit.
* `FromRoot`: no safe destination, including a key outside the shared prefix.

Before each commit, apply only that key's shared-prefix shrink. Predictions
made before a change cannot assume the old prefix. Use this invalidation
table, which is central to upstream's batch design:

| Committed change | Treatment of remaining predictions |
| --- | --- |
| Value replacement | Destinations remain valid |
| Fit insert into a leaf | A prediction for that leaf detects changed `saved_len` and searches that leaf again |
| Leaf split, including propagated branch splits | Invalidate that leaf's predictions and **all separator predictions**; unaffected leaf destinations remain valid |
| `FromRoot` commit, including shared-prefix shrink | Invalidate all remaining predictions; resume from root |

Compare leaf identity with `ref.eq` on retained node-wrapper references inside
private work-space logic. Do not invalidate unaffected leaf predictions just
to avoid this check. Once a `FromRoot` prediction is committed, all later
writes in that chunk use scalar root insertion, as upstream's
`descents_valid` flag requires; do not repredict later entries mid-chunk.

An initial successful append-hint write makes the rest of that batch serial,
as upstream does, to keep the sequential append path cheap. A root fallback
uses the ordinary insertion engine, including overflow checks, split bias and
prefix repair. A lane prediction does not reserve space or authorize writing
through a retired node. Upstream's write prefetch for shifts does not yield;
Dew's commit likewise runs to completion before advancing another write.

## 8. Iteration and bounds

### 8.1 Two-ended walks without leaf links

Preserve upstream's two path cursors. A whole-map iterator initializes the
front or back path only when that direction is used. It knows the exact
remaining entry count. A range iterator seeks bounded ends at construction;
an unbounded end can stay lazy. A cursor retains the owner map so that dropping
the caller's variable cannot drop live nodes.

Forward order within a leaf is its head if present, then regular entries.
After a leaf, ascend to the nearest ancestor with an unvisited right child,
then descend that child's first-child spine. The separator passed during
that ascent identifies the next leaf head's key in a plain tree. In an inline
tree the head supplies both key and value. Backward walking mirrors this:
regular keys in reverse, then the head, then the preceding subtree. Do not
visit an ancestor separator again after visiting its leaf head.

Each path uses arrays of node references and edge indices, with space based
on the map's height and bounded by the path limit. Cache each leaf's current
run limits. Advancing inside a run is a checked indexed load, not a root
search or full path update. Synchronize the path when crossing a leaf or
changing direction. A full-map `remaining` count prevents the two ends from
yielding the same item. For ranges, compare canonical path positions: the
root-to-leaf child-index sequence plus head/regular position. Reconcile the
two run limits when their paths meet. No comparator call is needed per item
after initial bound seeks. Do not solve crossing by copying all range keys
or doing a new key search after each `next`.

`next()` and `next_back()` return `Option<BTreeEntry<k,v>>`; keys/values
wrappers project the requested component directly and need not allocate a
discarded entry. Repeated exhaustion returns `None` in either direction.
`has_next()` is non-consuming and reports the shared exhaustion state.
The iterator implements Dew's existing `Iter<t>.next`; `next_back` is an
inherent/free method until a standard double-ended trait exists. `for` must
call `iter` once. An explicit `clone_cursor` copies path storage and position;
ordinary assignment aliases the same mutable iterator object.

Provide a leaf-run `fold`/`for_each` helper for internal set and bulk work and
a public `for_each` callback traversal that passes `(k,v)` directly. This
avoids mandatory snapshot-entry allocation on scans that do not need it.
It still visits heads and respects stored key order. User callbacks may
change referenced value objects but must not structurally mutate the map.

### 8.2 Bounds

Keep the existing ordered-collection call form:

```
range(lower: Option<k>, lower_inclusive: Bool,
      upper: Option<k>, upper_inclusive: Bool)
```

`None` is unbounded and ignores that side's inclusive flag. A present lower
bound seeks `>=` or `>`; a present upper bound seeks `<=` or `<`. Seek against
the full comparator even when windows tie. Range order is ascending under
the supplied comparator, which can itself express reverse numeric order.

Follow bbtree's invalid-bound rule: trap with a clear message if lower is
greater than upper, or if equal bounds are both excluded. Equal bounds with
one excluded end give an empty range; equal bounds with both ends included
give that one key if present. This replaces the older proposal to make all
reversed ranges empty. Test the four equal-bound combinations, absent equal
keys, unbounded sides, and prefix-outside seeks from both ends.

`lower_bound(k)` is the first key `>= k`; `upper_bound(k)` and `successor(k)`
are the first key `> k`; `predecessor(k)` is the last key `< k`. Minimum and
maximum include a leaf head where appropriate. Bounds return snapshot
entries and do not require the query key to exist.

### 8.3 Aliases and mutation

Use Dew's established collection contract. The map is a shared mutable
reference. A structural change (new key, removal, clear, split, append, bulk
rebuild) invalidates existing cursors. Their later traversal is unspecified
but remains memory- and type-safe. Do not add an epoch/version load on every
`next`. Keep live-slot/count checks so invalidated cursors cannot turn a
cleared nullable slot into an unchecked typed value.

Replacing an existing value does not invalidate a cursor. Unread entries see
the latest value; an already returned scalar snapshot is unchanged. A
returned reference value still aliases its referenced object. A snapshot
entry cannot set the map's value slot. This is the ordered-entry convention,
not the hash map's live `MapEntry` convention.

Rust borrowed, mutable-borrowed, and owning iterators are different APIs.
Dew cannot enforce their exclusive lifetimes or consuming ownership. Do not
expose Rust-like `&mut v`, an occupied-entry handle into a node, or an
implicitly consuming `into_iter`. Use snapshots and explicit whole-map
operations instead (D3). No persistence, snapshot isolation, or guarantee
that cursors survive structural mutation is added.

## 9. Bulk build, append and split

These operations reuse the same node engine. They are separate from the
serial-equivalent batch write API and belong in the complete first delivery.

### 9.1 Construction from entries

`from_entries(comparator, entries)` copies the input sequence to private
scratch, stable-sorts it by the comparator, and retains the **last key and
value** of each equal run, as upstream collection construction does. Do not
mutate the caller's input array. A `from_sorted_entries` form accepts strictly
increasing unique entries; check this precondition with a diagnostic before
publishing the map. The builder itself needs no comparison between entries.

Fill each leaf completely before starting its right neighbor. The next entry
after a full leaf becomes the new leaf head and a separator in the right
border. If its parent is full, start a new branch with that child as child 0,
then continue one level up. Create a root when needed. Only nodes on the
right border can be underfull, even empty. Shrink the shared prefix as input
requires. Refit a full node once it leaves the border and gets a right fence;
do not compute a fictitious right fence while it is still on the border.

At finish, repair the right border from the top down. Stock a border child to
`M+1` so a merge below can remove one parent separator without making it
underfull. For each chosen sibling pair, merge if it fits; otherwise borrow
as many entries as needed to reach `M+1`. This **bulk border** rule differs
from the exactly-one borrow after ordinary deletion. Collapse empty roots,
then refit all donor/changed prefixes from the bottom up. A sorted build is
linear after input validation; general construction also pays for sorting.

### 9.2 Append

`append(other)` merges two sorted walks through that builder in O(n+m), not
through repeated insertion. For equal keys, keep the receiver's stored key
and the donor's value. Empty the donor after successful transfer. Both maps
must have equivalent comparator order and compatible inline evidence, even
when two instances of `c` hold different state. This is a caller precondition;
a type match alone does not prove it. Recompute windows with the receiver's
provider. A different payload config in the donor is permitted for rebuilding.

The empty-donor path is a no-op; an empty receiver can take a compatible
donor's root/plan data, or use the builder if the config differs. Check self
aliases with the private `ref.eq` binding before detaching either root;
self-append is a no-op. Keep detached roots reachable until the new root is
installed. A trap does not
promise rollback, per section 6.4. Use checked length arithmetic; equal-key
collapse can make the union fit even when the two input lengths sum past U32.

### 9.3 Split

`split_off(key)` leaves keys `< key` in the receiver and returns keys `>= key`
in a new map with the same provider/config. Search to the leaf edge before
the cut. For a separator hit, this edge is at the end of the preceding leaf.
Before changing nodes, move the cut path's prefixes back to the old shared
prefix from top to bottom. From leaf to root, cut each node at the path edge:
left stays, right suffix moves to a new node whose child 0 is the right part
from the level below. Both result trees initially retain the old shared
prefix and may have underfull nodes only along their new borders.

Repair the left result's right border and the right result's left border with
the `M+1` bulk rule above. A leading separator in the right tree with nothing
left of it must come down into its globally first leaf as a regular entry,
including its head value. Collapse empty roots. To derive lengths, count
node key counts in the result with smaller height (the upper result on a
height tie), and subtract from the original length, as upstream does. This
is a node walk, not a promised O(log n) length calculation or a guaranteed
choice of the smaller entry population. Install both roots/counts before
refitting donor prefixes. Structural cut work touches O(height) nodes; count
work is proportional to nodes in the selected result. Do not add subtree
entry counts to every node merely to remove that count walk.

### 9.4 Retain

`retain(predicate)` visits stored keys in order and removes entries for which
the predicate returns false. The callback receives `(k,v)` snapshots, not a
mutable slot borrow. Use a mutable path walk whose removal returns the next
position after repair, as upstream `remove_and_go_to_next` does. Do not copy
all keys or restart from root per entry. Preserve the current key when no
removal occurs; move the saved position with shifts, head promotion, merges,
borrows and root collapse when removal occurs. This keeps the map valid
between callbacks. A callback cannot structurally change this map through
an alias. A value object may still be changed through its own reference.

Upstream's lazy `extract_if`, `iter_mut` and entry handles rely on exclusive
borrows and allow mutation of value slots through references. They are not
exposed under the same names with misleading guarantees. Dew's `retain`,
`update`, `get_or_insert_with` and snapshot walks supply the required safe
operations. A later explicit draining API would need its own alias contract;
it is not a hidden requirement of this delivery.

## 10. Public map surface and standard-library integration

Public facade modules are `dew.std.collections.btree_map` and
`dew.std.collections.btree_set`. The common module is
`dew.std.collections.btree`, in `std/collections/btree.dew`. It declares the
engine, config, prefix type, inline traits and standard provider impls.
Keeping those shared declarations together lets the prefix's mutation helpers
stay private and avoids a provider/engine import cycle. The map and set
facades import that module. Follow
the module registry/generator rules in `std/README.md`. All runtime algorithms
are Dew functions and use the same semantic rules as user modules.

Expose `BTreeMap<k,v,c>`, `BTreeEntry<k,v>`, `BTreeMapIter<k,v,c>`, key/value
iterator wrappers, and `BTreeConfig`. Fields are private. Provide method forms
and the established `btree_map_*` free-function forms; method forms call the
same engine. Require `c: Comparator<k>` where comparisons occur. Do not add a
Default, Eq, Hash, numeric, or inline-key bound to all keys/values. The map's
ordering equality is `compare(...) == Ordering::Equal`, not `k == k`.

Construct configs with `btree_config(leaf_bytes: U32,
inline_branch_bytes: U32, plain_branch_bytes: U32) -> BTreeConfig` and
`btree_default_config() -> BTreeConfig`. Validate at construction and again
at the map boundary if the compiler cannot prove the config came through
that constructor. Configs are immutable; getters expose the three budgets.

| Method or constructor | Result | Required behavior |
| --- | --- | --- |
| `new(comparator)` | map | Default config, no nodes |
| `with_config(comparator, config)` | map | Validate config once |
| `length()`, `is_empty()` | U32, Bool | O(1), count includes heads |
| `get(key)` | `Option<v>` | Value snapshot |
| `get_key_value(key)` | `Option<BTreeEntry<k,v>>` | The stored key, not the query key |
| `contains_key(key)` | Bool | No discarded value result |
| `insert(key,value)` | Bool | True if newly inserted; false if replaced |
| `set(key,value)` | Unit | Insert or replace, no result allocation |
| `put(key,value)` | `Option<v>` | Previous value, or None for a new key |
| `remove(key)` | Bool | True if an entry was removed |
| `take(key)` | `Option<v>` | Removed value |
| `remove_entry(key)` | `Option<BTreeEntry<k,v>>` | Removed stored key and value |
| `clear()` | Unit | Release map-held tree/work-space references |
| `minimum()`, `maximum()` | `Option<BTreeEntry<k,v>>` | Empty map returns None |
| `pop_minimum()`, `pop_maximum()` | `Option<BTreeEntry<k,v>>` | One structural removal at the selected end |
| `lower_bound`, `upper_bound`, `predecessor`, `successor` | `Option<BTreeEntry<k,v>>` | Section 8.2 |
| `iter()`, `keys()`, `values()` | corresponding iterator | Ordered, two-ended, lazy whole-map ends |
| `range(lower,lower_inclusive,upper,upper_inclusive)` | map iterator | Section 8.2 |
| `for_each(callback)` | Unit | Ordered `(k,v)` callbacks, no mandatory entry object |
| `update(key, transform)` | Bool | If present, replace value with `transform(old)` once; return true |
| `get_or_insert_with(key, factory)` | v | Return stored value; call factory once only when absent |
| `retain(predicate)` | Unit | Section 9.4 |
| `from_entries`, `from_sorted_entries`, `append`, `split_off` | as in section 9 | Bulk rules are distinct from batches |
| `get_many`, `contains_many`, `insert_many`, `put_many`, `extend`, `extend_iter` | as in section 7 | Input-order results and writes |

`BTreeEntry` has an ordinary `btree_entry(key,value)` constructor and `key()` /
`value()` accessors. There is no map mutation through this snapshot object.
Callbacks are ordinary generic callable parameters under current Dew function
rules, not foreign callbacks or new builtins. `update` never calls its
transform on a miss. `get_or_insert_with` preserves the original key on a
hit and does not evaluate the factory then. Callbacks cannot reenter a
mutating operation on the same map. At the maximum length, a missing-key
factory call traps before invoking the factory.

Implement `IndexedGet<k,v>` with the same missing-key trap convention as
`OrderedMap`, and `IndexedSet<k,v>` through `set`. Add the current `Iter`/`for`
integration. Do not invent optional/default arguments or Rust overloads.
Same-key-type queries are the initial public contract. Rust `Borrow<Q>` and
borrowed `str`/slice lookup are not direct Dew types; `StringView` has its own
provider. A future cross-key query protocol must prove comparator/encoding
compatibility and must not silently compare arbitrary physical carriers.

For all ordinary insert forms, equal keys retain the earlier stored key;
only the value changes. `from_entries` is the specified last-key exception.
Reference keys may be stored, but their order/encoding must remain stable
while stored. Key mutation that breaks that rule is a contract violation;
it must not become an unbounded loop or unsafe slot read.

## 11. Set scope: include it

Upstream `BBTreeSet<T>` wraps `BBTreeMap<T, SetValZST>`. It has no independent
nodes, balancing code, or concurrency engine. Its zero-sized value does not
take a value slot. The correct Dew first-delivery form is
`BTreeSet<k,c>` wrapping `BTreeMap<k,Unit,c>`, with the erased value column from
section 3.2. Do not copy the existing `OrderedSet` choice of a Bool payload.

The first delivery includes construction/config, length/empty, clear,
insert/remove/contains, `get` (stored key), `take` (removed stored key),
`replace` (replace the equal stored key and return the old one), min/max,
pop-min/pop-max, the four bounds, iter/range, contains-many/insert-many,
extend, from-entries, append, split-off and retain. Its methods and
`btree_set_*` free functions call the map engine. `insert` returns false and
keeps the earlier key on equality; `replace` is the explicit exception.
For `replace`, update the actual key home: a plain separator key in a branch,
or an inline head key in its leaf. Comparator-equal keys have the same
encoding/tag by contract, so this is not a structural change. Unread cursor
positions see the replacement key; already yielded keys remain snapshots.

Also include lazy ordered `union`, `intersection`, `difference`,
`symmetric_difference`, `is_subset`, `is_superset`, and `is_disjoint`.
Union yields the left set's stored key on equality, as upstream does.
Intersection can yield either representative: the merge path yields the
left key, and the lookup path yields the small set's key. Both providers must
define the same order. Use a two-stream merge for comparable sizes. Select
lookup-based intersection/difference/subset work when
`small_length <= large_length / 16`, independently of the batch cutoff.
Only batch those lookups when the large map passes that cutoff and at least
32 input keys remain; otherwise probe them one at a time. Keep the bounded
32-key lookahead buffer and consume its result mask in input order. The tail
of fewer than 32 keys uses scalar probes. Handle empty inputs before ratios.
Use min/max to reject disjoint ranges or settle a one-end intersection before
selecting a walk. Difference only probes right from left when the right set
is sufficiently larger; it cannot swap operands. Subset rejects a larger
left set and out-of-range endpoints first. Superset reverses subset, and
disjoint checks whether intersection has a first result.
Union and symmetric difference remain ordered merges. Algebra iterators must
not construct a materialized result set or a map entry for each Unit value.
Only the normal set iter/range wrappers promise `next_back`; algebra iterators
need the forward `Iter<k>` contract. Structural changes to either source
invalidate a lazy algebra iterator under the same collection rules.

The set is a final wrapper stage after the map, not a parallel tree project.
Its Unit erasure and wrapper overhead need emitted-code/allocation checks.

## 12. Concurrency: share algorithms, not unsupported guarantees

The single-threaded and shared bbtree maps use the same core tree. The shared
map wraps the node strategy in a latched strategy; it is not a persistent
tree or a completely different lock-free index. It requires inline keys, so
branches contain no movable full keys. Main features at the pinned commit:

* A 64-bit node latch: exclusive bit 0, shared-reader bits 1..20, and an upper
  version field. Latched headers are 16 bytes. The root is atomic.
* Optimistic, version-coupled branch descent. Leaf callbacks run while the
  leaf is held. Eligible copied-value reads can try an optimistic path, with
  validation and a locked fallback. Following a pointer to key bytes has
  stricter rules than checking a self-contained inline key.
* Structural writes try to hold the needed path, siblings and prefix-border
  nodes; contention causes a restart rather than waiting while holding a
  conflicting partial lock set. Held nodes then use the unsync repair code.
* Removed pages remain in typed free lists until map drop. Page kind and
  version rules let readers reject stale reads without epochs. This retains
  high-water memory, not just the live tree's memory. Stable-root validation
  is special when the root changes kind.
* No borrowed references or lock guards escape. Reads/updates use closures
  or copies. There is deliberately no globally contended exact-length word.
* Scans are ordered and visit entries that remain present exactly once;
  concurrent insertions/removals may or may not be observed. They are not a
  snapshot. Copied ranges use bounded caches (1/4/16), version stamps and
  resume positions, not the unsync borrowed cursor contract.
* Shared batches are serializable per entry, not atomic as a whole. Read
  callbacks can complete in lane order; write commits follow input order.
  Locks are not retained across a lane yield.

The upstream concurrency note also identifies limitations in Rust's formal
model for racing raw reads. Passing its stress and schedule tests is not a
proof that this design can be copied into another memory model unchanged.

Dew currently has no supported shared-GC reference publication, atomic
node-field memory model, or thread/borrow API on which to base these promises.
Therefore deliver only the unsync map. There is no lock word, version word,
atomic length, epoch, retired-page free list, or dormant thread switch in its
nodes. GC already keeps typed referenced objects alive for single-threaded
aliases. A future `ConcurrentBTreeMap` must be a separate API with a defined
memory model and tests; it may reuse plans and repair helpers only under its
own safe node-access layer. This is D6, a platform constraint, not a decision
to approximate concurrent behavior with unsynchronized aliases.

## 13. Correctness and performance acceptance

### 13.1 Tests and invariants

Implementation follows TDD where appropriate, with atomic commits and updated
documentation in every commit. Keep ordinary Dew tests in
`std/tests/btree_*_test.dew`. Use `tools/test-native.sh` for routine tests and
`tools/test-integration-native.sh` for complete compiler/backend cases.
Use `tools/test-stress-native.sh` only for large compiler stress cases and
`tools/test-starshine-native.sh` only when full pinned Starshine coverage is
needed. A raw workspace-wide `moon test` is not the routine test lane.
Time each compiler-related command. Any one that takes more than 30 seconds
must be recorded and investigated as a bug, not hidden in a total time.

A test-only tree inspector must check after each mutation:

1. Counts, capacities, minimum occupancy except root, equal leaf depth,
   `children = separators+1`, and the global length equation.
2. Strict comparator order, all child fences, each separator's unique key
   home and matching leaf head, and no head on the first leaf.
3. The exact selected widths/tags, every live window/tag recomputed from its
   key, safe inactive slots, no full keys in inline branches, and Unit value
   column absence. Inspect emitted GC types for the last two; a logical
   inspector alone cannot prove physical absence.
4. Shared-prefix validity, exact capped fence prefixes, child/parent prefix
   order, and all retired/scratch references cleared.
5. Both cursor directions, range endpoints and repeated exhaustion.

Build an independent small sorted-array oracle using the comparator; do not
use the tree's search helper inside the model. Generate deterministic mixes
of insert, replace, get, remove, bounds, batches, clear, append, split and
iteration. Compare snapshots and lengths at every step. Compare batches to
scalar replay **node by node**, including prefixes, for identical plans.
Run both forced plain and inline paths, plus forced lane execution below the
production cutoff. Failing cases keep the seed and operation log. Assertions
must fail with a diagnostic; tests must not catch the failure and turn it
into a pass or silently skip an unsupported carrier.

Required adversarial cases include:

* Capacities around 12, each `M/A` boundary, root growth/shrink, left-sibling
  preference, merge despite a borrowable sibling, and borrow when merge does
  not fit; leaf and branch repair at several levels.
* Every insertion index around the split separator, ascending/descending
  streams, duplicate keys in full nodes, append-hint invalidation and reuse.
* Delete plain and inline separators, including a successor that shortens
  the left subtree's prefix, repeated head deletions, and both border spines.
* Empty/zero/trailing-zero byte keys, all-ones windows, 2/4/8 widths, constant
  zero providers, tags with 0/1/2/3+ matches, saturated length tags, UTF-8
  boundaries, prefixes near 8/64/65,535 and longer keys, and 4-to-8 rehydration.
* Equality under a custom comparator with distinguishable key objects,
  signed integer extremes, absent bounds, equal-bound combinations, and
  alternating `next`/`next_back` until the cursors meet at a head.
* Batch sizes 0,1,2,16,32,64,65 and longer; repeats in one leaf; a split with
  later separator hits; shared-prefix shrink; root split; unchanged other
  leaves; serial and lane threshold edges; partial streaming tails.
* Value carriers I32/I64/F32/F64/V128, references, Unit, Option and nested
  Option; no Default bound; actual value-expression side effects for Unit.
* Aliases, replacement during iteration, retained snapshots, dropped map
  variables, clear/repopulate cycles and GC reachability after removes.
* Bulk duplicate last-key selection, append duplicate receiver-key selection,
  self-append, sorted-build final border repair, split at separator/extremes,
  retain after each type of repair, and set replacement/algebra.
* U32 overflow through checked test helpers near the limit, without needing
  to allocate four billion entries; invalid configs and path overflow must
  produce clear failures.

### 13.2 Cost model and measurements

No Dew runtime benchmark was run for this design-only change. Upstream's
native results motivate mechanisms; they do not establish Dew speedups,
cache-line counts or GC memory use. In particular, upstream's Wasm notes
report that scalar window counting can lose badly; packed SIMD is a required
part of this delivery, not a later optimization.

The implementation evidence must include exact Dewdrop commit, compiler and
engine versions/options, GC mode, host CPU/OS, native architecture, emitted
module identity, input generator/seed, harness, raw samples, warmups, run
order and noise. Do not treat cross-compilation or emulation as native runtime
evidence. Use independent processes where GC/heap history would bias results.
Use repeated A/B runs with matching inputs, not one attractive best sample.

Controls are Dew's current `OrderedMap`/`OrderedSet` (their red-black engine
uses parallel arrays and node indices, not one GC object per entry), a forced
plain B-tree, scalar replay of the same batches, and ordinary per-entry scans
versus run callbacks. For strings, vary common-prefix lengths, key lengths
and allocation sharing. Measure both cache-resident and large random trees;
include empty/one-entry, short maps, 1M and, where host memory permits, 10M
entries, sorted builds, random inserts, hit/miss lookup, replace, delete,
churn, bounds, short/full ranges, alternating ends, batches and set algebra.

Report time per operation and total throughput separately. Avoid a timer or
host boundary around every key. Check code size and specialization count,
compiler wall time, allocation count/bytes per operation, live and peak heap,
GC pauses, and bytes per live entry after churn and clear. Distinguish node
payload from key/value object graphs, public result objects and retained work
space. Measure empty maps too. No claim of exact page alignment or native
key/value cache adjacency is valid for the chosen GC layout.

Warm point lookup, contains, value replacement and fitting scalar insert must
have no tree/path temporary allocation. Bool/Unit result paths must not make
discarded Options. Splits allocate only the required new nodes/columns plus
bounded first-use work space. Iterator creation may allocate its state/paths;
each leaf step must not allocate another path. Entry snapshots and batch
results are explicit API costs. Unit sets must have no hidden value array.
Check generated Wasm: no unresolved type-query calls, per-key dynamic trait
lookup, whole-tree copying, branch full-key column, or `array.get` loop in
place of the required SIMD window count.

Optimize within the selected design until results show a sound cost, including
small maps, churn and tied prefixes. A runtime regression needs a measured
cause and a fix or an explicit engine constraint; correctness alone is not a
pass. Runtime wins take priority over a small memory win, but unexplained
allocation or retained-memory growth still blocks completion. Do not invent
a speedup percentage that the owner did not set. If an engine limitation
forces a new departure, record the reproducer and revise the departure list
before changing the design. Performance tuning cannot silently replace
bbtree's split policy, separator ownership, prefixes or batched writes.

### 13.3 Checks made for this design

On 2026-10-25, an arithmetic check covered every insertion position for every
capacity from 12 through 1023: 524,722 cases. All split results satisfy the
specified minimum counts and length equation. The same check confirmed that
the selected nonmerging sibling can spare one key after a single underflow.
It also checked the five capacity examples, both Dew batch cutoffs and the
U32 height bound. Local document links, code-fence pairs, all 15 numbered
sections, six departure records and 16 ordered stages were checked.

These are design checks, not runtime validation. No Dew compiler or native
test command was run, and no implementation or benchmark result is claimed.

## 14. Build order: one Sol thread per step

Each step starts from the previous committed step. Keep commits bounded and
tests local to the new behavior. Plain-only and scalar-batch stages are
internal checkpoints, not completion. A thread gets this document, the
previous step's code/tests and its recorded measurements; rereading upstream
is not a prerequisite. Do not launch these threads as part of this design
change.

| Step | One-thread scope and exit evidence |
| --- | --- |
| 1. Prove storage primitives | Small carrier/private-field/nullable-clear/SIMD/ref.eq probes through current compiler lanes; verify opaque module boundaries and no per-entry box; record compile times and allocation/GC types. Any compiler fix must be ordinary and separately scoped. |
| 2. Plans and key providers | Config validation, capacity formulas, optional evidence, standard windows/tags, paired versus column leaf storage, packed metadata, Unit erasure and node allocation/clear. Tests cover all widths/carriers and exact planned capacities. No tree balancing yet. |
| 3. Plain lookup and fit writes | Empty/root leaf, private search result, key retention, value replacement, checked counts, result policies and diagnostic invariant inspector. No public claim of multi-level support. |
| 4. Plain splits and append hint | Head ownership, branch descent, two-pass insertion, all split indices, root growth and last-leaf hint. Differential insertion and no-allocation fit-path evidence. |
| 5. Plain deletion | Regular/head/separator deletion, left-sibling choice, merge-first, one-entry borrow, upward repair, root shrink and slot clearing. Differential deletion/churn and reachability checks. |
| 6. Inline search and keyless branches | Wire all width plans into the shared node engine, SIMD ranks, exact/tagged/tied search and head-key walks. Start with prefix zero; test same map results and absence of full branch keys. This is not yet the finished inline tree. |
| 7. Prefix insert and split | Shared prefix, fence LCP, backshift/rehydration, border shrink, split refits and append behavior. Exact prefix inspector and long/zero-padding tests. |
| 8. Prefix delete and rotation | Fence replacement ordering, merge/borrow refits, both border sides and root shrink under all widths. Mixed-operation oracle passes with exact prefix checks after every write. |
| 9. Two-ended cursors and bounds | Saved paths, heads, run stepping, crossing limits, range validation, snapshots, keys/values projection and alias rules. Allocation/count/compare checks on scans. |
| 10. Public map facade | All scalar methods, entry snapshots, index/Iter integration, update/factory callbacks and free-function forms; module registry and std docs. Carrier/result-policy checks and native suite. Bulk methods remain explicitly pending. |
| 11. Read batches | Public runtime arrays, serial cutoff, bounded lane state machine, all read paths and chunks over 64; forced-lane oracle and crossover/alloc data. No fake prefetch hook. |
| 12. Ordered write batches | Predictions, every invalidation class, append fast path, old-value/Bool/Unit policies, extend and 16-entry streaming buffer. Node-by-node scalar equivalence and runtime/allocation results. |
| 13. Sorted builder and append | Stable last-key construction, full-node builder, M+1 border repair, merge append, alias handling and overflow checks. Bulk-shape/prefix tests and linear-build measurements. |
| 14. Split and retain | Cut-path transfer, both border repairs, length count walk, mutable retain cursor after repair. Tests at each separator/border and no repeated root seek or full-key snapshot. |
| 15. Set facade and algebra | Unit-backed wrappers, replace/take, normal two-ended cursors, merge algebra and 32-key batched asymmetric probes. Stored-key identity, empty/ratio boundaries and zero-value-storage evidence. |
| 16. Delivery evidence and tuning | Complete oracle/standard/integration coverage; repeated runtime, code-size, compile-time and memory matrix; tune with evidence; finalize std docs and this note's measured constraints. No unresolved required feature or unexplained cost is called complete. |

If a step exposes an actual compiler/platform defect, isolate its fix and
tests, update the evidence, then resume the dependent step. This is not
permission to leave a required tree feature out of the final delivery.

## 15. Complete departure list

These are the selected differences from the pinned **in-memory** bbtree
design. API spellings are grouped with the language constraint that causes
them. Separate upstream file/store products and research tooling are outside
this collection's scope, not alternate tree implementations being rejected.

| ID | Dewdrop difference | Constraint that forces it |
| --- | --- | --- |
| D1 | Typed GC arrays and packed V128 metadata replace native aligned pages and pointer tags. Heterogeneous reference-bearing key/value pairs use separate columns; same-type and scalar pairs remain adjacent. Root is replaceable; capacities/tag placement use a stated GC payload model, with extra default clear slots. GC controls reclamation. Unit values are erased explicitly. | Arbitrary Dew reference keys/values need tracing; Dew nominal structs are references and arrays are homogeneous. Raw GC addresses, headers, alignment and reference width are not specified by `size_of`. Raw untraced reference pages are unsafe; an object per pair would violate the required low-allocation layout. |
| D2 | Inline evidence belongs to the comparator. Ordinary optional traits and a width method replace Rust associated constants/defaults and Auto's native type recognition; standard plans cover actual Dew types. Cheap-search selection uses known scalar comparison behavior. | Dew uses explicit comparators, has method-only traits and logical compile-time queries, and lacks Rust fixed-length array types, scalar U128/I128 and native drop/layout reflection. A key-only encoding is unsound for arbitrary comparators. |
| D3 | Snapshot results and normal Dew mutators replace borrowed/mutable/owning Rust references, entry guards and consuming iterators; callback updates replace mutable slot borrows. Same-type queries and existing Option/bool/free-function conventions apply. Structural mutation invalidates cursors without per-next epochs. Self-append is a safe no-op. | Current Dew has shared mutable references, no Rust borrow lifetimes or consuming ownership, and an established ordered-collection/iteration contract. It cannot offer Rust exclusivity or `Borrow<Q>` by renaming methods. |
| D4 | U32 map length, checked growth, bounded GC path/work arrays and 15 path slots replace usize counts and native stack arrays. Traps during structural work require discarding aliases, not Rust unwind recovery. | Dew collections use U32 and GC arrays; the language does not supply native generic stack arrays or Rust unwinding/destructors. Exact overflow and trap behavior must match the host/runtime model. |
| D5 | Runtime `FixedArray` batch lengths, at most 64 active lanes in chunks, reusable GC work space and an explicit Dew lane machine replace const-generic arrays and stack futures. There is no software-prefetch hint. Initial cutoff uses the modeled leaf budget. | Dew lacks const generics/native stack futures; standard Wasm has no software-prefetch instruction for GC objects. Public calls must remain synchronous ordinary library code. Actual overlap and memory costs must be measured. |
| D6 | First delivery is single-threaded only; no latch/version/free-list fields or concurrent scan guarantees. | Dew has no supported shared-GC atomic publication and node-field memory model or thread/borrow API. Upstream's concurrent guarantees cannot be implemented safely on the current platform. |

No departure is selected for key ownership, plain versus inline plans,
keyless inline branches, window widths for supported standard types,
fence/shared prefixes, head entries, split bias, minimum occupancy,
merge-before-borrow, left-sibling preference, ordered batch commits,
two-ended path walking, or the thin set-on-map design.
