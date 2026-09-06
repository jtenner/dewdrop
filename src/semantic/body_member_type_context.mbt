///|
pub struct BodyMemberTypeDeclaration {
  parameters : Array[GenericParameterId]
  fields : Map[String, ResolvedTypeId]
  variants : Map[String, Array[ResolvedTypeId]]
}

///|
pub struct BodyMemberTypeContext {
  declarations : Map[DeclId, BodyMemberTypeDeclaration]
}

///|
fn body_member_type_context(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
) -> BodyMemberTypeContext? {
  if !resolved.types.any(type_ => type_ is MemberTypeProjection(_, _, _)) {
    return None
  }
  let declarations : Map[DeclId, BodyMemberTypeDeclaration] = {}
  for declaration in collected.declarations {
    if declaration.kind != StructDecl && declaration.kind != EnumDecl {
      continue
    }
    let parameters = []
    let span = collected.generic_parameters_of(declaration.id)
    for offset in 0..<span.length {
      parameters.push(collected.generic_parameters[span.start + offset].id)
    }
    declarations[declaration.id] = { parameters, fields: {}, variants: {}, }
  }
  for index, field in collected.fields {
    if field.variant is None {
      if declarations.get(field.declaration) is Some(owner) {
        owner.fields[collected.name(field.name)] = resolved.field_types[index]
      }
    }
  }
  for index, variant in collected.variants {
    if declarations.get(variant.declaration) is Some(owner) {
      let payload = []
      if variant.kind == StructVariantDecl {
        for field_index, field in collected.fields {
          if field.variant == Some(variant.id) {
            payload.push(resolved.field_types[field_index])
          }
        }
      } else {
        let span = resolved.variant_payloads[index]
        guard program_specialization_span_is_valid(
          span,
          resolved.signature_type_lists.length(),
        ) else {
          abort("ARN-101 member projection payload recipe")
        }
        for offset in 0..<span.length {
          payload.push(resolved.signature_type_lists[span.start + offset])
        }
      }
      owner.variants[collected.name(variant.name)] = payload
    }
  }
  if imports is Some(imports) {
    for declaration, _ in imports.type_declaration_types {
      let binding = match imports.scope.declaration_bindings.get(declaration) {
        Some(index) => imports.scope.declarations[index]
        None => continue
      }
      if binding.source_kind != StructDecl && binding.source_kind != EnumDecl {
        continue
      }
      let parameters = []
      for offset in 0..<binding.generic_parameters.length {
        parameters.push(
          make_semantic_id(
            semantic_id_module(declaration),
            binding.generic_parameters.start + offset,
          ),
        )
      }
      declarations[declaration] = { parameters, fields: {}, variants: {}, }
    }
    for field in imports.fields {
      if field.variant is None {
        if declarations.get(field.declaration) is Some(owner) {
          owner.fields[field.name] = field.type_
        }
      }
    }
    for variant in imports.variants {
      if declarations.get(variant.declaration) is Some(owner) {
        let payload = []
        if variant.kind == StructVariantDecl {
          for field in imports.fields {
            if field.variant == Some(variant.variant) {
              payload.push(field.type_)
            }
          }
        } else {
          let span = variant.payload_types
          guard program_specialization_span_is_valid(
            span,
            imports.variant_payload_types.length(),
          ) else {
            abort("ARN-101 imported member projection payload recipe")
          }
          for offset in 0..<span.length {
            payload.push(imports.variant_payload_types[span.start + offset])
          }
        }
        owner.variants[variant.name] = payload
      }
    }
  }
  Some({ declarations, })
}
