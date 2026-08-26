# Self-host compiler profile

Date: 2026-08-26

## Result

Compiler A execution CPU time fell from approximately 30.5 seconds to approximately 13.4 seconds.

The primary hot function in the Node CPU profile was Wasm function 1148. It accounted for 64.98% of sampled CPU time. Its source was `self_host_linked_field_by_name`.

The old implementation scanned every linked physical type and every field for each lookup. Each field-name check could then scan every lowering module and every named field. This made repeated owner-aware field recovery effectively multiplicative.

The optimized implementation:

- searches exact nominal-owner types before any global fallback;
- scans fields only on exact nominal candidates in the common path;
- uses the declaration-owner index before falling back to a global field-name scan.

Measured compiler A execution:

| Version | Wall time | User CPU | System CPU |
|---|---:|---:|---:|
| Before field lookup fix | 418.690 s | 30.544 s | 1.546 s |
| After field lookup fix | 148.647 s | 13.084 s | 0.362 s |

Later validation runs kept compiler execution near 13.2 seconds of user CPU despite wall times between 174 and 266 seconds.

## Host contention

The unrelated optimizer fuzz lane does affect wall time. This was measured rather than inferred.

A production source check took 33.805 seconds of wall time while consuming only 2.890 seconds of user CPU and 0.597 seconds of system CPU. A cold compiler A build took 167.248 seconds of wall time while consuming 10.986 seconds of user CPU and 5.904 seconds of system CPU.

The host showed more than 200 runnable tasks on 16 CPUs. The fuzz process alone used approximately 14 to 15 CPU cores. Four older semantic probe processes each used most of another core.

The exact-input persistent build cache still works under this load. A repeated compiler A build completed in 1.314 seconds and produced byte-identical output.

Therefore two separate problems existed:

1. `self_host_linked_field_by_name` caused a real compiler CPU regression. It is fixed.
2. Current wall times remain dominated by scheduler contention outside this workspace.
