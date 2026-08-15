///|
fn core_storage_ref_type_index(value : @lib.StorageType) -> Int? {
  match value {
    @lib.ValTypeStorageType(type_) =>
      match core_ref_defined_type(type_) {
        Some((_, _, index)) => Some(index)
        None => None
      }
    _ => None
  }
}

///|
fn core_find_dew_string_types(arena : CoreTypeArena) -> (Int, Int)? {
  for chunks_index, subtype in arena.subtypes {
    let chunks = match subtype.get_comptype() {
      @lib.ArrayCompType(field) =>
        match field.get_storage_type() {
          @lib.ValTypeStorageType(@lib.VecTypeValType) => true
          _ => false
        }
      _ => false
    }
    if !chunks {
      continue
    }
    for text_index, candidate in arena.subtypes {
      match candidate.get_comptype() {
        @lib.StructCompType(fields) if fields.length() == 3 =>
          if core_storage_ref_type_index(fields[0].get_storage_type()) ==
            Some(chunks_index) &&
            fields[1].get_storage_type() ==
            @lib.StorageType::val_type(@lib.ValType::i32()) &&
            fields[2].get_storage_type() ==
            @lib.StorageType::val_type(@lib.ValType::i32()) {
            return Some((chunks_index, text_index))
          }
        _ => ()
      }
    }
  }
  None
}

///|
fn core_i32(value : Int) -> @lib.Instruction {
  @lib.Instruction::i32_const(@lib.I32::new(value))
}

///|
fn core_local(index : Int) -> @lib.LocalIdx {
  @lib.LocalIdx::new(index.reinterpret_as_uint())
}

///|
fn core_adapter_mem_arg(memory : Int, align : UInt) -> @lib.MemArg {
  @lib.MemArg::new(
    @lib.U32::new(align),
    Some(@lib.MemIdx::new(memory.reinterpret_as_uint())),
    @lib.U64::new(0UL),
  )
}

///|
/// Loads one UTF-8 byte from Dew's packed v128 chunk representation.
fn core_append_dew_string_byte_load(
  output : Array[@lib.Instruction],
  chunks_type : Int,
  memory : Int,
  chunks_local : Int,
  start_local : Int,
  index_local : Int,
  absolute_local : Int,
  delta : Int,
) -> Unit {
  output.push(core_i32(0))
  output.push(@lib.Instruction::local_get(core_local(chunks_local)))
  output.push(@lib.Instruction::local_get(core_local(start_local)))
  output.push(@lib.Instruction::local_get(core_local(index_local)))
  output.push(@lib.Instruction::i32_add())
  if delta != 0 {
    output.push(core_i32(delta))
    output.push(@lib.Instruction::i32_add())
  }
  output.push(@lib.Instruction::local_tee(core_local(absolute_local)))
  output.push(core_i32(4))
  output.push(@lib.Instruction::i32_shr_u())
  output.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(chunks_type.reinterpret_as_uint()),
    ),
  )
  output.push(@lib.Instruction::v128_store(core_adapter_mem_arg(memory, 4U)))
  output.push(core_i32(0))
  output.push(@lib.Instruction::local_get(core_local(absolute_local)))
  output.push(core_i32(15))
  output.push(@lib.Instruction::i32_and())
  output.push(@lib.Instruction::i32_add())
  output.push(@lib.Instruction::i32_load8u(core_adapter_mem_arg(memory, 0U)))
}

///|
fn core_append_array_set_from_local(
  output : Array[@lib.Instruction],
  string_type : Int,
  array_local : Int,
  index_local : Int,
  value_local : Int,
) -> Unit {
  output.push(@lib.Instruction::local_get(core_local(array_local)))
  output.push(@lib.Instruction::local_get(core_local(index_local)))
  output.push(@lib.Instruction::local_get(core_local(value_local)))
  output.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(string_type.reinterpret_as_uint()),
    ),
  )
  output.push(@lib.Instruction::local_get(core_local(index_local)))
  output.push(core_i32(1))
  output.push(@lib.Instruction::i32_add())
  output.push(@lib.Instruction::local_set(core_local(index_local)))
}

///|
/// Builds the bounded Dew UTF-8 String to MoonBit UTF-16 String adapter.
fn core_dew_to_moonbit_string_adapter(
  dew_chunks_type : Int,
  dew_text_type : Int,
  moonbit_string_type : Int,
  target_function : Int,
  scratch_memory : Int,
) -> @lib.Func {
  let text = 1
  let chunks = 2
  let start = 3
  let length = 4
  let input_index = 5
  let utf16_length = 6
  let absolute = 7
  let byte = 8
  let output_string = 9
  let output_index = 10
  let codepoint = 11
  let b1 = 12
  let b2 = 13
  let b3 = 14
  let body : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(core_local(0)),
    @lib.Instruction::ref_as_non_null(),
    @lib.Instruction::ref_cast_type(
      @lib.RefType::new(
        false,
        @lib.HeapType::new(
          @lib.TypeIdx::new(dew_text_type.reinterpret_as_uint()),
        ),
      ),
    ),
    @lib.Instruction::local_tee(core_local(text)),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(dew_text_type.reinterpret_as_uint()),
      0U,
    ),
    @lib.Instruction::local_set(core_local(chunks)),
    @lib.Instruction::local_get(core_local(text)),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(dew_text_type.reinterpret_as_uint()),
      1U,
    ),
    @lib.Instruction::local_set(core_local(start)),
    @lib.Instruction::local_get(core_local(text)),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(dew_text_type.reinterpret_as_uint()),
      2U,
    ),
    @lib.Instruction::local_set(core_local(length)),
    core_i32(0),
    @lib.Instruction::local_set(core_local(input_index)),
    core_i32(0),
    @lib.Instruction::local_set(core_local(utf16_length)),
  ]
  let count_loop : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(core_local(input_index)),
    @lib.Instruction::local_get(core_local(length)),
    @lib.Instruction::i32_ge_u(),
    @lib.Instruction::br_if(@lib.LabelIdx::new(1U)),
  ]
  core_append_dew_string_byte_load(
    count_loop, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    0,
  )
  count_loop.push(@lib.Instruction::local_tee(core_local(byte)))
  count_loop.push(core_i32(0xC0))
  count_loop.push(@lib.Instruction::i32_and())
  count_loop.push(core_i32(0x80))
  count_loop.push(@lib.Instruction::i32_ne())
  let add_units : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(core_local(utf16_length)),
    @lib.Instruction::local_get(core_local(byte)),
    core_i32(0xF0),
    @lib.Instruction::i32_ge_u(),
    @lib.Instruction::if_(
      @lib.BlockType::val_type(@lib.ValType::i32()),
      [core_i32(2)],
      Some([core_i32(1)]),
    ),
    @lib.Instruction::i32_add(),
    @lib.Instruction::local_set(core_local(utf16_length)),
  ]
  count_loop.push(
    @lib.Instruction::if_(@lib.BlockType::void_(), add_units, None),
  )
  count_loop.push(@lib.Instruction::local_get(core_local(input_index)))
  count_loop.push(core_i32(1))
  count_loop.push(@lib.Instruction::i32_add())
  count_loop.push(@lib.Instruction::local_set(core_local(input_index)))
  count_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  body.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(count_loop),
        ),
      ]),
    ),
  )
  body.push(@lib.Instruction::local_get(core_local(utf16_length)))
  body.push(
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(moonbit_string_type.reinterpret_as_uint()),
    ),
  )
  body.push(@lib.Instruction::local_set(core_local(output_string)))
  body.push(core_i32(0))
  body.push(@lib.Instruction::local_set(core_local(input_index)))
  body.push(core_i32(0))
  body.push(@lib.Instruction::local_set(core_local(output_index)))
  let decode_loop : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(core_local(input_index)),
    @lib.Instruction::local_get(core_local(length)),
    @lib.Instruction::i32_ge_u(),
    @lib.Instruction::br_if(@lib.LabelIdx::new(1U)),
  ]
  core_append_dew_string_byte_load(
    decode_loop, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    0,
  )
  decode_loop.push(@lib.Instruction::local_set(core_local(byte)))
  let ascii : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(core_local(byte)),
    @lib.Instruction::local_set(core_local(codepoint)),
  ]
  core_append_array_set_from_local(
    ascii, moonbit_string_type, output_string, output_index, codepoint,
  )
  ascii.push(core_i32(1))
  let two : Array[@lib.Instruction] = []
  core_append_dew_string_byte_load(
    two, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute, 1,
  )
  two.push(@lib.Instruction::local_set(core_local(b1)))
  two.push(@lib.Instruction::local_get(core_local(byte)))
  two.push(core_i32(0x1F))
  two.push(@lib.Instruction::i32_and())
  two.push(core_i32(6))
  two.push(@lib.Instruction::i32_shl())
  two.push(@lib.Instruction::local_get(core_local(b1)))
  two.push(core_i32(0x3F))
  two.push(@lib.Instruction::i32_and())
  two.push(@lib.Instruction::i32_or())
  two.push(@lib.Instruction::local_set(core_local(codepoint)))
  core_append_array_set_from_local(
    two, moonbit_string_type, output_string, output_index, codepoint,
  )
  two.push(core_i32(2))
  let three : Array[@lib.Instruction] = []
  core_append_dew_string_byte_load(
    three, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    1,
  )
  three.push(@lib.Instruction::local_set(core_local(b1)))
  core_append_dew_string_byte_load(
    three, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    2,
  )
  three.push(@lib.Instruction::local_set(core_local(b2)))
  three.push(@lib.Instruction::local_get(core_local(byte)))
  three.push(core_i32(0x0F))
  three.push(@lib.Instruction::i32_and())
  three.push(core_i32(12))
  three.push(@lib.Instruction::i32_shl())
  three.push(@lib.Instruction::local_get(core_local(b1)))
  three.push(core_i32(0x3F))
  three.push(@lib.Instruction::i32_and())
  three.push(core_i32(6))
  three.push(@lib.Instruction::i32_shl())
  three.push(@lib.Instruction::i32_or())
  three.push(@lib.Instruction::local_get(core_local(b2)))
  three.push(core_i32(0x3F))
  three.push(@lib.Instruction::i32_and())
  three.push(@lib.Instruction::i32_or())
  three.push(@lib.Instruction::local_set(core_local(codepoint)))
  core_append_array_set_from_local(
    three, moonbit_string_type, output_string, output_index, codepoint,
  )
  three.push(core_i32(3))
  let four : Array[@lib.Instruction] = []
  core_append_dew_string_byte_load(
    four, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    1,
  )
  four.push(@lib.Instruction::local_set(core_local(b1)))
  core_append_dew_string_byte_load(
    four, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    2,
  )
  four.push(@lib.Instruction::local_set(core_local(b2)))
  core_append_dew_string_byte_load(
    four, dew_chunks_type, scratch_memory, chunks, start, input_index, absolute,
    3,
  )
  four.push(@lib.Instruction::local_set(core_local(b3)))
  four.push(@lib.Instruction::local_get(core_local(byte)))
  four.push(core_i32(7))
  four.push(@lib.Instruction::i32_and())
  four.push(core_i32(18))
  four.push(@lib.Instruction::i32_shl())
  for pair in [(b1, 12), (b2, 6), (b3, 0)] {
    let (slot, shift) = pair
    four.push(@lib.Instruction::local_get(core_local(slot)))
    four.push(core_i32(0x3F))
    four.push(@lib.Instruction::i32_and())
    if shift != 0 {
      four.push(core_i32(shift))
      four.push(@lib.Instruction::i32_shl())
    }
    four.push(@lib.Instruction::i32_or())
  }
  four.push(core_i32(0x10000))
  four.push(@lib.Instruction::i32_sub())
  four.push(@lib.Instruction::local_set(core_local(codepoint)))
  four.push(@lib.Instruction::local_get(core_local(codepoint)))
  four.push(core_i32(10))
  four.push(@lib.Instruction::i32_shr_u())
  four.push(core_i32(0xD800))
  four.push(@lib.Instruction::i32_add())
  four.push(@lib.Instruction::local_set(core_local(b1)))
  core_append_array_set_from_local(
    four, moonbit_string_type, output_string, output_index, b1,
  )
  four.push(@lib.Instruction::local_get(core_local(codepoint)))
  four.push(core_i32(0x3FF))
  four.push(@lib.Instruction::i32_and())
  four.push(core_i32(0xDC00))
  four.push(@lib.Instruction::i32_add())
  four.push(@lib.Instruction::local_set(core_local(b1)))
  core_append_array_set_from_local(
    four, moonbit_string_type, output_string, output_index, b1,
  )
  four.push(core_i32(4))
  let non_ascii = [
    @lib.Instruction::local_get(core_local(byte)),
    core_i32(0xE0),
    @lib.Instruction::i32_lt_u(),
    @lib.Instruction::if_(
      @lib.BlockType::val_type(@lib.ValType::i32()),
      two,
      Some([
        @lib.Instruction::local_get(core_local(byte)),
        core_i32(0xF0),
        @lib.Instruction::i32_lt_u(),
        @lib.Instruction::if_(
          @lib.BlockType::val_type(@lib.ValType::i32()),
          three,
          Some(four),
        ),
      ]),
    ),
  ]
  decode_loop.push(@lib.Instruction::local_get(core_local(byte)))
  decode_loop.push(core_i32(0x80))
  decode_loop.push(@lib.Instruction::i32_lt_u())
  decode_loop.push(
    @lib.Instruction::if_(
      @lib.BlockType::val_type(@lib.ValType::i32()),
      ascii,
      Some(non_ascii),
    ),
  )
  decode_loop.push(@lib.Instruction::local_get(core_local(input_index)))
  decode_loop.push(@lib.Instruction::i32_add())
  decode_loop.push(@lib.Instruction::local_set(core_local(input_index)))
  decode_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  body.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(decode_loop),
        ),
      ]),
    ),
  )
  body.push(@lib.Instruction::local_get(core_local(output_string)))
  body.push(
    @lib.Instruction::call(
      @lib.FuncIdx::new(target_function.reinterpret_as_uint()),
    ),
  )
  @lib.Func::new(
    @lib.Locals::from_types([
      @lib.ValType::ref_type(
        @lib.RefType::new(
          false,
          @lib.HeapType::new(
            @lib.TypeIdx::new(dew_text_type.reinterpret_as_uint()),
          ),
        ),
      ),
      @lib.ValType::ref_type(
        @lib.RefType::new(
          false,
          @lib.HeapType::new(
            @lib.TypeIdx::new(dew_chunks_type.reinterpret_as_uint()),
          ),
        ),
      ),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::ref_type(
        @lib.RefType::new(
          false,
          @lib.HeapType::new(
            @lib.TypeIdx::new(moonbit_string_type.reinterpret_as_uint()),
          ),
        ),
      ),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
      @lib.ValType::i32(),
    ]),
    @lib.Expr::new(body),
  )
}
