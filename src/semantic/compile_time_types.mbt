///|
// Declaration and generic-parameter IDs belong to separate arenas.
enum CompileTimeBindingKey {
  CtGenericBinding(GenericParameterId)
  CtSelfBinding(DeclId)
} derive(Eq, Hash, Debug)

///|
// Logical types, before ABI canonicalization. Nominal IDs remain nominal even
// when two declarations happen to have the same physical representation.
enum CompileTimeType {
  CtError
  CtUnknown
  CtPrimitive(PrimitiveType)
  CtParameter(GenericParameterId)
  CtNominal(DeclId)
  CtTrait(DeclId)
  CtProduct(Array[CompileTimeType])
  CtApplied(CompileTimeType, Array[CompileTimeType])
  CtFunction(Array[CompileTimeType], CompileTimeType)
  CtMemberProjection(CompileTimeType, Bytes, String)
} derive(Eq, Debug)

///|
enum CompileTimeConstant {
  CtBool(Bool)
  CtU32(Int)
  CtStringArray(Array[Bytes])
} derive(Eq, Debug)

///|
enum CompileTimeTypeError {
  CtUnknownBuiltin(Bytes)
  CtTypeArity(Bytes, Int, Int)
  CtInvalidType
  CtWrongTypeCategory(Bytes)
  CtTypeLimitExceeded
  CtEvidenceContextRequired
} derive(Eq, Debug)

///|
fn compile_time_type_query_arity(name : Bytes) -> Int? {
  match name {
    b"types.type_equal" | b"types.can_bitcast" | b"types.implements" => Some(2)
    b"types.is_unit"
    | b"types.is_never"
    | b"types.is_integer"
    | b"types.is_signed_integer"
    | b"types.is_float"
    | b"types.bit_width"
    | b"types.lane_count"
    | b"types.lane_bit_width"
    | b"types.tuple_length"
    | b"types.field_names"
    | b"types.variant_names"
    | b"types.size_of"
    | b"types.field_offset"
    | b"types.align_of" => Some(1)
    _ => None
  }
}

///|
// Validate every argument before deciding that a query is pending. An error in
// a later argument must not be hidden by an earlier generic parameter.
fn compile_time_types_are_concrete(
  arguments : Array[CompileTimeType],
) -> Result[Bool, CompileTimeTypeError] {
  let work : Array[(CompileTimeType, Int)] = []
  for argument in arguments {
    work.push((argument, 0))
  }
  let mut concrete = true
  while work.length() > 0 {
    let (type_, depth) = work.pop().unwrap()
    if depth >= 256 {
      return Err(CtTypeLimitExceeded)
    }
    match type_ {
      CtError => return Err(CtInvalidType)
      CtUnknown | CtParameter(_) => concrete = false
      CtMemberProjection(owner, _, _) => {
        concrete = false
        work.push((owner, depth + 1))
      }
      CtApplied(base, arguments) => {
        work.push((base, depth + 1))
        for argument in arguments {
          work.push((argument, depth + 1))
        }
      }
      CtFunction(arguments, result) => {
        work.push((result, depth + 1))
        for argument in arguments {
          work.push((argument, depth + 1))
        }
      }
      CtProduct(fields) =>
        for field in fields {
          work.push((field, depth + 1))
        }
      CtPrimitive(_) | CtNominal(_) | CtTrait(_) => ()
    }
  }
  Ok(concrete)
}

///|
fn compile_time_integer_signedness(primitive : PrimitiveType) -> Bool? {
  match primitive {
    I8Type | I16Type | I32Type | I64Type => Some(true)
    U8Type | U16Type | U32Type | U64Type => Some(false)
    _ => None
  }
}

///|
fn compile_time_lanes(primitive : PrimitiveType) -> (Int, Int)? {
  match primitive {
    I8x4Type | U8x4Type => Some((4, 8))
    I16x2Type | U16x2Type => Some((2, 16))
    I8x8Type | U8x8Type => Some((8, 8))
    I16x4Type | U16x4Type => Some((4, 16))
    I32x2Type | U32x2Type => Some((2, 32))
    I8x16Type | U8x16Type => Some((16, 8))
    I16x8Type | U16x8Type => Some((8, 16))
    I32x4Type | U32x4Type | F32x4Type => Some((4, 32))
    I64x2Type | U64x2Type | F64x2Type => Some((2, 64))
    _ => None
  }
}

///|
fn compile_time_bit_width(primitive : PrimitiveType) -> Int? {
  match primitive {
    I8Type | U8Type => Some(8)
    I16Type | U16Type => Some(16)
    I32Type | U32Type | F32Type | Swar32Type => Some(32)
    I64Type | U64Type | F64Type | Swar64Type => Some(64)
    V128Type => Some(128)
    _ =>
      match compile_time_lanes(primitive) {
        Some((lanes, bits)) => Some(lanes * bits)
        None => None
      }
  }
}

///|
// This is the existing zero-instruction unsafe.bitcast contract, not the
// contract of the separate i32.reinterpret_f32 / f32.reinterpret_i32 opcodes.
fn compile_time_bitcast_carrier(type_ : CompileTimeType) -> Int? {
  match type_ {
    CtPrimitive(primitive) =>
      match primitive {
        BoolType
        | I8Type
        | U8Type
        | I16Type
        | U16Type
        | I32Type
        | U32Type
        | Swar32Type
        | I8x4Type
        | U8x4Type
        | I16x2Type
        | U16x2Type => Some(0)
        I64Type
        | U64Type
        | Swar64Type
        | I8x8Type
        | U8x8Type
        | I16x4Type
        | U16x4Type
        | I32x2Type
        | U32x2Type => Some(1)
        F32Type => Some(2)
        F64Type => Some(3)
        V128Type
        | I8x16Type
        | U8x16Type
        | I16x8Type
        | U16x8Type
        | I32x4Type
        | U32x4Type
        | I64x2Type
        | U64x2Type
        | F32x4Type
        | F64x2Type => Some(4)
        _ => None
      }
    _ => None
  }
}

///|
fn evaluate_compile_time_type_query(
  name : Bytes,
  arguments : Array[CompileTimeType],
) -> Result[CompileTimeConstant?, CompileTimeTypeError] {
  let arity = match compile_time_type_query_arity(name) {
    Some(value) => value
    None => return Err(CtUnknownBuiltin(name))
  }
  if arguments.length() != arity {
    return Err(CtTypeArity(name, arity, arguments.length()))
  }
  match compile_time_types_are_concrete(arguments) {
    Err(error) => return Err(error)
    Ok(false) => return Ok(None)
    Ok(true) => ()
  }
  let first = arguments[0]
  if name == b"types.field_names" || name == b"types.variant_names" {
    return Err(CtEvidenceContextRequired)
  }
  if name == b"types.size_of" || name == b"types.align_of" {
    let (size, alignment, _) = match compile_time_raw_layout(first, 0) {
      Ok(value) => value
      Err(CtTypeLimitExceeded) => return Err(CtTypeLimitExceeded)
      Err(_) => return Err(CtWrongTypeCategory(name))
    }
    return Ok(
      Some(
        CtU32(
          (if name == b"types.align_of" { alignment } else { size }).reinterpret_as_int(),
        ),
      ),
    )
  }
  if name == b"types.field_offset" {
    return Err(CtEvidenceContextRequired)
  }
  if name == b"types.implements" {
    return Err(CtEvidenceContextRequired)
  }
  if name == b"types.type_equal" {
    return Ok(Some(CtBool(first == arguments[1])))
  }
  if name == b"types.can_bitcast" {
    return Ok(
      Some(
        CtBool(
          match
            (
              compile_time_bitcast_carrier(first),
              compile_time_bitcast_carrier(arguments[1]),
            ) {
            (Some(left), Some(right)) => left == right
            _ => false
          },
        ),
      ),
    )
  }
  if name == b"types.is_unit" {
    return Ok(Some(CtBool(first == CtPrimitive(UnitType))))
  }
  if name == b"types.is_never" {
    return Ok(Some(CtBool(first == CtPrimitive(NeverType))))
  }
  if name == b"types.is_integer" || name == b"types.is_signed_integer" {
    let result = match first {
      CtPrimitive(primitive) =>
        match compile_time_integer_signedness(primitive) {
          Some(signed) => name == b"types.is_integer" || signed
          None => false
        }
      _ => false
    }
    return Ok(Some(CtBool(result)))
  }
  if name == b"types.is_float" {
    return Ok(
      Some(
        CtBool(first == CtPrimitive(F32Type) || first == CtPrimitive(F64Type)),
      ),
    )
  }
  if name == b"types.tuple_length" {
    return match first {
      CtProduct(fields) => Ok(Some(CtU32(fields.length())))
      _ => Err(CtWrongTypeCategory(name))
    }
  }
  match first {
    CtPrimitive(primitive) => {
      if name == b"types.bit_width" {
        return match compile_time_bit_width(primitive) {
          Some(bits) => Ok(Some(CtU32(bits)))
          None => Err(CtWrongTypeCategory(name))
        }
      }
      match compile_time_lanes(primitive) {
        Some((lanes, bits)) =>
          Ok(
            Some(CtU32(if name == b"types.lane_count" { lanes } else { bits })),
          )
        None => Err(CtWrongTypeCategory(name))
      }
    }
    _ => Err(CtWrongTypeCategory(name))
  }
}
