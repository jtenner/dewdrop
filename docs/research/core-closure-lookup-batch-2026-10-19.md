# Core closure lookup check batch

Baseline: `f427d03938`. This batch closes the immediate closure lookup queue
before new feature work. It does not claim that the larger compiler audit in
`agent-todo.md` is complete.

## Contracts

The preceding capture-cell lookup change checks six exact cell families and
their reverse mappings. This batch adds three connected checks:

- The common closure lookup must select its one declared closure type. That
  type has one immutable entry field at position zero with nullable function
  reference storage. Missing and duplicate types are rejected.
- Base and selected lambda closure lookups must select their exact lambda
  type. Entry fields, ordered capture fields, and reverse ownership are
  checked before linking. Source-level capture checks use the selected
  lowering and validate the exact capture field or direct parameter layout.
- Lambda function lookups must retain the exact lambda and function kind.
  Their entry signatures must match the selected function. Bounds, dimensions,
  missing mappings, and duplicate plain functions are checked before reads.

Module and full-program emission use the same checks. A shared conversion
retains all nine failure fields and sets emission phase 7. The semantic
boundary uses phase 5. The existing source capture-cell check remains before
the new layout check, including at closure construction, so its precise source
failure is retained.

The source-level layout check runs per lambda. It does not scan every capture
for each function. A public generic export can retain an erased capture layout;
the checker resolves that shape from its saved ABI key and specialization
arguments. Saved Error shapes cannot be repaired from that evidence.

The detailed scope and focused evidence are in the
[common closure log](common-closure-type-contracts-2026-10-19.md),
[lambda closure log](lambda-closure-type-contracts-2026-10-19.md), and
[lambda function log](lambda-function-lookups-2026-10-19.md).

## Regressions and fixes during validation

The initial common lookup test accepted an in-range struct type as the common
closure. The lambda closure behavioral check accepted a lookup with the wrong
lambda type when only its new guards were disabled. A lambda function map swap also passed phase 5 and full program
emission: both source branches emitted the same function reference despite
their distinct bodies. The new guards reject these states with exact records.

A valid public generic export test exposed an overstrict new capture guard.
Its saved Generic capture had a proved reference ABI, but the first guard
rejected it before reading that evidence. The guard now uses the explicit
selected fragment evidence. This is a fix to the new guard, not a change to
the runtime ABI.

The guard-disabled lambda red run preceded final formatting. Its source was
restored exactly for that run; two backend before hashes differ from the later
formatted build. It is not a guards-disabled run of byte-identical final
source. Final build and full-lane source identity are checked separately.

A later mixed Error/Generic tuple test exposed a second guard defect. A LIFO
first-bad-leaf check could find Generic before its Error sibling and then
rebuild both fields from the valid tuple type. The new test failed before
the fix. A local shape check now gives Error priority across the saved graph,
with both tuple orders and nested Error cases. Scalars return before creating
a worklist; concrete products are walked once. All 72 targeted and related
tests pass after this fix. The first full pass was stopped and retained in
`.tmp/core-lookup-checks/pre-review`; the final pass uses the fixed source.

Old alias tests now expect the earlier module-boundary failure where the new
checks detect the same malformed record sooner. No unexpected exception or
missing test is treated as a passing result.

## Compiler cost

The final native debug generator build takes 51.666 seconds at 2,253,284 KiB
peak child RSS. This exceeds the 30-second rule and remains a timing defect.
There is no matched isolated before-build sample. Formatting takes 0.179
seconds; the scoped interface check takes 1.431 seconds.

The callback fixture uses the same source for both executables, one discarded
warm pair and five measured alternating pairs. All seven cache controls are
zero, including `DEW_CACHE_PACK`.

| Measure | Before | After |
| --- | ---: | ---: |
| Median compile seconds | 0.416545 | 0.412062 |
| Median peak child RSS, KiB | 37,484 | 37,528 |
| Compiler file bytes | 41,594,440 | 41,718,568 |
| `size` text/read-only bytes | 6,057,696 | 6,072,432 |
| `size` data bytes | 30,048 | 30,048 |
| `size` BSS bytes | 209,033 | 209,033 |

The measured ranges overlap. These small time and RSS differences do not show
a throughput or memory change. Compiler text/read-only data grows by 14,736
bytes. The file growth also includes debug data. Module checks use bounded
linear scans, one physical-type coverage array, one plain-lambda index array,
and an array of layout-map references. Per-lambda checks scan that lambda's
captures and shape leaves. Closure/Result allocations were not measured.
RSS means the largest child, not allocation counts or total concurrent memory.
No generated-program runtime speed measurement was made.

All 12 sample outputs match: 32,925 bytes, SHA-256
`22678986c2068c4ee423a95859e9a96d5d783a515d7c65ee205d57b00e46d0fd`.
Both outputs pass 367 native callback checks.

The before binary is retained from the prior verified lane, not rebuilt in an
isolated clean checkout. Its SHA-256 is
`8bb6e7df104c402caca318604186bef3a9f912025b8ae3b1b7ea34e31ee5aeed`.
The after binary SHA-256 is
`42df6c9a84dcb74ba7b10997b948dee58df234fb67de1b63b2a7891d0fa71aea`.
Build identity, 15 source hashes, raw samples, harness, section sizes, and logs
are in `.tmp/core-lookup-checks`. Measurements use native x86_64 Linux, MoonBit
`0.1.20261012 (748b63c)`, and Node `v24.21.0`. Full test tools are Bun `1.4.3`,
wasm-tools `1.262.0`, and Binaryen 133 through mise.

## Final verification

| Lane | Result | Seconds | Largest child RSS, KiB |
| --- | --- | ---: | ---: |
| native | 1,532 tests pass | 324.029 | 1,019,120 |
| integration | 272 tests pass | 80.133 | 92,960 |
| library | 343 tests and execution corpora pass | 70.092 | 2,253,596 |
| hardening | 1,022 tests, 504 exact records, 47 corpora pass | 98.297 | 1,464,928 |
| bootstrap | B/C core, raw, and final bytes match | 68.150 | 1,051,128 |
| stress | 15 tests pass | 0.360 | 15,660 |
| generated | source/policy/CLI checks pass | 14.568 | 634,908 |

All 38 new tests are included in the native total. The library lane includes
367 native callback checks. Hardening includes 366 shared callback checks in
1.481 seconds. The clean bootstrap preserves core, raw linked, and
final B/C bytes, with final SHA-256
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.

The native, integration, library, hardening, and bootstrap aggregates exceed
30 seconds and remain recorded timing defects. Hardening test generation
takes 37.292 seconds. No individual native or integration test group exceeds
30 seconds. The final full-lane logs and all 15 source hashes were checked
separately after review; they match the final build and frozen source.


The final independent read-only GPT review found no confirmed defect. It
verified the complete saved Error priority, both mixed tuple orders and nested
Error tests, the scalar fast path, exact maps and signatures, nine-field
records, raw cost samples, and all 15 source hashes. Only the two intended
lambda closure implementation/test files changed after the first review. The
combined review inspected every changed source hunk and all seven document
snapshots.

Review limits: full-lane logs and final result numbers were checked separately.
Unchanged regions of large files, several already-checked support verifiers,
warning-heavy historical log regions, and the external callback runner source
were not audited. The mixed Error regression calls the semantic verifier; it
does not repeat all four mutations through backend emission. The fixed fixture
does not bound larger capture graphs. The two frozen review packets are
`/tmp/dewdrop-core-closure-review` and
`/tmp/dewdrop-core-closure-final-review`.

Claude Code was launched from the repository root with normal authentication,
Opus/high, only Read/Glob/Grep tools, no MCP tools, and `dontAsk` permission mode.
It stopped before review with `You've hit your session limit`. No Claude
assessment is claimed. Frozen inputs, prompt, stdout, stderr, and exit status
are at `/tmp/dewdrop-core-closure-review`.


## Queue and remaining design work

A separate call-target audit found no confirmed selector defect in the paths
it inspected. Native call emission checks the saved target map and witness,
including hidden operands. Self-host call emission checks source and recipe
agreement, declaration, specialization, and trait evidence. Existing receiver
lookup rejects ambiguous plain candidates and requires keys for generic ones.
The audit did not implement older name-based shape recovery cleanup.

Full heap/nullability tracking, the full instruction shadow stack, runtime
trait-dictionary capture, phase snapshots, and the rest of the broader audit
remain listed as design work. This batch is the complete immediate lookup
queue; it does not add a further lookup task as a feature prerequisite.
