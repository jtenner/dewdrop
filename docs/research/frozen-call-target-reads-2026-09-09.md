# Frozen call-target reads

Call emission reads the expression's saved raw target and the saved call
recipe. It checks the encoded handle, linked table position, declaration,
specialization, and selected declaration evidence before using the target.
Missing body plans, expression targets, or recipes remain missing. No linked
plain-function lookup repairs them.

Lambda body descriptors use a sentinel declaration; their physical plans
retain the owning declaration. The reader checks this role separately from
ordinary function declarations, while retaining body and specialization checks.
The generic-lambda source probes caught an incorrect initial equality check.

The main instruction emitter no longer searches method names, result nominal
names, or runtime names to resolve unresolved/function-value calls. It no
longer implements an `into` conversion by source spelling. Selected calls use
the saved operand recipe. Runtime function-value targets must belong to the
body and cannot be poison, consumed, dead, deferred, or namespace references.

Tests remove one saved recipe or target, change a target to another existing
function or an invalid index, duplicate a recipe, change the proposed
declaration, and pass a target from another body. Trap tests check all nine
numeric fields. Policy tests forbid the deleted recovery paths.

Initial validation: 737 hardening tests passed, but four shared source groups
failed because lambda descriptor and owner IDs were incorrectly compared.
That run took 59.440 seconds. After correcting the role check and removing
the fallback code, hardening and all shared source checks passed in 64.856
seconds, including 252 specialized callback checks. These durations exceed
the 30-second timing requirement; speed work remains deferred.

Remaining scope: non-emission shape selectors still contain name searches.
Full reference assignability, parameterized heap-intrinsic wrappers, runtime
trait-dictionary closure captures, and complete linked-plan freeze are not
claimed by this change.

Final validation: 744 hardening tests, 359 exact failure records, and all shared
source checks passed in 66.255 seconds. The native stdlib lane passed in 28.833
seconds; generated/policy checks passed in 4.638 seconds. Clean bootstrap
passed in 200.240 seconds. Compiler B and C raw/linked SHA-256 values match:
`b4ed5c0399b956a71c087d24e6a1ce745528be172dd0377b10afeb1b318072a7`.
Compiler A build (44.402 seconds), A execution (55.392 seconds), and B execution
(80.354 seconds) remain recorded timing bugs, not deferred correctness checks.
