# Module constants in transforms

Baseline: `7a434f2e8f`. Both interpreters can read an immutable module binding
through its checked module-value instruction. The exported proof stores the
exact declaration's module, source file, and offset. The evaluator does not
resolve a source spelling to a same-named fallback.

Initializers run on first use with their own module/file context and an empty
local environment. A per-application cache retains values and object aliases.
An initialization stack detects cycles. Escaped return, break, and continue
produce a diagnostic. Mutable module bindings remain rejected. Initializers use
the existing interpreter budgets and have no host capability.

An immutable binding can contain a record with mutable fields, as ordinary Dew
permits. Changes are shared inside an application. The cache and initialization
stack are cleared before each annotation, including stacked annotations. State
cannot leak from one transform application into the next.

## Checks

Evidence is under `.tmp/transforms-v3/`. `constants-red.log` records the old
missing-checked-reference failure. `constants-tests-2.log` passes four whole
native compiler tests: dependent constants, state reset across stacked
annotations, rejection of mutable bindings, and an imported public constant.
The owning file took 9.539 seconds. `constants-native.log` built the initial
public example in 5.178 seconds. Later checks include the routine interpreter
regressions, Dew tests, clean compiler self-build, and all real request cases.

The first real imported-constant request failed in the Dew compiler's qualified
value checking and frozen public initializer type. Commit `45e7f30335` fixes those
compiler checks and adds dedicated regressions. The repeated final constant
script passes 21 interpreter regressions, four native constant tests, 25 real
Dew requests returning 42, and 13 rejection requests with the expected diagnostic
and no output. Clean B/C self-builds match with raw and linked SHA-256
`6304748096d3349523211c212108d472471beb94ca391ddc2db8242effe79f92`.
A source build took 17.713 seconds; A compiled B in 16.379 seconds and B compiled
C in 16.256 seconds. API and generated-source checks passed. This identity
predates the later shared-type export conversion cache fix.

Independent GPT and Claude read-only reviews covered these changes. Claude read
an earlier failing request log while checks were in progress; that imported-value
finding is resolved by the repeated final run above. Its generated-import and
context-construction findings are separate follow-up fixes. Neither review is a
hard-heap measurement. Review reports and coverage limits remain in
`.tmp/transforms-v3/`. The shared-type export conversion work-growth finding is
covered by the separate imported-value review and research note.
