///|
test "erased callback signatures retain precise originals and scalar order" {
  let values = [
    WasmI32Value,
    WasmNominalRefValue(7),
    WasmI64Value,
    WasmNullableExternalNominalRefValue(812UL),
  ]
  let source : PlannedWasmFunctionTypeFragment = {
    resolved_type: 3,
    signature_type_index: 20,
    parameters: { start: 0, length: 3, },
    results: { start: 3, length: 1, },
  }
  let signatures = [source]
  assert_eq(
    wasmgc_append_erased_callback_signature(signatures, values, source, 21),
    21,
  )
  assert_eq(signatures[0], source)
  assert_eq(values[1], WasmNominalRefValue(7))
  assert_eq(values[3], WasmNullableExternalNominalRefValue(812UL))
  assert_eq(signatures[1].parameters, { start: 4, length: 3, })
  assert_eq(signatures[1].results, { start: 7, length: 1, })
  assert_eq(values[4:8].to_array(), [
    WasmI32Value,
    WasmNullableEqRefValue,
    WasmI64Value,
    WasmNullableEqRefValue,
  ])
}

///|
test "callback erasure never treats a raw function reference as eqref" {
  assert_eq(
    wasmgc_erased_callback_value_type(WasmFunctionRefValue(13)),
    WasmFunctionRefValue(13),
  )
  let values = [WasmI32Value, WasmI64Value, WasmFunctionRefValue(13)]
  let source : PlannedWasmFunctionTypeFragment = {
    resolved_type: 3,
    signature_type_index: 20,
    parameters: { start: 0, length: 2, },
    results: { start: 2, length: 1, },
  }
  let signatures = [source]
  assert_eq(
    wasmgc_append_erased_callback_signature(signatures, values, source, 21),
    20,
  )
  assert_eq(signatures.length(), 1)
  assert_eq(values.length(), 3)
}
