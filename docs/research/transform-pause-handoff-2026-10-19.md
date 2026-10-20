# Transform work paused: 2026-10-19

Historical pause record. The user resumed work on 2026-10-20.
The details below describe the saved state at the pause.
No commit was made for the unfinished signature work. Keep the working tree.
No compiler/test process remained when root checked at pause.

## Committed

HEAD is `b98fc23bf6` (Preserve raw Bool bits in compile-time execution).
The previous commit is `2203a33065` (bounded memory and packed integers).
Raw Bool: Native 103 VM + 2 checked-source tests pass; Dew 7 new + 18 existing
focused checks pass; ordinary/transform Wasm match all 23 public results.
Original 10 Native probes also match with unchanged output sizes. See
`docs/research/raw-bool-bit-preservation-2026-10-19.md` and
`.tmp/transforms-v4/raw-bool-bits/`. Fresh ordinary Dew primitive Bool operator
comparison still needs the later bootstrap.

## Uncommitted root feature: signatures and checked call repair

Implemented in both transform engines:

- FnNode.signature (SignatureNode parameters/result), call_adapter Option.
- Method builders with_signature, with_parameters, with_return_type,
  repair_calls_with; body builders preserve both fields.
- Structured parameter/type constructors, bounded type/signature rendering.
- Explicit old-signature bridge; exact checked callee sites repair old calls.
- Validation check-file paths map to original target declarations.
- Two-phase expansion: execute all applications, then repair/render in order.
- Only the physically retained initial Source gets original-body repairs.
  New Source with identical text and adapter source remain new code.
- Adapter declaration uses existing size/nesting/parser validation.
- Short bridge names use a per-module identifier index; allocation/work charged.
- Per-file inserted bridge-name bytes capped at 1 MiB before output writes.
- Native caller tokens cached once per file with binary site lookup; Dew does
  likewise. A later improvement could group Native repairs per file to release
  token arrays sooner. Only annotated targets need saved repair proofs; filtering
  non-annotated targets is another small pending footprint improvement.

Main files: lib/dewdrop/ast.dew; generated transform_library/library mirrors;
Native transforms/{signature_nodes,signature_repair,expand,source}.mbt;
Native compiler_driver/transform_signature_calls.mbt and expansion/reflection
wiring; matching self_host/compiler/transform_signature*.dew plus model/source/
validation/expansion/reflection. Native Machine constructors have two new render
fields. examples/transforms/record.dew updated for explicit FnNode construction.
New public example: examples/transforms/signatures.dew, not yet registered in
public request script. New Dew test file is not yet registered in production
`tools/test-transforms.sh` (private saved lane includes it).

Root tests before the other agent's current semantic edits:

- Native VM 106/106: 2.581 s.
- Native signature source cases 10/10: 19.009 s (native-import.log).
- Existing canonical entry signature test 1/1: 1.667 s.
- Dew initial 7 cases passed, 175 total registered: generation 6.725 s,
  link 1.268 s, selected tests 5.616 s, total 18.389 s (dew-fourth.log).
- After that Dew pass, 3 cases (generic, stacked, imported direct) and explicit
  final-source rechecking were added. These 10 Dew cases have NOT been run yet.
- Current JS build passed in 1.756 s. Four actual Wasm controls validate,
  have no imports, initialize, and main returns 42. Compile times 2.12-2.18 s;
  whole-process max RSS 498880-513488 KiB. No speed/heap gain claimed.
- Private control-4.dew (generic) and control-5.dew (stack) are not yet executed.

Evidence/private helpers: `.tmp/transforms-v4/signatures/`:
red.log, native-{first,second,third,fourth}.log, native-final-stage.log,
native-import.log, dew-{first,second,third,fourth}.log, js-build.log,
runtime-{identity,results}.json, runtime-controls.log; runtime-controls.py and
runtime-check.mjs. Private test-dew.sh uses saved old Native generator/linker,
current production Dew sources and test list. Run with pinned tools:
`mise exec wasm-tools@1.262.0 -- bash .tmp/transforms-v4/signatures/test-dew.sh --filter 'transform signatures'`.

DO NOT rerun private `apply.py`: it already mutated source once. The private
integration/draft generators are stale and can overwrite later fixes. Production
source is current. `add-tests.py` appends tests and is also non-idempotent.

## Interrupted bug agent's uncommitted changes

/root/capture_fix_review was interrupted at the user's pause. It owned the
source/compiler lane for a bounded ordinary Native compiler fix. Root's feature
files must not be included in that bug's eventual atomic commit.

Confirmed baseline gap: `let callback = @h.answer` fails Native inference before
transform repair; qualified direct calls work. Source traces:
`infer_members_and_constructors.mbt` qualified values used only module-value
lookup; `infer_basic_bodies.mbt` function-reference constraints accepted only
HirNameExpr. The agent was authorized to reuse checked imported callable/reference
selection, add regressions, validate, document, and commit, but was stopped.

Current owned changes visible at pause:
- src/semantic/infer_basic_bodies.mbt
- src/semantic/infer_members_and_constructors.mbt
- new src/semantic/qualified_function_references_wbtest.mbt

Check `.tmp/transforms-v4/qualified-function-refs/` and agent messages for its
exact last state. Root has not reviewed or validated those latest edits. No
commit for this fix is recorded. The signature import test currently uses a
DIRECT imported call and passes; restore/add qualified function-value coverage
after this normal compiler fix passes. Dew counterpart status remains pending.

## Next feature step, not implemented

Ordinary source that already calls the NEW signature is still rejected by the
initial check. Larger checklist remains unchecked for signature changes until
this is handled. Private design: `.tmp/transforms-v4/signatures/body-guards-design.md`.
Some early notes there need refinement: Dew name diagnostics carry expression/
pattern IDs, not body IDs. Its merged inference JOBS do carry root-body identity
and diagnostic spans (`semantic_inference_merge.dew`).

Proposed safe approach: collect exact body-owned frontend errors; fatal errors
outside bodies remain fatal. Store errors by original module/file/declaration.
Reject a helper before ANY source_body execution (unified AST/bytecode, cold/
cached call path) and before global initializer evaluation. Full final ordinary
checking remains mandatory for runtime code. Native source_body is in
src/transforms/bytecode.mbt:711; Dew is transform_bytecode_compile.dew:399.
Do not bypass storage/physical invariant checks. First test whether original
lowering validates with deferred inference errors; do not assume it needs source
projection. Dew flow diagnostics may need a checked validation view while exact
body errors remain guarded. Generic instance checks must remain strict.

Repair collection must exclude invalid new-call callee sites (wrong arity/type/
ambiguous target), including their function-reference proof entries. Derive
call->callee offsets from checked HIR. Native initial opening-parenthesis bug
already fixed in compiler_driver/transform_signature_calls.mbt. Reflection should
export valid call repair proofs even if another original body has errors, while
retaining its current reflection error report behavior.

## Other remaining work / later validation

`docs/transform-features.md` still has unchecked dynamic trait objects, identical
Native/Dew resource accounting, persistent result cache/dependency tracking,
and parallel independent execution. Earlier designs are in the untracked
`docs/research/transform-remaining-work.md` and thread summary.

A separate ordinary Dew named-function singleton bug has a private unapplied
patch in `.tmp/transforms-v4/dew-runtime-singletons/`; /root/imported_constant_fix
prepared it, no production changes or compiler runs. Native ordinary identity is
already fixed in commit417dbc145b. Later grant lane, test four durable ordinary
identity controls, source initialization order/cross-module ABI/fresh captures.

Fresh A/B/C self-host bootstrap, current full public transform requests, full
backend integration, raw-default actual controls, and latest Wago checks still
need runs after feature work. Old A cannot read current FFI request fingerprint.
Do not claim latest fixed point/Wago/all-platform parity from earlier artifacts.
Claude read-only review was quota-blocked until20:50UTC; no completed Claude
assessment for this work. Do not change credentials or use --bare.

Use one source/compiler lane, freeze source during builds, and measure commands
with self_host_measure. Every command/activity >30 s is a recorded performance
fault. Do not spawn feature implementation agents; bug/review agents are allowed
by AGENTS. Explain tool sets in short ASD-STE100 user text. Do not push or send
external messages. Resume only after the user's new instruction.
