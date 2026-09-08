///|
// Admission has proved that these source lambdas do not capture a runtime
// dictionary. Their declared erased layout remains valid, but their calls
// still belong to the exact exported owner key, not the empty template key.
fn materialize_runtime_export_lambdas(
  module_ : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  owner : PlannedWasmFunctionFragment,
) -> Unit {
  let root = match owner.kind {
    PlannedWasmDefinedFunction(body) => body
    _ => return
  }
  for index, lambda in module_.lambdas {
    if lambda.root_body != root || lambda.elided {
      continue
    }
    if fragments.functions.any(function_ => {
        function_.lambda == index &&
        function_.specialization_abi_key == owner.specialization_abi_key
      }) {
      continue
    }
    guard index < fragments.lambda_function_indices.length() else {
      abort("FRG-404 runtime export lambda has no fragment slot")
    }
    let base_index = fragments.lambda_function_indices[index]
    guard base_index >= 0 && base_index < fragments.functions.length() else {
      abort("FRG-404 runtime export lambda has no base fragment")
    }
    let base = fragments.functions[base_index]
    guard base.lambda == index &&
      base.declaration == wasmgc_lambda_declaration(module_.module_id, index) else {
      abort("LNK-504 runtime export lambda identity mismatch")
    }
    fragments.functions[base_index] = { ..base, elided: true, }
    fragments.functions.push({
      ..base,
      elided: false,
      function_index: -1,
      specialization_shapes: owner.specialization_shapes,
      specialization_evidence: owner.specialization_evidence,
      specialization_abi_key: owner.specialization_abi_key,
    })
  }
}
