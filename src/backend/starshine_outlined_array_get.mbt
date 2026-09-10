///|
fn starshine_outlined_array_get(
  recipe : @semantic.RawArrayGetRecipe,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
  declaration : @semantic.DeclId,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let failure = fn(code, expected, actual, detail) {
    CompilerInvariantFailure({
      code,
      phase: 7U,
      module_id: caller.module_id,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected,
      actual,
      detail,
    })
  }
  guard recipe.opcode == b"array.get" || recipe.opcode == b"array_get" else {
    return Err(failure(714U, 2UL, 0xffffffffUL, 0UL))
  }
  let carrier = @semantic.wasmgc_raw_array_storage_carrier(recipe.element_shape)
  guard carrier >= 0 else { return Err(failure(301U, 1UL, 0UL, 0UL)) }
  for span in [parameters, results] {
    guard span.start >= 0 &&
      span.start <= types.length() &&
      span.length >= 0 &&
      span.length <= types.length() - span.start else {
      return Err(
        failure(
          101U,
          types.length().to_uint64(),
          span.length.reinterpret_as_uint().to_uint64(),
          span.start.reinterpret_as_uint().to_uint64(),
        ),
      )
    }
  }
  guard parameters.length == 2 else {
    return Err(failure(703U, 2UL, parameters.length.to_uint64(), 0UL))
  }
  guard types[parameters.start]
    is @semantic.WasmFixedArrayRefValue(actual_carrier) &&
    actual_carrier == carrier else {
    let actual = match types[parameters.start] {
      @semantic.WasmFixedArrayRefValue(value) =>
        value.reinterpret_as_uint().to_uint64()
      _ => 0xffffffffUL
    }
    return Err(failure(706U, carrier.to_uint64(), actual, 0UL))
  }
  guard types[parameters.start + 1] is @semantic.WasmI32Value else {
    return Err(
      failure(
        705U,
        4UL,
        (starshine_program_adapter_value_code(types[parameters.start + 1]) + 4).to_uint64(),
        1UL,
      ),
    )
  }
  let leaves : Array[@semantic.PlannedValueShape] = []
  starshine_product_leaf_shapes(recipe.element_shape, leaves)
  guard results.length == leaves.length() else {
    return Err(
      failure(
        709U,
        leaves.length().to_uint64(),
        results.length.to_uint64(),
        0UL,
      ),
    )
  }
  for index, shape in leaves {
    guard starshine_raw_array_result_value_matches(
      shape,
      types[results.start + index],
    ) else {
      return Err(
        failure(
          709U,
          (starshine_program_adapter_shape_code(shape) + 4).to_uint64(),
          (starshine_program_adapter_value_code(types[results.start + index]) +
          4).to_uint64(),
          index.to_uint64(),
        ),
      )
    }
  }
  let type_index = starshine_fixed_array_base_for_body(caller, program) +
    carrier
  let type_ = @lib.TypeIdx::new(type_index.reinterpret_as_uint())
  let output = [starshine_array_local_get(0), starshine_array_local_get(1)]
  output.push(
    match recipe.element_shape {
      @semantic.I8PlannedValueShape | @semantic.I16PlannedValueShape =>
        @lib.Instruction::array_get_s(type_)
      @semantic.U8PlannedValueShape | @semantic.U16PlannedValueShape =>
        @lib.Instruction::array_get_u(type_)
      _ => @lib.Instruction::array_get(type_)
    },
  )
  let locals : Array[@lib.ValType] = []
  match recipe.element_shape {
    @semantic.UnitPlannedValueShape => output.push(@lib.Instruction::drop())
    @semantic.ProductPlannedValueShape(_) => {
      locals.push(@lib.ValType::eqref_null())
      output.push(starshine_array_local_set(2))
      match
        starshine_append_product_unbox(
          output,
          caller,
          program,
          0UL,
          2,
          recipe.element_shape,
        ) {
        Ok(_) => ()
        Err(error) => return Err(error)
      }
    }
    _ => ()
  }
  Ok(@lib.Func::new(@lib.Locals::from_types(locals), @lib.Expr::new(output)))
}

///|
fn starshine_raw_array_result_value_matches(
  shape : @semantic.PlannedValueShape,
  value : @semantic.PlannedWasmValueType,
) -> Bool {
  match (shape, value) {
    (
      @semantic.I8PlannedValueShape
      | @semantic.U8PlannedValueShape
      | @semantic.I16PlannedValueShape
      | @semantic.U16PlannedValueShape
      | @semantic.I32PlannedValueShape
      | @semantic.U32PlannedValueShape
      | @semantic.Swar32PlannedValueShape,
      @semantic.WasmI32Value,
    ) => true
    (
      @semantic.I64PlannedValueShape
      | @semantic.U64PlannedValueShape
      | @semantic.Swar64PlannedValueShape,
      @semantic.WasmI64Value,
    ) => true
    (@semantic.F32PlannedValueShape, @semantic.WasmF32Value) => true
    (@semantic.F64PlannedValueShape, @semantic.WasmF64Value) => true
    (@semantic.V128PlannedValueShape, @semantic.WasmV128Value) => true
    (
      @semantic.RefPlannedValueShape,
      @semantic.WasmNullableEqRefValue
      | @semantic.WasmStringRefValue,
    ) => true
    _ => false
  }
}
