# Final cast plus array element: full compiler qualification

The candidate removes one complete native object resolver from a final indexed
array cast followed by a local/constant index and same-type array read. It keeps
the cast, null, canonical type, handle, selected-space, header, logical bounds
and physical element-extent checks. No raw pointer survives a safepoint.

The isolated source starts at exact origin/main `cd029409b`. Production is
`b6e1e529884a717f31e00659f56ecff0d1bed178`; evidence-only handoff is
`72705d0581559fa176cadb0e368a90c26545a946`. The public follow-up is prepared above
PR948 head `2c53a7838` because it owns the overlapping resolver paths. The private
combined qualification is `a13816b55a4551fbb25b53cb44df9262b771da90`, above installed
`321fae779`. All three adaptations preserve the same four-path production change;
the combined copy keeps PR1006 cold trap restores in existing resolvers.

The scalar/ref/pressure microbenchmarks take 50.30%,45.82%,40.02% less time.
The actual seven-pin small entry takes 8.18% less. Nop and arithmetic-index
negative controls remain unfused and change by -0.51%,+0.35%. All72 samples are
retained. These isolated micro comparisons use an origin/main production overlay
with identical final test sources/fixture. The combined full-job comparison below
also gives the control PR948's already-installed space-byte decoder.

## Fixed-input Wago comparison

Three balanced serial pairs use control/candidate, candidate/control,
control/candidate. CPU12,14 and GOMAXPROCS=2; identical compiler and request bytes;
fresh native caches and transform result misses. No task-owned build or test
overlaps. Both variants include every currently pushed safety repair. Held
type-only, collector-recycling, getter and diagnostic patches are excluded.

| Source | Samples, seconds | Median, seconds |
| --- | --- | ---: |
| Installed combined control | 37.873044,37.915011,38.101532 | 37.915011 |
| Combined plus fused array read | 36.145032,36.760062,36.451915 | 36.451915 |

The median takes **3.86% less time**. Candidate and control sample ranges do not
overlap. All six output Wasm/cache hashes match, the Wasm validates, and main
returns42. Each Wago artifact requires and supplies exact native roots. The known
default V8 target stays4seconds; no new V8 compiler timing is run after the user's
request to stop repeating it. The small Node process used to check the generated
main result is output validation only.

Both builds use the private managed-isolated-fork host patch needed by the fixed
transform harness. Host code and all production sources are otherwise unchanged.
The candidate host contains no profiling counters or held experiments. Combined
focused checks pass normal26.426s/checked+stats28.022s; candidate host build7.711s.

Full combined normal/checked suites pass147.157/139.056seconds; the checked
benchmark suite passes27.179seconds. Public feature tests pass normal25.664s
and checked+stats25.982s. Daybreak Blue (gpt-daybreak-blue-latest) independently
reviewed the production change before publication and found no defects. Its test
gaps and exact scope are recorded in the public research evidence. Exact hashes,
commands, per-run logs, root/code/metadata sizes and samples are in
[the data directory](data/wago-cast-array-full-2026-10-21/summary.json).

The next experiment preloads the Old space descriptor. Its first version speeds
an Old dependent-handle chain by26.72%, but slows Nursery/Large/Tiny by3.4–4.0%.
That separate candidate remains held while a shorter fallback is tested.

## Publication and install

Atomic public commit4f8ea382b405f5258139b4e99c9b77e8f4a333d9 is pushed to
readyPR948. Daybreak Blue reviewed it before publication with no findings.
The combined pick isdc961197a73698e7bbf3583769f8979fe3072fef; all four production
files match full-tested qualificationa13816b55 byte for byte. The user ARM64
file retains SHA33b8f91b38727df8487afc9c7a99d6c59bca0ed5d8be1b927c0ad6fefa2f0818.

The selected manager/runtime arelocal-gc-dc961197a on /home/dev/.local/bin/wago.
Both binaries build in4.62seconds. All46 CLI/build/run checks pass, including
fresh/native artifact array reads, collector references, pressure, packed widths
and pins. The first new ref-loop smoke expected the stored i31 payload sum;
the fixture actually counts nonnull references and returns8192. The failed
harness assertion remains saved. The corrected check and remaining cases pass
without rebuilding or changing runtime code. Install manifests and all checks
are saved under data/wago-cast-array-full-2026-10-21/install/.
