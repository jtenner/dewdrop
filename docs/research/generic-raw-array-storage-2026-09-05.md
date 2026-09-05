# Generic raw Wasm array fields

The native field planner treated a declared `WasmArray<t>` field as a raw
array of reference elements. A shared generic struct holding an I32 or I64
array therefore passed Wasm validation but trapped on a legal field access.
The reduced executable probe failed with `RuntimeError: illegal cast`.

A declared generic array element now makes the *field's array heap type*
erased. This is not a choice of reference element storage. Typed raw array
operations still select and check their actual element representation.
Concrete fields such as `WasmArray<I64>` retain their precise heap type.
The rule requires an actual declared `GenericParameterType`; Error is not
used as permission for this representation.

## Checks

- A native layout regression checks one erased generic array field and one
  precise I64 array field, plus complete Wasm validation.
- Seven shared execution cases cover I32, I64, reference, F32, and F64
  backing arrays; mutation; returning a backing array through a generic
  function; and replacing the backing allocation.
- The native library lane passed all existing tests and the seven new cases
  in 5.390 s. The same seven cases passed in the self-host real-library probe;
  all emission probes passed together in 6.042 s.
- All 795 native tests passed in 55.778 s; all 266 integration tests passed
  in 43.649 s. Both aggregate times remain performance bugs.
- Full self-host hardening passed: 161 tests, 27 exact numeric records, and
  all execution probes, including the seven storage cases. The cold native
  test-generator rebuild made this lane take 103.034 s; that remains a
  performance bug. Generated checks passed in 14.412 s.

## Next storage work

Keep typed raw arrays as the backing storage. Do not add per-scalar heap
boxes merely to work around this field-planning defect. The remaining Array
migration needs checked raw GC instruction contracts, explicit Unit storage
adapters distinct from logical operands, source-owned Array fields and
growth code, and removal of the legacy wrapper/name paths. The standard
module identity exceptions are not removed by this narrow fix.
