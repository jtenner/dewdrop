# Dewdrop improvements, 2026-10-18

The changes are complete and committed as separate work units. The user asked to implement the findings from
[the initial search](language-improvement-review-2026-10-18.md), commit each
change on its own, and push to remote `master`.

## Changes

| Change | Record |
| --- | --- |
| Preserve selected operator results, effects, traps, and coercions during constant folding | [Operator proof](operator-folding-selected-call-2026-10-18.md) |
| Check generic, trait, and finite nested matches; bound proof work and preserve mutable-field behavior | [Open domains](opaque-match-coverage-2026-10-18.md), [nested patterns](nested-pattern-coverage-2026-10-18.md), [mutable fields](pattern-matrix-mutable-fields-2026-10-18.md), [scan budget](pattern-matrix-variant-budget-2026-10-18.md) |
| Include erased scalar box types needed by product matches and loops | [Box demand](product-match-box-demand-2026-10-18.md) |
| Give parse-cache writers and readers equal depth, count, and scalar bounds | [Cache admission](parse-cache-depth-admission-2026-10-18.md) |
| Keep module and file boundaries distinct in cache owner keys | [Owner keys](cache-owner-boundaries-2026-10-18.md) |
| Read host input only when requested, with bounded vector reads and visible errors | [Host reads](run-host-readv-2026-10-18.md) |
| Add module-private struct fields in both compilers and protect checked JSON values | [Private fields](module-private-fields-2026-10-18.md), [exact diagnostic tests](private-field-diagnostic-tests-2026-10-18.md) |
| Keep custom limits in raw JSON documents | [JSON limits](raw-json-document-limits-2026-10-18.md) |
| Reuse checked function, type, callable, and field indexes in the self-hosted compiler | [Index measurements](self-host-index-lookups-2026-10-18.md) |
| Hash cache footer ranges without full-range copies | [Range hashing](cache-range-hashing-2026-10-18.md) |
| Add ordinary Dew mapping, chaining, and lazy defaults for Option and Result | [Value helpers](option-result-value-helpers-2026-10-18.md), [warm planning cost](result-helper-warm-planning-2026-10-18.md) |
| Add four checked integer conversions and strict decimal parsing from StringView | [Conversions](checked-integer-conversions-2026-10-18.md), [decimal parser](decimal-integer-parsing-2026-10-18.md) |
| Keep source boundaries after malformed strings and preserve input errors | [String recovery](malformed-string-recovery-2026-10-18.md), [comment input errors](tokenizer-comment-read-error-2026-10-18.md) |
| Round decimal F32 literals at exact midpoints with bounded scratch space | [F32 correction](f32-literal-rounding-2026-10-18.md) |
| Keep test failures visible and correct fixture assumptions | [Physical type fixture](physical-type-fixture-scope-2026-10-18.md), [reachability fixture](standard-reachability-fixture-2026-10-18.md) |
| Check lambda results against their own specialized types | [Lambda result ownership](lambda-result-ownership-2026-10-18.md) |
| Emit signed and floating literals in nested patterns | [Numeric patterns](nested-numeric-patterns-2026-10-18.md) |
| Use frozen loop result types and omit erased Unit bindings | [Self-hosted loops](generic-loop-carriers-2026-10-18.md), [native Unit bindings](native-erased-unit-pattern-bindings-2026-10-18.md) |
| Remove unused callback signatures and closure bases; give the planner a cache policy key | [Callback type liveness](callback-type-liveness-2026-10-18.md) |
| Keep cold test-generator builds below the local 30-second limit | [Generator builds](parity-generator-cold-builds-2026-10-18.md) |

The library features use ordinary Dew functions. No standard module spelling,
path, or declaration number selects a compiler rule. Private fields add static
metadata and access checks; they do not add runtime visibility checks.

## Final checks

Production source is fixed at `fc00559474e3397b4573fb1ae23d849f0be22252`.
Later commits add test wiring, snapshots, and records.
[Validation data](data/language-improvement-implementation-2026-10-18/validation.json)
contains commands, times, source and binary identities, and log hashes.

| Check | Result |
| --- | --- |
| Broad native tests before the final changes | 1,495 passed; later tokenizer/semantic run: 955 passed |
| Final callback, physical-type, Unit, and cache contracts | 52 passed |
| Final native integration and large-input tests | 272 and 15 passed |
| Full self-hosted compiler tests | 1,371 passed |
| Clean A/B/C bootstrap | B and C are byte-for-byte equal |
| Fresh compiler C feature probe | Returns 42; rejects private access and both missing-match cases |
| Module snapshots, Node and Wago | 461 passed; repeated output bytes are equal |
| Standard library, CLI, cache, and ABI checks | Passed; all 10 architecture budgets passed |
| SWAR, text, and WASI output checks | 61,000, 17,471, and 196 passed |
| Generated files, source format, whitespace, and 9 proof goals | Passed |

These are separate test runs. Their counts include repeated tests.
The final native CLI SHA-256 is
`d426709075299d333ca8700003b252cccd5c958dd2917859d603c2ccbd7bb768`.
Compiler B and C SHA-256 is
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.
The [portable probe](data/language-improvement-implementation-2026-10-18/feature-probe/run.py)
tests the fresh compiler C output, not only the native compiler.

The final aggregate callback case is 4,046 Wasm bytes and 17,835 canonical WAT
bytes. Its original budgets remain 4,100 and 18,000. No budget was increased.
The [snapshot audit](module-snapshot-refresh-2026-10-18.md) covers all 219 changed
WAT files. No error or runtime-result expectation changed. One generic Result
fixture retains two extra payload types. Its program body and allocation
instructions are equal; the type table is not proved minimal.

Each recorded compiler call in the final checks took less than 30 seconds.
Whole test groups can take longer. Two earlier cold release-generator builds
took more than 90 seconds. Debug test generators fix that build cost, with
larger tool files and no claim of lower peak memory.

## Measurement limits

The research records include inputs, raw samples, controls, and source identities.
Index gains are query measurements, not whole-compiler speed gains. Cache range
hash timings are within noise; the useful change is lower tracked temporary
storage. The allocator probe covers selected allocator calls, not every allocation
or peak RSS. Host input measurements include Node startup and pipe work. Native
Windows execution was not available; tests simulate the Windows branch.

F32 measurements use Node WasmGC on this Linux x86_64 host. Heap growth is not an
allocation count. No result here proves a gain on another engine or architecture.
The new Result methods reduce fragment-cache hits by one in a small fixture;
the measured warm build and planning differences were within noise.

## Review scope

Three read-only Claude Code reviews covered the initial frontend/library/cache,
performance, and compiler-core changes. They used normal authentication and
Read/Glob/Grep only. The lead read the reports, checked their evidence, and
addressed the confirmed findings. Exact scopes and limits are retained with
the [review records](data/language-improvement-implementation-2026-10-18/reviews.json).

A further review of the committed follow-up changes stopped at Claude's usage
limit. It returned no assessment. No pass is claimed for that attempt. Separate
GPT reviews checked the final lambda, nested numeric, loop, Unit, callback type,
and cache policy changes. One review found a missing live-lambda signature case
in the callback optimization. The fix and regression test are included.

The reviews and tests do not prove every combination of imported traits,
generic lambdas, and product results. The feature probe and focused tests cover
the confirmed failures. They remain ordinary source cases with no standard
module exception.
