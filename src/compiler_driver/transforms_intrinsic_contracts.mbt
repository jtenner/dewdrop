///|
fn transform_contract_carrier(value : @semantic.PlannedWasmValueType) -> String {
  match value {
    @semantic.WasmI32Value => "i32"
    @semantic.WasmI64Value => "i64"
    @semantic.WasmF32Value => "f32"
    @semantic.WasmF64Value => "f64"
    @semantic.WasmV128Value => "v128"
    _ => "ref"
  }
}

///|
fn compiler_register_transform_intrinsic_contracts(
  plan : @transforms.Plan,
  lowering : @semantic.PlannedProgramLowering,
) -> Unit {
  let registered : Map[Bytes, Bool] = {}
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      guard callable.kind is @semantic.PlannedBuiltinCallable(name) else { continue }
      if registered.contains(name) { continue }
      registered[name] = true
      match @semantic.raw_wasm_builtin_signature(name) {
        Some(signature) => plan.add_intrinsic_contract(
          name,
          signature.inputs.map(transform_contract_carrier),
          match signature.result { Some(value) => transform_contract_carrier(value); None => "unit" },
        )
        None => ()
      }
    }
  }
}
