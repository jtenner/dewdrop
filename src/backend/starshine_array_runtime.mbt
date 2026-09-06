///|
fn starshine_array_local_get(index : Int) -> @lib.Instruction {
  @lib.Instruction::local_get(@lib.LocalIdx::new(index.reinterpret_as_uint()))
}

///|
fn starshine_array_local_set(index : Int) -> @lib.Instruction {
  @lib.Instruction::local_set(@lib.LocalIdx::new(index.reinterpret_as_uint()))
}

///|
fn starshine_array_storage_carrier(shape : @semantic.PlannedValueShape) -> Int {
  match shape {
    // Unit has a logical array element but no operand. Its storage slot is a
    // null marker; this does not turn Unit into an expression carrier.
    @semantic.UnitPlannedValueShape => 5
    _ => starshine_value_carrier(shape)
  }
}

///|
fn starshine_array_storage_value_type(
  shape : @semantic.PlannedValueShape,
) -> @lib.ValType? {
  match shape {
    @semantic.UnitPlannedValueShape | @semantic.ProductPlannedValueShape(_) =>
      Some(@lib.ValType::eqref_null())
    _ => starshine_shape_value_type(shape)
  }
}

///|
fn starshine_array_append_unit_marker(
  output : Array[@lib.Instruction],
  shape : @semantic.PlannedValueShape?,
) -> Unit {
  if shape is Some(@semantic.UnitPlannedValueShape) {
    output.push(
      @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
    )
  }
}

///|
fn starshine_array_shape_uses_reference_storage(
  shape : @semantic.PlannedValueShape,
) -> Bool {
  match shape {
    @semantic.UnitPlannedValueShape
    | @semantic.RefPlannedValueShape
    | @semantic.GenericPlannedValueShape
    | @semantic.ProductPlannedValueShape(_) => true
    _ => false
  }
}

///|
fn starshine_array_append_option(
  output : Array[@lib.Instruction],
  _planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  shape : @semantic.PlannedValueShape,
  present : Bool,
  value : Array[@lib.Instruction],
) -> Result[Unit, StarshineCodeEmissionError] {
  let link = match program {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, -405))
  }
  let option_module = @semantic.semantic_id_module(
    @semantic.standard_option_some_variant(),
  )
  let option_module_index = match link.module_lookup.get(option_module) {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, -405))
  }
  let option_plan = link.modules[option_module_index]
  let variant = if present {
    @semantic.standard_option_some_variant()
  } else {
    @semantic.standard_option_none_variant()
  }
  let selected_physical = if present {
    starshine_variant_payload_physical_type_for_fields(
      option_plan,
      variant,
      StarshineExpectedTupleFields([shape]),
    )
  } else {
    starshine_variant_payload_physical_type(option_plan, variant)
  }
  let physical = match selected_physical {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, -405))
  }
  let type_index = link.physical_type_index(
    option_module_index,
    physical.type_index,
  )
  output.push(
    @lib.Instruction::i32_const(
      @lib.I32::new(option_plan.variant_tag_of(variant).unwrap()),
    ),
  )
  if present {
    for field_offset in 1..<physical.fields.length {
      let field = option_plan.fields[physical.fields.start + field_offset]
      if starshine_shape_matches_storage(shape, field.storage) {
        append_starshine_instructions(output, value)
      } else {
        append_starshine_instructions(
          output,
          starshine_default_storage_instructions(field.storage),
        )
      }
    }
  }
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
    ),
  )
  Ok(())
}

///|
fn starshine_product_leaf_shapes(
  shape : @semantic.PlannedValueShape,
  output : Array[@semantic.PlannedValueShape],
) -> Unit {
  match shape {
    @semantic.ProductPlannedValueShape(fields) =>
      for field in fields {
        starshine_product_leaf_shapes(field, output)
      }
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => ()
    _ => output.push(shape)
  }
}

///|
fn starshine_product_box_slot(shape : @semantic.PlannedValueShape) -> Int {
  match shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => 0
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => 1
    @semantic.F32PlannedValueShape => 2
    @semantic.F64PlannedValueShape => 3
    @semantic.V128PlannedValueShape => 4
    _ => -1
  }
}

///|
fn starshine_append_product_unbox(
  output : Array[@lib.Instruction],
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  product_local : Int,
  shape : @semantic.PlannedValueShape,
) -> Result[Unit, StarshineCodeEmissionError] {
  let leaves : Array[@semantic.PlannedValueShape] = []
  starshine_product_leaf_shapes(shape, leaves)
  let box_type = starshine_fixed_array_base_for_body(planned, program) + 5
  for index, leaf in leaves {
    output.push(starshine_array_local_get(product_local))
    output.push(starshine_match_cast(box_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(index)))
    output.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
      ),
    )
    let slot = starshine_product_box_slot(leaf)
    if slot >= 0 {
      let erased_type = match program {
        Some(link) if slot < link.erased_box_type_indices.length() =>
          link.erased_box_type_indices[slot]
        _ => -1
      }
      if erased_type < 0 {
        return Err(UnsupportedExpression(body_id, -421))
      }
      output.push(starshine_match_cast(erased_type))
      output.push(
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(erased_type.reinterpret_as_uint()),
          @lib.U32::new(0U),
        ),
      )
    }
  }
  Ok(())
}

///|
fn starshine_finish_array_literal(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  shape : @semantic.PlannedValueShape,
  fragments : Array[Array[@lib.Instruction]],
  backing_local : Int,
  value_local : Int,
  product_local : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let wrapper_type = match
    starshine_emitted_type_index(
      planned,
      program,
      @semantic.standard_array_type_declaration(),
    ) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body_id, -418))
  }
  let leaves : Array[@semantic.PlannedValueShape] = []
  starshine_product_leaf_shapes(shape, leaves)
  if backing_local < 0 ||
    (fragments.length() > 0 && (value_local < 0 || product_local < 0)) {
    return Err(UnsupportedExpression(body_id, -419))
  }
  let base = starshine_fixed_array_base_for_body(planned, program)
  let outer_type = base + 5
  let box_type = base + 5
  let output : Array[@lib.Instruction] = [
    @lib.Instruction::i32_const(@lib.I32::new(fragments.length())),
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(outer_type.reinterpret_as_uint()),
    ),
    starshine_array_local_set(backing_local),
  ]
  for element_index, fragment in fragments {
    append_starshine_instructions(output, fragment)
    starshine_append_product_local_sets(output, product_local, shape)
    for leaf_index, leaf in leaves {
      output.push(starshine_array_local_get(product_local + leaf_index))
      let slot = starshine_product_box_slot(leaf)
      if slot >= 0 {
        let erased_type = match program {
          Some(link) if slot < link.erased_box_type_indices.length() =>
            link.erased_box_type_indices[slot]
          _ => -1
        }
        if erased_type < 0 {
          return Err(UnsupportedExpression(body_id, -420))
        }
        output.push(
          @lib.Instruction::struct_new(
            @lib.TypeIdx::new(erased_type.reinterpret_as_uint()),
          ),
        )
      }
    }
    output.push(
      @lib.Instruction::array_new_fixed(
        @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
        @lib.U32::new(leaves.length().reinterpret_as_uint()),
      ),
    )
    output.push(starshine_array_local_set(value_local))
    output.push(starshine_array_local_get(backing_local))
    output.push(starshine_match_cast(outer_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(element_index)))
    output.push(starshine_array_local_get(value_local))
    output.push(
      @lib.Instruction::array_set(
        @lib.TypeIdx::new(outer_type.reinterpret_as_uint()),
      ),
    )
  }
  output.push(starshine_array_local_get(backing_local))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(fragments.length())))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(fragments.length())))
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
    ),
  )
  Ok(output)
}

///|
fn starshine_finish_array(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  operation : Int,
  shape : @semantic.PlannedValueShape?,
  fragments : Array[Array[@lib.Instruction]],
  _wrapper_local : Int,
  backing_local : Int,
  _index_local : Int,
  value_local : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  if operation != 48 {
    return Err(UnsupportedExpression(body_id, -409))
  }
  let wrapper_type = match
    starshine_emitted_type_index(
      planned,
      program,
      @semantic.standard_array_type_declaration(),
    ) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body_id, -401))
  }
  let carrier = match shape {
    Some(value) => starshine_array_storage_carrier(value)
    None => -1
  }
  let array_type = starshine_fixed_array_base_for_body(planned, program) +
    carrier
  let output : Array[@lib.Instruction] = []
  if carrier < 0 {
    return Err(UnsupportedExpression(body_id, -417))
  }
  output.push(@lib.Instruction::i32_const(@lib.I32::new(fragments.length())))
  output.push(
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  if fragments.length() == 0 {
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      ),
    )
    return Ok(output)
  }
  if backing_local < 0 || value_local < 0 {
    return Err(UnsupportedExpression(body_id, -417))
  }
  output.push(starshine_array_local_set(backing_local))
  for index, fragment in fragments {
    append_starshine_instructions(output, fragment)
    starshine_array_append_unit_marker(output, shape)
    output.push(starshine_array_local_set(value_local))
    output.push(starshine_array_local_get(backing_local))
    output.push(starshine_match_cast(array_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(index)))
    output.push(starshine_array_local_get(value_local))
    output.push(
      @lib.Instruction::array_set(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
  }
  output.push(starshine_array_local_get(backing_local))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(fragments.length())))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(fragments.length())))
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
    ),
  )
  Ok(output)
}
