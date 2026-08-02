# Wago Map/Set WasmGC performance

Date: 2026-08-02

## Workload

`tools/wago-map-bench` generates one import-free Dew WasmGC function containing deterministic Map and Set insertion and successful lookup operations. The investigated workload contains 512 keys and compiles to 712,494 Wasm bytes.

Before the local Wago investigation, the workload measured approximately:

```text
Node 26.3.0: 0.13-0.14 ms
Wago Core 3: 10.73 ms
```

An empty export measured about 87 ns in Wago, proving that ordinary public invocation overhead was not responsible for the gap.

## Generated-code profile

`WAGO_EXPLAIN=1` reported:

```text
Wasm bytes:             712,494
Wago native code:    14,603,409
hostsync sites:          72,603
ref.cast sites:          40,899
array.len sites:          8,180
struct.new sites:         2,050
array.new_default sites:  1,024
```

Node lowers and optimizes WasmGC operations within native code. The local Wago implementation routes most casts, reference field/array operations, lengths, and allocations through its synchronous parked-Go GC helper ABI. The benchmark therefore stresses internal helper transitions rather than `Instance.Invoke`.

## Local Wago findings and changes

The local sibling checkout at `../wago` was updated in files that were clean before this investigation, without touching its pre-existing unrelated modifications.

### Dense safepoint lookup

CPU profiling attributed 35.9% of the original execution time to `gcHelperRoots`. Every allocating helper linearly scanned all compiled safepoints to locate a dense numeric ID. Thousands of allocation sites in one generated function therefore caused quadratic root-lookup work.

Compiler-produced safepoint IDs now use direct `id - 1` indexing. A binary-search fallback preserves valid sparse codec metadata. Repeated focused dense lookup measurements range from approximately 1.3 to 2.1 ns/op with zero allocations.

### Internal helper dispatch

Internal GC helpers cannot invoke arbitrary host code or re-enter Wasm. They now retain the native execution lease instead of performing the public host-call release/reacquire protocol on every helper transition. Ordinary host calls retain the original behavior, with a focused regression test covering both paths.

### Final-type checks

Final defined `ref.cast` targets now compare canonical runtime type IDs directly instead of traversing subtype descriptors. Final struct/array helper checks use the same equality rule. Non-final types retain complete subtype traversal.

### Helper state locking

Only allocating helpers need the reusable `gcPublicState` constructor and frame-root scratch. Non-allocating casts, gets, sets, and lengths no longer create and lock that state on every call. Collector-domain locking remains in place.

### Null-only constructor roots

`NewStructWithRoots` now builds an initializer root set only when at least one initializer contains a live collector object. Merely having nullable reference fields initialized to null no longer allocates root-composition objects. I31 values remain immediate and do not require collector roots.

## Measurements

Sequential same-process measurements during the investigation were:

| Stage | Wago median | Incremental change |
| --- | ---: | ---: |
| Original | 10.728 ms | - |
| O(1) safepoint lookup | 7.420 ms | -30.8% |
| Final-cast equality fast path | 6.839 ms | -7.8% |
| Internal-helper lease retention | 6.025 ms | -11.9% |
| Allocate-only public-state locking | 5.766 ms | -4.3% |
| Final object-type equality | 5.368 ms | -6.9% |
| Skip roots for null-only initializers | 5.152 ms | -4.0% |

A longer nine-round rerun measured:

```text
Node: 0.142 ms
Wago: 5.694 ms
```

Wago host allocation fell from approximately 196,999 bytes to 98,563 bytes per workload. Timing varies with GC and scheduler state, but the changes consistently remove roughly half of the original runtime and half of the measured host allocation.

The load-factor comparison was repeated with the modified Wago runtime. Maximum load 1.0 remained fastest:

| Maximum load | Wago median |
| ---: | ---: |
| 0.50 | 5.715 ms |
| 0.75 | 6.587 ms |
| 0.875 | 6.569 ms |
| 1.00 | **5.283 ms** |

## Rejected native-cast experiment

Inlining a complete checked native final-type `ref.cast` reduced the workload to approximately 4.77 ms, but expanded generated native code from 14.6 MB to 22.6 MB because the full ABI, handle, heap, and type check was duplicated at all 40,899 cast sites. That experiment was reverted because it conflicts with Wago's low-footprint goal and increases instruction-cache pressure.

## Remaining gap

The remaining approximately 40x Node gap is architectural:

- All 72,603 static GC helper sites remain synchronous native-to-Go transitions.
- `ref.cast` alone accounts for 40,899 transitions.
- Reference struct/array get and set operations contribute roughly 19,400 transitions.
- `array.len` contributes 8,180 transitions.
- Some helper operations resolve the same compact handle and descriptor more than once.
- The 14.6 MB generated native function has substantial instruction-cache cost.

The next measured Wago candidates should be:

1. Shared native GC check/access stubs so checked casts and reference reads avoid both Go transitions and duplicated inline sequences.
2. Combined typed collector operations that resolve a compact handle once for final struct/array access.
3. Reusable caller-owned root-pair scratch for constructors containing non-null object references.
4. Direct native `array.len` and reference loads through the stable native collector ABI.
5. Producer-side typed scratch locals that reduce redundant casts without weakening Wago correctness for arbitrary producers.

Any native fast path must preserve stale/forged-reference rejection, final and non-final subtype semantics, moving-collector roots, Tiny/Throughput parity, and codec-loaded metadata validation.

## Validation

The modified Wago checkout passes:

```text
go test ./...
```

Dew's Map, Set, FixedArray, and Unit-returning insertion snapshots also pass under both Node and the modified local Wago Core 3 runner.
