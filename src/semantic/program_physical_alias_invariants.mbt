///|
fn physical_value_storage(value : PlannedWasmValueType) -> PlannedWasmStorageType {
  match value {
    WasmI32Value => WasmI32Storage
    WasmI64Value => WasmI64Storage
    WasmF32Value => WasmF32Storage
    WasmF64Value => WasmF64Storage
    WasmV128Value => WasmV128Storage
    WasmStringRefValue => WasmStringRefStorage
    WasmNullableEqRefValue => WasmNullableEqRefStorage
    WasmFunctionRefValue(index) => WasmFunctionRefStorage(index)
    WasmNominalRefValue(index) => WasmNominalRefStorage(WasmModuleTypeReference(index))
    WasmNullableNominalRefValue(index) => WasmNullableNominalRefStorage(WasmModuleTypeReference(index))
    WasmExternalNominalRefValue(declaration) => WasmExternalNominalRefStorage(declaration)
    WasmNullableExternalNominalRefValue(declaration) => WasmNullableExternalNominalRefStorage(declaration)
    WasmFixedArrayRefValue(carrier) => WasmFixedArrayRefStorage(carrier)
  }
}

///|
fn physical_signature_span_certificate(
  link : PlannedProgramWasmGCLink,
  owner : Int,
  declaration : DeclId,
  span : HirSpan,
  role : UInt64,
) -> Result[Array[UInt64], ProgramPhysicalTypeFailure] {
  let module_ = link.modules[owner]
  let values = module_.function_value_types
  guard span.start >= 0 && span.length >= 0 && span.start <= values.length() &&
    span.length <= values.length() - span.start else {
    return Err(physical_type_failure(module_.module_id, declaration, 101,
      values.length().to_uint64(), program_function_span_code(span), role, 0))
  }
  let result : Array[UInt64] = []
  for relative in 0..<span.length {
    let slot = span.start + relative
    match program_physical_storage_certificate(link, owner, declaration, -1, slot, physical_value_storage(values[slot])) {
      Err(error) => return Err(error)
      Ok(value) => result.push(value)
    }
  }
  Ok(result)
}

///|
fn verify_program_physical_signature_aliases(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let canonical : Map[Int, (Array[UInt64], Array[UInt64])] = {}
  let record = fn(owner : Int, declaration : DeclId, index : Int, parameters : HirSpan, results : HirSpan) -> Result[Unit, ProgramPhysicalTypeFailure] {
    let params = match physical_signature_span_certificate(link, owner, declaration, parameters, 57UL) {
      Err(error) => return Err(error)
      Ok(value) => value
    }
    let returns = match physical_signature_span_certificate(link, owner, declaration, results, 58UL) {
      Err(error) => return Err(error)
      Ok(value) => value
    }
    canonical[index] = (params, returns)
    Ok(())
  }
  // Include function types that live inside the physical recursive groups.
  for owner, module_ in link.modules {
    for type_ in module_.physical_types {
      let requirement = match type_.kind {
        PlannedWasmTraitMethodSignatureType(value) => value
        _ => continue
      }
      let index = link.module_type_indices[owner][type_.type_index]
      if canonical.contains(index) { continue }
      let source = match module_.function_of(requirement) {
        Some(value) if value.declaration == requirement => value
        _ => return Err(physical_type_failure(module_.module_id, requirement, 503, requirement, 0UL, 63UL, type_.type_index))
      }
      match record(owner, requirement, index, source.parameters, source.results) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  for signature in link.program_signature_types {
    let module_ = link.modules[signature.module_index]
    let (declaration, parameters, results) = match signature.kind {
      PlannedProgramFunctionType(index) => {
        let source = module_.function_types[index]
        (0UL, source.parameters, source.results)
      }
      PlannedProgramFunctionSignature(index) => {
        let source = module_.functions[index]
        (source.declaration, source.parameters, source.results)
      }
    }
    match record(signature.module_index, declaration, signature.type_index, parameters, results) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  let check = fn(owner : Int, declaration : DeclId, local : Int, parameters : HirSpan, results : HirSpan) -> Result[Unit, ProgramPhysicalTypeFailure] {
    match verify_physical_local_reference(link.modules[owner], declaration, local, true, local) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    let index = link.signature_type_index(owner, local)
    let expected = match canonical.get(index) {
      Some(value) => value
      None => return Err(physical_type_failure(link.modules[owner].module_id, declaration, 503,
        1UL, index.reinterpret_as_uint().to_uint64(), 63UL, local))
    }
    for entry in [(expected.0, parameters, 57UL, 59UL, 61UL), (expected.1, results, 58UL, 60UL, 62UL)] {
      let (wanted, span, span_role, count_role, value_role) = entry
      let actual = match physical_signature_span_certificate(link, owner, declaration, span, span_role) {
        Err(error) => return Err(error)
        Ok(value) => value
      }
      guard actual.length() == wanted.length() else {
        return Err(physical_type_failure(link.modules[owner].module_id, declaration, 504,
          wanted.length().to_uint64(), actual.length().to_uint64(), count_role, local))
      }
      for relative, value in actual {
        guard value == wanted[relative] else {
          return Err(physical_type_failure(link.modules[owner].module_id, declaration, 504,
            wanted[relative], value, value_role, span.start + relative))
        }
      }
    }
    Ok(())
  }
  for owner, module_ in link.modules {
    for source in module_.function_types {
      match check(owner, 0UL, source.signature_type_index, source.parameters, source.results) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
    for source in module_.functions {
      // Elided logical declarations have no physical signature to certify.
      if source.signature_type_index == -1 { continue }
      match check(owner, source.declaration, source.signature_type_index, source.parameters, source.results) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  Ok(())
}

///|
fn verify_program_physical_field_aliases(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  if link.program_type_groups.is_empty() { return Ok(()) }
  for owner, module_ in link.modules {
    for local, type_ in module_.physical_types {
      let target = link.program_physical_types[link.module_type_indices[owner][local] - program_physical_nominal_type_base(link)]
      if target.module_index == owner && target.fragment_index == local { continue }
      let canonical_module = link.modules[target.module_index]
      let canonical = canonical_module.physical_types[target.fragment_index]
      let declaration = physical_type_declaration(type_.kind)
      let failure = fn(expected, actual, role, slot) {
        physical_type_failure(module_.module_id, declaration, 504, expected, actual, role, slot)
      }
      guard canonical.fields.length == type_.fields.length else {
        return Err(failure(canonical.fields.length.to_uint64(), type_.fields.length.to_uint64(), 66UL, local))
      }
      for relative in 0..<type_.fields.length {
        let slot = type_.fields.start + relative
        let field = module_.fields[slot]
        let wanted_slot = canonical.fields.start + relative
        let wanted = canonical_module.fields[wanted_slot]
        guard field.role == wanted.role else {
          return Err(failure(1UL, 0UL, 67UL, slot))
        }
        guard field.mutable_ == wanted.mutable_ else {
          return Err(failure(if wanted.mutable_ { 1UL } else { 0UL }, if field.mutable_ { 1UL } else { 0UL }, 64UL, slot))
        }
        let actual = match program_physical_storage_certificate(link, owner, declaration, type_.group_index, slot, field.storage) {
          Err(error) => return Err(error)
          Ok(value) => value
        }
        let expected = match program_physical_storage_certificate(link, target.module_index, declaration, canonical.group_index, wanted_slot, wanted.storage) {
          Err(error) => return Err(error)
          Ok(value) => value
        }
        guard actual == expected else { return Err(failure(expected, actual, 65UL, slot)) }
      }
    }
  }
  Ok(())
}
