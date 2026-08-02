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
map[key]
map[key] = value
```

`Map::empty()` is also available when expected-result context determines both generic arguments:

```dew
fn new_counts() -> Map<I32, I32> {
  Map::empty()
}
```

`get` returns `None` for a missing key. `get_unchecked` and index syntax trap with `unreachable` for a missing key. `insert`, `set`, and indexed setting insert a new key or replace the existing value and return `Unit`. Replacement does not change `length`.

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

The initial implementation uses sixteen deterministic buckets and separate collision chains. Each private entry contains:

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

A Map or Set operation evaluates its collection, key, and Map value expressions once. It invokes the exact frozen `Hash::hash` implementation once, selects the bucket from the low four hash bits, compares stored hashes before invoking the exact frozen `Hash::hash_eq` implementation, and traverses the collision chain iteratively. Set removal retains the previous entry in a scratch local so head, middle, and tail unlinking remain iterative and stack-safe. No semantic trait selection is repeated during lowering or emission.

## Determinism

- There is no randomized process seed.
- Bucket count and bucket selection are deterministic.
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
- Map and Set empty/singleton construction, aliases, and mutation visibility;
- Map insertion, replacement, length, contains, safe get, index get, and indexed setting;
- Set idempotent insertion, repeated/missing removal, clear, insert-after-clear, length, emptiness, and membership;
- `i32`, `i64`, `f32`, `f64`, `v128`, and reference carrier combinations;
- all eight integer Hash implementations with equal and unequal keys;
- missing safe Map lookup returning `None`;
- missing indexed Map lookup trapping;
- Starshine validation and Node/Wago differential execution.

## Deferred work

- Geometric Map/Set bucket-table growth based on measured load factors.
- Map removal with deterministic chain unlinking and reference-slot clearing.
- String, StringView, Bytes, floating-point, vector, and collection Hash implementations after their equality/hash contracts are finalized.
- Iterators over Map keys/values/entries and Set keys.
- `Map::reserve`, `Map::clear`, Set/Map capacity introspection, and optional Set reserve support.
- Specialized compact entry layouts if profiling shows the canonical twelve-carrier entry is too costly.
- Enforce or diagnose asymmetric `hash_eq` behavior where possible.
