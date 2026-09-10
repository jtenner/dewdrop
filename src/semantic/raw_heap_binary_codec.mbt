///|
fn pb_write_raw_heap_instruction(
  writer : @cache_binary.Writer,
  instruction : RawHeapInstruction,
) -> Unit {
  match instruction {
    RawStructGetInstruction(recipe) => {
      writer.write_byte(0)
      pb_write_raw_struct_get(writer, recipe)
    }
    RawRefCastInstruction(recipe) => {
      writer.write_byte(1)
      writer.write_bytes(recipe.opcode)
      pb_write_raw_heap_owner(writer, recipe.target)
    }
    RawArrayGetInstruction(recipe) => {
      writer.write_byte(2)
      writer.write_bytes(recipe.opcode)
      ib_write_shape(writer, recipe.element_shape)
    }
  }
}

///|
fn pb_read_raw_heap_instruction(
  reader : @cache_binary.Reader,
  field : String,
) -> RawHeapInstruction {
  match reader.read_byte(field) {
    0 => RawStructGetInstruction(pb_read_raw_struct_get(reader, field))
    1 => {
      let opcode = reader.read_bytes(planning_binary_maximum_text, field)
      let target = pb_read_raw_heap_owner(reader, field)
      RawRefCastInstruction({ opcode, target, })
    }
    2 => {
      let opcode = reader.read_bytes(planning_binary_maximum_text, field)
      let element_shape = ib_read_shape(reader, field)
      RawArrayGetInstruction({ opcode, element_shape, })
    }
    _ => {
      reader.fail(field, "unknown raw heap instruction discriminant")
      RawRefCastInstruction({ opcode: b"", target: InvalidRawHeapOwner(0), })
    }
  }
}
