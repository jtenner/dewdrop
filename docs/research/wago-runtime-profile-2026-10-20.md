# Wago runtime profile — 2026-10-20

## Follow-up

The current-main line profile found a large-array reservation cleanup scan.
The fix is [Wago PR #987](https://github.com/wago-org/wago/pull/987). Plain runs pass
with the same output hashes: base 108.349 / 114.202 seconds; fix 105.509 /
102.368 seconds. The range is wide, so this is not a precise general speed
ratio. See the [full follow-up](wago-large-array-cancel-2026-10-20.md) for
raw samples, safety tests, memory limits, and the separate saved-code fix
qualified in existing Wago PR #948.

## Current main rebuild

The host is rebuilt against Wago `origin/main` commit
`7997c86c36e05cfba4c4f39cabb026a318f55fc0`. This includes GC updates
`7538462db` and `a45a096e7`. The fresh-cache compiler run passes in **110.858
seconds**, with peak RSS **1,141,596 KiB**. Output and transform-cache hashes
match the earlier run. This single observation does not show a speed gain.

The builder now pins this exact commit. It retains the reference-local and
private worker patches, removes the module-lifetime patch now covered upstream,
and adapts Facet v0.1.0 and the worker plugin to current Wago `HostCall` APIs.
The native cache identity includes the Wago commit, both Wago patches, the
Facet patch, and host source hash. Reference safety tests and worker race tests
pass. Build wall time was 32.123 seconds.

Build and run data are in [current-main](data/wago-profile-2026-10-20/current-main/).
The build is `.tmp/wago-origin-main-2026-10-20/host-main`. It was made from
checksum-verified private module copies. The main Wago working tree was not
changed. These runtime and build times exceed the project's 30-second limit.

The same host loading the saved native artifact still reaches a compiler
invariant trap after **26.644 seconds**, exit 1. This is a failed correctness
check. It is not a warm-cache speed result. The new GC update does not remove
this observed failure. The follow-up metadata test found that the codec loses
`HasStart` and `StartLocalFunc`. Existing Wago PR #948 preserves these fields;
its cold and warm runs both pass this Dewdrop request. See the
[follow-up report](wago-large-array-cancel-2026-10-20.md). Use a fresh absolute
`WAGO_HOME` for this compiler until the saved-artifact fault is fixed.

The fresh-cache two-worker run also passes, with the same output/cache hashes:
**179.130 seconds**, **243.556 CPU seconds**, peak RSS **2,103,572 KiB**.
The host reports `2 applications, 2 workers`. Workers remain slower for this
small workload. These samples use the production host without the older CPU
or collector recorder. They do not establish a general regression or a precise
old-versus-new speed ratio: there are few observations and other user jobs
were active.

| Current-main run | Wall seconds | User + system CPU seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | ---: | --- |
| Fresh native cache, serial | 110.858 | 112.792 | 1,141,596 | Pass; output/cache match |
| Saved native artifact, serial | 26.644 | 26.918 | 456,440 | Fail; compiler invariant |
| Fresh native cache, two workers | 179.130 | 243.556 | 2,103,572 | Pass; output/cache match |

The bounded [saved-artifact review](data/wago-profile-2026-10-20/current-main/warm-cache-review.md)
found no confirmed small codec or ownership fix. It checks the finished root-map
write/read paths, mapping lifetime, GC type metadata, and changed entry flags.
A later fresh-versus-restored metadata comparison found the missing start
fields and qualified the existing fix in Wago PR #948. The older numeric invariant fields below have not been
reconfirmed on current main; only the assertion trap is confirmed here.

## Earlier pinned-runtime profile

The remaining sections describe the earlier Wago `2dd978ccda6f` build. Its CPU
profiles and allocation counters must not be treated as current-main profiles.

**Wago is a major bottleneck for this compiler request.** The same compiler Wasm
and request take about 3.9 seconds in Node and 96 seconds in the successful Wago
CPU-profile run. Output Wasm and transform-cache bytes match. Native compilation
and instance setup account for about two seconds. Most cost is execution:
managed allocation, GC helper calls, and generated Array/byte access code.

This changes the first work order from the earlier
[speed inventory](dewdrop-speed-inventory-2026-10-20.md). Profile Wago and reduce
runtime allocation costs before selecting a broad Dewdrop rewrite or more workers.
The scan's repeated-work findings remain useful, but are not measured speed gains.

During this earlier profile, no production compiler or runtime source was changed. All Wago instrumentation
was built in private copies of the pinned source. The separate Wago checkout
with local changes was not modified by this work. There is no proposed default
change or qualified speed fix in this report.

## Inputs and method

- Dewdrop: `69ea1cb533edd60353e0a9f49d6169403c92ef41`.
- Wago: `2dd978ccda6f`, with the three existing local safety/worker patches.
- Facet: `v0.1.0`; Go: `1.27.2`; Linux AMD64, Ryzen 7 8845HS, 16 logical CPUs.
- Node: the installed Node 24 binary; full version is in [identity.json](data/wago-profile-2026-10-20/identity.json).
- Request: [parallel.dew](../../examples/transforms/parallel.dew), two transform
  applications, transform-result cache forced to miss. Serial and worker modes
  use the same request bytes.
- Compiler SHA-256:
  `c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`.
  The Node memory-export preparation produced the same compiler bytes.
- Request SHA-256:
  `873a02bd62e26ef7e15b5556a78a9ea8315df449aafe1ca109c386de2b7ac721`.
- Wago options: `-p8 --core 3 --local --locked --no-input --gc-heap 512MiB
  --gc-nursery 64MiB`. `-p8` controls native compiler workers. The separate
  `DEW_TRANSFORM_WORKERS=2` option controls guest transform workers.

Each successful run validates output Wasm and executes `main() == 42`. Successful
runs in both engines produce output SHA-256
`89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb`
and cache SHA-256
`c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240`.
Thus source, output, reports, and cache contents are held fixed across the main
comparisons. The engines use their respective Facet host implementations.

Timed runs used one measurement lane. Other user jobs were active and were left
alone. Native code was compiled in a fresh absolute `WAGO_HOME` for each accepted
cold Wago case. Profiles, counters, and experimental native address probes are
separate observations. They must not be merged into one cost distribution.

## Measured runs

| Run | Wall seconds | User + system CPU seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | ---: | --- |
| Node control 1 | 3.872 | 5.525 | 464,860 | Pass |
| Node control 2 | 3.854 | 5.472 | 456,720 | Pass |
| Node with CPU recording | 3.886 | 5.632 | 487,160 | Pass |
| Wago serial, Go CPU recording | 95.863 | 99.257 | 1,297,148 | Pass |
| Wago two workers, Go CPU recording | 158.562 | 216.673 | 2,295,764 | Pass |
| Wago serial, tagged GC counters | 132.412 | 135.413 | 1,266,796 | Pass; diagnostic overhead |
| Wago serial, extra batch counters/native probes | 137.913 | 140.915 | 1,305,820 | Pass; diagnostic overhead |
| Wago serial, module global pins off | 90.977 | 93.593 | 1,271,692 | Pass; one experiment |

Raw [samples.json](data/wago-profile-2026-10-20/samples.json) contains commands,
binary identities, environment, phase times, status, and output hashes. No ARM64
runtime result is claimed. Tagged GC runs add substantial work and are not normal
runtime measurements. These are few process observations, not a p95 estimate or
a general engine speed ratio.

A first cold serial timing also passed at 112.509 seconds under higher host load,
but lost its CPU samples because the guest exit skipped Go defers. Its phase
records are retained. The recorder was fixed before the complete CPU profile.
This variation is another reason not to treat a small timing change as a win.

### Startup is a small part of the successful serial run

From [serial phase records](data/wago-profile-2026-10-20/serial-cold-complete/run.log):

| Phase | Seconds |
| --- | ---: |
| Native compile | 1.064 |
| Artifact publication | 0.029 |
| Complete module load, including those phases | 1.095 |
| Instance creation/start | 1.032 |
| Guest invocation | 93.696 |

Nested rows overlap. Do not add module load to the compile/publication rows.
Cache preparation itself takes tens of microseconds here. Native compiler
parallelism or a faster host build cannot remove the 94-second execution cost.

### CPU samples point to allocation and helper execution

The [ordinary serial CPU profile](data/wago-profile-2026-10-20/serial-cold-complete/cpu-top.txt)
has 98.14 sampled CPU seconds:

| Path | Sampled seconds | Share | Meaning |
| --- | ---: | ---: | --- |
| `runtime._ExternalCode` | 49.15 | 50.08% | Native code not named by Go's sampler |
| `dispatchGCHelperParked` | 34.05 | 34.70% | Cumulative internal GC helper work |
| `dispatchGCStructHelperParked` | 22.30 | 22.72% | Part of the helper row |
| `dispatchGCArrayHelperParked` | 11.62 | 11.84% | Part of the helper row |
| `CollectMinor` | 10.86 | 11.07% | Collection work inside allocation/helper paths |
| `reserveNativeHandles` | 7.25 | 7.39% | Includes most `newHandle` work |
| `newHandle` | 6.70 | 6.83% | Flat cost; mostly writing reused handle entries |
| `gcHelperRoots` | 0.63 | 0.64% | Cumulative allocation-time frame-root setup |

These rows overlap. In particular, collection and handle work are inside helper
work. Do not add the percentages. The call loop and native resume also cost time;
this is more than collector pauses. Normal host dispatch is a small part of the
profile compared with the dedicated GC helper branch.

Go's recorded total stop-the-world pause time is about 0.015 seconds in this run.
That does not measure all concurrent Go GC work, but it rules out long Go GC
pauses as the main explanation.

## Allocation volume and wasted reservations

A handle is Wago's small ID for a managed object. The tagged serial run reports:

| Counter | Count |
| --- | ---: |
| Derived native fast allocations | 240,847,549 |
| Go allocation paths | 76,227,907 |
| Combined managed allocations | 317,075,456 |
| Synchronous Go GC-helper calls after instance setup | 232,650,205 |
| Native handle batch refills | 16,957,873 |
| Minor collections | 145 |
| Full collections | 0 |

The native fast count is derived by the existing collector telemetry. It is not
a direct instruction counter. Helper tracking starts after instance setup, so
its totals have a slightly different lifetime from allocation telemetry.
These are physical Wago allocations, not source-transform budget charges, and
not a measurement of Node's allocations or retained live objects.

The later batch probe reproduces those work totals and adds:

| Handle batch result | Count |
| --- | ---: |
| Slots reserved, in groups of 32 | 542,651,936 |
| Slots consumed in completed/canceled groups | 240,847,543 |
| Slots canceled unused | 301,804,361 |
| Groups that consumed zero slots | 5,386,486 |
| Groups that consumed all 32 slots | 6,042,945 |
| Full nursery-compaction fallbacks on cancel | 0 |

About **55.6% of reserved slots are canceled**. A final open batch explains the
small gap between reserved and accounted slots. The complete occupancy histogram
is in the [native probe log](data/wago-profile-2026-10-20/serial-native-bounded/run.log).

Source: pinned `src/core/runtime/gc/native/native_alloc.go:49–86` reserves 32
handles; `:188–267` returns unused handles. Allocation helpers cancel the current
batch before their potentially collecting path. The profile attributes 6.46
seconds inside `reserveNativeHandles` to `newHandle`; this makes the unused work
worth testing. It does not prove that shrinking the batch is faster: smaller
batches can cause more helper transitions. Preserve handle ownership, generations,
root safety, and collection behavior in any fix.

Recorded minor collection time in the tagged run is 15.857 seconds. Sweep work
is about 7.424 seconds and promotion/copy about 5.531 seconds. Native frame-root
telemetry is about 0.019 seconds. The earlier source suspicion about expensive
caller-root lookup is not a leading performance finding for this request.
The zero compaction-fallback count also rules out that suspected slow path here.

Diagnostic collection totals exclude some surrounding accounting costs. Do not
subtract them from process wall time and call the remainder native guest compute.
The heap snapshot is not a post-full-GC retention test, and peak RSS includes
compiler data, native code, Go memory, and all managed heaps.

## Native code samples name the other hot paths

Go's `_ExternalCode` samples cannot recover guest program counters after capture.
A separate bounded `ptrace` probe read only CPU registers of our own child. It
attached briefly to CPU-active threads, then detached and forwarded real signals.
It recorded 5,525 leaf probes with no reported sampling errors. The sum of the
stop/read/detach intervals was 0.342 seconds over 137.903 seconds. This is not a
measurement of total probe overhead or a hardware CPU profile.

The probe found 2,885 addresses in Wago's native image. Of these, 142 were in the
shared tail outside function blocks. Leading function blocks were:

| Function block | Probes |
| --- | ---: |
| `array_get_unchecked` specialization | 328 |
| `self_host_resolved_imported_callable_at` | 145 |
| `bytes_byte_at` | 125 |
| imported `intern_function` | 114 |
| `self_host_index_module_implementations_with_imports` | 105 |
| another `get_unchecked` specialization | 98 |
| `array_iter_next` | 96 |
| Array `length` specialization | 94 |
| `array_length` specialization | 93 |

[Summary and exact native offsets](data/wago-profile-2026-10-20/serial-native-bounded/native-summary.json).
Ranges include function entry wrappers and padding. They do not provide Wasm
instruction or inline-call attribution. Probe counts are not CPU-time percentages.
The mapping and final function boundary are saved; the large native image is
identified by hash rather than copied into repository documentation.

The hottest individual sampled offset is inside the Array getter's wrapper
return. The [disassembly](data/wago-profile-2026-10-20/serial-native-bounded/array-get-disassembly.txt)
shows a restore to global 0 at native offset `0x41bd`. Wago selects mutable global
register pins for the whole module and synchronizes them at wrapper/Go boundaries.
The ordinary register ABI rejects reference parameters/results, so these Array
calls use wrappers. The [source note](data/wago-profile-2026-10-20/module-global-scan.md)
records the exact selection, load/store, and ABI rules.

`WAGO_PIN_GLOBAL_K=0` produced a passing 90.977-second run and a smaller native
image: 20,305,524 versus 21,170,004 bytes. This is one observation under different
host load and a later diagnostic build than the first serial profile. It does
not qualify a runtime gain. The switch also changes register allocation and some
prepared-call eligibility. No default was changed. A focused, repeated paired
experiment is needed. The artifact key omits this environment switch, so this
control used a fresh native cache.

## Workers overlap, but repeat expensive work

The successful [two-worker run](data/wago-profile-2026-10-20/parallel-cold-complete/run.log)
shows:

| Event | Seconds |
| --- | ---: |
| Guest work before worker batch | 69.835 |
| First child creation/start | 0.863 |
| Second child creation/start | 0.875 |
| Child job 0 | 55.626 |
| Child job 1 | 54.505 |
| Complete batch | 57.364 |
| Guest work after batch | 29.566 |

The child calls start within about 0.1 ms of each other and overlap. They reuse
native code. Worker creation is about 1.7 seconds total; it is not the main added
cost. The full run uses about 217 CPU seconds versus 99 for serial execution.
Its CPU profile shows the same helper/allocation paths, with much more total work.

The compiler parent checks the source, then each job rebuilds and checks the full
snapshot before interpretation. See [transform_workers.dew](../../self_host/compiler/transform_workers.dew).
For this two-job case, preparing once per child still means two additional child
preparations. Batching that preparation helps many-job workloads, but cannot alone
remove this case's duplication. A prepared immutable program/bytecode transport
needs a safe validation and ownership design. Keep final source checks, fresh
per-application mutable state, source order, limits, and serial replay rules.
More workers will not remove duplicated parent/child work.

## Separate correctness fault: cached native artifacts

Cold execution passes. A diagnostic cache hit loads in roughly 0.02 seconds but
fails in guest name resolution. The unchanged production host also fails using
its earlier warm cache. These failed runs are **not speed results**.

The latest numeric crash record is:

```text
code=102 phase=1 module_id=4294901760
body=18446462598732841654 declaration=18446462598732842243
expression=0 expected=72 actual=0 detail=4123
```

This means expression ID 0 is outside the current body's span `[4123, 4195)`.
It occurs in `dew.std.preamble`, body 694/declaration 1283, at
`SelfHostBodyNameResolver.expression_index`. The name task or child expression
may have become invalid earlier. See the [decoded source trace](data/wago-profile-2026-10-20/warm-invariant-decode.md).

Cold and warm saved native images have identical SHA-256
`6eb46b29fbf9bc825a9e82116cbb5ca19c325ff36788780b944746ba74408c0f`.
This excludes a changed machine-code image. It does not distinguish restored
metadata, instance context, or a latent lifetime problem exposed by different
allocation behavior. The reviewed codec carries the finished root-map fields;
there is no proved missing-field fix. `AllReferenceLocals` is used during code
generation and is not itself a required serialized runtime field.

A focused next diagnostic must compare fresh/restored metadata and trace the
first task/child-expression divergence for this body, including GC boundaries.
Do not bypass the compiler assertion, accept a failed warm run as fast, or enable
broader cache reuse until this failure is repaired.

## Revised work order

1. **Repair the cached-artifact fault before trusting warm Wago execution.**
   Keep the same source/request and compare the first divergence in body 694.
2. **Test native handle reservation use.** Reduce unused reserve/cancel work with
   a general bounded policy. Measure both full batches and alternating native/
   helper-only constructors. Keep all collector/root assertions.
3. **Test reference-call and getter code generation.** Use small kernels for Array
   reads, byte reads, ref casts, and wrapper calls, plus the full compile. Prove
   redundant work before removing it. Retain trap order and typed-reference checks.
   The global-pin test is a lead, not a selected default.
4. **Remove repeated transform preparation/checking.** Measure one prepared child
   snapshot per batch and then a safe immutable checked-program transport. Include
   two-job and many-job cases; keep interpreter execution and private GC domains.
5. **Reduce compiler allocation volume and measured import/type searches.** The
   native samples point to specific library and semantic operations. Use the
   earlier inventory to select bounded fixes, with new before/after measurements.

This is the measured reason to work on Wago and Dewdrop together. It does not
support attributing the delay only to worker startup, cold native compilation,
GC root scanning, or one generic instruction.

## Evidence and reproduction

[Evidence index](data/wago-profile-2026-10-20/README.md) contains the private host
build helper, exact instrumentation patch, run harness, raw profiles/counters,
source notes, rejected probes, and limits. The diagnostic builds copy the three
existing safety patches. Their startup strings say `unpatched`/`unverified`
because the production link-time identity variables were not set; this is not
an upstream unpatched source build. Every measured binary hash is recorded, and
private cache homes keep these diagnostic identities away from normal caches.

No whole workspace test suite was run for this profiling task. Successful request
runs passed Wasm validation and execution, and the saved diagnostic patch was
checked and rebuilt from the pinned baseline. Claude review remained unavailable
due to the existing account quota. No independent Claude review is claimed.
