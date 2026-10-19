# Native mutable capture source shapes

The capture record and its source local retain separate shapes. A concrete
capture did not stop a source local containing Generic or Error from selecting
a reference cell. The native emitter now checks live mutable source locals in
body-local planning and returns an exact SPC-301 error before it emits storage.
Function bodies, nested lambda bodies, and module initializers share the check.
The four body-local planning callers propagate its Result without replacing the
error. Elided locals and erased Unit/Never values need no cell.

The numeric failure has code 301, phase 7, module ID, owning declaration and
body, expression 0xffffffff, expected 0, actual 1 for Generic or 2 for Error,
and the absolute source-local arena index in detail. Both saved and selected
shapes are checked, including product leaves. Saved Error takes precedence and
cannot be repaired by substitution. A concrete carrier conflict reports SPC-302
with the same context and expected/actual cell slots. Error leaves take
precedence when a product also contains Generic.

A public generic export can use an explicit erased reference ABI. A saved
Generic template is accepted only when substitution proves a concrete selected
shape and both select the same cell carrier. Saved Error leaves always reject.
This proves storage compatibility; it does not assert that all saved template
facts were concrete before substitution. The selected-I64 corruption case
rejects because a generic reference cell cannot hold an I64 stack value.

The valid-input tests exposed an older native planner defect: an ordinary
generic function with a live mutable lambda had no selected lambda instance
unless it used a type query or a bound call. Its local, closure, and lambda
layouts disagreed. Generic owners of live lambdas now enter the existing exact
instance path. Existing caller demand propagation selects them through generic
callers. No second specialization path was added. Source templates stay intact;
the selected locals, captures, cells, and signatures freeze together. The Dew
compiler already selects generic lambda cells for each request.

The scalar shape walk allocates no worklist. Product checks use temporary
worklists for saved and selected shapes. Result wrappers can allocate; allocation
counts were not measured. The owner-demand rule scans live lambdas and reuses
the existing demand maps and instance cache. It also causes the existing
compile-time fold and full module-array copies for each newly selected logical
instance. This can increase compile time, memory, and code size for many logical
types that share one ABI. The measurements below cover a fixed callback corpus,
not every possible instance graph. No runtime instructions implement the guard.

The expanded runtime test also found a missing selected-product scratch slot.
Capture/module-value reads allocated scratch from their raw expression shape,
while emission used the selected shape. A Generic read selected as a product
therefore returned unsupported-expression -423. Scratch planning now uses that
same selected shape. It reuses one shared reference slot per function; scalar
and Unit reads add none. The two focused regressions failed first in 8.108
seconds and passed with full Wasm validation in 8.679 seconds.

## Validation

The initial exact-record regression failed in 7.048 seconds: full emission
returned Ok for a source Generic shape, with an unchanged concrete capture.
After the guard, it passed in 7.041 seconds. The expanded exact-record tests
cover top-level Generic/Error and product leaves, function and lambda owners,
escaping closures, distinct declaration/body IDs and local offsets, module
initializers, and selected generic instance corruption. Valid tests cover Unit,
products, plain generic owners, and public erased generic exports.

A separate selected-shape regression first returned Ok for invalid selected
evidence in 8.626 seconds. After checking selected shapes and carrier agreement,
all three guard tests pass in 12.583 seconds. Exact direct checks distinguish
Generic-to-I64 rejection, Generic-to-reference admission, invalid selected
product leaves, and an I64/I32 concrete carrier conflict.

The generic instance test checks I64 and Unit source/capture agreement, selected
lambda signatures and cell storage, distinct layouts, and unchanged source
templates. It passes in 9.777 seconds. The shared callback corpus checks runtime
values for I64, Unit, nested products, generic caller forwarding, and escaping
and nested generic mutable closures in both compilers. Escaping closures read
the prior value before they write, and callers check both invocations. The
native runner also calls the public erased export with real GC references and
reads the selected object's field. Self-host tests use typed main wrappers.

## Measured compiler cost

The unchanged baseline callback source was compiled by retained before/after
native executables, with one warm pair discarded and five alternating measured
runs per executable. Parse, interface, body, body-family, planning, program, and
cache-pack caches were disabled. OS file/code pages remained warm. The before
executable came from the prior verified library lane; this was not a pair of
isolated clean source builds. Exact executable hashes, source/provider hashes,
raw samples, and the harness are retained in `.tmp/mutable-capture-source`.

| Measure | Before | After |
| --- | ---: | ---: |
| Median compile seconds | 0.436171 | 0.422910 |
| Median compiler peak RSS, KiB | 37,532 | 37,388 |
| Native compiler executable bytes | 41,516,112 | 41,539,544 |
| Output Wasm bytes | 28,590 | 28,599 |

These small samples show no material cost change for this input. They do not
prove a speed gain, bound the cost of many logical instances, or measure
individual allocations. The output has one additional selected closure type;
its nine-byte size increase is 0.032 percent. Both outputs pass all 336 original
callback value checks. Output hashes are stable within each executable. Runtime
speed was not benchmarked.

Building the changed native test compiler took 48.641 seconds. This exceeds the
30-second activity limit and remains a recorded compiler-build timing defect.
The first cost harness stopped because `/usr/bin/time` was absent; the working
harness uses per-child `wait4` data. Its first valid run detected the nine-byte
output change rather than byte identity. The type difference was inspected and
the full original runtime oracle passed on both outputs before accepting it.

## Final lanes

| Lane | Result | Seconds | Largest child RSS, KiB |
| --- | --- | ---: | ---: |
| Native | 1,476 tests pass | 301.277 | 1,060,832 |
| Integration | 272 tests pass | 81.046 | 92,864 |
| Library | 343 tests and execution corpora pass | 79.280 | 2,259,808 |
| Self-host hardening | 1,022 tests, 504 exact records, 47 corpora pass | 96.682 | 1,411,784 |
| Clean bootstrap | B/C bytes match | 69.273 | 1,089,220 |
| Stress | 15 tests pass | 0.381 | 15,424 |
| Generated checks, warm isolated run | source/policy/CLI checks pass | 6.967 | 311,144 |

The library lane includes 367 native callback value checks. The self-host lane
passes 366 shared callback checks in 1.450 seconds. The extra native-only check
calls the actual erased export with GC references. Generated checks also passed
on the first final run in 15.013 seconds. The warm rerun uses exact-child wait4
resource data to avoid inherited prior-lane process accounting. RSS means the
largest child process, not total concurrent process-tree memory or allocation
counts. Lane totals and cold build phases are not controlled before/after
comparisons.

The native, integration, library, hardening, and bootstrap aggregates exceed
30 seconds and remain recorded timing defects. Cold hardening test generation,
including its native generator rebuild, takes 36.858 seconds. The longest native
and integration test groups remain below 30 seconds. Bootstrap A source build
takes 21.098 seconds; A/B execution takes 17.299 and 17.255 seconds. Each
bootstrap phase stays below the limit. B/C core, raw linked, and final bytes
match. The final linked SHA-256 remains
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.

Measurements use x86_64 Linux, MoonBit `0.1.20261012 (748b63c)`, Node `v24.21.0`,
Bun `1.4.3`, and wasm-tools `1.262.0`. Tool-dependent lanes select installed
versions through mise. Full raw logs, exact commands, source/provider hashes,
compiler executable hashes, samples, and harnesses are in
`.tmp/mutable-capture-source`. All tested source hashes were checked again before
commit. Existing function snapshot sources were inspected for generic lambda
owners; those controls do not exercise the changed owner-demand rule.

## Review

Read-only GPT and Claude Code reviews found no confirmed defect in the final
code. Earlier review found the unchecked selected-shape path; the added exact
regression failed before that fix. Documentation now includes full instance-copy
costs and distinguishes native erased-export calls from self-host typed wrappers.
All changed source areas were inspected. Unchanged parts of large files and the
final full-lane logs were outside Claude's final source review. The final test
runs and source hashes were checked separately. The review also lists unverified
trait-dictionary cases and the cost of many logical types sharing one ABI; this
audit is still open. Immutable generic product captures also need selected
lambda instances, as the second scratch regression shows.

Review packets and reports are outside production source at
`/tmp/dewdrop-mutable-capture-review`,
`/tmp/dewdrop-mutable-capture-final-review`, and
`/tmp/dewdrop-mutable-capture-final-review-2`.

The following change adds agreement between each source-local cell and every
mutable capture of that source. See the
[cell agreement log](native-capture-cell-agreement-2026-10-18.md).
