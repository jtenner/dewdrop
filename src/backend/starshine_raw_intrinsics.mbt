///|
fn starshine_raw_builtin_operand_matches(
  actual : @semantic.PlannedWasmValueType,
  expected : @semantic.PlannedWasmValueType,
) -> Bool {
  // Equality references accept concrete GC subtypes, not raw function refs.
  if expected is @semantic.WasmNullableEqRefValue {
    match actual {
      @semantic.WasmStringRefValue
      | @semantic.WasmNullableEqRefValue
      | @semantic.WasmNominalRefValue(_)
      | @semantic.WasmExternalNominalRefValue(_)
      | @semantic.WasmFixedArrayRefValue(_)
      | @semantic.WasmNullableNominalRefValue(_)
      | @semantic.WasmNullableExternalNominalRefValue(_) => true
      _ => false
    }
  } else {
    actual == expected
  }
}

///|
// A zero-instruction cast may change the Dew type, not the Wasm carrier.
// Such casts exclude references: carrier equality is not a heap-type or
// nullability proof. Reference instructions have their own stack contracts.
fn starshine_verify_raw_builtin_signature(
  kind : @semantic.PlannedWasmFunctionKind,
  direct : Bytes,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[Unit, StarshineCodeEmissionError] {
  let name = if direct.length() > 0 {
    direct
  } else {
    match kind {
      @semantic.PlannedWasmInlineBuiltinFunction(name)
      | @semantic.PlannedWasmOutlinedBuiltinFunction(name) => name
      _ => return Ok(())
    }
  }
  let signature = @semantic.raw_wasm_builtin_signature(name)
  if name != b"unsafe.bitcast" && signature is None {
    return Ok(())
  }
  let inputs = types[parameters.start:parameters.start + parameters.length].to_owned()
  let outputs = types[results.start:results.start + results.length].to_owned()
  match signature {
    Some(signature) => {
      let expected_outputs = match signature.result {
        Some(result) => [result]
        None => []
      }
      let mut inputs_match = inputs.length() == signature.inputs.length()
      if inputs_match {
        for index in 0..<inputs.length() {
          if !starshine_raw_builtin_operand_matches(
              inputs[index], signature.inputs[index],
            ) {
            inputs_match = false
            break
          }
        }
      }
      if inputs_match && outputs == expected_outputs {
        return Ok(())
      }
      return Err(InvalidBuiltinSignature(name, inputs, outputs))
    }
    None => ()
  }
  if inputs.length() == 1 && outputs.length() == 1 && inputs[0] == outputs[0] {
    match inputs[0] {
      @semantic.WasmI32Value
      | @semantic.WasmI64Value
      | @semantic.WasmF32Value
      | @semantic.WasmF64Value
      | @semantic.WasmV128Value => return Ok(())
      _ => ()
    }
  }
  Err(InvalidBuiltinSignature(name, inputs, outputs))
}
