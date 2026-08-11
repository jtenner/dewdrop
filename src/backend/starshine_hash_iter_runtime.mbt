///|
fn starshine_hash_iter_wrapper_field(
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
fn starshine_hash_iter_state_field(
  wrapper_type : Int,
  bucket_type : Int,
  wrapper_local : Int,
  field : Int,
) -> Array[@lib.Instruction] {
  let output = starshine_hash_iter_wrapper_field(wrapper_type, wrapper_local, 0)
  output.push(starshine_match_cast(bucket_type))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(field)))
  output.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
  )
  output
}

///|
fn starshine_hash_iter_set_state_field(
  output : Array[@lib.Instruction],
  wrapper_type : Int,
  bucket_type : Int,
  wrapper_local : Int,
  field : Int,
  value : Array[@lib.Instruction],
) -> Unit {
  append_starshine_instructions(
    output,
    starshine_hash_iter_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  output.push(starshine_match_cast(bucket_type))
  output.push(@lib.Instruction::i32_const(@lib.I32::new(field)))
  append_starshine_instructions(output, value)
  output.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
  )
}

///|
fn starshine_hash_iter_ensure_current(
  wrapper_type : Int,
  collection_type : Int,
  bucket_type : Int,
  _entry_type : Int,
  iterator_local : Int,
  entry_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  append_starshine_instructions(
    output,
    starshine_hash_iter_state_field(
      wrapper_type, bucket_type, iterator_local, 1,
    ),
  )
  output.push(@lib.Instruction::ref_is_null())
  let scan : Array[@lib.Instruction] = []
  let loop_body : Array[@lib.Instruction] = []
  append_starshine_instructions(
    loop_body,
    starshine_hash_iter_wrapper_field(wrapper_type, iterator_local, 1),
  )
  append_starshine_instructions(
    loop_body,
    starshine_hash_iter_state_field(
      wrapper_type, bucket_type, iterator_local, 0,
    ),
  )
  loop_body.push(starshine_match_cast(collection_type))
  loop_body.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(collection_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  loop_body.push(starshine_match_cast(bucket_type))
  loop_body.push(@lib.Instruction::array_len())
  loop_body.push(@lib.Instruction::i32_ge_u())
  loop_body.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  append_starshine_instructions(
    loop_body,
    starshine_hash_iter_state_field(
      wrapper_type, bucket_type, iterator_local, 0,
    ),
  )
  loop_body.push(starshine_match_cast(collection_type))
  loop_body.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(collection_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  loop_body.push(starshine_match_cast(bucket_type))
  append_starshine_instructions(
    loop_body,
    starshine_hash_iter_wrapper_field(wrapper_type, iterator_local, 1),
  )
  loop_body.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
  )
  loop_body.push(starshine_array_local_set(entry_local))
  starshine_hash_iter_set_state_field(
    loop_body,
    wrapper_type,
    bucket_type,
    iterator_local,
    1,
    [starshine_array_local_get(entry_local)],
  )
  loop_body.push(starshine_array_local_get(entry_local))
  loop_body.push(@lib.Instruction::ref_is_null())
  loop_body.push(@lib.Instruction::i32_eqz())
  loop_body.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  loop_body.push(starshine_array_local_get(iterator_local))
  loop_body.push(starshine_match_cast(wrapper_type))
  append_starshine_instructions(
    loop_body,
    starshine_hash_iter_wrapper_field(wrapper_type, iterator_local, 1),
  )
  loop_body.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  loop_body.push(@lib.Instruction::i32_add())
  loop_body.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(1U),
    ),
  )
  loop_body.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  scan.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(loop_body),
        ),
      ]),
    ),
  )
  output.push(@lib.Instruction::if_(@lib.BlockType::void_(), scan, None))
  output
}

///|
fn starshine_finish_hash_iter(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  operation : Int,
  key_shape : @semantic.PlannedValueShape,
  value_shape : @semantic.PlannedValueShape,
  fragments : Array[Array[@lib.Instruction]],
  iterator_local : Int,
  state_local : Int,
  entry_local : Int,
  _index_local : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let set_operation = operation >= 10 && operation <= 12
  let collection_declaration = if set_operation {
    @semantic.standard_set_type_declaration()
  } else {
    @semantic.standard_map_type_declaration()
  }
  let collection_type = match
    starshine_emitted_type_index(planned, program, collection_declaration) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body_id, -501))
  }
  let iterator_declaration = match operation {
    1 | 4 | 5 => @semantic.standard_map_key_iterator_type_declaration()
    2 | 6 | 13 => @semantic.standard_map_value_iterator_type_declaration()
    3 | 7 | 14 => @semantic.standard_map_entry_iterator_type_declaration()
    10 | 11 | 12 => @semantic.standard_set_iterator_type_declaration()
    _ => collection_declaration
  }
  let wrapper_type = starshine_emitted_type_index(
    planned, program, iterator_declaration,
  ).unwrap_or(collection_type)
  let map_base = starshine_map_base_for_body(planned, program)
  let bucket_type = map_base
  let entry_type = map_base + 1
  let output : Array[@lib.Instruction] = []
  if operation == 8 || operation == 9 {
    append_starshine_instructions(output, fragments[0])
    output.push(starshine_match_cast(entry_type))
    let shape = if operation == 8 { key_shape } else { value_shape }
    let field = starshine_map_entry_field(shape, operation == 9)
    if field < 0 {
      return Err(UnsupportedExpression(body_id, -502))
    }
    output.push(starshine_map_entry_get(entry_type, field))
    return Ok(output)
  }
  if iterator_local < 0 || state_local < 0 || entry_local < 0 {
    return Err(UnsupportedExpression(body_id, -503))
  }
  if operation == 1 || operation == 2 || operation == 3 || operation == 10 {
    append_starshine_instructions(output, fragments[0])
    output.push(starshine_array_local_set(iterator_local))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(2)))
    output.push(
      @lib.Instruction::array_new_default(
        @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
      ),
    )
    output.push(starshine_array_local_set(state_local))
    output.push(starshine_array_local_get(state_local))
    output.push(starshine_match_cast(bucket_type))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(starshine_array_local_get(iterator_local))
    output.push(
      @lib.Instruction::array_set(
        @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
      ),
    )
    output.push(starshine_array_local_get(state_local))
    output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      ),
    )
    return Ok(output)
  }
  append_starshine_instructions(output, fragments[0])
  output.push(starshine_array_local_set(iterator_local))
  append_starshine_instructions(
    output,
    starshine_hash_iter_ensure_current(
      wrapper_type, collection_type, bucket_type, entry_type, iterator_local, entry_local,
    ),
  )
  if operation == 4 || operation == 11 || operation == 13 || operation == 14 {
    append_starshine_instructions(
      output,
      starshine_hash_iter_state_field(
        wrapper_type, bucket_type, iterator_local, 1,
      ),
    )
    output.push(@lib.Instruction::ref_is_null())
    output.push(@lib.Instruction::i32_eqz())
    return Ok(output)
  }
  append_starshine_instructions(
    output,
    starshine_hash_iter_state_field(
      wrapper_type, bucket_type, iterator_local, 1,
    ),
  )
  output.push(starshine_array_local_set(entry_local))
  output.push(starshine_array_local_get(entry_local))
  output.push(@lib.Instruction::ref_is_null())
  output.push(
    @lib.Instruction::if_(
      @lib.BlockType::void_(),
      [@lib.Instruction::unreachable_()],
      None,
    ),
  )
  starshine_hash_iter_set_state_field(
    output,
    wrapper_type,
    bucket_type,
    iterator_local,
    1,
    [
      starshine_array_local_get(entry_local),
      starshine_match_cast(entry_type),
      starshine_map_entry_get(entry_type, 0),
    ],
  )
  append_starshine_instructions(
    output,
    starshine_hash_iter_state_field(
      wrapper_type, bucket_type, iterator_local, 1,
    ),
  )
  output.push(@lib.Instruction::ref_is_null())
  let advance_bucket : Array[@lib.Instruction] = [
    starshine_array_local_get(iterator_local),
    starshine_match_cast(wrapper_type),
  ]
  append_starshine_instructions(
    advance_bucket,
    starshine_hash_iter_wrapper_field(wrapper_type, iterator_local, 1),
  )
  advance_bucket.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  advance_bucket.push(@lib.Instruction::i32_add())
  advance_bucket.push(
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(1U),
    ),
  )
  output.push(
    @lib.Instruction::if_(@lib.BlockType::void_(), advance_bucket, None),
  )
  if operation == 7 {
    output.push(starshine_array_local_get(entry_local))
  } else {
    let key_result = operation == 5 || operation == 12
    let shape = if key_result { key_shape } else { value_shape }
    let field = starshine_map_entry_field(shape, !key_result)
    if field < 0 {
      return Err(UnsupportedExpression(body_id, -504))
    }
    output.push(starshine_array_local_get(entry_local))
    output.push(starshine_match_cast(entry_type))
    output.push(starshine_map_entry_get(entry_type, field))
  }
  Ok(output)
}
