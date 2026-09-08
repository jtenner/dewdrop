# Remove the old Array provider fallback

The pinned Starshine provider still exposes the removed Array algorithms through
`funcs_push_runtime` and three instruction-builder exports. No compiler source
calls those instruction-builder exports anymore. Array operations now belong
to `std/array.dew`; the real-library corpus covers both compilers.

The old Map builder still uses six Array layout helpers. Keep only those
helpers with Map until its separate removal. This does not justify retaining
Array allocation, mutation, iteration, or its encoded Map insertion shortcut.

## Implementation and checks

Removed the old Array runtime dispatcher and all algorithm/instruction builders.
Moved the six remaining layout helpers into the old Map runtime; no Array
algorithm remains with them. Removed three unused exports from the selected Dew
FFI list. The runtime-builder signature stays unchanged until Map's removal.

The policy regression fails before removal (seven subtest failures,
0.073 seconds). The bridge boundary regression fails before removal in
6.601 seconds (12 pass, one failure). It now checks all 18 old names across
eight former carrier encodings, including the old encoded Map insertion path.
Public interface refresh takes 0.975 seconds. Provider wrapper regeneration
takes 4.094 seconds and removes exactly three exports (4,188 remain). The Dew
used-export list now selects 469 functions. All 16 policy tests pass in
0.077 seconds. All 13 focused bridge tests pass in 6.873 seconds.

Provider removal is committed as `7c9f5aa08`. Provider rebuild takes
10.845 seconds; consumer regeneration after that commit takes 4.061 seconds.
The provider SHA-256 is
`9dd5ef9f5628e96ec0058c6c00a5327a5cc4dca8256a30178ecc060dc743ba3c`.
The refreshed provider passes the full self-host hardening lane in
70.322 seconds: 325 tests, 75 exact failure records, and all shared corpora.
Real-library Array has 29 passing checks (0.958 seconds), Map has 12
(1.459 seconds), and Set has eight (1.519 seconds).
The generated-source lane passes in 3.732 seconds. A fresh native compilation
of the real Array fixture takes 0.439 seconds; all 29 checks pass in
0.025 seconds. Broad final lanes remain due
after the remaining batches. Runs above 30 seconds remain speed bugs; no speed
work is included.
