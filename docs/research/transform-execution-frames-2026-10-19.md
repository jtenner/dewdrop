# Checked execution frames for source transforms

The VM previously kept one proof set per source offset. A generic helper can
use that offset with different logical types and trait implementations.
Concrete queries worked; a helper's pending query reached an unsupported builtin.

Both implementations now use the normal instance and trait planners. Each
selected helper has an execution-frame key. Call targets carry the target key;
closures capture their owner key. Calls restore the prior frame on return and
error. Instance maps hold checked calls, references, scalar reads, and primitive
operator proofs. Parsed source and global layouts remain shared.

Folded query constants are saved before branch pruning. Name arrays are fresh
VM values each time they execute. Computed field and variant-payload types stay
in type positions. Standard helper bodies execute in the existing interpreter;
there is no second payload, Wasm instance, or host capability.

## Defects found during implementation

- The original generic width helper failed visibly on `types.bit_width`.
- Independent review identified lost nongeneric method and primitive-operator
  proofs after selected-body checking. The valid method probe failed at the VM
  call fallback. Instance proof export now reads the selected plan, including
  scalar reads that had no concrete template proof.
- A selected invalid call could execute when its callee ignored the argument.
  The probe called an I64 parameter with an I32 value and emitted 42. Setup now
  rejects selected-instance diagnostics before source execution. The same probe
  rejects with CT-041 in 1.132 seconds.
- Qualified query guards omitted a checked import-reference variant in two Native
  lookups. The separate qualified-guard note records that fix. The unqualified
  controls made the frame defects visible before that fix.
- Copy limits initially omitted arrays and rechecks. The charge now lists the
  clone bundles, uses subtraction checks to avoid count-sum overflow, and charges
  rechecks again. This limits copied arena work, not all compiler allocations.
- Native concrete-type validation had a depth bound but no node bound. It now
  stops after 65,536 visits, including shared type-tree edges, before building a
  structural instance key. A shared binary tree regression exercises this limit.

## Bounds and limits

Transform planning allows 128 logical instances and 1,048,576 copied arena
entries. The copy ledger is separate from VM work and allocation work. It is not
identical across implementations and does not measure bytes or peak memory.
Fresh inferred arenas, physical planning, normal frontend work, and source
storage are outside that ledger. These limits do not replace VM depth, work,
output, and allocation checks.

Generic implementation methods and trait objects need further source coverage.
Separate generic function-reference equality still requires the runtime ABI
identity; frame keys are not used as a guessed replacement. No persistent cache,
bytecode backend, or parallel execution is claimed by this change.

## Checks so far

- Native VM tests: 75 passed, 2.437 seconds.
- Native type tests: 7 passed, including shared-tree limit, 10.714 seconds.
- Native frame source tests: 9 passed, 20.503 seconds.
- Native vector source rejection/control tests: 6 passed, 5.868 seconds.
- Dew production source check: 234 files, 15.576 seconds.
- Generator refresh: 38.219 seconds. This exceeds the project's 30-second rule
  and remains a measured performance bug.
- The first qualified-guard tests failed due to inline Dew fixture syntax. Their
  corrected execution and full Dew/frame request checks are pending below.

Logs are in `.tmp/transforms-v3/`, with `frame-*`,
`generic_selected_*-corrected.*`, and `generic-invalid-selected-*` names.
The read-only review packet is `frame-review/`. Independent GPT reviewers read
all seventeen files in its declared scope. Claude usage was unavailable then;
no Claude assessment is claimed. Times are completion checks, not controlled
speed measurements. Peak memory has not been measured.


## Integrated Dew result

All 91 Dew tests now pass: generation 7.102 seconds, link 1.415 seconds,
execution 7.713 seconds, full lane 21.107 seconds. This includes nine checked
source frame cases, four qualified guards, and three vector contract cases.
The source fixtures carry 13 real standard modules (277,990 source bytes), with
the same ordinary import files as the public request fixture. No test host
loader was added. The first two fixture attempts failed on missing imports;
these were not execution passes.

The first real trait-frame run passed 90 cases and failed one. Its witnessed
method was present in the selected expression, while the exporter read shared
legacy inference targets. The exporter now uses the final selected expression
and preserves the shared tables. See `dew-selected-trait-proofs-2026-10-19.md`.

A separate `generic_trait_impl.dew` probe still fails in Native. It adds a generic
implementation method with its own type query. That larger implementation path
is the next task; this checkpoint does not close all generic trait work.

## Bootstrap and independent review

The fast bootstrap passed after the selected-proof correction. Compiler B and
C have SHA-256 `deb03dd830b8a2432f17818c51941f5b4967331b7bcb45d087f5040cbbb31383`.
A built in 23.968 seconds, A ran in 26.420 seconds, and B ran in 28.030 seconds.
The full lane took 93.034 seconds, above the 30-second rule. This is an aggregate
lane cost; each measured compiler action stayed below 30 seconds in this run.

Claude Opus returned a read-only assessment with normal repository authentication
and the required restricted tools. Its packet is
`.tmp/transforms-v3/claude-frame-review/`. It read fifteen scope files in full,
one in part, and the large Native log in part. Thus full coverage is not claimed.
Its snapshot predates the selected-proof correction. The confirmed Dew trait
failure is now fixed. Its trait-test finding was verified: checking a sum could
miss swapped implementations. The fixture now checks both results separately.
The copy-ledger difference is an explicit open goal, not an identical accounting
claim. Whole-program planning, fallback proofs, shared-context mutation, and
repeated planning costs need the follow-up checks recorded with their fixes.
No controlled speed or heap measurement was supplied to Claude or claimed here.

## Public compile requests

All 48 valid requests returned 42 after Wasm validation, and all 18 rejection
requests failed with the required diagnostic. The full lane took 203.178 seconds;
per-request compile times stayed below 30 seconds. This aggregate exceeds the
project lane limit. Evidence: `.tmp/transforms-v3/requests-frames.log`.

## Final checkpoint checks

The stronger independent-result trait fixture passed all 9 Native source tests
in 19.206 seconds. The Dew suite passed all 91 tests: generation 7.014 seconds,
link 1.547 seconds, execution 7.509 seconds, full lane 20.857 seconds. Vector
generation and oracle checks passed. The three changed package interfaces passed
in 5.748 seconds. A workspace-wide interface attempt failed in the bootstrap
package's backend-specific host functions; that attempt is not a passing check.

A new 129-instance runtime-only control confirms that whole-program frame roots
can consume the transform limit (1.151 seconds). The control and smaller cases
are in `.tmp/transforms-v3/frame-runtime-root/`. That defect and the advanced
generic implementation case are separate follow-up fixes, not closed goals.
