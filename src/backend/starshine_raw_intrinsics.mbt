///|
// A zero-instruction cast may change the Dew type, not the Wasm carrier.
// References are deliberately excluded: carrier equality is not a heap-type
// or nullability proof. Use explicit Wasm reference operations for those.
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
      @semantic.PlannedWasmInlineBuiltinFunction(name) => name
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
      let expected_inputs = match signature.second {
        Some(second) => [signature.first, second]
        None => [signature.first]
      }
      let expected_outputs = match signature.result {
        Some(result) => [result]
        None => []
      }
      if inputs == expected_inputs && outputs == expected_outputs {
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
