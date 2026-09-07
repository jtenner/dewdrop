///|
struct ProgramFunctionIndexFailure {
  function_slot : Int
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///|
fn record_program_function_index(
  seen : Array[Bool],
  index : Int,
  slot : Int,
) -> Result[Unit, ProgramFunctionIndexFailure] {
  guard index >= 0 && index < seen.length() else {
    return Err({
      function_slot: slot,
      expected: seen.length(),
      actual: index,
      detail: 0,
    })
  }
  guard !seen[index] else {
    return Err({ function_slot: slot, expected: 0, actual: index, detail: 1, })
  }
  seen[index] = true
  Ok(())
}

///|
fn verify_program_function_indices(
  link : PlannedProgramWasmGCLink,
) -> Result[Unit, ProgramFunctionIndexFailure] {
  let imports = link.imported_function_count
  let definitions = link.defined_function_count
  guard imports >= 0 && definitions >= 0 && imports <= 2147483647 - definitions else {
    return Err({
      function_slot: -1,
      expected: 2147483647,
      actual: imports,
      detail: 3,
    })
  }
  let count = imports + definitions
  let maximum = link.functions.length() + link.initializers.length() + 1
  guard count <= maximum else {
    return Err({
      function_slot: -1,
      expected: maximum,
      actual: count,
      detail: 4,
    })
  }
  let seen = Array::make(count, false)
  for slot, function_ in link.functions {
    let has_function = match function_.kind {
      PlannedWasmInlineBuiltinFunction(_) | PlannedWasmSignatureOnlyFunction =>
        false
      _ => true
    }
    let emitted = !function_.elided && has_function
    if !emitted {
      guard function_.function_index == -1 else {
        return Err({
          function_slot: slot,
          expected: -1,
          actual: function_.function_index,
          detail: 5,
        })
      }
      continue
    }
    match record_program_function_index(seen, function_.function_index, slot) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
    let imported = function_.kind is PlannedWasmImportedFunction(_)
    guard imported == (function_.function_index < imports) else {
      return Err({
        function_slot: slot,
        expected: imports,
        actual: function_.function_index,
        detail: 6,
      })
    }
  }
  for slot, initializer in link.initializers {
    if !initializer.constant {
      match
        record_program_function_index(
          seen,
          initializer.function_index,
          link.functions.length() + slot,
        ) {
        Err(error) => return Err(error)
        Ok(_) => ()
      }
    }
  }
  if link.startup_function_index != -1 {
    match
      record_program_function_index(
        seen,
        link.startup_function_index,
        maximum - 1,
      ) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  for index, present in seen {
    guard present else {
      return Err({ function_slot: -1, expected: 1, actual: index, detail: 2, })
    }
  }
  Ok(())
}

///|
fn assert_program_function_indices(link : PlannedProgramWasmGCLink) -> Unit {
  match verify_program_function_indices(link) {
    Ok(_) => ()
    Err(failure) =>
      abort(
        "LNK-502 function_slot=\{failure.function_slot} expected=\{failure.expected} actual=\{failure.actual} detail=\{failure.detail}",
      )
  }
}
