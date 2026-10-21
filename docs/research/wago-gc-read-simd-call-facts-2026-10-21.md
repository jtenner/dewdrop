# GC check facts across native vector and memory readers

The four-second Dew compiler target remains unmet. This change expands the
existing internal-call proof; it does not add a runtime lookup table.

The shared planner/emitter summary now admits checked scalar linear-memory
loads, standard native SIMD computation and loads, and plain `array.get` on
final native V128 arrays. The array rule uses `directGCArrayAccessLayout`, the
same gate as the emitter. `directGCScalarStorage` remains unchanged. SIMD source
stores, reserved codes, and relaxed SIMD stay outside the proof. All existing
unknown-call, write, allocation, recursion, EH, and custom-instruction exclusions
remain. Native SIMD fallback uses private frame scratch and cannot collect.

Saved facts describe GC object addresses, checked extents, and GC child-field
identity. They do not cache linear-memory contents. A changing memory result
cannot invalidate these facts. A failing bounds, cast, interrupt, or stack check
unwinds the frame. It cannot resume with a stale address.

Go-capable helper emission in an approved owner now returns a visible compiler
error. Its message names the owner, active inline function, and Wasm offset.
This guards the proof against later lowering changes. It changes no native ABI,
artifact format, root mask, call-clobber rule, or runtime cache ownership.

The focused regression initially records two reused checks instead of three.
New cases cover direct/transitive vector and scalar readers, final vector GC
arrays, helper-disabled/non-final rejection, writes, memory growth, host calls,
malformed/reserved SIMD, nullable/array/memory traps, fresh entry after traps,
three GC configurations, and saved-artifact reload. The source fixture and
compiled fixture are both checked in.

Astra's static proof found the missing vector-array layout gate before this
change. Daybreak Blue found no safety blocker; it requested correct inline
identity in the new error, which is fixed. Both reviews were read-only.

On the pinned Dew compiler, diagnostic compilation takes 0.507 seconds. Reused
checks rise from 4,757 in 1,035 functions to 4,766 in 1,036 functions. Native
bytes fall by 400 to 25,972,587. Exact roots stay at 25,794 safepoints, 50,438
callsites, 77 maximum roots, and 1,803,076 metadata bytes.

Six serial cold-cache full jobs use identical Wasm/request inputs and output
hashes, CPUs 12/14, GOMAXPROCS=2, a 512 MiB heap, and a 64 MiB nursery. The
control is the preceding read-call-facts change. Order is control/candidate,
candidate/control, control/candidate. Control times: 37.331490, 34.422530,
36.828077 seconds. Candidate times: 36.245573, 35.877888, 34.837831 seconds.
Medians are 36.828077 and 35.877888 seconds. One paired result reverses and the
control spans 2.9 seconds. These data do not establish a reliable speed gain.
Median peak RSS is 1,131,208 versus 1,135,092 KiB, about 3.8 MiB more. All six
outputs validate and return main=42. No builds or tests overlap these timings.

The full-job output SHA is
89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb;
the result-cache SHA is
c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240.
Raw local evidence is under `/tmp/wago-four-seconds/simd` and the Dewdrop
research data directory `gc-read-simd-call-facts-2026-10-21`.

Full AMD64 backend, collector, runtime, and Wago tests pass normally and with
`wago_regalloccheck`. Their test/build lanes take 55.34 and 55.31 seconds;
individual Wago tests take 27.98 and 28.08 seconds. Focused stats tests pass in
25.92 seconds including build. The installed compiler and its separate ARM64
edit remain untouched.

Final-source verification matches the measured native artifact exactly:
`011c1ae5cc8e1adf55856f6809d4662b44f1c5b679a305e23a57229520b14dc6`.
The final diagnostic compilation takes 0.512 seconds.

Private Wago commit: `9d84600f1`. It is not published or installed.
