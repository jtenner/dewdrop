# Nested packed pattern reads

## Defect

Direct payload bindings use the checked field-read helper, but nested pattern
paths emitted plain `struct.get` for every field. Nested I8, U8, I16, and U16
payload bindings therefore produced invalid Wasm. The source field storage was
correct; the instruction ignored its packed width and signedness.

An isolated nested I8/U8 enum probe reaches Starshine's explicit error:
`struct.get used on packed field; use struct.get_s or struct.get_u` (0.348
seconds). The shared regression then reproduces it in `nestedPayloadI8` during
the hardening lane (63.660 seconds). Compile or validation errors are failures,
not accepted runtime traps. Earlier exploratory probes had syntax, unsupported
struct-pattern selection, or missing fixture conversion functions; those are
not counted as witnesses of this packed read defect.

## Change

Every nested pattern path now uses the existing linked field-read helper. It
selects `struct.get_s` or `struct.get_u` from the selected field's exact declared
storage. Full-width and reference fields retain plain reads. The link plan is
passed explicitly to all path consumers, including alternative patterns.

Nested literal comparison also accepts the four small integer constant kinds.
Their stack values are I32; comparison uses the same I32 equality instruction
as other I32-shaped literals, after the correct packed read.

The shared packed corpus grows from 20 to 32 cases: four nested binding reads
with values that require truncation and signed/unsigned extension, and eight
literal checks (a match and a non-match for each small integer type). This does
not implement generic enum boxing or general struct-pattern target selection.

## Validation

Hardening passes all 703 internal tests, 328 full numeric records, and all
shared corpora, including the 32 packed cases (65.890 seconds). The native
library lane also passes, including all 32 packed cases (26.731 seconds).
Generated checks pass (4.254 seconds). Clean bootstrap passes (187.826 seconds).
B/C raw and linked compiler hashes match:
`3554d36c247af3d5c0393219923ccbda5adb158c2900aece9710316a35d024c1`.
Runs above 30 seconds remain speed defects; no speed work is included.
