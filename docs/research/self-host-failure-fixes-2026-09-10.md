# Self-host failure fixes, 2026-09-10

The imported-constructor work exposed 15 failures in the complete self-host
suite. A control build from HEAD reproduced the same 15 failures. This follow-up
fixes the implementation errors and brings the old fixtures into line with the
current compiler rules.

## Implementation fixes

- Integer token errors contain the original source spelling. Removed appended
  debug state, which broke parity with the native tokenizer.
- Identifier text uses checked UTF-8 conversion. The old ASCII-only builder
  trapped on valid Unicode identifiers. Tests cover one through four bytes per
  code point, at-identifiers, comments, and byte offsets.
- Builtin overload collection updates the stored binding. The old identity
  helper copied its mutable tail, leaving the stored tail stale. The regression
  test checks all links in a three-overload chain with actual Wasm instructions.

## Fixture repairs

- Loop and checked-array fixtures now declare their ordinary Array, iterator,
  Option, indexing trait, and assertion functions. They keep their exact field,
  binding, and result-type checks.
- A resolved pattern type can have a negative encoded arena reference. The test
  checks the decoded Bool shape.
- Specialization keeps I8 distinct from I32 and U32. Tests now check both narrow
  type retention and wide-carrier deduplication, including product fields.
- Closure tests check the base entry, subtype entry and capture, and the planned
  lambda function. The compiler already plans that function in this phase.
- The tuple-payload fixture uses newline-separated record fields and checks
  valid lowering before checking its exact nominal payload.
- Local emission validation compares frozen local and expression certificates.
  Its test now changes the local certificate. A separate test checks that field
  emission rejects changed physical storage with a visible carrier diagnostic.

## Performance work

A Node CPU profile of the self-built compiler took 73.941 seconds. The field
nominal-owner lookup accounted for 47.483 seconds inclusive, including 21.531
seconds in its own loops. It repeatedly searched field arenas and searched
initializers even for concrete scalar fields.

Field layout lookup now uses the module and slot already stored in the semantic
identity. A runtime assertion checks that the selected field has that identity.
Concrete fields with no nominal owner return that result directly. Deferred
types retain their initializer-evidence path.

Native profiling also found whole-module scans in each body's compile-time guard
analysis. Guard scopes and immutable local sources now visit the root body and
its lambdas. Lambda jobs normalize their synthetic body ID to the root body so
they retain enclosing guards. Tests check captured initializers, sibling-body
isolation, mutable captures, and an enclosing Unit guard. The self-host guard
scope walk uses the same boundary.

The native Dew test generator now uses the same `-Og -pipe` C flags as the CLI,
with the existing wraparound and aliasing flags. Its rebuild took 29.385 seconds,
instead of the earlier long `-O2` build. The short-inference test tool defaults
to that release executable; the debug profile remains available through
`DEW_SHORT_INFERENCE_NATIVE_PROFILE=debug`.

The bootstrap script now builds A's Dew core with the normal compiler host and
links it with the same native linker used for B and C. The former A build used
the Wasm-host linker to process the large provider graph. Provider checks,
cleanup, final validation, and the selected per-phase validation mode remain
part of the link step.

The emission corpus profile found repeated query-name allocation and host calls
for individual input bytes. Query target maps now belong to a module's imported
input set and are shared by its body jobs. Query arity checks reject other
builtin namespaces before creating query-name literals and do not allocate a
list of unary names. The test host copies input through one extra memory page;
an ordinary Dew loop appends each page to a pre-sized byte builder. Six full
byte comparisons check empty input, single bytes, exact page boundaries, and
partial final pages. This does not add a compiler builtin or a host import.

The complete emission corpus runs on two isolated Node workers. Each worker
keeps its own compiler state. The parent waits for both, checks their exit
status, and verifies that every corpus ran exactly once. Per-corpus checks and
failure messages remain unchanged. This bounds the full batch as well as the
individual compiler operations.

The routine native lane also measures backend tests by owning file, as it
already does for semantic tests. The former combined backend process exceeded
30 seconds. The file runs keep failures visible and release process state
between independent cases; they do not remove any routine test.

## Validation

The complete self-host suite passes all 1,264 tests. The fixes retain visible
failure diagnostics and add regression checks for the corrected behavior.

- `tools/test-short-inference-self-host.sh --all`: 1,264 passed in 0.866
  seconds. Generation took 8.496 seconds, linking 6.002 seconds, and emitted
  inference probes 0.316 seconds.
- Native guard and query regression groups passed: local sources 2, guard
  refinements 6, guarded traits 5, and query edges 7. Each group stayed below
  ten seconds, including incremental native rebuilds.
- Native basic inference passed 15 tests. The revised routine runner passed
  all 151 backend tests, 19 loader tests, and 3 driver tests. Backend file runs
  took at most 15.767 seconds. Their total, including loader and driver, was
  92.277 seconds; the runner measures each independent file or package step.
- `tools/test-self-host-hardening.sh`: 970 tests passed in 0.495 seconds,
  504 invariant trap records passed in 0.868 seconds, and both host-record
  decoder tests passed. Generation took 7.016 seconds and linking 5.693 seconds.
  All 47 emission corpora passed in 21.241 seconds on two isolated workers.
  Both workers passed the six complete bulk-input byte comparisons. Emitted
  short-inference and semantic probes also passed.
- `tools/check-self-host-bootstrap.sh --fast`: all validation and semantic
  probes passed. A's source build took 17.616 seconds and native link 5.121
  seconds. A emitted B in 20.733 seconds; B emitted C in 20.811 seconds. Their
  native links took 6.198 and 6.219 seconds. B and C are byte-identical, with
  SHA-256 `f22c9dd000e66e8a93611ad863d2dd160d8114893681d4d40a83cd0d6df8f1e8`.

The measured final self-host steps all stay below 30 seconds. Logs are under
`.tmp/failure-fixes/`: `all-tests-complete.log`, `hardening-complete.log`, and
`bootstrap-complete.log`. Native results are in `native-guards.log`,
`native-guards-2.log`, and `native-by-file-complete.log`.

Run the native checks with `tools/test-native.sh`. Changed MoonBit files were
formatted directly; shell and JavaScript syntax checks and `git diff --check`
also passed.
