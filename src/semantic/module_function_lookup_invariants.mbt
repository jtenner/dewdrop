///|
fn module_function_is_plain(function_ : PlannedWasmFunctionFragment) -> Bool {
  function_.lambda == -1 && function_.specialization_shapes.length == 0 &&
  function_.specialization_abi_key == "" && !(function_.kind is PlannedWasmDefinedLambdaFunction(_)) &&
  !(function_.kind is PlannedWasmTraitAdapterFunction(_, _))
}

///|
fn check_module_function_lookup_at(
  module_ : PlannedModuleWasmGCFragments,
  declaration : DeclId,
  index : Int,
) -> Result[PlannedWasmFunctionFragment, ProgramPhysicalTypeFailure] {
  let failure = fn(code, expected, actual, role) {
    physical_type_failure(module_.module_id, declaration, code, expected, actual, role, index)
  }
  guard index >= 0 && index < module_.functions.length() else {
    return Err(failure(101, module_.functions.length().to_uint64(), index.reinterpret_as_uint().to_uint64(), 70UL))
  }
  let source = module_.functions[index]
  guard source.declaration == declaration else {
    return Err(failure(504, declaration, source.declaration, 71UL))
  }
  guard source.lambda == -1 else {
    return Err(failure(504, 0xffffffffUL, source.lambda.reinterpret_as_uint().to_uint64(), 72UL))
  }
  guard source.specialization_shapes.length == 0 && source.specialization_abi_key == "" else {
    return Err(failure(304, 0UL,
      if source.specialization_shapes.length != 0 { source.specialization_shapes.length.reinterpret_as_uint().to_uint64() } else { 1UL }, 73UL))
  }
  guard !(source.kind is PlannedWasmDefinedLambdaFunction(_)) &&
    !(source.kind is PlannedWasmTraitAdapterFunction(_, _)) else {
    return Err(failure(504, 0UL, 1UL, 74UL))
  }
  Ok(source)
}

///|
fn check_module_function_lookup(
  module_ : PlannedModuleWasmGCFragments,
  declaration : DeclId,
) -> Result[PlannedWasmFunctionFragment?, ProgramPhysicalTypeFailure] {
  if semantic_id_module(declaration) == module_.module_id {
    let local = semantic_id_local(declaration)
    if local < 0 || local >= module_.function_by_declaration.length() { return Ok(None) }
    let index = module_.function_by_declaration[local]
    if index == -1 { return Ok(None) }
    return match check_module_function_lookup_at(module_, declaration, index) {
      Err(error) => Err(error)
      Ok(source) => Ok(Some(source))
    }
  }
  // Imported signature fragments do not have a local declaration slot.
  // Require one exact plain record; specialization/link order is not evidence.
  let mut selected = -1
  let mut count = 0
  for index, source in module_.functions {
    if source.declaration == declaration && module_function_is_plain(source) {
      if selected == -1 { selected = index }
      count += 1
    }
  }
  guard count <= 1 else {
    return Err(physical_type_failure(module_.module_id, declaration, 304, 1UL, count.to_uint64(), 76UL, selected))
  }
  if selected == -1 { return Ok(None) }
  match check_module_function_lookup_at(module_, declaration, selected) {
    Err(error) => Err(error)
    Ok(source) => Ok(Some(source))
  }
}

///|
fn verify_module_function_lookups(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  for local, index in module_.function_by_declaration {
    if index == -1 { continue }
    match check_module_function_lookup_at(module_, make_semantic_id(module_.module_id, local), index) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  let imported : Map[DeclId, Int] = {}
  for index, source in module_.functions {
    if !module_function_is_plain(source) { continue }
    let declaration = source.declaration
    if semantic_id_module(declaration) != module_.module_id {
      match imported.get(declaration) {
        Some(first) => return Err(physical_type_failure(module_.module_id, declaration, 304, 1UL, 2UL, 76UL, first))
        None => imported[declaration] = index
      }
      continue
    }
    let local = semantic_id_local(declaration)
    guard local >= 0 && local < module_.function_by_declaration.length() else {
      return Err(physical_type_failure(module_.module_id, declaration, 101,
        module_.function_by_declaration.length().to_uint64(), local.reinterpret_as_uint().to_uint64(), 75UL, index))
    }
    let actual = module_.function_by_declaration[local]
    guard actual == index else {
      return Err(physical_type_failure(module_.module_id, declaration,
        if actual == -1 { 503 } else { 504 }, index.to_uint64(), actual.reinterpret_as_uint().to_uint64(), 75UL, index))
    }
  }
  Ok(())
}
