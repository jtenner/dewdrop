///|
fn verify_physical_local_reference(
  module_ : PlannedModuleWasmGCFragments,
  declaration : DeclId,
  index : Int,
  signature : Bool,
  slot : Int,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let count = module_.physical_types.length()
  let role = if signature { 51UL } else { 49UL }
  let limit = count.to_uint64() + (if signature { module_.signature_type_count.reinterpret_as_uint().to_uint64() } else { 0UL })
  guard index >= 0 && index.to_uint64() < limit else {
    return Err(physical_type_failure(module_.module_id, declaration, 101,
      limit, index.reinterpret_as_uint().to_uint64(), role, slot))
  }
  if index < count {
    let actual = module_.physical_types[index].kind is PlannedWasmTraitMethodSignatureType(_)
    guard actual == signature else {
      return Err(physical_type_failure(module_.module_id, declaration, 504,
        if signature { 1UL } else { 0UL }, if actual { 1UL } else { 0UL }, role, slot))
    }
  }
  Ok(())
}

///|
fn verify_module_physical_storage_references(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  guard module_.signature_type_count >= 0 else {
    return Err(physical_type_failure(module_.module_id, 0UL, 103,
      0UL, module_.signature_type_count.reinterpret_as_uint().to_uint64(), 54UL, 0))
  }
  // Structural preflight has checked every field and group span first.
  for type_ in module_.physical_types {
    let declaration = physical_type_declaration(type_.kind)
    for relative in 0..<type_.fields.length {
      let slot = type_.fields.start + relative
      let storage = module_.fields[slot].storage
      let checked = match storage {
        WasmNominalRefStorage(reference) | WasmNullableNominalRefStorage(reference) => {
          let local = match reference {
            WasmModuleTypeReference(index) => index
            WasmRecursiveTypeReference(index) => {
              let group = module_.type_groups[type_.group_index]
              guard index >= 0 && index < group.types.length else {
                return Err(physical_type_failure(module_.module_id, declaration, 101,
                  group.types.length.to_uint64(), index.reinterpret_as_uint().to_uint64(), 50UL, slot))
              }
              group.first_type_index + index
            }
          }
          verify_physical_local_reference(module_, declaration, local, false, slot)
        }
        WasmFunctionRefStorage(index) => verify_physical_local_reference(module_, declaration, index, true, slot)
        WasmFixedArrayRefStorage(carrier) => {
          guard carrier >= 0 && carrier < 8 else {
            return Err(physical_type_failure(module_.module_id, declaration, 101,
              8UL, carrier.reinterpret_as_uint().to_uint64(), 52UL, slot))
          }
          Ok(())
        }
        _ => Ok(())
      }
      match checked {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  Ok(())
}

///|
// This is an injective encoding of an emitted storage type, not a hash.
// Heap indices use all 32 low bits; the tag retains packing and nullability.
fn program_physical_storage_certificate(
  link : PlannedProgramWasmGCLink,
  owner : Int,
  declaration : DeclId,
  group_index : Int,
  slot : Int,
  storage : PlannedWasmStorageType,
) -> Result[UInt64, ProgramPhysicalTypeFailure] {
  let module_ = link.modules[owner]
  let nominal = fn(index : Int, nullable : Bool) {
    ((if nullable { 11UL } else { 10UL }) << 32) | index.reinterpret_as_uint().to_uint64()
  }
  let failure = fn(expected, actual, role) {
    physical_type_failure(module_.module_id, declaration, 503, expected, actual, role, slot)
  }
  match storage {
    WasmI8SignedStorage | WasmI8UnsignedStorage => Ok(1UL << 32)
    WasmI16SignedStorage | WasmI16UnsignedStorage => Ok(2UL << 32)
    WasmI32Storage => Ok(3UL << 32)
    WasmI64Storage => Ok(4UL << 32)
    WasmF32Storage => Ok(5UL << 32)
    WasmF64Storage => Ok(6UL << 32)
    WasmV128Storage => Ok(7UL << 32)
    WasmStringRefStorage | WasmNullableEqRefStorage => Ok(8UL << 32)
    WasmNullableFunctionRefStorage => Ok(9UL << 32)
    WasmFunctionRefStorage(local) => {
      match verify_physical_local_reference(module_, declaration, local, true, slot) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
      let index = link.signature_type_index(owner, local)
      guard index >= 0 && index < link.type_count else {
        return Err(failure(link.type_count.to_uint64(), index.reinterpret_as_uint().to_uint64(), 55UL))
      }
      Ok(nominal(index, true))
    }
    WasmNominalRefStorage(reference) | WasmNullableNominalRefStorage(reference) => {
      let local = match reference {
        WasmModuleTypeReference(index) => index
        WasmRecursiveTypeReference(index) => module_.type_groups[group_index].first_type_index + index
      }
      match verify_physical_local_reference(module_, declaration, local, false, slot) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
      Ok(nominal(link.module_type_indices[owner][local], storage is WasmNullableNominalRefStorage(_)))
    }
    WasmExternalNominalRefStorage(target) | WasmNullableExternalNominalRefStorage(target) => {
      let index = link.type_lookup.get(target).unwrap_or(-1)
      guard index >= 0 && index < link.type_count else {
        return Err(failure(target, index.reinterpret_as_uint().to_uint64(), 53UL))
      }
      Ok(nominal(index, storage is WasmNullableExternalNominalRefStorage(_)))
    }
    WasmFixedArrayRefStorage(carrier) => {
      guard carrier >= 0 && carrier < 8 else {
        return Err(physical_type_failure(module_.module_id, declaration, 101,
          8UL, carrier.reinterpret_as_uint().to_uint64(), 52UL, slot))
      }
      let base = link.fixed_array_type_base
      guard base >= 0 && base <= link.type_count && carrier < link.type_count - base else {
        return Err(failure(link.type_count.reinterpret_as_uint().to_uint64(), base.reinterpret_as_uint().to_uint64(), 56UL))
      }
      Ok(nominal(base + carrier, false))
    }
  }
}

///|
fn verify_program_physical_storage_references(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  for owner, module_ in link.modules {
    for type_ in module_.physical_types {
      for relative in 0..<type_.fields.length {
        let slot = type_.fields.start + relative
        match program_physical_storage_certificate(link, owner,
          physical_type_declaration(type_.kind), type_.group_index, slot, module_.fields[slot].storage) {
          Err(error) => return Err(error)
          Ok(_) => ()
        }
      }
    }
  }
  Ok(())
}
