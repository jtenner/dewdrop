///|
pub struct ProgramPhysicalTypeFailure {
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
fn physical_type_declaration(kind : PlannedWasmPhysicalTypeKind) -> DeclId {
  match kind {
    PlannedWasmStructType(declaration)
    | PlannedWasmForeignMarkerType(declaration)
    | PlannedWasmEnumBaseType(declaration)
    | PlannedWasmTraitMethodSignatureType(declaration)
    | PlannedWasmTraitVTableType(declaration)
    | PlannedWasmTraitObjectType(declaration) => declaration
    PlannedWasmEnumSubtypeType(declaration, _, _) => declaration
    _ => 0UL
  }
}

///|
fn physical_type_failure(
  module_id : ModuleId,
  declaration : DeclId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  role : UInt64,
  slot : Int,
) -> ProgramPhysicalTypeFailure {
  {
    code, phase: 5, module_id, declaration, body: 0UL,
    expression: 0xffffffffU, expected, actual,
    detail: (role << 32) | slot.reinterpret_as_uint().to_uint64(),
  }
}

///|
fn verify_module_physical_type_fragments(
  module_ : PlannedModuleWasmGCFragments,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  match verify_module_function_lookups(module_) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let physical = module_.physical_types
  let groups = module_.type_groups
  let seen = Array::make(physical.length(), false)
  for slot, type_ in physical {
    let declaration = physical_type_declaration(type_.kind)
    let failure = fn(code, expected, actual, role, index) {
      physical_type_failure(module_.module_id, declaration, code, expected, actual, role, index)
    }
    guard type_.type_index == slot else {
      return Err(failure(502, slot.to_uint64(), type_.type_index.reinterpret_as_uint().to_uint64(), 4UL, slot))
    }
    guard type_.group_index >= 0 && type_.group_index < groups.length() else {
      return Err(failure(101, groups.length().to_uint64(), type_.group_index.reinterpret_as_uint().to_uint64(), 5UL, slot))
    }
    let fields = type_.fields
    guard fields.start >= 0 && fields.length >= 0 &&
      fields.start <= module_.fields.length() &&
      fields.length <= module_.fields.length() - fields.start else {
      return Err(failure(101, module_.fields.length().to_uint64(), program_function_span_code(fields), 6UL, slot))
    }
    for index in 0..<fields.length {
      let field = module_.fields[fields.start + index]
      guard field.physical_index == index else {
        return Err(failure(504, index.to_uint64(), field.physical_index.reinterpret_as_uint().to_uint64(), 7UL, fields.start + index))
      }
    }
  }
  for group_index, group in groups {
    let span = group.types
    guard span.start >= 0 && span.length >= 0 &&
      span.start <= physical.length() && span.length <= physical.length() - span.start else {
      return Err(physical_type_failure(module_.module_id, 0UL, 101,
        physical.length().to_uint64(), program_function_span_code(span), 8UL, group_index))
    }
    guard group.first_type_index == span.start else {
      return Err(physical_type_failure(module_.module_id, 0UL, 504,
        span.start.to_uint64(), group.first_type_index.reinterpret_as_uint().to_uint64(), 9UL, group_index))
    }
    for offset in 0..<span.length {
      let index = span.start + offset
      let type_ = physical[index]
      let declaration = physical_type_declaration(type_.kind)
      guard !seen[index] else {
        return Err(physical_type_failure(module_.module_id, declaration, 404, 1UL, 2UL, 11UL, index))
      }
      guard type_.group_index == group_index else {
        return Err(physical_type_failure(module_.module_id, declaration, 504,
          group_index.to_uint64(), type_.group_index.reinterpret_as_uint().to_uint64(), 10UL, index))
      }
      seen[index] = true
    }
  }
  for index, present in seen {
    guard present else {
      return Err(physical_type_failure(module_.module_id, physical_type_declaration(physical[index].kind),
        404, 1UL, 0UL, 11UL, index))
    }
  }
  verify_module_physical_storage_references(module_)
}

///|
pub fn verify_program_physical_type_fragments(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  for item in [(1UL, link.module_type_indices.length()), (2UL, link.module_signature_indices.length()), (3UL, link.module_type_bases.length())] {
    let (role, length) = item
    guard length == link.modules.length() else {
      return Err(physical_type_failure(0UL, 0UL, 103, link.modules.length().to_uint64(), length.to_uint64(), role, 0))
    }
  }
  for module_index, module_ in link.modules {
    match verify_module_physical_type_fragments(module_) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    let stored_owner = link.module_lookup.get(module_.module_id).unwrap_or(-1)
    guard stored_owner == module_index else {
      return Err(physical_type_failure(module_.module_id, 0UL, 504, module_index.to_uint64(), stored_owner.reinterpret_as_uint().to_uint64(), 27UL, module_index))
    }
    let indices = link.module_type_indices[module_index]
    guard indices.length() == module_.physical_types.length() else {
      return Err(physical_type_failure(module_.module_id, 0UL, 103,
        module_.physical_types.length().to_uint64(), indices.length().to_uint64(), 12UL, module_index))
    }
    guard link.module_signature_indices[module_index].length() == module_.signature_type_count else {
      return Err(physical_type_failure(module_.module_id, 0UL, 103,
        module_.signature_type_count.reinterpret_as_uint().to_uint64(), link.module_signature_indices[module_index].length().to_uint64(), 13UL, module_index))
    }
    for local_index, index in indices {
      guard index >= 0 && index < link.type_count else {
        return Err(physical_type_failure(module_.module_id, physical_type_declaration(module_.physical_types[local_index].kind), 503,
          link.type_count.reinterpret_as_uint().to_uint64(), index.reinterpret_as_uint().to_uint64(), 14UL, local_index))
      }
    }
  }
  if link.program_type_groups.is_empty() {
    guard link.program_physical_types.is_empty() else {
      return Err(physical_type_failure(0UL, 0UL, 404, 0UL, link.program_physical_types.length().to_uint64(), 15UL, 0))
    }
    for module_index, module_ in link.modules {
      let base = link.module_type_bases[module_index]
      guard base >= 0 && base <= link.type_count else {
        return Err(physical_type_failure(module_.module_id, 0UL, 503,
          link.type_count.reinterpret_as_uint().to_uint64(), base.reinterpret_as_uint().to_uint64(), 16UL, module_index))
      }
      for local_index, actual in link.module_type_indices[module_index] {
        // Use wide arithmetic for the diagnostic too; a corrupt base must
        // never overflow the host's signed physical index representation.
        let expected = base.to_uint64() + local_index.to_uint64()
        guard actual.to_uint64() == expected else {
          return Err(physical_type_failure(module_.module_id, physical_type_declaration(module_.physical_types[local_index].kind),
            504, expected, actual.to_uint64(), 17UL, local_index))
        }
      }
    }
  } else {
    let nodes = link.program_physical_types
    let seen = Array::make(nodes.length(), false)
    let mut next = 0
    for group_index, group in link.program_type_groups {
      let span = group.types
      guard span.start >= 0 && span.length >= 0 && span.start <= nodes.length() &&
        span.length <= nodes.length() - span.start else {
        return Err(physical_type_failure(0UL, 0UL, 101, nodes.length().to_uint64(), program_function_span_code(span), 18UL, group_index))
      }
      guard group.first_type_index == span.start else {
        return Err(physical_type_failure(0UL, 0UL, 504, span.start.to_uint64(), group.first_type_index.reinterpret_as_uint().to_uint64(), 19UL, group_index))
      }
      guard span.start == next else {
        return Err(physical_type_failure(0UL, 0UL, 504, next.to_uint64(), span.start.to_uint64(), 26UL, group_index))
      }
      guard span.length > 0 else {
        return Err(physical_type_failure(0UL, 0UL, 404, 1UL, 0UL, 20UL, group_index))
      }
      next += span.length
      for offset in 0..<span.length {
        let slot = span.start + offset
        guard !seen[slot] else {
          return Err(physical_type_failure(0UL, 0UL, 404, 1UL, 2UL, 20UL, slot))
        }
        seen[slot] = true
      }
    }
    for slot, node in nodes {
      guard seen[slot] else {
        return Err(physical_type_failure(0UL, 0UL, 404, 1UL, 0UL, 20UL, slot))
      }
      guard node.module_index >= 0 && node.module_index < link.modules.length() else {
        return Err(physical_type_failure(0UL, 0UL, 101, link.modules.length().to_uint64(), node.module_index.reinterpret_as_uint().to_uint64(), 21UL, slot))
      }
      let module_ = link.modules[node.module_index]
      guard node.fragment_index >= 0 && node.fragment_index < module_.physical_types.length() else {
        return Err(physical_type_failure(module_.module_id, 0UL, 101, module_.physical_types.length().to_uint64(), node.fragment_index.reinterpret_as_uint().to_uint64(), 22UL, slot))
      }
      let type_ = module_.physical_types[node.fragment_index]
      let actual = link.module_type_indices[node.module_index][node.fragment_index]
      guard actual == slot else {
        return Err(physical_type_failure(module_.module_id, physical_type_declaration(type_.kind), 504, slot.to_uint64(), actual.to_uint64(), 23UL, slot))
      }
    }
    for module_index, module_ in link.modules {
      for local_index, actual in link.module_type_indices[module_index] {
        let type_ = module_.physical_types[local_index]
        guard actual < nodes.length() else {
          return Err(physical_type_failure(module_.module_id, physical_type_declaration(type_.kind), 503, nodes.length().to_uint64(), actual.to_uint64(), 24UL, local_index))
        }
        let target = nodes[actual]
        if target.module_index == module_index && target.fragment_index == local_index {
          continue
        }
        // Only these generated physical families are canonicalized across
        // modules. An ordinary nominal type cannot acquire an alias target.
        let canonical = link.modules[target.module_index].physical_types[target.fragment_index]
        let shared = match type_.kind {
          PlannedWasmClosureType | PlannedWasmTraitMethodSignatureType(_)
          | PlannedWasmTraitVTableType(_) | PlannedWasmTraitObjectType(_) => true
          _ => false
        }
        guard shared && type_.kind == canonical.kind else {
          return Err(physical_type_failure(module_.module_id, physical_type_declaration(type_.kind), 504,
            1UL, 0UL, 25UL, local_index))
        }
      }
    }
  }
  for module_index, module_ in link.modules {
    for local_index, type_ in module_.physical_types {
      match type_.kind {
        PlannedWasmStructType(declaration) | PlannedWasmForeignMarkerType(declaration)
        | PlannedWasmEnumBaseType(declaration) => {
          let index = link.module_type_indices[module_index][local_index]
          let selected = link.type_lookup.get(declaration).unwrap_or(-1)
          guard selected == index else {
            return Err(physical_type_failure(module_.module_id, declaration, 504, index.to_uint64(), selected.reinterpret_as_uint().to_uint64(), 28UL, local_index))
          }
        }
        _ => ()
      }
    }
  }
  for declaration, actual in link.type_lookup {
    let owner_id = semantic_id_module(declaration)
    let owner = link.module_lookup.get(owner_id).unwrap_or(-1)
    guard owner >= 0 && owner < link.modules.length() else {
      return Err(physical_type_failure(owner_id, declaration, 101, link.modules.length().to_uint64(), owner.reinterpret_as_uint().to_uint64(), 46UL, 0))
    }
    let module_ = link.modules[owner]
    guard module_.module_id == owner_id else {
      return Err(physical_type_failure(owner_id, declaration, 504, owner_id, module_.module_id, 46UL, owner))
    }
    let local = module_.type_index_of(declaration).unwrap_or(-1)
    guard local >= 0 && local < module_.physical_types.length() else {
      return Err(physical_type_failure(owner_id, declaration, 101, module_.physical_types.length().to_uint64(), local.reinterpret_as_uint().to_uint64(), 47UL, 0))
    }
    let expected = link.module_type_indices[owner][local]
    guard actual == expected else {
      return Err(physical_type_failure(owner_id, declaration, 504, expected.to_uint64(), actual.reinterpret_as_uint().to_uint64(), 48UL, local))
    }
  }
  match verify_program_physical_signatures(link) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match verify_program_physical_type_schedule(link) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match verify_program_physical_storage_references(link) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  match verify_program_physical_field_aliases(link) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  verify_program_physical_signature_aliases(link)
}

///|
fn assert_program_physical_type_fragments(link : PlannedProgramWasmGCLink) -> Unit {
  match verify_program_physical_type_fragments(link) {
    Ok(_) => ()
    Err(error) => abort(@debug.to_string(error))
  }
}
