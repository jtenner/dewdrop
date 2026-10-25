# Scalar conversion policy gate follow-up

Scope: the stale assertions in tools/test_scalar_builtin_policy.py.
No compiler, runtime, B-tree layout, or design change.

Branch: feat/btree-step-2-plans-providers.
The worktree was clean at 4e5fa46fa9e208c47407a0abff07bdef684d1fab.
It was fast-forwarded with git merge --ff-only feat/btree-integration to
91a88912d6d0101d38e178857542f000339baa6a. That is this follow-up's base.
The final handoff gives its exact commit.

The parent worktree, master, and origin were not changed. The follow-up does
not change docs/research/btree-build-status.md. No B-tree test or Starshine
build was repeated.

## Inventory and repair

The baseline test fails at line 29 with AssertionError: 34 != 23.
The native conversion table has 34 unique branches. The scalar Into source
has 23 unique raw builtin targets. These are different surfaces.

The 11 native-only entries are:

* i64.extend8_s, i64.extend16_s, i64.extend32_s.
* i32.trunc_sat_f32_s, i32.trunc_sat_f32_u.
* i32.trunc_sat_f64_s, i32.trunc_sat_f64_u.
* i64.trunc_sat_f32_s, i64.trunc_sat_f32_u.
* i64.trunc_sat_f64_s, i64.trunc_sat_f64_u.

The test now checks 34 native branches, uniqueness, and an exact match to
CONVERSION_INSTRUCTIONS, including each opcode's instruction method.
It checks the exact 23 library targets by subtracting the named 11 entries.
The original scalar opcode-name check and single zero-argument instruction
regex remain in place. The existing check for all 100 library conversion
functions is unchanged. Failures still use ordinary unittest assertions.

Read-only inspection also confirmed that all 34 self-host conversion branches
push exactly one instruction with the matching native method.

The native conversion table, scalar standard source, self-host emitter,
shared catalog, and both relevant generators are byte-identical to the base.
Only the test assertions and this note change. Their source hashes and the
inventory are saved in the scratch folder below.

## Checks and times

Commands ran from /home/dev/.t3/worktrees/dewdrop/t3-78c50516.
Each command used tools/self-host-common.sh self_host_measure.

* python3 tools/test_scalar_builtin_policy.py before the fix:
  exit 1, 2 tests with 1 failure, 0.045 seconds.
* python3 tools/test_scalar_builtin_policy.py after the fix:
  exit 0, 2 tests passed, 0.047 seconds.
* Final scalar check after the comment edit: exit 0, 2 tests passed,
  0.043 seconds.
* tools/check-generated.sh after the fix:
  exit 1, 0.669 seconds. The scalar policy checks pass.
  The gate stops at the separate failure below.
* python3 tools/test_debug_float_policy.py as a direct reproduction:
  exit 1, 3 tests with 1 error, 0.049 seconds.

No compiler build or Dew compilation ran. The full gate stopped in Python
policy checks before its later compiler activities. No measured command
above took more than 30 seconds.

## Remaining generated-source gate failure

The next failure is
test_private_debug_helpers_do_not_become_public_aliases in
tools/test_debug_float_policy.py:13. It calls rendered_intrinsics().
tools/generate_wasm_intrinsics_std.py:229 raises:

~~~text
SystemExit: backend inline builtins without Dew source declarations: f32.copysign, f32.max, f32.min, f64.copysign, f64.max, f64.min, i32.clz, i32.eqz, i32.rotl, i32.rotr, i32.trunc_sat_f32_s, i32.trunc_sat_f32_u, i32.trunc_sat_f64_s, i32.trunc_sat_f64_u, i64.clz, i64.ctz, i64.eqz, i64.extend16_s, i64.extend32_s, i64.extend8_s, i64.popcnt, i64.rotl, i64.rotr, i64.trunc_sat_f32_s, i64.trunc_sat_f32_u, i64.trunc_sat_f64_s, i64.trunc_sat_f64_u, ref.eq
~~~

There are 28 missing declarations. The direct debug-float run has the same
error. Its test, generator, and std/wasm/intrinsics.dew are unchanged from
the follow-up base. Each gate policy test runs in a separate Python process.
The scalar test edit does not supply or change this declaration inventory.
This separate failure was left unchanged, as required by the bounded scope.
The full generated-source gate is not claimed to pass.

## Read-only Claude review

Claude Code used normal authentication from this worktree, Opus with high
effort, and only Read, Glob, and Grep. No --bare, shell tools, MCP tools,
edits, or credential access were used. The process returned exit 0 with
empty stderr and a source review report.

Claude read the baseline test, patch, current test, catalog and generators,
native table, relevant standard declarations, self-host conversion branches,
and focused test evidence. It found no confirmed defect and no weakened
one-instruction check. It also checked all 34 opcode/method pairs by hand.

Coverage limits: it did not read every unrelated Into function body or the
self-host emitter's unrelated branches. It could not compute source hashes
with the allowed read tools. The worker checked those hashes and all 34
self-host single-instruction bodies separately.

Claude noted two general low risks, not regressions: the generator and new
list check share a catalog, and the fixed count checks give short messages.
The independent single-instruction regex and explicit counts were retained.
A final comment edit clarifies the subset relation; it changes no assertion.

## Evidence files

All scratch evidence is under:

/home/dev/.t3/worktrees/dewdrop/t3-78c50516/.tmp/btree-step-2-scalar-policy/

* baseline, focused, check-generated, and debug-float stdout/stderr/status files.
* inventory.json: native/library counts, exact native-only names, source
  hashes, and verified self-host opcode/method mappings.
* remaining-gate-failure.json: the owning test, generator location, full
  diagnostic, and all 28 names.
* review-packet/before.py, fix.diff, and unchanged-sources.json.
* claude-prompt.txt, claude.stdout, claude.stderr, and claude.status.

The reviewed functional patch is unchanged. The final source comment is more
precise than the reviewed comment. No runtime or memory measurement is needed
for these test-only changes; no runtime improvement is claimed.
