# Source-defined function transforms

Baseline: `83c7e3b483`. This change adds function body transforms to the native
compiler and the compiler written in Dew. It uses an AST interpreter inside the
compiler instance. It does not load a second Wasm program or expose host APIs to
transform code.

## Design

`transform fn` marks a compile-time entry. `#name` and `#@alias.name` apply it.
Entries take the canonical `FnNode` and `TransformContext` types and return
`FnNode` or `Result<FnNode, TransformError>`. Aliases are accepted. Entries have no
receiver or type parameters. Stacked annotations execute in source order.

The first API changes bodies and preserves signatures. The original body becomes
an explicit single-arm `match` expression in `ExprNode::Source`: bare braces in
Dew mean an object value. The `Block` syntax builder uses the same block context.
This permits returns, bindings, and nested use of an original body.

The compiler checks entry signatures and helper code before execution. It blanks
target bodies without changing original source positions and adds separate check
files. Generated functions use separate logical files and pass normal compiler
checks. Exact selected scalar operator proofs prevent custom operator methods
from being replaced with assumed primitive behavior.
Pattern proofs use the selected enum identity or local binding at the original
source offset. Imported nominal names come from checked import scopes. There is
no evaluator shortcut for constructing standard Result or Option values.

The native interpreter receives the same selected standard source modules as
semantic checking. Those modules are used for lookup and helper execution; they
are not copied into the output manifest. The Dew request already contains its
standard sources. Ordinary package sources use normal imports and visibility.

The API files in `lib/dewdrop` are ordinary Dew code. One generator embeds them
for both compilers. No standard library algorithm gets special runtime dispatch.

## Safety boundary

Execution has work, recursion, estimated allocation-work, and output byte limits.
Host calls, unsupported builtins, indirect calls, general method dispatch, and
unsupported operations return errors. Generated source must parse as exactly one
function. Source and string decoding cannot silently replace invalid UTF-8.

This is a language subset, not a complete Dew interpreter. The allocation counter
is not a measured heap bound. There is no transform result cache or bytecode VM.
Work accounting differs between the two implementations. The limits are safety
checks, not portable instruction counts. Dew proof insertion still scans prior
entries and can have quadratic cost for large pattern tables; this is a known
unmeasured scale risk for later indexing work.
See [the user guide](../compile-time-transforms.md) for exact limits and supported
operations. Performance work follows functional and safety checks.

## Checks and review

Logs are under `.tmp/transforms/`. The broad native suite passed 1,561 tests,
integration passed 272, and stress passed 15. Generated-source and CLI fixture
checks passed. The final pattern and name changes then passed 18 interpreter
tests and 19 driver tests (`pattern-native-3.log`). The Dew interpreter passed
10 tests (`dew-8.log`).

The clean final self-host bootstrap passed with identical B and C outputs
(`bootstrap-5.log`). The raw and linked SHA-256 values are both
`fb08a55d4d4e4a474c909e89f250ee6953500b6c7f0e3d70fe5181cdc680352b`.
Compiler A built in 17.380 s. A compiled B in 18.470 s, and B compiled C in
17.968 s.

All four final self-host requests produced `main() = 42`: local, imported,
enum-pattern, and direct syntax-record construction. Invalid signatures, sibling
declarations, and host calls failed with their required diagnostics and no
output file (`requests-node-7.log`).

The final full self-host lane passed 1,034 tests, all emission cases, runtime
library checks, and semantic probes (`hardening-3.log`). Test generation took
38.275 s and exceeded the project 30-second limit; that build cost remains a
performance bug. Linking took 1.483 s and test execution took 0.717 s.

All four public `tools/dew build` examples passed and their exported `main`
functions returned 42. The local, imported, pattern, and record builds took
2.347 s, 2.350 s, 2.227 s, and 2.298 s. Their output sizes were 1,642, 1,639,
1,720, and 1,610 bytes. Logs are `public-*-final.log`. The public transformed
test passed in 0.590 s (`public-test-final.log`). Generated-source checks,
14 bootstrap fixture tests, and three CLI fixtures passed (`generated-3.log`).

The first Claude review inspected the native implementation and found source
position, scan-cost, lookup-cost, context, and UTF-8 issues. Those findings were
checked and fixed. A full Claude review then found the body-block syntax,
bare-pattern selection, standard-source access, and build faults. Those were
fixed and tested. Claude could not run the final delta review because its session
limit was reached; its saved status is 1. No authentication changes were made.
A separate GPT review covered all 49 scoped deltas and found no confirmed defect.
Its report is `gpt-final-delta-review.md`; it lists the source and evidence it did
not read. GPT bug reviews also found operator-proof and entry-signature gaps.
The later record-constructor delta review found a missing exact imported-kind
check. That finding is closed: only a checked `StructDecl` permits record
construction. Module-value inference retains the same import scope. The final
caller review found no further defect. The focused fixed suite passes 67 tests;
the saved old gate fails the three new non-struct rejection tests.

The feature exposed two backend faults and a constructor-resolution fault. Each
has its own regression or research note. A successful native build alone does not
establish self-host correctness; the final checks include real compile requests
and the clean compiler bootstrap.

The self-host tests use the existing Node facet host. Wago was not installed in
the configured host path, so no Wago execution result is claimed. The interpreter
runs within the existing compiler Wasm instance and adds no host API dependency.

No runtime speed gain or hard memory bound is claimed. Native generator rebuilds
exceeded 30 seconds and are recorded as performance bugs in the timing logs.
