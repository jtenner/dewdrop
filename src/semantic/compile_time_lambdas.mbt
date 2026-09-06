///|
// A lambda belongs to its root function's logical instance. A carrier-only
// function key cannot distinguish two closures with different query results.
fn materialize_compile_time_lambdas(
  lowering : PlannedProgramLowering,
  module_index : Int,
  fragments : PlannedModuleWasmGCFragments,
  owner : PlannedWasmFunctionFragment,
) -> Unit {
  let context = match lowering.compile_time {
    Some(value) => value
    None => return
  }
  let instance = match context.instances.get(owner.specialization_abi_key) {
    Some(value) => value.module_
    None => return
  }
  let root = match owner.kind {
    PlannedWasmDefinedFunction(body) => body
    _ => return
  }
  for index, lambda in instance.lambdas {
    if lambda.root_body != root {
      continue
    }
    let base_index = fragments.lambda_function_indices[index]
    if base_index < 0 {
      continue
    }
    let base = fragments.functions[base_index]
    fragments.functions[base_index] = { ..base, elided: true, }
    if lambda.elided {
      continue
    }
    let callable = instance.functions.callable_of(owner.declaration).unwrap()
    let generics = program_callable_generic_parameters(callable)
    let checks = [(lambda.root_type, lambda.result_shape)]
    for offset in 0..<lambda.locals.length {
      let local = instance.locals[lambda.locals.start + offset]
      if local.kind == ParameterLocal {
        checks.push((local.type_, local.shape))
      }
    }
    for offset in 0..<lambda.captures.length {
      let capture = instance.captures[lambda.captures.start + offset]
      checks.push((capture.type_, capture.shape))
    }
    let mut layout_changes = false
    for check in checks {
      let (type_, shape) = check
      if program_resolve_specialized_shape(
          instance,
          generics,
          fragments.specialization_shapes,
          owner.specialization_shapes,
          type_,
          shape,
        ) !=
        shape {
        layout_changes = true
      }
    }
    if layout_changes {
      instance.diagnostics.push(
        CompileTimeQueryDiagnostic(
          lambda.expressions.start,
          "CT-038 query lambda requires a specialized capture or signature layout",
          base.offset,
        ),
      )
      continue
    }
    fragments.functions.push({
      ..base,
      elided: false,
      function_index: -1,
      specialization_shapes: owner.specialization_shapes,
      specialization_evidence: owner.specialization_evidence,
      specialization_abi_key: owner.specialization_abi_key,
    })
  }
  guard instance.module_id == lowering.modules[module_index].module_id else {
    abort("LNK-504 query lambda module identity mismatch")
  }
}

///|
// Select once for the emitting function. Lambda lookups below this boundary
// use this exact table, never the first linked lambda for a declaration.
pub fn program_function_fragments(
  fragments : PlannedModuleWasmGCFragments,
  key : String,
) -> PlannedModuleWasmGCFragments {
  if key == "" {
    return fragments
  }
  let indices = fragments.lambda_function_indices.copy()
  for index, function_ in fragments.functions {
    if function_.lambda >= 0 &&
      !function_.elided &&
      function_.specialization_abi_key == key {
      indices[function_.lambda] = index
    }
  }
  { ..fragments, lambda_function_indices: indices, }
}
