///|
// Taking an intrinsic's address requires a real function, not a host import.
// Its body has the declared physical signature and only the intrinsic itself.
fn emit_starshine_outlined_builtin(
  kind : @semantic.PlannedWasmFunctionKind,
  name : Bytes,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  if name != b"unsafe.bitcast" && @semantic.raw_wasm_builtin_signature(name) is None {
    return Err(UnsupportedBuiltin(name))
  }
  match starshine_verify_raw_builtin_signature(
    kind, b"", types, parameters, results,
  ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let output : Array[@lib.Instruction] = []
  for index in 0..<parameters.length {
    output.push(@lib.Instruction::local_get(@lib.LocalIdx::new(index.reinterpret_as_uint())))
  }
  match starshine_inline_builtin_instructions(name) {
    Err(error) => return Err(error)
    Ok(instructions) => append_starshine_instructions(output, instructions)
  }
  Ok(@lib.Func::new(@lib.Locals::empty(), @lib.Expr::new(output)))
}
