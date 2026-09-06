///|
// The raw tuple encoding is independent of the runtime GC tuple representation.
// Fields keep source order and natural alignment; the total includes tail padding.
fn compile_time_raw_align(size : UInt, alignment : UInt) -> UInt? {
  let remainder = size % alignment
  let padding = if remainder == 0U { 0U } else { alignment - remainder }
  if padding > 4294967295U - size {
    None
  } else {
    Some(size + padding)
  }
}

///|
fn compile_time_raw_layout(
  type_ : CompileTimeType,
  depth : Int,
) -> Result[(UInt, UInt, Array[UInt]), CompileTimeTypeError] {
  if depth >= 256 {
    return Err(CtTypeLimitExceeded)
  }
  match type_ {
    CtPrimitive(primitive) => {
      let size = match primitive {
        UnitType => 0U
        BoolType => 4U
        _ =>
          match compile_time_bit_width(primitive) {
            Some(bits) => (bits / 8).reinterpret_as_uint()
            None => return Err(CtInvalidType)
          }
      }
      Ok((size, if size == 0U { 1U } else { size }, []))
    }
    CtProduct(fields) => {
      let mut size = 0U
      let mut alignment = 1U
      let offsets = []
      for field in fields {
        let (field_size, field_alignment, _) = match
          compile_time_raw_layout(field, depth + 1) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        size = match compile_time_raw_align(size, field_alignment) {
          Some(value) => value
          None => return Err(CtInvalidType)
        }
        offsets.push(size)
        if field_size > 4294967295U - size {
          return Err(CtInvalidType)
        }
        size += field_size
        if field_alignment > alignment {
          alignment = field_alignment
        }
      }
      match compile_time_raw_align(size, alignment) {
        Some(value) => Ok((value, alignment, offsets))
        None => Err(CtInvalidType)
      }
    }
    _ => Err(CtInvalidType)
  }
}

///|
fn evaluate_compile_time_field_offset(
  types : Array[CompileTimeType],
  index : UInt,
) -> Result[CompileTimeConstant?, CompileTimeTypeError] {
  let name = b"types.field_offset"
  if types.length() != 1 {
    return Err(CtTypeArity(name, 1, types.length()))
  }
  match compile_time_types_are_concrete(types) {
    Err(error) => return Err(error)
    Ok(false) => return Ok(None)
    Ok(true) => ()
  }
  guard types[0] is CtProduct(_) else { return Err(CtWrongTypeCategory(name)) }
  match compile_time_raw_layout(types[0], 0) {
    Ok((_, _, offsets)) if index < offsets.length().reinterpret_as_uint() =>
      Ok(Some(CtU32(offsets[index.reinterpret_as_int()].reinterpret_as_int())))
    Err(CtTypeLimitExceeded) => Err(CtTypeLimitExceeded)
    _ => Err(CtWrongTypeCategory(name))
  }
}
