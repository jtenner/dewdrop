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
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  grow.push(starshine_array_local_set(index_local))
  let copy_loop : Array[@lib.Instruction] = [
    starshine_array_local_get(index_local),
  ]
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  copy_loop.push(@lib.Instruction::i32_ge_u())
  copy_loop.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  copy_loop.push(starshine_array_local_get(backing_local))
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  copy_loop.push(@lib.Instruction::i32_add())
  copy_loop.push(starshine_array_local_set(index_local))
  copy_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  grow.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(copy_loop),
        ),
      ]),
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
  let iterator_type = wrapper_type
  let carrier = match shape {
    Some(value) => starshine_fixed_array_carrier(value)
    None => -1
  }
  let array_type = starshine_fixed_array_base_for_body(planned, program) +
    carrier
  let output : Array[@lib.Instruction] = []
  if operation == 1 || operation == 2 {
    if carrier < 0 || (operation == 2 && index_local < 0) {
      return Err(UnsupportedExpression(body_id, -402))
    }
    if operation == 2 {
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
  if operation == 12 {
    if iterator_type < 0 {
      return Err(UnsupportedExpression(body_id, -407))
    }
    append_starshine_instructions(output, fragments[0])
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(iterator_type.reinterpret_as_uint()),
      ),
    )
    return Ok(output)
  }
  if operation == 13 || operation == 14 {
    if iterator_type < 0 ||
      wrapper_local < 0 ||
      index_local < 0 ||
      (operation == 14 && carrier < 0) {
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
    if operation == 13 {
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
    output.push(starshine_array_local_get(index_local))
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
  append_starshine_instructions(output, fragments[0])
  output.push(starshine_array_local_set(wrapper_local))
  if operation == 5 || operation == 6 || operation == 7 || operation == 8 {
    append_starshine_instructions(output, fragments[1])
    output.push(starshine_array_local_set(index_local))
  }
  if operation == 7 || operation == 8 || operation == 9 {
    if value_local < 0 {
      return Err(UnsupportedExpression(body_id, -404))
    }
    append_starshine_instructions(output, fragments[fragments.length() - 1])
    output.push(starshine_array_local_set(value_local))
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
