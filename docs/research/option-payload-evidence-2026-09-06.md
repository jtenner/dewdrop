# Option payload evidence

After the indexed-result fix, the ordinary Map probe reached an I64 Option
constructor. The shared variant selector chose the I64 payload from the emitted
field value. A second direct-call-only step then replaced it with the field's
erased eqref storage type. This emitted an I64 operand to an eqref constructor.

The extra selection step is removed. Direct variant calls use the common
variant selector, which distinguishes an unboxed value from its storage slot.
The shared raw-storage fixture now covers a generic owner with a second type
argument whose I64 field is wrapped in Option::Some.

Self-host hardening and shared execution pass (49.459 seconds). This full lane
still exceeds 30 seconds. Native library and shared execution also pass; the
exact run time is in `/tmp/dewdrop-option-field-library.log`.

The Map probe passes this boundary and now exposes a separate missing Unit
marker on generic field assignment. Neither Map migration nor the wider
constructor audit is complete yet.
