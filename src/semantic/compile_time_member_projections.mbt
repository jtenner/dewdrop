///|
fn reduce_compile_time_projections(
  context : CompileTimeProgramContext,
  adapter : PlannedModuleLowering,
  type_ : CompileTimeType,
  depth : Int,
) -> Result[CompileTimeType, String] {
  if depth >= 256 {
    return Err("CT-034 member projection limit exceeded")
  }
  match type_ {
    CtMemberProjection(owner, operation, selector) => {
      if !computed_type_builtin(operation) {
        return Err("CT-033 invalid member projection operation")
      }
      let owner = match
        reduce_compile_time_projections(context, adapter, owner, depth + 1) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      match compile_time_types_are_concrete([owner]) {
        Ok(false) => return Ok(CtMemberProjection(owner, operation, selector))
        Err(_) => return Err("CT-033 invalid member projection owner")
        Ok(true) => ()
      }
      let (declaration, arguments) = match owner {
        CtNominal(id) => (id, [])
        CtApplied(CtNominal(id), arguments) => (id, arguments)
        _ => return Err("CT-032 member type query requires a struct or enum")
      }
      for index, collected in context.program.modules {
        if collected.module_id != semantic_id_module(declaration) {
          continue
        }
        let resolved = context.analyzed.frozen.interfaces[index].resolved_types
        let reading = {
          ..adapter,
          resolved_types: resolved.types,
          resolved_type_arguments: resolved.type_arguments,
        }
        let generics = collected.generic_parameters_of(declaration)
        if generics.length != arguments.length() {
          return Err("CT-031 member owner has the wrong generic arity")
        }
        let bindings : Map[CompileTimeBindingKey, CompileTimeType] = {}
        for offset in 0..<generics.length {
          bindings[CtGenericBinding(
            collected.generic_parameters[generics.start + offset].id,
          )] = arguments[offset]
        }
        let field_query = operation == b"types.field_type"
        let kind = match collected.declaration(declaration) {
          Some(TopLevelReference(value)) => value.kind
          _ => return Err("CT-032 invalid member type owner")
        }
        if (field_query && kind != StructDecl) ||
          (!field_query && kind != EnumDecl) {
          return Err(
            "CT-032 field_type requires a struct; variant_payload_types requires an enum",
          )
        }
        let syntax : Array[HirTypeId] = []
        let mut found = false
        if field_query {
          for field in collected.fields {
            if field.declaration == declaration &&
              field.variant is None &&
              collected.name(field.name) == selector {
              syntax.push(field.type_)
              found = true
              break
            }
          }
        } else {
          for variant in collected.variants {
            if variant.declaration != declaration ||
              collected.name(variant.name) != selector {
              continue
            }
            found = true
            if variant.kind == StructVariantDecl {
              for field in collected.fields {
                if field.variant == Some(variant.id) {
                  syntax.push(field.type_)
                }
              }
            } else {
              for offset in 0..<variant.payload_types.length {
                syntax.push(
                  collected.type_arguments[variant.payload_types.start + offset],
                )
              }
            }
            break
          }
        }
        if !found {
          return Err("CT-032 no such member: " + selector)
        }
        let values = []
        for source in syntax {
          let logical = match
            compile_time_read_type(
              reading,
              -resolved.syntax_types[source] - 2,
              bindings,
            ) {
            Ok(value) => value
            Err(_) => return Err("CT-033 invalid member type dependency")
          }
          match
            reduce_compile_time_projections(
              context,
              reading,
              logical,
              depth + 1,
            ) {
            Ok(value) => values.push(value)
            Err(error) => return Err(error)
          }
        }
        return Ok(if field_query { values[0] } else { CtProduct(values) })
      }
      Err("CT-032 missing member type owner module")
    }
    CtProduct(fields) | CtApplied(_, fields) | CtFunction(fields, _) => {
      let values = []
      for field in fields {
        match
          reduce_compile_time_projections(context, adapter, field, depth + 1) {
          Ok(value) => values.push(value)
          Err(error) => return Err(error)
        }
      }
      match type_ {
        CtApplied(base, _) =>
          match
            reduce_compile_time_projections(context, adapter, base, depth + 1) {
            Ok(base) => Ok(CtApplied(base, values))
            Err(error) => Err(error)
          }
        CtFunction(_, result) =>
          match
            reduce_compile_time_projections(context, adapter, result, depth + 1) {
            Ok(result) => Ok(CtFunction(values, result))
            Err(error) => Err(error)
          }
        _ => Ok(CtProduct(values))
      }
    }
    _ => Ok(type_)
  }
}
