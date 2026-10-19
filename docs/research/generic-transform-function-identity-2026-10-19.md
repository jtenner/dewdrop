# Checked generic function identity

Baseline: `d9c3e44518`. The implementation uses the normal compiler runtime
specialization identity, separately from transform execution frames. Forcing
extra logical instances for interpretation must not change function equality.

## Native path

Keep the normal logical/query demand maps before forcing transform instances.
Use the selected specialization ABI key and its checked trait evidence. Remove
only the verified terminal logical suffix added solely for transform execution.
Intern `(declaration, normal ABI key)` in one pool for the whole frame export.
Pass an optional U32 ID to the VM. ID zero is valid; absence has no numeric
sentinel. The long checked key does not enter runtime equality comparisons.

## Dew path

Use a separate normal planning context and the existing checked request matcher.
Physical shapes come from the selected request; evidence comes from the normal
call-evidence helper. The side pool spans all exported frames. Pair its U32 ID
with the checked declaration. Do not use forced interpreter frame indexes as
runtime identity.

## Safety and source controls

Physical alias checks stay first. Bound receivers and closures keep instance
identity. Two known generic references compare declaration and interned ID.
A known and missing proof for the same declaration produces a visible error in
both operand orders. Different declarations still compare false.

Four public examples cover ordinary I32/U32 sharing, narrow types, query demand,
nested generic wrappers, generic lambdas, global references, and distinct trait
implementation evidence on nominal values with the same physical carrier.
References are called as well as compared. This checks that identity sharing
does not replace the selected execution frame.

## Validation

Artifacts are in `.tmp/transforms-v4/identity/`.

- `native-controls.log`: checked Native identity4/4,14.831s; text1/1,1.454s.
- `native-interned.log`: the four source identity tests pass with U32 IDs.
  A new VM test had a rejected test-only `try?` form in that run.
- `native-vm-interned.log`: corrected explicit catch test; VM80/80,2.392s.
- `dew-controls.log`: all four identity controls and null controls pass.
  Full lane123pass/1fail: the separate full text test exceeded the Dew work
  limit. This is not an all-green lane; its independent fix is recorded next.
- `api-interned.log`: scoped API generation5.791s.
- `review.md`: independent read-only Native/Dew review and numeric-ID delta
  review found no confirmed identity defect. The mixed-proof risk was changed
  to a diagnostic and covered in both VMs. Claude quota prevented its review;
  no Claude assessment is claimed.

No elapsed-time or retained-heap gain is inferred from numeric IDs. Semantic
export still constructs checked ABI strings. Fresh runtime and self-host
fixed-point checks must use the current FFI fingerprint, not old compiler A.

Final shared check with the environment fix applied: Native VM80/80 plus
identity4/4 and text1/1 pass (`native-final.log`,7.002s total). Dew130/130
pass (`text-accounting/shared-final.log`), generation6.971s/link1.397s/run28.196s.
The full Dew command took76.113s including a cold release generator build; this
is a recorded build-time performance fault, not a sub-30s aggregate claim.
