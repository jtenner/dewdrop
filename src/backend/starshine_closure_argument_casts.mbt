///| Resolve the selected signature, then map logical arguments by their

///|
/// physical widths. Unit contributes an evaluation but no parameter.
fn starshine_closure_argument_casts(
  lowering : @semantic.PlannedModuleLowering,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  caller_index : Int,
  specialization : StarshineGenericSpecialization?,
  body : @semantic.BodyId,
  expression : @semantic.ExprId,
  arguments : @semantic.HirSpan,
  signature : Int,
) -> Result[Array[Array[@lib.Instruction]], StarshineCodeEmissionError] {
  let mut owner = caller
  let mut owner_index = caller_index
  let mut parameters : @semantic.HirSpan? = None
  match program {
    Some(link) =>
      for candidate in link.program_signature_types {
        if candidate.type_index == signature {
          owner_index = candidate.module_index
          owner = link.modules[owner_index]
          parameters = Some(
            match candidate.kind {
              @semantic.PlannedProgramFunctionType(index) =>
                owner.function_types[index].parameters
              @semantic.PlannedProgramFunctionSignature(index) =>
                owner.functions[index].parameters
            },
          )
          break
        }
      }
    None =>
      for candidate in caller.function_types {
        if candidate.signature_type_index == signature {
          parameters = Some(candidate.parameters)
          break
        }
      }
  }
  let parameters = match parameters {
    Some(value) => value
    None => return Err(UnsupportedExpression(body, expression))
  }
  let output : Array[Array[@lib.Instruction]] = []
  let mut physical = 0
  for index in 0..<arguments.length {
    let source = lowering.expressions[lowering.expression_children[arguments.start +
      index]]
    let shape = starshine_specialized_shape(
      lowering,
      specialization,
      source.type_,
      source.shape,
    )
    let width = starshine_shape_leaf_count(shape)
    if width > parameters.length - physical {
      return Err(UnsupportedExpression(body, expression))
    }
    let casts : Array[@lib.Instruction] = []
    for leaf in 0..<width {
      let value = owner.function_value_types[parameters.start + physical + leaf]
      let mut nullable = false
      let heap = match value {
        @semantic.WasmNominalRefValue(index) =>
          starshine_local_physical_type_index(program, owner_index, index)
        @semantic.WasmNullableNominalRefValue(index) => {
          nullable = true
          starshine_local_physical_type_index(program, owner_index, index)
        }
        @semantic.WasmExternalNominalRefValue(declaration)
        | @semantic.WasmNullableExternalNominalRefValue(declaration) => {
          nullable = value is @semantic.WasmNullableExternalNominalRefValue(_)
          match program {
            Some(link) =>
              match link.type_lookup.get(declaration) {
                Some(index) => index
                None => return Err(UnsupportedExpression(body, expression))
              }
            None => return Err(UnsupportedExpression(body, expression))
          }
        }
        @semantic.WasmFixedArrayRefValue(carrier) =>
          starshine_fixed_array_base_for_body(owner, program) + carrier
        @semantic.WasmFunctionRefValue(index) =>
          match program {
            Some(link) => link.signature_type_index(owner_index, index)
            None => index
          }
        _ => -1
      }
      if heap >= 0 {
        // Flattened product fields currently have erased reference ABIs.
        // Do not pretend a top-of-stack cast can narrow an earlier leaf.
        if width != 1 {
          return Err(UnsupportedExpression(body, expression))
        }
        casts.push(
          if nullable {
            starshine_nullable_match_cast(heap)
          } else {
            starshine_match_cast(heap)
          },
        )
      }
    }
    physical += width
    output.push(casts)
  }
  if physical != parameters.length {
    return Err(UnsupportedExpression(body, expression))
  }
  Ok(output)
}
