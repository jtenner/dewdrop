///|
// Every source fragment has exactly one linked record, including logical-only
// fragments. Synthetic erased adapters have an explicit target instead.
pub fn verify_program_source_function_fragments(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramFunctionLookupFailure] {
  let seen = link.modules.map(fn(module_) {
    Array::make(module_.functions.length(), false)
  })
  for slot, function_ in link.functions {
    if function_.fragment_index == -1 && function_.erased_adapter_target >= 0 {
      continue
    }
    match
      check_program_source_function_lookup(
        link,
        function_.declaration,
        slot,
        false,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    // Owner and fragment bounds were checked before these reads.
    let owned = seen[function_.module_index]
    let index = function_.fragment_index
    guard !owned[index] else {
      return Err(
        program_function_lookup_failure(
          function_.declaration,
          404,
          1UL,
          2UL,
          slot.to_uint64(),
        ),
      )
    }
    owned[index] = true
  }
  for module_index, owned in seen {
    for fragment_index, present in owned {
      guard present else {
        return Err(
          program_function_lookup_failure(
            link.modules[module_index].functions[fragment_index].declaration,
            404,
            1UL,
            0UL,
            (module_index.to_uint64() << 32) | fragment_index.to_uint64(),
          ),
        )
      }
    }
  }
  Ok(())
}

///|
fn assert_program_source_function_fragments(
  link : PlannedProgramWasmGCLink,
) -> Unit {
  match verify_program_source_function_fragments(link) {
    Ok(_) => ()
    Err(error) => abort(@debug.to_string(error))
  }
}
