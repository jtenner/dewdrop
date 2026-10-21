# Wago native-segment checked-address cache, 2026-10-21

Completed experiment: rejected for speed and memory. The full Dew compiler
target is 4 seconds. It is not met. All prototypes are disabled by default and
are not installed or published.

## Small-table prototype boundary

AMD64 code may reuse a successfully checked final cast/struct-field address
inside one uninterrupted native segment. The runtime turns the capability off
immediately when native code returns, before Go helpers or host code run. Each
supported native entry/resume advances the collector cache epoch. Epoch wrap
clears all entries. No raw address is a root or serialized artifact value.

Only ordinary parked host loops and the bounded GC-helper driver opt in.
Inline, raw prepared, async and start drivers keep the capability disabled.
The admission check rejects imported/dynamic GC reachability, foreign native
calls and shared native control. A private collector requires independent
execution. A store-owned collector requires exactly one static domain that
matches the collector and is owned by the current invocation. Admission is
checked again after every Go callback. Shared collector instances cannot run
native work at the same time under this complete invocation lease.

A cache entry records compact reference, epoch, address, extent and module-local
type index. Each epoch belongs to one instance view; every other instance view
has a zero capability. This permits a local type key without loading the type
map on a hit. A miss performs all original canonical type and extent checks.
Only equal header/handle extents enter the cache. Unequal extents keep the
original result and trap behavior. Foreign high bits, null and i31 checks run
before the probe. Payload stores never become cached field-value reads.

The optional ABI uses the previously zero version-9 instance word at offset28
as capability. Every new collector-view access is guarded by this word. Old
code uses the original prefix. New code on an old runtime uses the full checked
resolver. The collector view grows from200 to208 bytes. A typed cache owner
adds8 bytes at the end of Collector, preserving prior field offsets. Engine
adds one8-byte callback, cleared on close/pool release.

## Initial evidence

The private-only gate did not admit the real compiler host: flags0x10,
store-owned collector. A diagnostic full run had epoch0/hits0. Do not treat that
run as a cache-hit speed result.

The canonical-type-key version, with single-store-domain admission, recorded
6,178,097 epochs,2,475,842,412 hits and456,437,146 fills (84.43% hit rate).
It still lost the normal full-run pair:34.4367s versus33.5901s control. The
counter-enabled run took35.5148s and is diagnostic only. Both produced the
pinned output hashes and main42. The current experiment removes type-map loads
from cache hits and folds entry-base displacement into memory operands.

## Checks

Focused tests cover real hits, capability disabled in Go, entry and callback
header/handle corruption without manual epoch changes, larger later reads,
wrong type, null, i31, foreign high bits, payload stores, allocation-helper
collection, host collection, same-instance InvokeFromHost reentry, codec load,
private and actual store-owned non-independent instances, layout and epoch wrap.
The optional-ABI fallback test poisons the extension pointer while capability is
zero; generated reads must succeed without using that pointer.

Daybreak review rounds1 and2 found no concrete production safety issue. They
found layout-test expectations and a store test that did not reach the intended
store-owned path. These are fixed. A third review covers the module-local key.
Later review and screening results are recorded below.

Raw measurements and diagnostic source are in
`/tmp/wago-four-seconds/segment/` until final evidence is copied here.

## Rejected full-workload experiments

All variants below are private prototypes, default off, not installed or
published. The compiler Wasm, 8.9MiB request, CPU affinity12,14, GOMAXPROCS2,
512MiB heap and64MiB nursery stay fixed. Result and native caches are cold.
Each successful sample has the pinned output Wasm/cache hashes and main42.

| Variant | Candidate s | Adjacent control s | Candidate peak KiB | Control peak KiB |
|---|---:|---:|---:|---:|
| Canonical key128 slots, no counters |34.4367|33.5901|1,098,224|1,139,180|
| Local key128 slots, no counters |34.6196|34.0161|1,100,860|1,074,588|
| Local key512 slots, no counters |33.9921|34.0161 (nearby)|1,142,852|1,074,588|
| Early hit leaf128 slots |33.2551|33.6355|1,139,568|1,133,584|
| Dense32-byte entry per handle |35.5010|33.4349|1,543,128|1,129,764|

These are screening pairs, not statistically strong speed claims. The early
hit leaf avoids R9-R11 pin saves on hits but wins only1.13% in its one pair.
The dense table loses6.18% and adds413,364KiB (403.68MiB). Do not install it.
The dense form is preserved here as research; the small-table source is also
saved under `/tmp/wago-four-seconds/segment/small-table-source/`.

The dense prototype uses the old reserved instance word as an exclusive
compact-reference bound (zero disables the extension). Full-width unsigned
range comparison rejects foreign high words before following the new pointer.
Null retains its original checked path and nullable flag. Each32-byte handle
entry has epoch@0,address@8,zero guard@16,local type@24,extent@28. An even
compact reference shifted by4 selects its entry. An odd i31 reference selects
the zero guard and cannot match a nonzero epoch. Entry zero holds counters and
current epoch and is never used for a null hit. Allocation grows the typed Go
cache backing only under the Go boundary and publishes a new bound before
native entry. This design is correct in the tested boundary but too costly.

Validation: dense focused tests with `wago_regalloccheck,wago_segmentcache`
pass, including corruption, equal/unequal extents, actual store-owned domains,
codec reload, allocation collection, host collection and InvokeFromHost reentry.
The earlier small-table full normal backend, collector, runtime and Wago suites
pass (51.51s total, Wago test execution27.63s). A full dense suite was not run;
the failed speed/memory screen is sufficient to reject this prototype.
Daybreak rounds1 through5 found no concrete production safety issue. Rounds1
and2 found test setup/layout issues, fixed before the relevant focused runs.
Round5 checked dense bounds, odd refs, metadata entry zero, growth and wrap.

Next: use immutable input identities to reuse a check inside a loop, with bounded
function-private homes and no global lookup. Preserve original trap order and
never keep raw addresses usable across a Go transition. Astra is checking the
smallest complete proof and the central emission hooks before implementation.

Research source commit: `934136c3d` on private Wago branch
`dewdrop/gc-native-segment-cache-20261021`, based on `512d6493f`.
It is not a PR, install, or runtime update. The installed runtime remains
`local-gc-6894c7f8a`. New loop work starts from `512d6493f` without this cache.
