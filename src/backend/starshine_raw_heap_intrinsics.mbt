///|
priv enum StarshineRawStructHeap {
  PrimitiveStructHeap(Int)
  DeclaredStructHeap(
    Int,
    @semantic.PlannedModuleWasmGCFragments,
    @semantic.PlannedWasmPhysicalType
  )
}

///|
fn starshine_raw_struct_heap(
  owner : @semantic.RawHeapOwner,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  opcode : Bytes,
) -> Result[StarshineRawStructHeap, StarshineCodeEmissionError] {
  match owner {
    @semantic.PrimitiveRawHeapOwner(primitive) => {
      let offset = match primitive {
        @semantic.StringType => 1
        @semantic.BytesType => 2
        @semantic.StringViewType => 3
        @semantic.StringBuilderType => 4
        @semantic.BytesBuilderType => 5
        _ =>
          return Err(
            InvalidHeapIntrinsic(opcode, "owner is not a struct reference"),
          )
      }
      Ok(
        PrimitiveStructHeap(
          starshine_text_runtime_base_for_body(caller, program) + offset,
        ),
      )
    }
    @semantic.DeclaredRawHeapOwner(declaration) => {
      let (module_, module_index) = match program {
        Some(link) => {
          let index = match
            link.module_lookup.get(@semantic.semantic_id_module(declaration)) {
            Some(index) => index
            None =>
              return Err(
                InvalidHeapIntrinsic(
                  opcode, "struct owner module is not linked",
                ),
              )
          }
          if index < 0 || index >= link.modules.length() {
            return Err(
              InvalidHeapIntrinsic(
                opcode, "struct owner module index is invalid",
              ),
            )
          }
          (link.modules[index], index)
        }
        None => {
          if @semantic.semantic_id_module(declaration) != caller.module_id {
            return Err(
              InvalidHeapIntrinsic(
                opcode, "external struct requires program linking",
              ),
            )
          }
          (caller, -1)
        }
      }
      let mut selected : @semantic.PlannedWasmPhysicalType? = None
      for type_ in module_.physical_types {
        if type_.kind is @semantic.PlannedWasmStructType(candidate) &&
          candidate == declaration {
          if selected is Some(_) {
            return Err(
              InvalidHeapIntrinsic(
                opcode, "struct owner has multiple physical layouts",
              ),
            )
          }
          selected = Some(type_)
        }
      }
      let type_ = match selected {
        Some(value) => value
        None =>
          return Err(
            InvalidHeapIntrinsic(opcode, "declared owner has no struct layout"),
          )
      }
      let index = match program {
        Some(link) => link.physical_type_index(module_index, type_.type_index)
        None => type_.type_index
      }
      if index < 0 {
        return Err(
          InvalidHeapIntrinsic(
            opcode, "struct physical type has no linked index",
          ),
        )
      }
      Ok(DeclaredStructHeap(index, module_, type_))
    }
    @semantic.InvalidRawHeapOwner(reason) =>
      Err(
        InvalidHeapIntrinsic(
          opcode,
          "invalid heap owner (1=parameters, 2=arena, 3=nonconcrete, 4=cycle): \{reason}",
        ),
      )
  }
}

///|
fn starshine_raw_heap_instructions(
  instruction : @semantic.RawHeapInstruction,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  match instruction {
    @semantic.RawStructGetInstruction(recipe) =>
      starshine_raw_struct_get_instructions(
        recipe, caller, program, types, parameters, results,
      )
    @semantic.RawRefCastInstruction(recipe) =>
      starshine_raw_ref_cast_instructions(
        recipe, caller, program, types, parameters, results,
      )
  }
}

///|
fn starshine_raw_ref_cast_instructions(
  recipe : @semantic.RawRefCastRecipe,
  caller : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  types : Array[@semantic.PlannedWasmValueType],
  parameters : @semantic.HirSpan,
  results : @semantic.HirSpan,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  if recipe.opcode != b"ref.cast" {
    return Err(
      InvalidHeapIntrinsic(
        recipe.opcode,
        "ref.cast takes its target from the declared result type",
      ),
    )
  }
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
        "ref.cast requires one operand and one result",
      ),
    )
  }
  for position in [parameters.start, results.start] {
    match types[position] {
      @semantic.WasmStringRefValue
      | @semantic.WasmNullableEqRefValue
      | @semantic.WasmNominalRefValue(_)
      | @semantic.WasmExternalNominalRefValue(_)
      | @semantic.WasmNullableNominalRefValue(_)
      | @semantic.WasmNullableExternalNominalRefValue(_)
      | @semantic.WasmFixedArrayRefValue(_) => ()
      _ =>
        return Err(
          InvalidHeapIntrinsic(
            recipe.opcode,
            "ref.cast requires reference carriers",
          ),
        )
    }
  }
  let heap = match
    starshine_raw_struct_heap(recipe.target, caller, program, recipe.opcode) {
    Ok(PrimitiveStructHeap(index)) | Ok(DeclaredStructHeap(index, _, _)) =>
      index
    Err(error) => return Err(error)
  }
  // The raw operation returns a non-null reference to this exact heap. Erased
  // eqref results accept it; nominal result signatures must retain its identity.
  let expected_heap = match types[results.start] {
    @semantic.WasmStringRefValue | @semantic.WasmNullableEqRefValue => None
    @semantic.WasmNominalRefValue(index)
    | @semantic.WasmNullableNominalRefValue(index) =>
      match program {
        Some(link) => {
          let module_index = match link.module_lookup.get(caller.module_id) {
            Some(value) => value
            None =>
              return Err(
                InvalidHeapIntrinsic(
                  recipe.opcode,
                  "result owner module is not linked",
                ),
              )
          }
          Some(link.physical_type_index(module_index, index))
        }
        None => Some(index)
      }
    @semantic.WasmExternalNominalRefValue(declaration)
    | @semantic.WasmNullableExternalNominalRefValue(declaration) =>
      match program {
        Some(link) =>
          match link.type_lookup.get(declaration) {
            Some(value) => Some(value)
            None =>
              return Err(
                InvalidHeapIntrinsic(
                  recipe.opcode,
                  "result declaration has no linked heap",
                ),
              )
          }
        None => None // Standalone signatures explicitly erase external references.
      }
    @semantic.WasmFixedArrayRefValue(_) =>
      return Err(
        InvalidHeapIntrinsic(
          recipe.opcode,
          "ref.cast target is not an array heap",
        ),
      )
    _ =>
      return Err(
        InvalidHeapIntrinsic(
          recipe.opcode,
          "ref.cast result has no reference carrier",
        ),
      )
  }
  if expected_heap is Some(expected) && expected != heap {
    return Err(
      InvalidHeapIntrinsic(
        recipe.opcode,
        "ref.cast result heap differs from its retained target",
      ),
    )
  }
  Ok([
    @lib.Instruction::ref_cast(
      false,
      @lib.HeapType::new(@lib.TypeIdx::new(heap.reinterpret_as_uint())),
    ),
  ])
}
