///|
test "raw Unit array storage does not change logical or enum carrier evidence" {
  assert_eq(wasmgc_raw_array_storage_carrier(UnitPlannedValueShape), 5)
  assert_eq(wasmgc_fixed_array_carrier(UnitPlannedValueShape), -1)
  assert_eq(wasmgc_raw_array_storage_carrier(I32PlannedValueShape), 0)
  assert_eq(wasmgc_raw_array_storage_carrier(I64PlannedValueShape), 1)
  assert_eq(wasmgc_raw_array_storage_carrier(GenericPlannedValueShape), -1)
  assert_eq(wasmgc_raw_array_storage_carrier(ErrorPlannedValueShape), -1)
  assert_eq(wasmgc_raw_array_storage_carrier(NeverPlannedValueShape), -1)
}
