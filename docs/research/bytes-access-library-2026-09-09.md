# Byte access uses Dew storage and lane instructions

`bytes_byte_at` now reads the declared V128-array/start/length representation.
Dew checks the logical index and start addition before the Core array read.
A swizzle selects the requested lane, and an unsigned lane extraction returns
the byte. The representation cast and vector bitcast are explicit unsafe
operations; no compiler-owned byte-access function is emitted.

The preamble reaches the library body through an ordinary private import of
`dew.std.text_runtime`. Ordering and Facet also use ordinary calls. The shared
production-assertion fixture imports only the preamble and now checks byte
access with no host calls, so an explicit text import cannot hide a broken
dependency path. There is no new standard-module dispatch rule.

The Bytes corpus grows from 37 to 43 cases. New cases cover returned functions,
view offsets, invalid/maximum indices, evaluation order, all 256 byte values,
and all sixteen vector alignments. The initial native probe passes all 43:
compilation takes 10.604 seconds and execution takes 0.025 seconds.

The policy check fails seven assertions before implementation in 0.037
seconds and passes all three tests afterward in 0.038 seconds. Provider
tests move from 19 passes and one failure in 6.863 seconds to 20 passes in
6.791 seconds. Provider commit: `6213a3a1d`. Public Core FFI types remain
unchanged; physical binding metadata and fingerprints are refreshed.

The old native/provider dispatcher entry and separate byte-access body are
removed. Internal byte-copy helpers remain only for the seven builder runtime
operations that are still open.

The final native library lane passes in 29.872 seconds, including 43 Bytes
checks and the preamble-only assertion fixture. The self-host hardening lane
passes 873 tests, 457 exact invariant records, and all shared execution probes
in 97.187 seconds. This exceeds the 30-second timing budget and remains a
performance defect, not a skipped check.

An initial test added a second export to the assertion fixture. The self-host
probe exports only `main`, so that test failed at the harness boundary. The
final fixture checks byte access in `main`, retaining both assertion effect
traces. No compiler check was disabled to obtain the passing result.

The first full native lane failed 145 semantic tests in 128.668 seconds. This
exposed a source-selection defect: a direct `dew.std.text_runtime` import did
not select that source. Calls compiled when another text module happened to
load it. A new dependency test reproduces the missing source (two tests pass,
one fails in 12.168 seconds). The source selector now recognizes this registry
entry on its own and follows its instruction-module import. It does not select
unrelated text modules or add a semantic/emission special case. The scalar
source-closure fixture includes the two new transitive files.

The dependency regression passes all three tests in 13.295 seconds. The next
full native run passes 801 of 805 semantic tests in 193.316 seconds; the four
remaining failures are legacy isolated-module fixtures that infer embedded
preamble bodies without loading imports. They now use the ordinary program
analysis path, retaining their exact name, inference, file-order, and test-only
visibility checks. All 12 tests in those three files pass in 13.680 seconds.

The first integration run takes 107.587 seconds and exposes nine failures.
One is a second loader defect: collection always includes the preamble,
Option, and Result modules, but dependency selection omitted their imports
when implicit user imports were disabled. Selection now closes the sources
of all modules that collection actually includes. The user module still has
zero implicit import edges when `default_preamble` is false.

The remaining integration fixtures are updated to test explicit imports
without an embedded preamble, retain the new library SCC, and analyze the
Fibonacci program with its imports. The intentionally isolated helper test
still requires a missing builder-method diagnostic, in addition to the three
missing-import diagnostics from the embedded preamble helper.

The final integration lane passes all 270 tests in 120.005 seconds.

The final routine semantic package passes all 805 tests in 198.512 seconds.
The backend package then passes 128 tests and exposes two more isolated-module
fixtures. Both now emit a complete linked program; the cross-file test checks
the exact `double` and `run` targets instead of a preamble-dependent function
count. Both focused backend tests pass in 10.271 seconds. The full backend
package and remaining routine packages are rerun after this test-only change.

Final validation is complete. All 1,289 routine native tests pass across the
serial package runs: 805 semantic tests, 130 backend tests (91.467 seconds),
21 loader/driver tests (14.451 seconds), and 333 tokenizer/parser tests.
Generated checks pass in 22.094 seconds. Clean bootstrap passes in 192.451
seconds; compiler B/C raw and linked output hashes are identical:
`aff90e58e8fa5e5762251c5b48f6d51227529f6c7fbec3b420a03b8bde36047f`.
Package formatting touched unrelated files; those formatting-only edits were
removed before commit. No unrelated production changes are included.

The seven builder runtime entries remain open. The full pinned provider and
stress lanes are still required for final migration signoff; focused provider
tests and the regenerated consumer do not replace those lanes.
