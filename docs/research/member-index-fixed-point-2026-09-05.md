# Indexed members and call inference

The array bulk-operation regression exposed `NoMatchingMethod` for
`values[index].value == expected`. Native inference finished operator resolution
before the final member pass. Indexing could supply a member's receiver type,
but equality had already failed before that member supplied its field type.

Methods, function-value calls, operators, and members now share a resolution
loop. Pending calls are only diagnosed after the loop stops making progress.
Every successful round removes a pending call; a visible assertion rejects an
increase in the pending count. This has no fixed pass limit.

The reduced case then exposed a native emission defect: field access decided
whether to cast its receiver from a short source-expression-kind list. The list
missed indexing and nested fields. Field reads and writes now use the selected
physical owner's checked reference cast. Removing a redundant cast later needs
an exact physical type proof, not another syntax-kind exception.

The shared executable fixture also exposed a self-host lowering mismatch.
`PlannedIndexGet` and `PlannedIndexSet` copied the ordinary call target instead
of the selected operator target. They now preserve the same target and generic
arguments as inference and specialization.

Native tests pass all 792 cases. Ten shared execution checks cover generic
index get/set, nested field read/write, method dispatch, comparison, scalar
limits, and reference alias identity. Both compilers pass. Self-host hardening
also passes. Native tests took 82.712 seconds and hardening took 117.179 seconds;
these build times remain performance bugs. The unrelated new `Array<Unit>`
bulk fixture remains an open storage defect in the next array change.
