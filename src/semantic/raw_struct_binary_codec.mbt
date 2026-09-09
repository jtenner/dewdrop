///|
fn pb_write_raw_struct_get(
  writer : @cache_binary.Writer,
  recipe : RawStructGetRecipe,
) -> Unit {
  writer.write_bytes(recipe.opcode)
  ib_write_int(writer, recipe.field_index)
  pb_write_raw_heap_owner(writer, recipe.owner)
}

///|
fn pb_write_raw_heap_owner(writer : @cache_binary.Writer, owner : RawHeapOwner) -> Unit {
  match owner {
    DeclaredRawHeapOwner(declaration) => {
      writer.write_byte(0)
      ib_write_id(writer, declaration)
    }
    PrimitiveRawHeapOwner(primitive) => {
      writer.write_byte(1)
      ib_write_primitive(writer, primitive)
    }
    InvalidRawHeapOwner(reason) => {
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
  let owner = pb_read_raw_heap_owner(reader, field)
  { opcode, owner, field_index, }
}

///|
fn pb_read_raw_heap_owner(reader : @cache_binary.Reader, field : String) -> RawHeapOwner {
  match reader.read_byte(field) {
    0 => DeclaredRawHeapOwner(ib_read_id(reader, field))
    1 => PrimitiveRawHeapOwner(ib_read_primitive(reader, field))
    2 => InvalidRawHeapOwner(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown raw heap owner discriminant")
      InvalidRawHeapOwner(0)
    }
  }
}
