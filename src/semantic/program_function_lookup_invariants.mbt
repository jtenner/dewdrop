///|
pub struct ProgramFunctionLookupFailure {
  code : Int
  phase : Int
  module_id : ModuleId
  declaration : DeclId
  body : BodyId
  expression : UInt
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
fn program_function_lookup_failure(
  declaration : DeclId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 5,
    module_id: semantic_id_module(declaration),
    declaration,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
fn check_program_named_function_lookup(
  link : PlannedProgramWasmGCLink,
  declaration : DeclId,
) -> Result[PlannedProgramWasmFunction?, ProgramFunctionLookupFailure] {
  let index = match link.function_lookup.get(declaration) {
    Some(index) => index
    None => return Ok(None)
  }
  check_program_source_function_lookup(link, declaration, index, true)
}

///|
fn check_program_source_function_lookup(
  link : PlannedProgramWasmGCLink,
  declaration : DeclId,
  index : Int,
  plain : Bool,
) -> Result[PlannedProgramWasmFunction?, ProgramFunctionLookupFailure] {
  guard index >= 0 && index < link.functions.length() else {
    return Err(
      program_function_lookup_failure(
        declaration,
        101,
        link.functions.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        0UL,
      ),
    )
  }
  let slot = index.to_uint64()
  let function_ = link.functions[index]
  guard function_.declaration == declaration else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        declaration,
        function_.declaration,
        slot,
      ),
    )
  }
  // This table is populated only by plain fragments. Exact specializations
  // have their own lookup; a damaged entry cannot substitute one here.
  guard !plain || function_.specialization_shapes.length == 0 else {
    return Err(
      program_function_lookup_failure(
        declaration,
        304,
        0UL,
        function_.specialization_shapes.length.reinterpret_as_uint().to_uint64(),
        (5UL << 32) | slot,
      ),
    )
  }
  guard function_.module_index >= 0 &&
    function_.module_index < link.modules.length() else {
    return Err(
      program_function_lookup_failure(
        declaration,
        101,
        link.modules.length().to_uint64(),
        function_.module_index.reinterpret_as_uint().to_uint64(),
        (1UL << 32) | slot,
      ),
    )
  }
  let module_ = link.modules[function_.module_index]
  // Imported trait requirements have local signature-only fragments. They
  // retain the declaration's identity but are stored in the importing module.
  guard module_.module_id == semantic_id_module(declaration) ||
    function_.kind is PlannedWasmSignatureOnlyFunction else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        semantic_id_module(declaration),
        module_.module_id,
        (2UL << 32) | slot,
      ),
    )
  }
  guard function_.fragment_index >= 0 &&
    function_.fragment_index < module_.functions.length() else {
    return Err(
      program_function_lookup_failure(
        declaration,
        101,
        module_.functions.length().to_uint64(),
        function_.fragment_index.reinterpret_as_uint().to_uint64(),
        (3UL << 32) | slot,
      ),
    )
  }
  let fragment = module_.functions[function_.fragment_index]
  guard fragment.declaration == declaration else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        declaration,
        fragment.declaration,
        (4UL << 32) | slot,
      ),
    )
  }
  guard function_.kind == fragment.kind else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        1UL,
        0UL,
        (8UL << 32) | slot,
      ),
    )
  }
  guard function_.lambda == fragment.lambda else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        fragment.lambda.reinterpret_as_uint().to_uint64(),
        function_.lambda.reinterpret_as_uint().to_uint64(),
        (6UL << 32) | slot,
      ),
    )
  }
  guard function_.specialization_abi_key == fragment.specialization_abi_key else {
    return Err(
      program_function_lookup_failure(
        declaration,
        504,
        1UL,
        0UL,
        (7UL << 32) | slot,
      ),
    )
  }
  match
    check_program_function_signature_copy(
      link, index, module_, fragment, function_,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  Ok(Some(function_))
}

///|
fn verify_program_named_function_lookups(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  for declaration, _ in link.function_lookup {
    match check_program_named_function_lookup(link, declaration) {
      Ok(_) => ()
      Err(failure) => return Err(failure)
    }
  }
  Ok(())
}

///|
fn assert_program_named_function_lookups(
  link : PlannedProgramWasmGCLink,
) -> Unit {
  match verify_program_named_function_lookups(link) {
    Ok(_) => ()
    Err(failure) => abort(@debug.to_string(failure))
  }
}
