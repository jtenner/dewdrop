# String pattern call recipes

The self-host physical planner now records one call recipe per live String
literal pattern with selected equality evidence. It does not change the literal's
reference carrier to the comparison's Bool carrier.

The recipe has two operands:

1. `PatternSubjectPhysicalOperand(pattern_id)`: the cached subject value.
2. `ExplicitArgumentPhysicalOperand(expression_id)`: the string literal.

The evaluation schedule contains only the literal. The match subject was already
evaluated. A nested pattern uses its cached field path, not a new call to the
source expression.

Target selection uses the exact call-site map. A call with no generic arguments
may use its plain function. A missing entry stays missing; there is no search by
name or first-specialization fallback in this recipe builder.

The verifier checks target identity, specialization, evaluation order, operand
count and ownership, receiver presence, both reference carriers, and exactly one
i32 result. Seven one-field negative cases check BOD-607 and ABI-701, ABI-702,
ABI-703, ABI-704, ABI-705, and ABI-709. Each mutation is restored and the original
recipe must pass again. Owner spans use ARN-101; literal ownership uses ARN-102
before subtraction or access. In these ARN-101 records, `detail` packs span
length in the high word and arena kind in the low word (1 expressions, 2 patterns).

## Limits and next change

Emission still uses the old String equality runtime lookup. The next change must
consume these frozen recipes for both top-level and nested patterns, and check
them again at emission. Only then can the runtime equality builder be removed.
The native compiler already retains the selected logical target, but still needs
to emit that exact target. The broader full-heap-type ABI audit remains open;
these checks use the current physical reference carrier model.

## Validation

- Baseline: the new test failed with the specific missing-recipe assertion
  (63.458 seconds for the complete hardening lane).
- Positive recipe run: all hardening and shared probes pass (58.681 seconds).
- Seven mutation cases and restored recipe pass (62.320 seconds).
- Final hardening: 236 tests, 29 invariant records, and all shared probes pass
  (61.769 seconds).
- Clean bootstrap passes (194.477 seconds). B and C have the same SHA-256:
  `adb5cf802b954415f233715f76f3c77c6469b5c6d8155f1a157e41ff5d5b5c79`.
- These aggregate compiler activities exceed 30 seconds and remain performance
  bugs. Compiler A's build also exceeds the limit (46.629 seconds), as does its
  compiler-source compilation (55.888 seconds).
