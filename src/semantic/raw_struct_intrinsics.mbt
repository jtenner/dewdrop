///|
pub enum RawHeapOwner {
  DeclaredRawHeapOwner(DeclId)
  PrimitiveRawHeapOwner(PrimitiveType)
  InvalidRawHeapOwner(Int)
} derive(Eq, Debug)

///|
pub struct RawStructGetRecipe {
  opcode : Bytes
  owner : RawHeapOwner
  field_index : Int
} derive(Eq, Debug)

///|
// The opcode owns its immediate. Source declaration spelling has no meaning.
pub fn raw_struct_get_opcode(name : Bytes) -> Bool {
  let prefix = b"struct.get"
  if name.length() < prefix.length() {
    return false
  }
  for index in 0..<prefix.length() {
    if name[index] != prefix[index] {
      return false
    }
  }
  true
}

///|
pub fn raw_struct_get_field(name : Bytes) -> Int? {
  if !raw_struct_get_opcode(name) || name.length() < 12 || name[10] != b' ' {
    return None
  }
  if name.length() > 12 && name[11] == b'0' {
    return None
  }
  let mut field = 0
  for index in 11..<name.length() {
    if name[index] < b'0' || name[index] > b'9' {
      return None
    }
    let digit = name[index].to_int() - 48
    if field > (2147483647 - digit) / 10 {
      return None
    }
    field = field * 10 + digit
  }
  Some(field)
}

///|
fn raw_struct_get_owner(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
) -> RawHeapOwner {
  if callable.has_receiver ||
    callable.parameters.length != 1 ||
    callable.parameters.start < 0 ||
    callable.parameters.start >= functions.parameters.length() {
    return InvalidRawHeapOwner(1)
  }
  raw_heap_owner(resolved, functions.parameters[callable.parameters.start].type_)
}

///|
fn raw_heap_owner(
  resolved : ResolvedModuleTypes,
  initial : ResolvedTypeId,
) -> RawHeapOwner {
  let mut type_ = initial
  // Failure stays invalid metadata, never a fabricated reference owner.
  for _ in 0..<resolved.types.length() {
    if type_ < 0 || type_ >= resolved.types.length() {
      return InvalidRawHeapOwner(2)
    }
    match resolved.types[type_] {
      AppliedType(base, _) => type_ = base
      NominalType(declaration) => return DeclaredRawHeapOwner(declaration)
      PrimitiveType(primitive) => return PrimitiveRawHeapOwner(primitive)
      _ => return InvalidRawHeapOwner(3)
    }
  }
  InvalidRawHeapOwner(4)
}

///|
fn raw_struct_get_recipe(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
  opcode : Bytes,
) -> RawStructGetRecipe {
  {
    opcode,
    owner: raw_struct_get_owner(resolved, functions, callable),
    field_index: raw_struct_get_field(opcode).unwrap_or(-1),
  }
}
