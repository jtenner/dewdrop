///|
pub struct RawRefCastRecipe {
  opcode : Bytes
  target : RawHeapOwner
} derive(Eq, Debug)

///|
pub enum RawHeapInstruction {
  RawStructGetInstruction(RawStructGetRecipe)
  RawRefCastInstruction(RawRefCastRecipe)
} derive(Eq, Debug)

///|
pub fn RawHeapInstruction::opcode(self : RawHeapInstruction) -> Bytes {
  match self {
    RawStructGetInstruction(recipe) => recipe.opcode
    RawRefCastInstruction(recipe) => recipe.opcode
  }
}

///|
fn raw_ref_cast_opcode(name : Bytes) -> Bool {
  let prefix = b"ref.cast"
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
fn raw_ref_cast_recipe(
  resolved : ResolvedModuleTypes,
  callable : PlannedCallable,
  opcode : Bytes,
) -> RawRefCastRecipe {
  {
    opcode,
    target: if callable.has_receiver || callable.parameters.length != 1 {
      InvalidRawHeapOwner(1)
    } else if callable.result_type >= 0 &&
      callable.result_type < resolved.types.length() &&
      resolved.types[callable.result_type] is AppliedType(_, _) {
      // A declaration ID alone cannot certify a specialized generic heap.
      InvalidRawHeapOwner(3)
    } else {
      raw_heap_owner(resolved, callable.result_type)
    },
  }
}
