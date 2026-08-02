# Hash, Map, and Set

## Status

Implemented as compiler-owned `dew.std.map` and `dew.std.set` with ambient `Hash` evidence.

```dew
pub trait Hash {
  fn hash(self) -> U64
  fn hash_eq(self, right: Self) -> Bool
}
```

A complete `Hash` implementation is sufficient for a type to be used as a Map or Set key. `hash` chooses a bucket and `hash_eq` resolves collisions among entries with the same 64-bit hash. Equality is part of `Hash` rather than a separate collection bound because Dew does not yet support supertraits or generic where-clauses, and a U64 hash alone cannot provide correct key identity in the presence of collisions.

The standard preamble provides deterministic Hash implementations for `I8`, `I16`, `I32`, `I64`, `U8`, `U16`, `U32`, and `U64`. Integer hash values currently preserve the integer bit value; the map still remains correct when low bits collide because `hash_eq` is always checked after hash equality.

## API

```dew
open dew.std.map

let map = Map::singleton(key, value)
map.length()
map.contains_key(key)
map.get(key)          // Option<value>
map.get_unchecked(key)
map.insert(key, value)
map.set(key, value)
map.remove(key)       // true only when a key was removed
map.clear()
map[key]
map[key] = value
```

`Map::empty()` is also available when expected-result context determines both generic arguments:

```dew
fn new_counts() -> Map<I32, I32> {
  Map::empty()
}
```

`get` returns `None` for a missing key. `get_unchecked` and index syntax trap with `unreachable` for a missing key. `insert`, `set`, and indexed setting insert a new key or replace the existing value and return `Unit`. Replacement does not change `length`. `remove` returns `true` only when it unlinks a present key and decrements logical length. `clear` replaces the bucket array and resets logical length, preserving mutable wrapper identity so aliases observe the empty map.

```dew
open dew.std.set

let set = Set::singleton(key)
set.length()
set.is_empty()
set.contains(key)
set.insert(key)  // true only for a new key
set.remove(key)  // true only for a present key
set.clear()
```

`Set::empty()` is available when expected-result context determines the key type. Set insertion is idempotent. Removal unlinks the matching collision-chain node and updates logical length without disturbing the remaining chain. Clear replaces the bucket array and resets length, preserving mutable reference identity so all aliases observe the empty set.

## Representation

A map is a mutable reference-identity WasmGC struct containing:

1. a private mutable bucket-array reference;
2. a mutable logical entry count.

Each table starts with sixteen deterministic buckets and grows geometrically through power-of-two capacities. A new distinct insertion grows the table when the prospective logical length would exceed the current bucket count, giving a measured maximum load factor of 1.0. Each private entry contains:

1. nullable next-entry reference;
2. stored U64 hash;
3. six erased key carrier slots;
4. six erased value carrier slots.

The carrier order is the same deterministic generic storage order used elsewhere:

```text
i32
i64
f32
f64
v128
nullable eqref
```

Only the statically selected key and value slots are read or written. Scalar and vector values remain Wasm values in GC fields rather than heap-boxed scalar objects. The unused slots trade memory for one canonical generic entry layout and avoid broad key/value monomorphization.

Set reuses the same wrapper, bucket array, and canonical entry type. Only the key carrier is populated; the six value carriers remain deterministic defaults. Sharing the representation avoids a second hash-table runtime and keeps collision behavior identical between Map and Set. Reachable Set code triggers the shared private bucket/entry types even when no Map operation is reachable.

A Map or Set operation evaluates its collection, key, and Map value expressions once. It invokes the exact frozen `Hash::hash` implementation once, selects the bucket with `low_i32(hash) & (bucket_count - 1)`, compares stored hashes before invoking the exact frozen `Hash::hash_eq` implementation, and traverses the collision chain iteratively. Map and Set removal retain the previous entry in a scratch local so head, middle, and tail unlinking remain iterative and stack-safe. No semantic trait selection is repeated during lowering or emission.

Growth allocates a bucket array with twice the previous power-of-two length. It walks old buckets and collision chains iteratively, saves each entry's old `next` reference before relinking, and computes the new bucket from the already stored U64 hash. Rehashing therefore does not call user `hash` or `hash_eq`, does not allocate replacement entries, and preserves the wrapper's mutable reference identity and logical length. The old bucket array becomes unreachable after the insertion operation returns.

## Measured growth threshold

`tools/wago-map-bench` generates 512 deterministic LCG-distributed U32 keys and runs Map and Set insertion plus successful lookup in one exported workload. Candidate maximum load factors were compared with 20 calls per round and seven measured rounds on an AMD Ryzen 7 8845HS using Node 26.3.0 and the local Wago Core 3 runtime:

| Maximum load | Node median per workload | Wago Core 3 median per workload | Wago host allocation per workload |
| ---: | ---: | ---: | ---: |
| 0.50 | 175,550 ns | 5,715,100 ns | 98,496 B |
| 0.75 | 142,796 ns | 6,587,371 ns | 98,496 B |
| 0.875 | 138,771 ns | 6,569,150 ns | 98,563 B |
| 1.00 | **132,271 ns** | **5,282,518 ns** | 98,563 B |

A maximum load of 1.0 was fastest in both engines and retains the smallest bucket array of the measured candidates. The Wago values were rerun after the local GC-helper improvements documented in `docs/research/wago-map-set-performance.md`; the threshold ordering remained unchanged. Wago host allocation per invocation was effectively unchanged across candidates; these host measurements include invocation overhead and do not expose the engine's internal WasmGC heap bytes directly. The 1.0 policy nevertheless minimizes internal bucket-reference capacity. The threshold remains an implementation choice rather than a source-level guarantee and should be remeasured before changing the entry layout, GC engine, or hash workloads.

## Determinism

- There is no randomized process seed.
- Bucket count, growth thresholds, rehash order, and bucket selection are deterministic.
- Hash and equality implementation declarations are frozen semantic identities.
- Hash/equality call targets participate in whole-program reachability.
- Shared hash-table runtime types are emitted only when reachable code uses a Map or Set operation.
- Iteration order is intentionally unspecified; no iterator API is exposed yet.

User Hash implementations must remain consistent: if `left.hash_eq(right)` is true, both values must return the same U64 hash. Violating that contract can make a key unreachable, as in other hash-map APIs.

## Validation

Coverage includes:

- stable compiler-owned source and declaration identities;
- exact Hash hash/equality evidence selection;
- primitive integer keys;
- custom nominal keys with Hash and no separate Eq implementation;
- deliberate equal-hash collisions between unequal keys;
- a 129-entry Map single-bucket collision chain with head/middle/tail lookup and replacement;
- a 65-entry Set single-bucket collision chain with head/middle/tail removal;
- stored-hash prefilter tests in which unequal hashes select the same bucket and `hash_eq` traps if called incorrectly;
- side-effect counters proving one hash invocation and the expected equality count per singleton operation;
- deterministic WAT snapshots showing rehash bucket selection reads the stored entry hash and emits no Hash dispatch inside the rehash loops;
- correctness immediately before, at, and after the 16/32/64-bucket growth thresholds;
- 66 keys whose low seven hash bits are zero, keeping one collision chain intact through all three growth steps;
- alias-visible growth across Map and Set wrappers;
- Map and Set empty/singleton construction, aliases, and mutation visibility;
- Map insertion, replacement, Boolean head/middle/tail removal, alias-visible clear, length, contains, safe get, index get, and indexed setting;
- Set idempotent insertion, repeated/missing removal, clear, insert-after-clear, length, emptiness, and membership;
- `i32`, `i64`, `f32`, `f64`, `v128`, and reference carrier combinations;
- all eight integer Hash implementations with equal and unequal keys;
- missing safe Map lookup returning `None`;
- missing indexed Map lookup trapping;
- Starshine validation and Node/Wago differential execution.

## Deferred work

- String, StringView, Bytes, floating-point, vector, and collection Hash implementations after their equality/hash contracts are finalized.
- Iterators over Map keys/values/entries and Set keys.
- `Map::reserve`, Set/Map capacity introspection, and optional Set reserve support.
- Specialized compact entry layouts if profiling shows the canonical twelve-carrier entry is too costly.
- Enforce or diagnose asymmetric `hash_eq` behavior where possible.
