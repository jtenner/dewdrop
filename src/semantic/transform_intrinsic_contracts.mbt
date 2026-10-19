///|
fn transform_intrinsic_shape_carriers(
  shape : PlannedValueShape,
) -> Array[PlannedWasmValueType]? {
  match shape {
    GenericPlannedValueShape | ErrorPlannedValueShape => None
    UnitPlannedValueShape | NeverPlannedValueShape => Some([])
    RefPlannedValueShape => Some([WasmNullableEqRefValue])
    ProductPlannedValueShape(fields) => {
      let result = []
      for field in fields {
        match transform_intrinsic_shape_carriers(field) {
          Some(values) => for value in values { result.push(value) }
          None => return None
        }
      }
      Some(result)
    }
    _ => match raw_wasm_nonreference_carrier(shape) {
      Some(value) => Some([value])
      None => None
    }
  }
}

///|
/// Check known declaration carriers before transforms can discard a builtin.
/// Generic slots stay deferred until an executing call has concrete carriers.
pub fn compile_time_intrinsic_contract_error(
  lowering : PlannedProgramLowering,
) -> String? {
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      let name = match callable.kind {
        PlannedBuiltinCallable(name) => name
        _ => continue
      }
      if name == b"ref_is_null" {
        if callable.parameters.length != 1 {
          return Some("Wasm null test requires one reference operand")
        }
        let parameter = module_.functions.parameters[callable.parameters.start]
        let shape = planned_value_shape_from_resolved_types(
          module_.resolved_types, module_.resolved_type_arguments, parameter.type_,
        )
        match transform_intrinsic_shape_carriers(shape) {
          Some([WasmNullableEqRefValue]) => ()
          Some(_) => return Some("Wasm null test requires one reference operand")
          None => ()
        }
        match transform_intrinsic_shape_carriers(planned_value_shape_from_resolved_types(
          module_.resolved_types, module_.resolved_type_arguments, callable.result_type,
        )) {
          Some([WasmI32Value]) => ()
          Some(_) => return Some("Wasm null test requires an i32 result carrier")
          None => ()
        }
      }
      let signature = match raw_wasm_builtin_signature(name) {
        Some(value) => value
        None => continue
      }
      let inputs = []
      let mut known = true
      for index in 0..<callable.parameters.length {
        let parameter = module_.functions.parameters[callable.parameters.start + index]
        match transform_intrinsic_shape_carriers(planned_value_shape_from_resolved_types(
          module_.resolved_types, module_.resolved_type_arguments, parameter.type_,
        )) {
          Some(values) => for value in values { inputs.push(value) }
          None => known = false
        }
      }
      if known && inputs != signature.inputs {
        return Some("Wasm intrinsic operand carrier mismatch: " + @utf8.decode_lossy(name))
      }
      let outputs = transform_intrinsic_shape_carriers(planned_value_shape_from_resolved_types(
        module_.resolved_types, module_.resolved_type_arguments, callable.result_type,
      ))
      let expected = match signature.result { Some(value) => [value]; None => [] }
      if outputs is Some(outputs) && outputs != expected {
        return Some("Wasm intrinsic result carrier mismatch: " + @utf8.decode_lossy(name))
      }
    }
  }
  None
}
