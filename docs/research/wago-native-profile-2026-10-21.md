# Native profile after call ABI and space-byte changes

The diagnostic host uses production source `5efc7acb1`, before the cold
GuestStorage query-copy repair in installed `321fae779`. That repair does not
change generated native code. No diagnostic binary is installed.

The full compiler job completed in 38.003 seconds. Both output hashes match the
fixed-input baseline, the Wasm validates, and main returns 42. This is a profile,
not a matched speed comparison. The host adds Go CPU profiling and code/source
maps, without helper counters or native instruction instrumentation.

Go's CPU profile records 38.22 sampled seconds:

| Region | Sampled seconds | Share |
| --- | ---: | ---: |
| Generated native code (`runtime._ExternalCode`) | 30.93 | 80.93% |
| Minor GC, cumulative | 4.52 | 11.83% |
| Sparse evacuation finish, flat | 1.74 | 4.55% |

The rows overlap where indicated; do not add cumulative and flat values. The
remaining gap is mainly generated native execution, not Go call overhead alone.

Brief software PC probes collected 1,892 samples, including 1,091 in generated
native images. Sampling stops totalled 75.2 ms; there were no recorded errors or
lost metadata. Thread selection uses recent CPU activity and is not a hardware
CPU profile. The native/total PC ratio is **not** an estimate of native CPU time.

The hot functions and instruction clusters are:

| Function | Native PC samples | Notable instruction |
| --- | ---: | --- |
| array_get_unchecked | 142 | Header type compare and handle/space loads |
| self_host_index_module_implementations_with_imports | 86 | 35 samples at the test after the space-byte load |
| self_host_imported_requirement_identity | 70 | 37 samples at the test after the space-byte load |
| bytes_byte_at | 60 | Header compare and dependent space loads |
| intern_function | 56 | Space descriptor and header loads |

Disassembly covers the 25 most sampled regions. The repeated chain is handle
table base -> handle entry -> space byte -> space base/length -> object span ->
header type -> payload. A consumer instruction can receive a sample while it
waits for a prior load. Dependent-load latency is a supported hypothesis; cache
misses were not measured with hardware counters.

Astra's read-only review found four resolver calls in array_get_unchecked.
The final pair performs `ref.cast 9021` and `array.get 9021` on the same array,
with only an index local read between them. Type 9021 is final. Existing fusion
covers final cast plus struct field or array length, but not array element.
A dedicated bounded fusion can remove a whole resolver without a persistent
address cache. It must preserve cast/null/bounds trap order and physical checks.

A strict same-local address cache would miss other key accesses because calls,
local writes, control flow or a different object separate them. A dedicated
non-root stack slot is possible, but temporary spill allocation does not prove
slot ownership. That larger change is not justified before testing the simpler
cast/read fusion.

Small profile summaries and raw Go reports are in
[the data directory](data/wago-native-profile-2026-10-21/sample.json).
The full source maps, code image, CPU profile and disassembly remain at
`.tmp/wago-next-gc-perf/combined-profile/`. That directory and its host are for
diagnostics only.
