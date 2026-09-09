///|
priv enum StarshineRawStructScalar {
  RawStructI32
  RawStructI64
  RawStructF32
  RawStructF64
  RawStructV128
}

///|
fn starshine_raw_struct_get_layout(
  recipe : @semantic.RawStructGetRecipe,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
) -> Result[(Int, StarshineRawStructScalar), StarshineCodeEmissionError] {
  if @semantic.raw_struct_get_field(recipe.opcode) != Some(recipe.field_index) ||
    recipe.field_index < 0 {
    return Err(InvalidHeapIntrinsic(recipe.opcode, "invalid struct.get field immediate"))
  }
  let heap = match starshine_raw_struct_heap(recipe.owner, caller, program, recipe.opcode) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match heap {
    PrimitiveStructHeap(index) => {
      if recipe.field_index >= 3 {
        return Err(InvalidHeapIntrinsic(recipe.opcode, "field is outside the primitive struct"))
      }
      if recipe.field_index == 0 {
        return Err(InvalidHeapIntrinsic(recipe.opcode, "reference fields require a complete heap result contract"))
      }
      Ok((index, RawStructI32))
    }
    DeclaredStructHeap(index, owner, type_) => {
      let fields = type_.fields
      if fields.start < 0 || fields.start > owner.fields.length() ||
        fields.length < 0 || fields.length > owner.fields.length() - fields.start ||
        recipe.field_index >= fields.length {
        return Err(InvalidHeapIntrinsic(recipe.opcode, "field is outside the declared struct"))
      }
      let field = owner.fields[fields.start + recipe.field_index]
      if field.physical_index != recipe.field_index {
        return Err(InvalidHeapIntrinsic(recipe.opcode, "stored struct field identity is inconsistent"))
      }
      let scalar = match field.storage {
        @semantic.WasmI32Storage => RawStructI32
        @semantic.WasmI64Storage => RawStructI64
        @semantic.WasmF32Storage => RawStructF32
        @semantic.WasmF64Storage => RawStructF64
        @semantic.WasmV128Storage => RawStructV128
        _ => return Err(InvalidHeapIntrinsic(recipe.opcode, "struct.get currently requires unpacked scalar field storage"))
      }
      Ok((index, scalar))
    }
  }
}

///|
fn starshine_raw_struct_get_instructions(
  recipe : @semantic.RawStructGetRecipe,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  if parameters.start < 0 ||
    parameters.start > types.length() ||
    parameters.length != 1 ||
    parameters.length > types.length() - parameters.start ||
    results.start < 0 ||
    results.start > types.length() ||
    results.length != 1 ||
    results.length > types.length() - results.start {
    return Err(
      InvalidHeapIntrinsic(
        recipe.opcode,
        "struct.get requires one operand and one result",
      ),
    )
  }
  match types[parameters.start] {
    @semantic.WasmStringRefValue
    | @semantic.WasmNullableEqRefValue
    | @semantic.WasmNominalRefValue(_)
    | @semantic.WasmExternalNominalRefValue(_)
    | @semantic.WasmNullableNominalRefValue(_)
    | @semantic.WasmNullableExternalNominalRefValue(_) => ()
    _ =>
      return Err(
        InvalidHeapIntrinsic(
          recipe.opcode,
          "struct.get operand has no reference carrier",
        ),
      )
  }
  let (type_index, storage) = match
    starshine_raw_struct_get_layout(recipe, caller, program) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let matches = match (storage, types[results.start]) {
    (RawStructI32, @semantic.WasmI32Value)
    | (RawStructI64, @semantic.WasmI64Value)
    | (RawStructF32, @semantic.WasmF32Value)
    | (RawStructF64, @semantic.WasmF64Value)
    | (RawStructV128, @semantic.WasmV128Value) => true
    _ => false
  }
  if !matches {
    return Err(
      InvalidHeapIntrinsic(
        recipe.opcode,
        "struct.get result carrier does not match its field",
      ),
    )
  }
  let type_ = @lib.TypeIdx::new(type_index.reinterpret_as_uint())
  // Explicit representation adapter from the Dew reference ABI to the exact
  // selected heap. The raw instruction itself is exactly struct.get.
  Ok([
    @lib.Instruction::ref_cast(false, @lib.HeapType::new(type_)),
    @lib.Instruction::struct_get(
      type_,
      @lib.U32::new(recipe.field_index.reinterpret_as_uint()),
    ),
  ])
}

///|
fn starshine_outlined_heap_instruction(
  recipe : @semantic.RawHeapInstruction,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let operation = match
    starshine_raw_heap_instructions(
      recipe, caller, program, types, parameters, results,
    ) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let instructions = [@lib.Instruction::local_get(@lib.LocalIdx::new(0U))]
  append_starshine_instructions(instructions, operation)
  Ok(@lib.Func::new(@lib.Locals::empty(), @lib.Expr::new(instructions)))
}
