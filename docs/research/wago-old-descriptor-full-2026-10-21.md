# Preloaded Old descriptors: full compiler qualification

This candidate remains held. It is not pushed or installed. Installed Wago is
`local-gc-dc961197a`, which includes the separately qualified array cast/read
fusion. The current experiment adds fixed-displacement Old descriptor loads
and a shorter indexed fallback at five AMD64 resolver bodies. Guards, roots,
metadata layout, caller pins and PR1006 cold trap restores remain intact.

Prototype production: `f596ee6e6`, `0a2442b1a`, `7ba95e52b`; evidence-only
handoff `97f07070f`. Combined qualification is
`77ccd8a26d549e499bf340b90a90d758e2133329`, above array qualification `a13816b55`.
The one merge conflict retained `castFailure(condA)` before the new selection
helper, preserving the existing cold-pin restoration path.

The initial uniform-chain micro improved Old by 26.72%, while other spaces
regressed 3.4–4.0%. Replacing multiply/LEA/add fallback addressing with a checked
32-bit shift and indexed loads preserved Old speed and improved the fallback
by 11.1–11.4% against that initial candidate. All raw samples are retained.

## Six serial full compiler runs

| Variant | Samples, seconds | Median, seconds |
| --- | --- | ---: |
| Installed fusion control | 39.711607, 39.953669, 41.556480 | 39.953669 |
| Refined Old preload | 37.831027, 39.760474, 39.652825 | 39.652825 |

The grouped median is only 0.753% lower and ranges overlap widely. Within-pair
reductions are about 4.74%, 0.48%, 4.58%, so the result also contains directional
evidence that the grouped medians obscure. Control times trend upward and are
well above the preceding fusion matrix's 36.45-second candidate median. This
small matrix does not establish a robust full-job gain or an absolute new speed
claim. No samples are discarded, and no V8 compiler timings are repeated.

All six outputs have matching Wasm/cache hashes, Wasm validates and main
returns 42. Native GC roots are required and exact. The comparison uses CPU12,14,
GOMAXPROCS=2, identical compiler/request bytes, fresh native caches and result
misses; no task-owned build/test overlaps. Control reuses the exact qualified
fusion binary whose production sources match the installed pick. The candidate
host contains no diagnostic or held collector/type-fact code.

Combined focused normal and checked+stats tests pass in 25.908/26.209 seconds;
host build takes 7.674 seconds. Daybreak Blue independently reviewed the full
candidate and found no defects before any proposed public update. The review
checked each site's RCX liveness, R8 destination/base alias, exact selected
descriptor identity including Large, range/extent/type/null checks, original
trap paths, pins, frames, roots and ABI. Remaining test gaps are selected Base
mutation, descriptor refresh races outside the serialized runtime contract, and
a standalone encoder assertion for the base/destination alias.

The next reducer separates the folded indexed address calculation from the Old
special case. It also adds alternating and fixed-random Old/Nursery chains;
uniform-only fixtures do not measure branch prediction on mixed generations.
No further production change will be kept on the strength of uniform micro
results alone.

Full raw commands, hashes, outputs, native code/metadata sizes, samples, focused
checks and candidate build are in
[the data directory](data/wago-old-descriptor-full-2026-10-21/summary.json).
