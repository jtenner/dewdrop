# Native mutable capture cell agreement

The source local and each mutable capture keep separate saved shapes. The
native source check proved that the source's saved and selected shapes used
the same cell. It did not compare that cell with the capture's cell. Two valid
shapes, such as I32 and I64, could therefore select different cells.

Native lambda emission now checks each capture with a mutable source or a
mutable capture flag before local planning or instruction emission. It reads
the source through the owning body or lambda's local span. The existing
saved/selected source check runs first. The new check then compares source and
capture cell requirements from their saved shapes and mutable flags. It does
not stop after the first capture of one source.

An SPC-302 failure reports phase 7, module ID, source declaration and root body,
expression 0xffffffff, the source slot as expected, the capture slot as actual,
and `(2 << 32) | absolute_capture_index` as detail. The high tag distinguishes
capture indexes from source-local indexes. The erased slot -1 is encoded
as unsigned 0xffffffff. The older source saved/selected conflict retains its
source-local index in detail.

Small integers can share an I32 cell. Products and references can share a
reference cell. This check proves cell storage agreement, not logical type or
product layout equality. Both sides can omit a cell. If only one side needs a
cell, the check fails. Public generic exports retain the existing checked erased
reference ABI. A source marked read-only has no cell, even if its shape matches
the mutable capture. A read-only capture cannot read a source cell as a plain
value. Only emitted lambdas enter this check.

The check walks each emitted lambda's capture span once. It adds no retained
table and emits no runtime instructions. Scalar checks need no shape worklist.
Product source checks retain temporary worklists from the existing guard.
Generic product substitution can also build temporary shape arrays.
Result wrappers can allocate; allocation counts have not been measured. Source
lookup reuses the root body record and the source lambda's local span. It does
not construct a temporary lambda-body view for each capture.

The self-host compiler already checks the selected capture carrier against the
cell keyed by source local and specialization in
`semantic_capture_cell_plans.dew` and `semantic_capture_access_plans.dew`.
`semantic_closure_construction_plans.dew` checks erasedness and forwarded cell
identity. No self-host production change is needed for this check.

## Tests

The first regression failed before the fix: full emission returned Ok when a
saved I64 source was changed to I32 and its capture stayed I64. The red run took
7.947 seconds. Six final focused tests pass in 12.656 seconds. They check full
numeric failure records, function and lambda sources, module initializers,
second aliases, erased/physical conflicts in both directions, selected generic
instances, nested forwarded captures, both read-only flag conflicts, I8/I32
cell compatibility, and product/reference cell compatibility. The nested test
proves that the selected inner lambda is in the outer lambda's expression span.
Positive cases validate the full Wasm module. A pure `PlannedCapture::with_shape` copy
helper follows the existing source-local helper for exact corruption tests.

The reverse flag regression failed before its fix in 13.143 seconds: the other
five tests passed, but full emission accepted a read-only capture of a source
that remained in a cell for another mutable capture. Existing source metadata
checks validate identities and spans, not this flag agreement. Both tested flag
directions now produce an exact failure before lambda instructions are emitted.

An early expanded fixture used raw string bytes instead of UTF-8. The corrected
fixture uses the UTF-8 encoder and reports source errors through test failures.
Those failed fixture runs are retained with the other evidence.

## Evidence

Raw logs, commands, compiler executables, fixed callback source, and cost
samples are kept in `.tmp/capture-cell-agreement`. The baseline is commit
`76915347e6`.

## Measured compiler cost

The same fixed callback source was compiled by retained before/after native
debug executables. One warm pair was discarded, followed by five alternating
runs per executable. Parse, interface, body, body-family, plan, program, and
cache-pack caches were disabled. OS file/code pages remained warm. The before
executable is retained from the previous verified library lane; these are not
two isolated clean source builds. Exact executable and source hashes, raw
samples, environment, harness, and controls are retained with the evidence.

| Measure | Before | After |
| --- | ---: | ---: |
| Median compile seconds | 0.407801 | 0.402740 |
| Median compiler peak RSS, KiB | 37,448 | 37,548 |
| Native compiler executable bytes | 41,539,544 | 41,572,960 |
| Output Wasm bytes | 32,925 | 32,925 |

The small timing and RSS differences are within run variation. They do not
prove a speed or memory gain. Both outputs are byte-identical, with SHA-256
`22678986c2068c4ee423a95859e9a96d5d783a515d7c65ee205d57b00e46d0fd`,
and pass all 367 callback checks. The host compiler grows by 33,416 bytes
(0.080 percent). Runtime speed and allocation counts were not measured. This
fixed input does not bound every possible capture or specialization graph.

ELF section checks separate file size from loaded memory. GNU `size` reports
728 extra bytes of loaded text and read-only data, with no change to writable
data or BSS. Machine code itself grows by 576 bytes. Most file growth is in
debug sections that are not loaded. Raw section deltas and the size report are
retained with the evidence. This does not measure temporary heap allocations.

The first cost run, before removing a temporary source lambda-body view, showed
a small compile-time increase: 0.423304 to 0.434654 seconds. Both raw runs are
retained. The final guard uses the root body record directly. The changed
native compiler build took 47.742 seconds. This exceeds the 30-second activity
limit and remains a recorded build-time defect. Earlier intermediate builds
took 49.654, 51.236, and 49.174 seconds.

The scoped semantic interface check passed in 1.364 seconds. An earlier
workspace-wide `moon info --target native` checked canonical default interfaces
too and failed on 17 missing platform names in the unchanged bootstrap command
package. Its failure remains visible in `interfaces.log`; the scoped command
is `moon info src/semantic`.

## Final lanes

| Lane | Result | Seconds | Largest child RSS, KiB |
| --- | --- | ---: | ---: |
| Native | 1,482 tests pass | 299.441 | 1,034,128 |
| Integration | 272 tests pass | 81.383 | 93,200 |
| Library | 343 tests and execution corpora pass | 67.659 | 2,260,884 |
| Self-host hardening | 1,022 tests, 504 exact records, 47 corpora pass | 94.296 | 1,414,384 |
| Clean bootstrap | B/C bytes match | 64.124 | 1,047,512 |
| Stress | 15 tests pass | 0.374 | 15,644 |
| Generated checks | source/policy/CLI checks pass | 12.916 | 634,948 |

The library lane includes 367 native callback checks. The self-host lane
includes 366 shared callback checks in 1.348 seconds. The extra native check
calls the actual public erased export with GC references. Bootstrap B/C core,
raw linked, and final bytes match. The final SHA-256 remains
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.

The native, integration, library, hardening, and bootstrap aggregates exceed
30 seconds and remain recorded timing defects. Cold hardening test generation,
including its native generator build, takes 34.708 seconds. No individual
native or integration test group exceeds 30 seconds. Bootstrap A source build
takes 17.095 seconds; A/B execution takes 16.775 and 16.839 seconds. RSS is the
largest child process, not total concurrent memory or allocation counts.

Measurements use x86_64 Linux, MoonBit `0.1.20261012 (748b63c)`, Node
`v24.21.0`, Bun `1.4.3`, wasm-tools `1.262.0`, and Binaryen 133. Installed tools
are selected through mise. The pre-review full pass is retained in
`.tmp/capture-cell-agreement/pre-review`; the table uses the final source.

## Review and limits

Read-only GPT and Claude Code reviews inspected the changed production and
test areas. Earlier review found the read-only source gap, the reverse capture
flag gap, the untagged diagnostic index, and the weak nesting assertion. The
final Claude review reports no confirmed defect. Authentication and required
reads succeeded. Reports and frozen inputs are at
`/tmp/dewdrop-capture-cell-agreement-review` and
`/tmp/dewdrop-capture-cell-agreement-final-review`.

Unchanged parts of large files and some support files were outside the final
review. Its resolver source read came from the workspace and was verified
unchanged. Claude did not inspect the final full-lane logs, ELF section data,
or documentation. These were checked separately, as were all five reviewed
source hashes against the final build and tests.

The check runs when each lambda is emitted. A parent function can have built
instructions in memory first; full emission still returns the error. The final
review lists possible earlier parent-path errors as an unverified risk, not a
confirmed crash. Plain capture value-shape agreement is outside this cell
check. Absent cells can mean either an immutable value or an erased value.
Diagnostic decoders must use phase and code too: phase 4 uses a relative
capture index, while this phase-7 SPC-302 uses an absolute capture index.

The red logs show the earlier test revisions before each fix, not a final
six-test run against the baseline. The retained baseline executable has its
hash and prior verified-lane provenance, not an isolated clean rebuild. The
cost-summary cache filter omits `DEW_CACHE_PACK`; the harness sets it to zero.
These limits prevent stronger scaling, allocation, or speed claims.

## Next check

Check each used capture-cell type lookup against its physical type and field
contract. Bounds checks alone permit an in-range I64 lookup to select an I32
cell. Require the expected cell kind and slot, one mutable value field, and
the expected field storage.
