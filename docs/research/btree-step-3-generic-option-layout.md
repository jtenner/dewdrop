# Step-3 generic Option compiler probe

This is an ordinary compiler issue, not a change to the B-tree design.
No compiler fix is part of step 3. All required value carriers run in the
passing tree tests; none is skipped.

Base: `bee17cd481a4d48f2ed02d895119ee05192defee`.
The two source probes are `tools/btree-fit/generic-option.dew` and
`tools/btree-fit/generic-option-valid.dew`. Neither uses B-tree code.

The first probe returns `Option<v>` inside a generic helper and unwraps it
before the helper returns `v`. Calling that helper with F32 fails during
emission. The control passes the Option to the concrete caller and then
unwraps it. It compiles and preserves the same result without adding an
unused constructor as a type witness.

## Repeat

Run from the worktree root with a native CLI. Measure each command separately:

```bash
source tools/self-host-common.sh
DEW_STD_ROOT="$PWD" DEW_PROGRAM_CACHE=0 self_host_measure 'generic Option failure' \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe build \
  --root probe.option --module probe.option tools/btree-fit/generic-option.dew \
  -o .tmp/btree-step-3/generic-option.wasm
DEW_STD_ROOT="$PWD" DEW_PROGRAM_CACHE=0 self_host_measure 'generic Option control' \
  _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe build \
  --root probe.option --module probe.option tools/btree-fit/generic-option-valid.dew \
  -o .tmp/btree-step-3/generic-option-valid.wasm
```

The first command must currently fail; it is a saved reproducer, not a
positive test that treats an assertion failure as a pass. The final local
CLI run failed in 0.236 seconds. The control compiled in 0.227 seconds.
Exact commands, tool/source hashes and output are under
`.tmp/btree-step-3/general-repro/` in the step-3 worktree.

## Confirmed cause and diagnostic limit

`program_generic_enum_instantiations` in
`src/semantic/program_specialization_plan.mbt:2903` collects resolved and
inferred enum types but does not follow concrete types through every generic
call chain. The missing Option<F32> demand leaves no matching physical
payload layout for the pattern emitter in `src/backend/starshine_code.mbt:2477`.
An unrelated concrete Option use can supply the missing demand. The same
small case also fails for I64, F64 and Unit; I32 passes in the recorded probe.
An array producer and a Result version show the same general defect.

The emitter also puts pattern IDs in `UnsupportedExpression` errors. The
test generator reads that number as an expression ID. Thus the displayed
`PlannedLocalGet`, offset and expression kind can identify unrelated code.
The saved small lowering dump places the failing ID outside the helper's
expression span and inside its pattern span, at `Option::Some(item)`.
The report is not evidence of a scalar arithmetic or array read defect.

A general fix must collect concrete enum demands from reachable generic
instances before physical layouts are fixed. It must cover nested calls,
all carriers, reference payloads and Unit without a standard module rule.
A distinct pattern error must preserve the actual pattern/file identity.
Those fixes need their own compiler tests and cost checks.

## Independent checks

One read-only Sol/high task reduced the failure to the small source above
and ran the passing form for I32, I64, F32, F64, V128, reference, Option,
nested Option and Unit. I repeated the small failure/control with the local
CLI and ran the complete tree tests with the passing form.

A read-only Claude Code Opus/high review used normal authentication, Read,
Glob and Grep, no shell or MCP tools, and no permission bypass. It confirmed
the false diagnostic path. It did not establish the missing-layout cause.
It also found test gaps: shifted values and negative keys now have direct
checks, a normal Unit fill reaches capacity, and the separate diagnostic
driver checks exact failure text. Its concern about Unit policy aliases was
resolved by using Unit directly with an explicit result type; no wrapper
object or ambiguous result inference is used.

Review files, logs, status and unread-input lists are in
`.tmp/btree-step-3/claude-bug/` and `.tmp/btree-step-3/sol-bug/report.md`.
Claude did not inspect binary Wasm or run tests. The Sol task did not edit
production source or review performance. Neither review covers the full
compiler or the parent's unrelated intrinsic inventory repair.

The tree tests return the already requested `Option<v>` to the concrete
caller and then unwrap it. This adds no unused constructor and preserves
every carrier check and the inspector. It does not claim that requested
Options or comparator results are allocation-free.
