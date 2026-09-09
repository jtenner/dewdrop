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
    _ => {
      reader.fail(field, "unknown raw heap instruction discriminant")
      RawRefCastInstruction({ opcode: b"", target: InvalidRawHeapOwner(0), })
    }
  }
}
