///|
fn program_module_index_record(
  module_id : ModuleId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code, phase: 5, module_id, declaration: 0UL, body: 0UL,
    expression: 0xffffffffU, expected, actual, detail,
  }
}

///|
fn check_program_module_index(
  index : ProgramIndex,
  module_id : ModuleId,
) -> Result[Int?, ProgramFunctionLookupFailure] {
  let selected = match index.module_lookup.get(module_id) {
    None => return Ok(None)
    Some(selected) => selected
  }
  guard selected >= 0 && selected < index.indexed_modules.length() else {
    return Err(program_module_index_record(
      module_id, 101, index.indexed_modules.length().to_uint64(),
      selected.reinterpret_as_uint().to_uint64(), 0UL,
    ))
  }
  let actual = index.indexed_modules[selected].module_id
  guard actual == module_id else {
    return Err(program_module_index_record(
      module_id, 106, module_id, actual, selected.to_uint64(),
    ))
  }
  Ok(Some(selected))
}

///|
// The specialization pass also has direct map readers. Check the complete
// index against the pass's actual module array before any of those reads.
fn check_program_module_index_table(
  index : ProgramIndex,
  modules : Array[PlannedModuleLowering],
) -> Result[Unit, ProgramFunctionLookupFailure] {
  guard index.indexed_modules.length() == modules.length() else {
    return Err(program_module_index_record(
      0UL, 103, modules.length().to_uint64(),
      index.indexed_modules.length().to_uint64(), 0UL,
    ))
  }
  guard index.module_lookup.length() == modules.length() else {
    return Err(program_module_index_record(
      0UL, 103, modules.length().to_uint64(),
      index.module_lookup.length().to_uint64(), 1UL,
    ))
  }
  for slot, module_ in modules {
    let selected = match check_program_module_index(index, module_.module_id) {
      Err(failure) => return Err(failure)
      Ok(None) => return Err(program_module_index_record(
        module_.module_id, 105, 1UL, 0UL, slot.to_uint64(),
      ))
      Ok(Some(selected)) => selected
    }
    guard selected == slot else {
      return Err(program_module_index_record(
        module_.module_id, 106, slot.to_uint64(), selected.to_uint64(), 2UL,
      ))
    }
  }
  Ok(())
}
