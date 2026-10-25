# Wago large-array cleanup — 2026-10-20

Fix: [Wago PR #987](https://github.com/wago-org/wago/pull/987), commit
`3da9b38d6500d600e16e7d64c7f9d0aaf695cc7d`.

Wago has a measured GC cost in `discardNativeLargeArrayAllocation`. An unused
large-array reservation is appended to the nursery handle list. Cleanup scans
from the start to find that handle. For this Dewdrop request, the profile puts
13.30 CPU seconds in cleanup; 13.29 seconds are on the search loop and equality
check. This is a runtime cost, not a Wasm compiler setup cost.

## Fix and safety

The fix records the list position when Wago appends the reservation. Cleanup
checks both the bounds and handle identity before it uses that position. If the
list moved or removed the entry, cleanup uses the old forward search. Stable
copy deletion keeps the remaining handle order. Freeing, nursery rewind,
consumed reservations, checked generations, state reset, and epoch wrap retain
their old rules.

This adds one private Go `int` at the end of `Collector`: 3,128 to 3,136 bytes
on measured AMD64. Old field offsets and the 40-byte native large-array state
stay fixed. The timed benchmark has zero bytes and zero allocations per call
on both versions. This does not show a whole-job memory reduction. The two
changed Go function symbols grow by 156 bytes in the paired plain hosts; the
plain host text section grows by 160 bytes (about 0.003%). The whole ELF
file shrinks by 352 bytes; this is not a code-size gain. File layout and
metadata also affect the total. Generated
Dewdrop output size and bytes stay the same.

A diagnostic run records 24,879 cancellations and 29,604,346,682 old search
comparisons. None of the handles is at the list tail; 8,496 have one later
entry. This rules out a tail-only change for this workload. The saved position
also avoids the scan when many later entries exist. Deleting a front entry
still copies the full suffix and remains linear.

## Source and controls

The measured Wago base is `7997c86c36e05cfba4c4f39cabb026a318f55fc0`. The PR
base is `ed76fd17957fd472b92a69d2fa3f5f63680f2cd5`, with candidate
`3da9b38d6500d600e16e7d64c7f9d0aaf695cc7d`. The two upstream commits between
these bases change tests, docs, and CI. They do not change runtime source.
SHA-256 checks confirm that the measured runtime files match the PR files.

The host uses private copies of the checksum-checked Wago source and Facet
v0.1.0. Both sides include the same reference-local safety patch, private
worker patch, and Facet HostCall adapter. The dirty Wago checkout is unchanged.
All compiler jobs were timed with `self_host_measure`; full runs still exceed
the project limit of 30 seconds. Root ran one timed job at a time. Other user
work was active, so small time or RSS differences can be noise.

The full request uses the same compiler Wasm and request, serial transform
execution, a forced transform-result cache miss, `-p8`, a 512 MiB GC heap,
a 64 MiB nursery, and a distinct empty absolute `WAGO_HOME` per run. It compiles
`examples/transforms/parallel.dew` with two transform applications. The output
passes Wasm validation and returns `main() == 42` in Node.

Input and output SHA-256 values:

- Compiler: `c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`
- Request: `873a02bd62e26ef7e15b5556a78a9ea8315df449aafe1ca109c386de2b7ac721`
- Output: `89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb`
- Transform cache: `c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240`

## Small benchmark

Both versions use the same committed benchmark harness, Go 1.27.2,
`GOWORK=off`, `GOMAXPROCS=4`, Linux AMD64, and three 100 ms samples per case.
The harness creates real live objects before timing. The timed loop calls the
real reservation API, publishes a saved later suffix, and cancels the
reservation. Both sides time the same suffix copies. It measures the combined
loop, not only the cleanup function. There is no timing assertion in the test.

| One million live handles; later entries | Base median ns/op | Fix median ns/op |
| --- | ---: | ---: |
| 0 | 432,076 | 16.73 |
| 1 | 415,513 | 17.17 |
| 512 | 428,009 | 60.24 |
| 1,024 | 423,109 | 102.1 |
| All; reservation at front | 493,505 | 486,828 |

The front-entry result is unchanged within noise. The large gain in the other
cases follows from removing the live-prefix scan. It is not the full compiler
speed ratio. Raw samples are in the linked data directory below.

The paired plain host builds take 5.464 and 5.538 seconds (one build each).
This does not establish a change in build cost.

## Full compiler profile

| Profiled run | Wall seconds | CPU seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| Base | 116.994 | 118.974 | 1,105,168 |
| Fix | 103.332 | 105.298 | 1,151,216 |

Large-array cleanup falls from 13.30 seconds flat CPU to 0.01 seconds flat /
0.03 seconds cumulative. The old baseline diagnostic banner has unverified
host identity labels; its private source was checked. The candidate embeds
explicit host identities. Use the paired plain runs for the controlled wall
time comparison. These profile runs support the location of the removed cost.
RSS is higher in the candidate profile; these single samples do not prove a
memory regression or a memory gain.

## Plain full compiler runs

The order is base, fix, fix, base. Every run uses a fresh native cache and the
same two private plain binaries. These hosts omit all diagnostic code. All
four runs match the input/output hashes above and return 42.

| Run, in time order | Wall seconds | CPU seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| gc-plain-baseline | 108.349 | 110.172 | 1,114,944 |
| gc-plain-candidate | 105.509 | 107.361 | 1,058,320 |
| gc-plain-candidate-2 | 102.368 | 104.278 | 1,136,756 |
| gc-plain-baseline-2 | 114.202 | 116.026 | 1,144,680 |

The first pair has 2.62% lower wall time for the fix; the reverse-order pair
has 10.36% lower wall time. Both show a lower time, but the range is wide.
Two samples per version do not give a precise or general speed ratio. Load
average at completion ranges from 3.10 to 5.37. No root-owned build or test
ran with these jobs. RSS varies and does not support a whole-job memory claim.
The profile locates the removed cost more directly than the wall-time pairs.

## Checks and review

- Full native collector package: pass, normal and `wagodebug`.
- Full native collector package with Go race checks: pass.
- New cancellation tests on the baseline: pass. The benchmark exposes the cost.
- Native array/struct allocation, mixed reservations, traps, nursery growth,
  collection, and ABI execution tests: pass.
- Linux ARM64 collector test binary: compile pass; no ARM64 runtime claim.
- Same-output full compiler profile: pass.
- Independent GPT review: all seven changed files read; no code defect found.
- Claude review could not run: weekly usage limit until October 24, 16:00 UTC.
  Exit status and output are saved. This is not a completed Claude review.

## Separate saved-code fault

The metadata comparison finds that the native codec loses `HasStart=true` and
`StartLocalFunc=6961` for this compiler. Loaded code has `HasStart=false` and
`StartLocalFunc=0`, so Wago skips Wasm start initialization. This is already
fixed by [Wago PR #948](https://github.com/wago-org/wago/pull/948), head
`7cb262b5ea2ee548889b5633695bf15cbbec43ec`. No duplicate codec change was made.

That head passes both cold and warm Dewdrop runs with the same output hashes:
158.632 and 147.984 seconds. These are correctness checks. They are slower
than the current-main samples here and do not qualify a performance gain for
this workload. Use an empty Wago native cache until that fix is available.

## Data

[Raw profiles, samples, test logs, source diffs, host identities, build harness,
and review data](data/wago-profile-2026-10-20/large-array-cancel/).
The host builder needs the recorded baseline private source trees and the
local Dewdrop compiler/request artifacts. The standalone Wago benchmark is
in the PR; the full Dewdrop artifact is not a Wago fixture. No native runtime
measurement was made on another architecture. These results qualify this
request and do not prove a general Wago or parallel-worker speed ratio.
