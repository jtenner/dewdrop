# Linked function signatures retain their source fragments

A valid linked function with one parameter was changed to a zero-length
parameter span. The old named-function reader accepted it. The focused red
test failed by comparing the returned function with the required complete
LNK-504 record (0.201 seconds, after test compilation). An earlier invocation
used a name filter instead of the file path and selected zero tests; that run
is not validation evidence.

Named lookup now verifies copied parameter, result, specialization-shape, and
trait-evidence spans against the selected source fragment. Source spans must
fit their own arenas before any later consumer reads them. Direct-builtin and
elision metadata must also remain unchanged. Signature indices must match the
checked module relocation map; an unassigned physical index is LNK-503, not
a usable signature.

The shared fragment identity reader also checks specialized functions,
lambdas, imported signatures, and logical-only fragments. Link completion and
public module emission require exactly one linked record for each source
function fragment. Missing and duplicate records produce FRG-404. Explicit
synthetic erased adapters do not claim a source fragment and remain subject
to their separate adapter checks. This does not prove the complete physical
type table or adapter operand recipes.

The checks do not compare function names: test exports are intentionally
renamed during linking. Physical function indices are assigned by the linker,
not copied from module-local function indices. Existing imported trait
signature fragments remain valid in the importing module.

Focused validation:

- Initial signature and existing lookup tests: 9 passed, 10.528 seconds.
- Shared reader with specialized-call tests: 15 passed, 13.018 seconds.
- Expanded span, metadata, relocation, coverage, and specialization checks:
  14 passed, 11.823 seconds (including the 8 existing lookup tests).
- Emission rejects a duplicate source fragment with the full phase-7 record:
  1 passed, 8.811 seconds. Its unchanged module first passes Wasm validation.

Full native checks pass: 1,147 tests in 156.755 seconds. Integration passes:
268 tests in 66.096 seconds. Scoped public API generation passes in 3.874 seconds;
the library lane passes 326 tests and all shared corpora in 32.634 seconds;
generated checks pass in 17.635 seconds. The public verifier uses the existing numeric
failure type; codecs and the pinned provider are unchanged. This batch changes
only native compiler code. The earlier caller-frame batch has the latest clean
B/C fixed point; the next self-host emitter batch will run a fresh bootstrap.
Runs above 30 seconds remain speed bugs. No speed work is included.
