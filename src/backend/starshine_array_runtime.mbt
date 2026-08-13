///|
fn starshine_array_local_get(index : Int) -> @lib.Instruction {
  @lib.Instruction::local_get(@lib.LocalIdx::new(index.reinterpret_as_uint()))
}

///|
fn starshine_array_local_set(index : Int) -> @lib.Instruction {
  @lib.Instruction::local_set(@lib.LocalIdx::new(index.reinterpret_as_uint()))
}

///|
fn starshine_array_wrapper_field(
  wrapper_type : Int,
  wrapper_local : Int,
  field : Int,
) -> Array[@lib.Instruction] {
  [
    starshine_array_local_get(wrapper_local),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(field.reinterpret_as_uint()),
    ),
  ]
}

///|
fn starshine_array_iterator_field(
  iterator_type : Int,
  iterator_local : Int,
  field : Int,
) -> Array[@lib.Instruction] {
  [
    starshine_array_local_get(iterator_local),
    starshine_match_cast(iterator_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(iterator_type.reinterpret_as_uint()),
      @lib.U32::new(field.reinterpret_as_uint()),
    ),
  ]
}

///|
fn starshine_circular_head(
  wrapper_type : Int,
  wrapper_local : Int,
) -> Array[@lib.Instruction] {
  let output = starshine_array_wrapper_field(wrapper_type, wrapper_local, 2)
  output.push(@lib.Instruction::i32_const(@lib.I32::new(2147483647)))
  output.push(@lib.Instruction::i32_and())
  output
}

///|
fn starshine_circular_mode(
  wrapper_type : Int,
  wrapper_local : Int,
) -> Array[@lib.Instruction] {
  let output = starshine_array_wrapper_field(wrapper_type, wrapper_local, 2)
  output.push(@lib.Instruction::i32_const(@lib.I32::new(-2147483648)))
  output.push(@lib.Instruction::i32_and())
  output
}

///|
fn starshine_circular_push_existing(
  wrapper_type : Int,
  array_type : Int,
  wrapper_local : Int,
  value_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(array_type))
  append_starshine_instructions(
    output,
    starshine_circular_head(wrapper_type, wrapper_local),
  )
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  output.push(@lib.Instruction::i32_add())
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(array_type))
  output.push(@lib.Instruction::array_len())
  output.push(@lib.Instruction::i32_rem_u())
  output.push(starshine_array_local_get(value_local))
  output.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_array_local_get(wrapper_local))
  output.push(starshine_match_cast(wrapper_type))
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output.push(@lib.Instruction::i32_add())
  output.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(1U),
    ),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output
}

///|
fn starshine_circular_push_front_existing(
  wrapper_type : Int,
  array_type : Int,
  wrapper_local : Int,
  value_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  output.push(starshine_array_local_get(wrapper_local))
  output.push(starshine_match_cast(wrapper_type))
  append_starshine_instructions(
    output,
    starshine_circular_mode(wrapper_type, wrapper_local),
  )
  append_starshine_instructions(
    output,
    starshine_circular_head(wrapper_type, wrapper_local),
  )
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(array_type))
  output.push(@lib.Instruction::array_len())
  output.push(@lib.Instruction::i32_add())
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output.push(@lib.Instruction::i32_sub())
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(array_type))
  output.push(@lib.Instruction::array_len())
  output.push(@lib.Instruction::i32_rem_u())
  output.push(@lib.Instruction::i32_or())
  output.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(2U),
    ),
  )
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(array_type))
  append_starshine_instructions(
    output,
    starshine_circular_head(wrapper_type, wrapper_local),
  )
  output.push(starshine_array_local_get(value_local))
  output.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_array_local_get(wrapper_local))
  output.push(starshine_match_cast(wrapper_type))
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output.push(@lib.Instruction::i32_add())
  output.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(1U),
    ),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output
}

///|
fn starshine_circular_grow(
  wrapper_type : Int,
  array_type : Int,
  wrapper_local : Int,
  backing_local : Int,
  index_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  append_starshine_instructions(
    output,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_array_local_set(backing_local))
  output.push(starshine_array_local_get(backing_local))
  output.push(starshine_match_cast(array_type))
  output.push(@lib.Instruction::array_len())
  output.push(@lib.Instruction::i32_eqz())
  output.push(
    @lib.Instruction::if_(
      @lib.BlockType::val_type(@lib.ValType::i32()),
      [@lib.Instruction::i32_const(@lib.I32::new(4))],
      Some([
        starshine_array_local_get(backing_local),
        starshine_match_cast(array_type),
        @lib.Instruction::array_len(),
        @lib.Instruction::i32_const(@lib.I32::new(2)),
        @lib.Instruction::i32_mul(),
      ]),
    ),
  )
  output.push(starshine_array_local_set(index_local))
  output.push(starshine_array_local_get(wrapper_local))
  output.push(starshine_match_cast(wrapper_type))
  output.push(starshine_array_local_get(index_local))
  output.push(
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  output.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  output.push(starshine_array_local_set(index_local))
  let copy : Array[@lib.Instruction] = []
  copy.push(starshine_array_local_get(index_local))
  append_starshine_instructions(
    copy,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  copy.push(@lib.Instruction::i32_ge_u())
  copy.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  append_starshine_instructions(
    copy,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  copy.push(starshine_match_cast(array_type))
  copy.push(starshine_array_local_get(index_local))
  copy.push(starshine_array_local_get(backing_local))
  copy.push(starshine_match_cast(array_type))
  append_starshine_instructions(
    copy,
    starshine_circular_head(wrapper_type, wrapper_local),
  )
  copy.push(starshine_array_local_get(index_local))
  copy.push(@lib.Instruction::i32_add())
  copy.push(starshine_array_local_get(backing_local))
  copy.push(starshine_match_cast(array_type))
  copy.push(@lib.Instruction::array_len())
  copy.push(@lib.Instruction::i32_rem_u())
  copy.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy.push(starshine_array_local_get(index_local))
  copy.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  copy.push(@lib.Instruction::i32_add())
  copy.push(starshine_array_local_set(index_local))
  copy.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  output.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(@lib.BlockType::void_(), @lib.Expr::new(copy)),
      ]),
    ),
  )
  output.push(starshine_array_local_get(wrapper_local))
  output.push(starshine_match_cast(wrapper_type))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(-2147483648)))
  output.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(2U),
    ),
  )
  output
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
  let physical = match
    starshine_variant_payload_physical_type(option_plan, variant) {
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
    for field in option_plan.variant_fields_of(variant) {
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
fn starshine_array_growth(
  wrapper_type : Int,
  array_type : Int,
  wrapper_local : Int,
  backing_local : Int,
  index_local : Int,
) -> Array[@lib.Instruction] {
  let grow : Array[@lib.Instruction] = []
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 2),
  )
  grow.push(@lib.Instruction::i32_eqz())
  let doubled : Array[@lib.Instruction] = []
  append_starshine_instructions(
    doubled,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 2),
  )
  doubled.push(@lib.Instruction::i32_const(@lib.I32::new(2)))
  doubled.push(@lib.Instruction::i32_mul())
  grow.push(
    @lib.Instruction::if_(
      @lib.BlockType::val_type(@lib.ValType::i32()),
      [@lib.Instruction::i32_const(@lib.I32::new(4))],
      Some(doubled),
    ),
  )
  grow.push(starshine_array_local_set(index_local))
  grow.push(starshine_array_local_get(index_local))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 2),
  )
  grow.push(@lib.Instruction::i32_le_u())
  grow.push(
    @lib.Instruction::if_(
      @lib.BlockType::void_(),
      [@lib.Instruction::unreachable_()],
      None,
    ),
  )
  grow.push(starshine_array_local_get(index_local))
  grow.push(
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  grow.push(starshine_array_local_set(backing_local))
  grow.push(starshine_array_local_get(backing_local))
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  grow.push(
    @lib.Instruction::array_copy(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  grow.push(starshine_array_local_get(wrapper_local))
  grow.push(starshine_match_cast(wrapper_type))
  grow.push(starshine_array_local_get(backing_local))
  grow.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  grow.push(starshine_array_local_get(wrapper_local))
  grow.push(starshine_match_cast(wrapper_type))
  grow.push(starshine_array_local_get(backing_local))
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::array_len())
  grow.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(2U),
    ),
  )
  grow
}

///|
fn starshine_finish_array(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  operation : Int,
  shape : @semantic.PlannedValueShape?,
  fragments : Array[Array[@lib.Instruction]],
  wrapper_local : Int,
  backing_local : Int,
  index_local : Int,
  value_local : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let wrapper_type = match
    starshine_emitted_type_index(
      planned,
      program,
      @semantic.standard_array_type_declaration(),
    ) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body_id, -401))
  }
  let iterator_type = match
    starshine_emitted_struct_type_index(
      planned,
      program,
      @semantic.standard_array_iterator_type_declaration(),
    ) {
    Some(value) => value
    None => wrapper_type
  }
  let carrier = match shape {
    Some(value) => starshine_fixed_array_carrier(value)
    None => -1
  }
  let array_type = starshine_fixed_array_base_for_body(planned, program) +
    carrier
  let output : Array[@lib.Instruction] = []
  if operation == 1 ||
    operation == 2 ||
    operation == 20 ||
    operation == 21 ||
    operation == 33 {
    let has_capacity = operation == 2 || operation == 20 || operation == 21
    if carrier < 0 || (has_capacity && index_local < 0) {
      return Err(UnsupportedExpression(body_id, -402))
    }
    if has_capacity {
      append_starshine_instructions(output, fragments[0])
      output.push(starshine_array_local_set(index_local))
      output.push(starshine_array_local_get(index_local))
    } else {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    }
    output.push(
      @lib.Instruction::array_new_default(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    if operation == 2 {
      output.push(starshine_array_local_get(index_local))
    } else if operation == 21 || operation == 33 {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(-2147483648)))
    } else {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      ),
    )
    return Ok(output)
  }
  if operation == 3 || operation == 4 {
    append_starshine_instructions(output, fragments[0])
    output.push(starshine_match_cast(wrapper_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(if operation == 3 { 1U } else { 2U }),
      ),
    )
    return Ok(output)
  }
  if operation == 12 || operation == 30 {
    if iterator_type < 0 {
      return Err(UnsupportedExpression(body_id, -407))
    }
    append_starshine_instructions(output, fragments[0])
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    if iterator_type == wrapper_type {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(iterator_type.reinterpret_as_uint()),
      ),
    )
    return Ok(output)
  }
  if operation == 13 || operation == 14 || operation == 31 || operation == 32 {
    if iterator_type < 0 ||
      wrapper_local < 0 ||
      index_local < 0 ||
      ((operation == 14 || operation == 32) && carrier < 0) {
      return Err(UnsupportedExpression(body_id, -408))
    }
    append_starshine_instructions(output, fragments[0])
    output.push(starshine_array_local_set(wrapper_local))
    append_starshine_instructions(
      output,
      starshine_array_iterator_field(iterator_type, wrapper_local, 1),
    )
    append_starshine_instructions(
      output,
      starshine_array_iterator_field(iterator_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(wrapper_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
    output.push(@lib.Instruction::i32_lt_u())
    if operation == 13 || operation == 31 {
      return Ok(output)
    }
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::void_(),
        [],
        Some([@lib.Instruction::unreachable_()]),
      ),
    )
    append_starshine_instructions(
      output,
      starshine_array_iterator_field(iterator_type, wrapper_local, 1),
    )
    output.push(starshine_array_local_set(index_local))
    append_starshine_instructions(
      output,
      starshine_array_iterator_field(iterator_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(wrapper_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(0U),
      ),
    )
    output.push(starshine_match_cast(array_type))
    if operation == 32 {
      append_starshine_instructions(
        output,
        starshine_array_iterator_field(iterator_type, wrapper_local, 0),
      )
      output.push(starshine_match_cast(wrapper_type))
      output.push(
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
          @lib.U32::new(2U),
        ),
      )
      output.push(@lib.Instruction::i32_const(@lib.I32::new(2147483647)))
      output.push(@lib.Instruction::i32_and())
      output.push(starshine_array_local_get(index_local))
      output.push(@lib.Instruction::i32_add())
      append_starshine_instructions(
        output,
        starshine_array_iterator_field(iterator_type, wrapper_local, 0),
      )
      output.push(starshine_match_cast(wrapper_type))
      output.push(
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
          @lib.U32::new(0U),
        ),
      )
      output.push(starshine_match_cast(array_type))
      output.push(@lib.Instruction::array_len())
      output.push(@lib.Instruction::i32_rem_u())
    } else {
      output.push(starshine_array_local_get(index_local))
    }
    output.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    output.push(starshine_array_local_get(wrapper_local))
    output.push(starshine_match_cast(iterator_type))
    output.push(starshine_array_local_get(index_local))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
    output.push(@lib.Instruction::i32_add())
    output.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(iterator_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
    return Ok(output)
  }
  if operation == 16 {
    append_starshine_instructions(output, fragments[0])
    output.push(starshine_match_cast(wrapper_type))
    output.push(
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
    output.push(@lib.Instruction::i32_eqz())
    return Ok(output)
  }
  let shape = match shape {
    Some(value) => value
    None => return Err(UnsupportedExpression(body_id, -403))
  }
  if carrier < 0 || wrapper_local < 0 || backing_local < 0 || index_local < 0 {
    return Err(UnsupportedExpression(body_id, -403))
  }
  let defer_wrapper_store = operation == 5 ||
    operation == 6 ||
    operation == 7 ||
    operation == 8 ||
    operation == 9 ||
    operation == 26 ||
    operation == 34 ||
    operation == 35 ||
    operation == 38
  append_starshine_instructions(output, fragments[0])
  if !defer_wrapper_store {
    output.push(starshine_array_local_set(wrapper_local))
  }
  if operation == 23 {
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(array_type))
    output.push(@lib.Instruction::array_len())
    return Ok(output)
  }
  if operation == 25 {
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(array_type))
    output.push(@lib.Instruction::array_len())
    output.push(@lib.Instruction::i32_eq())
    return Ok(output)
  }
  if operation == 5 || operation == 6 || operation == 7 || operation == 8 {
    append_starshine_instructions(output, fragments[1])
    output.push(starshine_array_local_set(index_local))
  }
  if operation == 7 ||
    operation == 8 ||
    operation == 9 ||
    operation == 26 ||
    operation == 34 ||
    operation == 35 ||
    operation == 38 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -404))
    }
    append_starshine_instructions(output, fragments[fragments.length() - 1])
    output.push(starshine_array_local_set(value_local))
  }
  if defer_wrapper_store {
    output.push(starshine_array_local_set(wrapper_local))
  }
  if operation == 26 || operation == 34 || operation == 35 || operation == 38 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -412))
    }
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(array_type))
    output.push(@lib.Instruction::array_len())
    output.push(@lib.Instruction::i32_eq())
    let full : Array[@lib.Instruction] = []
    append_starshine_instructions(
      full,
      starshine_circular_mode(wrapper_type, wrapper_local),
    )
    full.push(@lib.Instruction::i32_eqz())
    let grow = starshine_circular_grow(
      wrapper_type, array_type, wrapper_local, backing_local, index_local,
    )
    append_starshine_instructions(
      grow,
      if operation == 35 || operation == 38 {
        starshine_circular_push_front_existing(
          wrapper_type, array_type, wrapper_local, value_local,
        )
      } else {
        starshine_circular_push_existing(
          wrapper_type, array_type, wrapper_local, value_local,
        )
      },
    )
    full.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::i32()),
        [@lib.Instruction::i32_const(@lib.I32::new(0))],
        Some(grow),
      ),
    )
    let available = if operation == 35 || operation == 38 {
      starshine_circular_push_front_existing(
        wrapper_type, array_type, wrapper_local, value_local,
      )
    } else {
      starshine_circular_push_existing(
        wrapper_type, array_type, wrapper_local, value_local,
      )
    }
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::i32()),
        full,
        Some(available),
      ),
    )
    if operation == 34 || operation == 38 {
      output.push(@lib.Instruction::drop())
    }
    return Ok(output)
  }
  if operation == 5 {
    let success : Array[@lib.Instruction] = []
    let value : Array[@lib.Instruction] = []
    append_starshine_instructions(
      value,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    value.push(starshine_match_cast(array_type))
    value.push(starshine_array_local_get(index_local))
    value.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    match
      starshine_array_append_option(
        success, planned, program, shape, true, value,
      ) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -405))
    }
    let failure : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(failure, planned, program, shape, false, []) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -405))
    }
    output.push(starshine_array_local_get(index_local))
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_lt_u())
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        success,
        Some(failure),
      ),
    )
  } else if operation == 6 || operation == 8 {
    output.push(starshine_array_local_get(index_local))
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_ge_u())
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::void_(),
        [@lib.Instruction::unreachable_()],
        None,
      ),
    )
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(array_type))
    output.push(starshine_array_local_get(index_local))
    if operation == 6 {
      output.push(
        @lib.Instruction::array_get(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
    } else {
      output.push(starshine_array_local_get(value_local))
      output.push(
        @lib.Instruction::array_set(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
    }
  } else if operation == 7 {
    let success : Array[@lib.Instruction] = []
    append_starshine_instructions(
      success,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    success.push(starshine_match_cast(array_type))
    success.push(starshine_array_local_get(index_local))
    success.push(starshine_array_local_get(value_local))
    success.push(
      @lib.Instruction::array_set(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    success.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
    output.push(starshine_array_local_get(index_local))
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_lt_u())
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::i32()),
        success,
        Some([@lib.Instruction::i32_const(@lib.I32::new(0))]),
      ),
    )
  } else if operation == 9 {
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 2),
    )
    output.push(@lib.Instruction::i32_eq())
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::void_(),
        starshine_array_growth(
          wrapper_type, array_type, wrapper_local, backing_local, index_local,
        ),
        None,
      ),
    )
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    output.push(starshine_match_cast(array_type))
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(starshine_array_local_get(value_local))
    output.push(
      @lib.Instruction::array_set(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    output.push(starshine_array_local_get(wrapper_local))
    output.push(starshine_match_cast(wrapper_type))
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
    output.push(@lib.Instruction::i32_add())
    output.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
  } else if operation == 10 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -406))
    }
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_eqz())
    let empty : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(empty, planned, program, shape, false, []) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -406))
    }
    let present : Array[@lib.Instruction] = []
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
    present.push(@lib.Instruction::i32_sub())
    present.push(starshine_array_local_set(index_local))
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    present.push(starshine_match_cast(array_type))
    present.push(starshine_array_local_get(index_local))
    present.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    present.push(starshine_array_local_set(value_local))
    let reference_shape = match shape {
      @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
        true
      _ => false
    }
    if reference_shape {
      append_starshine_instructions(
        present,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      present.push(starshine_match_cast(array_type))
      present.push(starshine_array_local_get(index_local))
      present.push(
        @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
      )
      present.push(
        @lib.Instruction::array_set(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
    }
    present.push(starshine_array_local_get(wrapper_local))
    present.push(starshine_match_cast(wrapper_type))
    present.push(starshine_array_local_get(index_local))
    present.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
    let some : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(some, planned, program, shape, true, [
        starshine_array_local_get(value_local),
      ]) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -406))
    }
    append_starshine_instructions(present, some)
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        empty,
        Some(present),
      ),
    )
  } else if operation == 17 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -410))
    }
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_eqz())
    let empty : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(empty, planned, program, shape, false, []) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -410))
    }
    let present : Array[@lib.Instruction] = []
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
    present.push(@lib.Instruction::i32_sub())
    present.push(starshine_array_local_set(index_local))
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    present.push(starshine_match_cast(array_type))
    present.push(starshine_array_local_get(index_local))
    present.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    present.push(starshine_array_local_set(value_local))
    let some : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(some, planned, program, shape, true, [
        starshine_array_local_get(value_local),
      ]) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -410))
    }
    append_starshine_instructions(present, some)
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        empty,
        Some(present),
      ),
    )
  } else if operation == 18 || operation == 19 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -411))
    }
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_eqz())
    let empty : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(empty, planned, program, shape, false, []) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -411))
    }
    let present : Array[@lib.Instruction] = []
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    present.push(starshine_match_cast(array_type))
    present.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    present.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    present.push(starshine_array_local_set(value_local))
    if operation == 19 {
      present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      present.push(starshine_array_local_set(index_local))
      let shift : Array[@lib.Instruction] = []
      shift.push(starshine_array_local_get(index_local))
      append_starshine_instructions(
        shift,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      shift.push(@lib.Instruction::i32_ge_u())
      shift.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
      append_starshine_instructions(
        shift,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      shift.push(starshine_match_cast(array_type))
      shift.push(starshine_array_local_get(index_local))
      shift.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      shift.push(@lib.Instruction::i32_sub())
      append_starshine_instructions(
        shift,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      shift.push(starshine_match_cast(array_type))
      shift.push(starshine_array_local_get(index_local))
      shift.push(
        @lib.Instruction::array_get(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
      shift.push(
        @lib.Instruction::array_set(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
      shift.push(starshine_array_local_get(index_local))
      shift.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      shift.push(@lib.Instruction::i32_add())
      shift.push(starshine_array_local_set(index_local))
      shift.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
      present.push(
        @lib.Instruction::block(
          @lib.BlockType::void_(),
          @lib.Expr::new([
            @lib.Instruction::loop_(
              @lib.BlockType::void_(),
              @lib.Expr::new(shift),
            ),
          ]),
        ),
      )
      append_starshine_instructions(
        present,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      present.push(@lib.Instruction::i32_sub())
      present.push(starshine_array_local_set(index_local))
      let reference_shape = match shape {
        @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
          true
        _ => false
      }
      if reference_shape {
        append_starshine_instructions(
          present,
          starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
        )
        present.push(starshine_match_cast(array_type))
        present.push(starshine_array_local_get(index_local))
        present.push(
          @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
        )
        present.push(
          @lib.Instruction::array_set(
            @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
          ),
        )
      }
      present.push(starshine_array_local_get(wrapper_local))
      present.push(starshine_match_cast(wrapper_type))
      present.push(starshine_array_local_get(index_local))
      present.push(
        @lib.Instruction::struct_set(
          @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
          @lib.U32::new(1U),
        ),
      )
    }
    let some : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(some, planned, program, shape, true, [
        starshine_array_local_get(value_local),
      ]) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -411))
    }
    append_starshine_instructions(present, some)
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        empty,
        Some(present),
      ),
    )
  } else if operation == 27 ||
    operation == 28 ||
    operation == 36 ||
    operation == 37 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -413))
    }
    append_starshine_instructions(
      output,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
    )
    output.push(@lib.Instruction::i32_eqz())
    let empty : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(empty, planned, program, shape, false, []) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -413))
    }
    let present : Array[@lib.Instruction] = []
    append_starshine_instructions(
      present,
      starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
    )
    present.push(starshine_match_cast(array_type))
    append_starshine_instructions(
      present,
      starshine_circular_head(wrapper_type, wrapper_local),
    )
    if operation == 36 || operation == 37 {
      append_starshine_instructions(
        present,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      present.push(@lib.Instruction::i32_add())
      present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      present.push(@lib.Instruction::i32_sub())
      append_starshine_instructions(
        present,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      present.push(starshine_match_cast(array_type))
      present.push(@lib.Instruction::array_len())
      present.push(@lib.Instruction::i32_rem_u())
    }
    present.push(
      @lib.Instruction::array_get(
        @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      ),
    )
    present.push(starshine_array_local_set(value_local))
    if operation == 27 || operation == 36 {
      let reference_shape = match shape {
        @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
          true
        _ => false
      }
      if reference_shape {
        append_starshine_instructions(
          present,
          starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
        )
        present.push(starshine_match_cast(array_type))
        append_starshine_instructions(
          present,
          starshine_circular_head(wrapper_type, wrapper_local),
        )
        if operation == 36 {
          append_starshine_instructions(
            present,
            starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
          )
          present.push(@lib.Instruction::i32_add())
          present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          present.push(@lib.Instruction::i32_sub())
          append_starshine_instructions(
            present,
            starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
          )
          present.push(starshine_match_cast(array_type))
          present.push(@lib.Instruction::array_len())
          present.push(@lib.Instruction::i32_rem_u())
        }
        present.push(
          @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
        )
        present.push(
          @lib.Instruction::array_set(
            @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
          ),
        )
      }
      present.push(starshine_array_local_get(wrapper_local))
      present.push(starshine_match_cast(wrapper_type))
      append_starshine_instructions(
        present,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      present.push(@lib.Instruction::i32_sub())
      present.push(
        @lib.Instruction::struct_set(
          @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
          @lib.U32::new(1U),
        ),
      )
      if operation == 27 {
        present.push(starshine_array_local_get(wrapper_local))
        present.push(starshine_match_cast(wrapper_type))
        append_starshine_instructions(
          present,
          starshine_circular_mode(wrapper_type, wrapper_local),
        )
        append_starshine_instructions(
          present,
          starshine_circular_head(wrapper_type, wrapper_local),
        )
        present.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        present.push(@lib.Instruction::i32_add())
        append_starshine_instructions(
          present,
          starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
        )
        present.push(starshine_match_cast(array_type))
        present.push(@lib.Instruction::array_len())
        present.push(@lib.Instruction::i32_rem_u())
        present.push(@lib.Instruction::i32_or())
        present.push(
          @lib.Instruction::struct_set(
            @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            @lib.U32::new(2U),
          ),
        )
      }
    }
    let some : Array[@lib.Instruction] = []
    match
      starshine_array_append_option(some, planned, program, shape, true, [
        starshine_array_local_get(value_local),
      ]) {
      Ok(_) => ()
      Err(_) => return Err(UnsupportedExpression(body_id, -413))
    }
    append_starshine_instructions(present, some)
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::eqref_null()),
        empty,
        Some(present),
      ),
    )
  } else if operation == 29 {
    let reference_shape = match shape {
      @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
        true
      _ => false
    }
    if reference_shape {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
      output.push(starshine_array_local_set(index_local))
      let clear : Array[@lib.Instruction] = []
      clear.push(starshine_array_local_get(index_local))
      append_starshine_instructions(
        clear,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      clear.push(@lib.Instruction::i32_ge_u())
      clear.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
      append_starshine_instructions(
        clear,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      clear.push(starshine_match_cast(array_type))
      append_starshine_instructions(
        clear,
        starshine_circular_head(wrapper_type, wrapper_local),
      )
      clear.push(starshine_array_local_get(index_local))
      clear.push(@lib.Instruction::i32_add())
      append_starshine_instructions(
        clear,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      clear.push(starshine_match_cast(array_type))
      clear.push(@lib.Instruction::array_len())
      clear.push(@lib.Instruction::i32_rem_u())
      clear.push(
        @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
      )
      clear.push(
        @lib.Instruction::array_set(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
      clear.push(starshine_array_local_get(index_local))
      clear.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      clear.push(@lib.Instruction::i32_add())
      clear.push(starshine_array_local_set(index_local))
      clear.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
      output.push(
        @lib.Instruction::block(
          @lib.BlockType::void_(),
          @lib.Expr::new([
            @lib.Instruction::loop_(
              @lib.BlockType::void_(),
              @lib.Expr::new(clear),
            ),
          ]),
        ),
      )
    }
    output.push(starshine_array_local_get(wrapper_local))
    output.push(starshine_match_cast(wrapper_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
    output.push(starshine_array_local_get(wrapper_local))
    output.push(starshine_match_cast(wrapper_type))
    append_starshine_instructions(
      output,
      starshine_circular_mode(wrapper_type, wrapper_local),
    )
    output.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(2U),
      ),
    )
  } else if operation == 11 {
    let reference_shape = match shape {
      @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
        true
      _ => false
    }
    if reference_shape {
      output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
      output.push(starshine_array_local_set(index_local))
      let clear_loop : Array[@lib.Instruction] = [
        starshine_array_local_get(index_local),
      ]
      append_starshine_instructions(
        clear_loop,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
      )
      clear_loop.push(@lib.Instruction::i32_ge_u())
      clear_loop.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
      append_starshine_instructions(
        clear_loop,
        starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
      )
      clear_loop.push(starshine_match_cast(array_type))
      clear_loop.push(starshine_array_local_get(index_local))
      clear_loop.push(
        @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
      )
      clear_loop.push(
        @lib.Instruction::array_set(
          @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
        ),
      )
      clear_loop.push(starshine_array_local_get(index_local))
      clear_loop.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      clear_loop.push(@lib.Instruction::i32_add())
      clear_loop.push(starshine_array_local_set(index_local))
      clear_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
      output.push(
        @lib.Instruction::block(
          @lib.BlockType::void_(),
          @lib.Expr::new([
            @lib.Instruction::loop_(
              @lib.BlockType::void_(),
              @lib.Expr::new(clear_loop),
            ),
          ]),
        ),
      )
    }
    output.push(starshine_array_local_get(wrapper_local))
    output.push(starshine_match_cast(wrapper_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(
      @lib.Instruction::struct_set(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(1U),
      ),
    )
  } else {
    return Err(UnsupportedExpression(body_id, -409))
  }
  Ok(output)
}
