///|
fn pb_write_raw_struct_get(
  writer : @cache_binary.Writer,
  recipe : RawStructGetRecipe,
) -> Unit {
  writer.write_bytes(recipe.opcode)
  ib_write_int(writer, recipe.field_index)
  match recipe.owner {
    DeclaredRawStructOwner(declaration) => {
      writer.write_byte(0)
      ib_write_id(writer, declaration)
    }
    PrimitiveRawStructOwner(primitive) => {
      writer.write_byte(1)
      ib_write_primitive(writer, primitive)
    }
    InvalidRawStructOwner(reason) => {
      writer.write_byte(2)
      ib_write_int(writer, reason)
    }
  }
}

///|
fn pb_read_raw_struct_get(
  reader : @cache_binary.Reader,
  field : String,
) -> RawStructGetRecipe {
  let opcode = reader.read_bytes(planning_binary_maximum_text, field)
  let field_index = ib_read_int(reader, field)
  let owner = match reader.read_byte(field) {
    0 => DeclaredRawStructOwner(ib_read_id(reader, field))
    1 => PrimitiveRawStructOwner(ib_read_primitive(reader, field))
    2 => InvalidRawStructOwner(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown raw struct owner discriminant")
      InvalidRawStructOwner(0)
    }
  }
  { opcode, owner, field_index, }
}
