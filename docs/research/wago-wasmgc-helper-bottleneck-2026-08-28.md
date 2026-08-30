# Wago WasmGC helper bottleneck

## Result

The strict Wago slowdown is not Facet I/O, collection frequency, or native-root admission.

The active Wago issue is that hot non-allocating WasmGC operations leave native guest code and enter the synchronous Go helper dispatcher. During self-host body emission, almost every helper transition is either a non-final `ref.cast` or a reference-valued `struct.get`.

The initial measurements used upstream Wago revision:

```text
1d3b364f3db2f4267fe5913c336cf20bf2448583
```

The container was later updated and reverified at:

```text
595a0d7ea3fde1616c172b071aec044efc9910e8
```

Exact native-root admission remained enabled:

```text
Required:true
Exact:true
Safepoints:19712
Callsites:30741
MaximumRoots:62
MetadataBytes:1283740
```

## Exact helper counts

A local `wago_gcstats` diagnostic build counted each synchronous GC helper operation. The diagnostic changes were not installed into the production runtime.

A 30-second profile started after 70 seconds, inside compiler body emission:

```text
.tmp/wago-current-emission-detail.cpu.pprof
.tmp/wago-current-emission-detail.log
```

The profile executed 224,710,290 synchronous GC helper transitions:

| Operation | Calls | Share |
|---|---:|---:|
| non-final `ref.cast` | 138,886,863 | 61.807% |
| `struct.get` | 78,799,300 | 35.067% |
| `array.get` | 3,703,151 | 1.648% |
| allocation helpers | 3,280,431 | 1.460% |
| mutation helpers | 26,721 | 0.012% |
| `array.len` | 13,824 | 0.006% |

The categories account for every recorded transition. Non-allocating reads and casts are 98.528% of all helper calls in this interval.

The helper rate was 7.49 million transitions per second. This rate is not useful work alone. Each transition parks native execution, enters the host loop, dispatches in Go, locks the collector domain, performs the operation, and resumes native execution.

## CPU profile

The same body-emission profile reports:

| Runtime path | Inclusive CPU |
|---|---:|
| `Engine.callWithHostLoop` | 63.61% |
| `dispatchSynchronousHostCall` | 48.68% |
| `dispatchGCHelperParked` | 46.78% |
| `dispatchGCStructHelperParked` | 45.05% |
| collector `refTest` | 15.79% |
| collector `StructGetTyped` | 6.43% |
| native guest execution | 32.39% |

The `wago_gcstats` counter itself used 2.20% inclusive CPU in this diagnostic build. The earlier non-instrumented profile has the same shape:

```text
.tmp/profile-latest-512.cpu.pprof
```

Its synchronous host dispatcher used 54.68% inclusive CPU and GC helper dispatch used 52.75%.

## Why Wago takes this path

The amd64 backend already has direct native paths for some final-type and scalar operations. The missing cases match the profile exactly.

### Non-final `ref.cast`

`emitGCI31Cast` can elide a cast from exact compiler facts and can emit a native exact-type check for final struct or array targets. A cast to a non-final defined type falls through to:

```go
callGCStructHelper(gcStructRefCast, ...)
```

The Go helper then resolves the object, reads its dynamic type, and performs subtype testing. Wago already builds compact DFS subtype intervals in `core/runtime/gc/subtype_interval.go`, but the native generated code cannot use them. It must enter Go for the check.

Dewdrop uses many non-final recursive struct hierarchies. Its emitted compiler contains 74,781 static `ref.cast` instructions, and the hot ones execute repeatedly inside semantic planning and expression emission.

### Reference-valued `struct.get`

`emitDirectGCStructGet` uses `directGCScalarStorage`. That layout accepts numeric scalar fields, but not collector reference fields. A reference-valued field therefore uses the synchronous `gcStructGet` helper even when the field offset is known.

Dewdrop stores most semantic nodes and compiler metadata behind reference fields. Its emitted compiler contains 52,642 static `struct.get` instructions.

Wago already contains a fused native final-cast/reference-get path. The missing general direct reference load is therefore narrower than designing a new object representation: resolve the checked object, load the compact child reference at the known field offset, and return it before any safepoint can relocate the object.

## `gc-ref-facts` experiment

A separate 60-second run enabled Wago's `gc-ref-facts` optimization:

```text
.tmp/wago-current-helpers-facts.cpu.pprof
.tmp/wago-current-helpers-facts.log
```

It increased recorded helper throughput from 9.61 million to 11.32 million calls per second, approximately 17.8%. This proves compiler facts help, but they do not remove the main problem. Dynamic non-final casts and reference field reads remain helper-bound.

## Proposed Wago issue

Suggested title:

```text
amd64: keep non-final ref.cast and reference struct.get out of the synchronous Go helper loop
```

Suggested fix order:

1. Add a native non-final defined `ref.test`/`ref.cast` path using immutable subtype metadata.
2. Add a direct native reference-field `struct.get` path for known layouts.
3. Keep the current Go helpers as fail-closed slow paths for unsupported or cross-domain cases.
4. Add build-tagged telemetry and benchmarks that assert hot read/cast loops make zero synchronous helper transitions.

The native subtype path needs a stable, read-only table that maps canonical type IDs to pre/post DFS intervals. Generated code can compare the actual object's interval with the required interval without taking the collector lock.

Focused upstream benchmarks on this machine measured the collector's interval check at approximately 10.6 ns for depth 1 and 18-19 ns for depths 16 and 256. The existing end-to-end pinned-state GC helper benchmark measured 437-444 ns per invocation. The benchmark includes public invocation overhead, so it is not a pure helper-transition latency measurement, but it confirms that subtype interval arithmetic is small compared with the current helper path.

The direct reference load must preserve existing relocation rules: resolve the object only after the last safepoint, load the compact child handle immediately, and never retain the raw payload pointer across a helper, allocation, or call.

## Current upstream reverification

The manager, standard runtime, source checkout, and project-local Facet plugin were updated together to `595a0d7e`. The refreshed revision includes:

```text
992216ca amd64: benchmark and optimize GC and scalar instructions (#549)
595a0d7e runtime: harden TinyGo trampoline and trap handling (#529)
```

Installed SHA-256 values are:

```text
4be74c8bc3ce3c2d0fd247c22b5ea25e7c81080fec7cd7bdb83230bf1b5a377c  /home/metidos/.wago/bin/wago
02f5277450fa1d74063272b55bad7c7242f02d2b623820b26045e6d7c11b4f0f  /home/metidos/.wago/data/versions/canary/standard/normal/wago-runtime
4094a6917b09eac80f951cf29bf1a1f002da21528166894b3ccfe4131a964cd0  .wago/builds/canary/standard/normal/bin/wago
```

Focused upstream tests passed for `src/wago`, the amd64 backend, the native runtime, and the collector.

The new instruction benchmarks reproduce the intended narrow optimization:

| Instruction | Default | `WAGO_AMD64_GC_REF_FACTS=1` |
|---|---:|---:|
| final `ref.cast` | about 2.8 ns/op | about 2.9 ns/op |
| final scalar `struct.get` | about 2.4 ns/op | about 2.4 ns/op |
| non-final `ref.cast` | about 84 ns/op | about 84 ns/op |
| non-final scalar `struct.get` | about 78 ns/op | about 2.6 ns/op |

This confirms #549 specializes only scalar `struct.get` through an open supertype when exact final receiver facts are available. It does not add a general native non-final cast and does not add a direct reference-valued `struct.get`.

### Self-host default profile

A new 30-second body-emission profile with the default policy recorded 227,952,455 synchronous helpers:

| Operation | Calls | Share |
|---|---:|---:|
| non-final `ref.cast` | 140,770,924 | 61.755% |
| `struct.get` | 80,127,134 | 35.151% |
| `array.get` | 3,706,765 | 1.626% |
| allocations | 3,308,418 | 1.451% |
| mutations | 26,014 | 0.011% |
| `array.len` | 13,200 | 0.006% |

The default workload shape is unchanged. The synchronous host dispatcher used 51.35% inclusive CPU.

Artifacts:

```text
.tmp/wago-updated-emission-default.cpu.pprof
.tmp/wago-updated-emission-default.log
```

### Self-host opt-in profile

At the same wall-clock sampling interval, `WAGO_AMD64_GC_REF_FACTS=1` recorded 329,721,881 helpers. It reached different work during the fixed interval, so percentages are not a direct per-operation before/after comparison. Its profile was still helper-bound: the synchronous host dispatcher used 50.92% inclusive CPU.

Artifacts:

```text
.tmp/wago-updated-emission-facts.cpu.pprof
.tmp/wago-updated-emission-facts.log
```

The complete strict runs did not improve:

| Wago policy | Compiler A execution | Result |
|---|---:|---|
| default | 2,053.997 s | stack fence at function 2371 |
| `gc-ref-facts` | 3,858.760 s | stack fence at function 2371 |

Function 2371 is the recursively generated `Encode for Instruction` implementation. Its linked Wasm body is approximately 1.5 MB of WAT, has local indexes through 2114, and contains five self-calls for structured instruction forms. Wago uses a fixed 4 MiB native execution stack with a 256 KiB fence margin. The current linked compiler eventually exhausts that capacity while recursively encoding the output module.

This is a separate runtime-capacity blocker from the helper-transition bottleneck. It is not evidence of bad native-root admission or an undersized GC heap. The same compiler validates and runs through this work under Node. A Wago production proof now needs either a configurable/larger native execution stack or a non-recursive/smaller-frame instruction encoder.

## Acceptance test

A focused Wago fixture should loop over:

- a successful cast from `eqref` to a non-final struct supertype;
- a failing non-final cast or `ref.test`;
- a reference-valued `struct.get` from a known layout;
- nullable and non-null variants;
- nursery, old, large, and moved objects.

With `wago_gcstats`, the steady-state loop should report zero synchronous helper transitions for successful supported cases. Existing trap, subtype, relocation, exact-root, and stress-collection tests must continue to pass.
