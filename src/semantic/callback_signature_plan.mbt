///|
// Generic reference specializations use an explicitly erased callback ABI.
// Keep that signature beside the precise signature; never use a carrier-code
// match as proof that two nominal function types are equal.
fn wasmgc_erased_callback_value_type(
  type_ : PlannedWasmValueType,
) -> PlannedWasmValueType {
  match type_ {
    WasmNominalRefValue(_)
    | WasmExternalNominalRefValue(_)
    | WasmFixedArrayRefValue(_)
    | WasmNullableNominalRefValue(_)
    | WasmNullableExternalNominalRefValue(_) => WasmNullableEqRefValue
    // Function references are not eq references. Closure values already use
    // eqref; raw function-reference operands must retain their signature.
    _ => type_
  }
}

///|
fn wasmgc_append_erased_callback_signature(
  signatures : Array[PlannedWasmFunctionTypeFragment],
  values : Array[PlannedWasmValueType],
  source : PlannedWasmFunctionTypeFragment,
  next_signature : Int,
) -> Int {
  let mut changed = false
  for span in [source.parameters, source.results] {
    if span.start < 0 ||
      span.start > values.length() ||
      span.length < 0 ||
      span.length > values.length() - span.start {
      abort(
        "ABI-704 callback signature=\{source.signature_type_index} invalid span=\{span.start}:\{span.length} arena=\{values.length()}",
      )
    }
    for index in 0..<span.length {
      let type_ = values[span.start + index]
      if wasmgc_erased_callback_value_type(type_) != type_ {
        changed = true
      }
    }
  }
  if !changed {
    return source.signature_type_index
  }
  let parameter_start = values.length()
  for index in 0..<source.parameters.length {
    values.push(
      wasmgc_erased_callback_value_type(values[source.parameters.start + index]),
    )
  }
  let result_start = values.length()
  for index in 0..<source.results.length {
    values.push(
      wasmgc_erased_callback_value_type(values[source.results.start + index]),
    )
  }
  signatures.push({
    resolved_type: -1,
    signature_type_index: next_signature,
    parameters: { start: parameter_start, length: source.parameters.length, },
    results: { start: result_start, length: source.results.length, },
  })
  next_signature
}
