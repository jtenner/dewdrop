# Native capture-cell type lookup contracts

## Scope and failure

Baseline: `e70614c336942beec316e717fe63390a0322af9d`.

A native capture-cell lookup could select an in-range type from the wrong
cell family. An I64 cell lookup that selected the I32 cell passed both full
program and module-only emission. The two first regression tests failed
before the fix because emission returned `Ok`, rather than an error.
The red run took 8.601 seconds and used 1,057,968 KiB of peak child RSS.

`verify_module_capture_cell_types` now checks these contracts:

- The lookup has six entries. A value of `-1` means no cell for that family.
- Each used entry selects its exact `PlannedWasmCaptureCellType(slot)` and
  retains the correct stored arena index.
- Each cell has one value field at position zero. Its role has the same
  slot, its mutable flag is true, and its storage is exact.
- Every declared cell maps back to its own arena index. Missing mappings,
  orphan cells, duplicate cells, and invalid declared slots are errors.

The six storage types are I32, I64, F32, F64, V128, and nullable eqref.
Packed integers, string references, and function references cannot replace
these full-width storage types. All index and span checks occur before reads.
Unit cells can remain absent.

The check runs in native physical type verification before linking. Full
program emission uses that verifier. Module-only code emission calls the same
check before it builds function code. The module path copies all nine failure
fields and sets phase 7. The semantic verifier uses phase 5. This change adds
no runtime instructions to generated programs.

Self-host cell plans already require exact source and selected-instance cell
identity, a single exact mutable field, and exact linked type identity. No
self-host production change is needed for this native lookup table.

## Numeric failure records

The check uses the existing nine-field physical type failure record. Module
identity is retained. Declaration and body are zero; expression is
`0xffffffff`. The high half of `detail` is the role. The low half is the
family slot unless the table below says otherwise.

| Role | Check | Code | Expected / actual |
| --- | --- | --- | --- |
| 80 | Lookup count | 103 | Six / count |
| 81 | Lookup bounds | 101 | Physical type count / lookup index |
| 82 | Cell kind and family | 504 | Family slot / stored family or sentinel |
| 83 | Reverse mapping | 503 if absent, otherwise 504 | Arena index / lookup index |
| 84 | Field count | 504 | One / count |
| 85 | Field role | 504 | Family slot / stored family or sentinel |
| 86 | Mutable flag | 504 | One / zero |
| 87 | Exact storage | 504 | Family slot / storage family or sentinel |
| 88 | Declared slot bounds | 101 | Six / slot; low detail is arena index |

Existing roles 4, 6, and 7 report a bad stored type index, field span, or
field position. Their low detail identifies the physical type or absolute
field index. Negative values use their unsigned 32-bit representation; the
sentinel is `0xffffffff`.

## Regression tests

Eight semantic tests check all six valid families, absent cells, erased Unit,
lookup count and bounds, wrong kinds and slots, stored indices, missing and
duplicate mappings, field spans and counts, field roles, mutability, and
exact storage. They compare the complete phase-5 record through both the
narrow checker and the full program verifier.

Four backend tests check wrong in-range entries in full program and standalone
module emission, valid Wasm for all six families in both paths, and selected
generic cells with a public erased export and a Unit use. Error tests compare
the complete phase-7 record. Valid modules pass the Wasm validator before
their plans are changed.

The initial two backend tests pass after the fix in 9.819 seconds. The final
eight semantic tests pass in 11.119 seconds at 1,129,844 KiB peak child RSS.
The final four backend tests pass in 8.280 seconds at 1,062,324 KiB. Formatting
takes 0.056 seconds; the scoped interface check takes 1.269 seconds.

## Compiler cost

The native debug generator build takes 45.085 seconds at 2,261,276 KiB peak
child RSS. This exceeds the 30-second limit and is a recorded timing defect.
A harness copy first lost execute permission; the measurement stopped before
the full lanes. The script now preserves file mode, and the same built
executable is used for the completed measurements and checks.

One warm pair is discarded. Five measured pairs use alternating order, the
same callback source, and seven cache controls set to zero, including
`DEW_CACHE_PACK`.

| Measure | Before | After |
| --- | ---: | ---: |
| Median compile seconds | 0.388665 | 0.386787 |
| Median peak child RSS, KiB | 37,412 | 37,428 |
| Compiler file bytes | 41,572,960 | 41,594,440 |
| `size` text bytes, including read-only data | 6,055,400 | 6,057,696 |
| `size` data bytes | 30,048 | 30,048 |
| `size` BSS bytes | 209,033 | 209,033 |

These small time and RSS differences do not show a speed or memory change.
The text and read-only data increase is 2,296 bytes. File size also includes
debug data. The checker scans six entries and the physical type arena. It
adds no retained table or worklist. Closure and Result allocation counts were
not measured. RSS is not a measure of allocation counts or total concurrent
memory.

Every before/after sample emits the same 32,925-byte callback Wasm, SHA-256
`22678986c2068c4ee423a95859e9a96d5d783a515d7c65ee205d57b00e46d0fd`.
Both outputs pass 367 native callback checks. There is no generated-program
runtime speed measurement.

The before executable is retained from the prior verified lane, not an
isolated clean rebuild. Its SHA-256 is
`8d2bf1a7a931be7720ef8d1d4e72463f7a0cb9378d38fb327c400017dc67ce10`.
The after executable SHA-256 is
`8bb6e7df104c402caca318604186bef3a9f912025b8ae3b1b7ea34e31ee5aeed`.
Build identity, six source hashes, raw samples, harness, logs, and metrics are
in `.tmp/capture-cell-lookups`. The system is x86_64 Linux with MoonBit
`0.1.20261012 (748b63c)` and Node `v24.21.0`. Test tools use Bun `1.4.3`,
wasm-tools `1.262.0`, and Binaryen 133 through mise.

## Full checks and review

| Lane | Result | Seconds | Largest child RSS, KiB |
| --- | --- | ---: | ---: |
| native | 1,494 tests pass | 298.105 | 1,127,944 |
| integration | 272 tests pass | 75.347 | 93,272 |
| library | 343 tests and execution corpora pass | 66.045 | 2,260,540 |
| hardening | 1,022 tests, 504 exact records, 47 corpora pass | 108.750 | 1,416,332 |
| bootstrap | B/C core, raw, and final bytes match | 68.861 | 1,046,464 |
| stress | 15 tests pass | 0.359 | 15,148 |
| generated | source/policy/CLI checks pass | 14.093 | 634,868 |

The library lane includes 367 native callback checks. The hardening lane
includes 366 shared callback checks in 1.283 seconds. Bootstrap B/C core, raw
linked, and final bytes match. Their final SHA-256 remains
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.

The native, integration, library, hardening, and bootstrap aggregates exceed
30 seconds and remain recorded timing defects. Hardening test generation
takes 41.479 seconds, including its generator build. No individual native or
integration test group exceeds 30 seconds. Peak RSS is the largest child
process, not total concurrent memory.


A fresh read-only GPT review inspected all six changed files and relevant
planning, lookup, storage, linking, and emission paths. It found no confirmed
source defect. It checked the raw cost samples, harness, build identity,
metrics, section sizes, and focused test results. The small time and RSS
differences are within the sample spread.

Review limits: backend corruption tests cover wrong-family selection rather
than every semantic mutation; there is no direct Never capture test. The
generated interface review covered the new declaration and nearby context.
Unrelated regions of large support files and full warning logs were not read.
Full-lane logs and documentation are outside the frozen packet and were checked
separately. All six reviewed source hashes match the final build identity
and the source used by the completed checks.

Claude Code was launched from the repository root with normal authentication,
Opus/high, Read/Glob/Grep tools, no MCP tools, and `dontAsk` permission mode.
It stopped before review with `You've hit your session limit`. It read none
of the requested scope. No Claude assessment is claimed. Frozen inputs, the
prompt, stdout, stderr, and exit status are retained at
`/tmp/dewdrop-capture-cell-lookup-review`.

The shared disk became nearly full while the tests were saved. MoonBit's
cache-clean command cleared the old native release cache. Source files were
retained. The old release cache is no longer available. There is no matched
baseline build measurement, so these build times do not prove a regression.

## Follow-up

The [closure lookup batch](core-closure-lookup-batch-2026-10-19.md) now checks
the common closure type, per-lambda closure/capture tables, and lambda function
and entry-signature maps. This completes the immediate lookup-check queue.
