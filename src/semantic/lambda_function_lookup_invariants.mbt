///|
pub fn verify_module_lambda_function_lookups(
  module_ : PlannedModuleWasmGCFragments,
  selected_key~ : String = "",
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let indices = module_.lambda_function_indices
  let entries = module_.lambda_entry_signature_indices
  let count = module_.lambda_closure_type_indices.length()
  let failure = fn(code, expected, actual, role, slot) {
    physical_type_failure(
      module_.module_id,
      0UL,
      code,
      expected,
      actual,
      role,
      slot,
    )
  }
  guard indices.length() == count else {
    return Err(
      failure(103, count.to_uint64(), indices.length().to_uint64(), 120UL, 0),
    )
  }
  guard entries.length() == count else {
    return Err(
      failure(103, count.to_uint64(), entries.length().to_uint64(), 120UL, 1),
    )
  }
  let signature_limit = module_.physical_types.length().to_int64() +
    module_.signature_type_count.to_int64()
  guard module_.signature_type_count >= 0 && signature_limit <= 0x7fffffffL else {
    return Err(
      failure(
        101,
        0x7fffffffUL,
        signature_limit.reinterpret_as_uint64(),
        125UL,
        0,
      ),
    )
  }
  for lambda, index in indices {
    guard index >= -1 && index < module_.functions.length() else {
      return Err(
        failure(
          101,
          module_.functions.length().to_uint64(),
          index.reinterpret_as_uint().to_uint64(),
          121UL,
          lambda,
        ),
      )
    }
    let entry = entries[lambda]
    guard entry == -1 ||
      (
        entry >= module_.physical_types.length() &&
        entry.to_int64() < signature_limit
      ) else {
      return Err(
        failure(
          101,
          signature_limit.to_uint64(),
          entry.reinterpret_as_uint().to_uint64(),
          125UL,
          lambda,
        ),
      )
    }
    if index == -1 {
      guard entry == -1 else {
        return Err(failure(503, 1UL, 0UL, 130UL, lambda))
      }
      continue
    }
    let source = module_.functions[index]
    guard source.lambda == lambda else {
      return Err(
        failure(
          504,
          lambda.to_uint64(),
          source.lambda.reinterpret_as_uint().to_uint64(),
          122UL,
          lambda,
        ),
      )
    }
    let kind_lambda = match source.kind {
      PlannedWasmDefinedLambdaFunction(value) => value
      _ => -1
    }
    guard kind_lambda == lambda else {
      return Err(
        failure(
          504,
          lambda.to_uint64(),
          kind_lambda.reinterpret_as_uint().to_uint64(),
          123UL,
          lambda,
        ),
      )
    }
    guard source.specialization_abi_key == "" ||
      source.specialization_abi_key == selected_key else {
      return Err(failure(504, 1UL, 0UL, 131UL, lambda))
    }
    guard entry >= 0 && source.signature_type_index == entry else {
      return Err(
        failure(
          if entry == -1 {
            503
          } else {
            504
          },
          source.signature_type_index.reinterpret_as_uint().to_uint64(),
          entry.reinterpret_as_uint().to_uint64(),
          124UL,
          lambda,
        ),
      )
    }
  }
  // A selected view can replace a plain template with one exact instance.
  // Other instances remain in the arena; they need no base-map entry.
  let plain = Array::make(count, -1)
  for slot, source in module_.functions {
    let kind_lambda = match source.kind {
      PlannedWasmDefinedLambdaFunction(value) => value
      _ => -1
    }
    if source.lambda == -1 &&
      !(source.kind is PlannedWasmDefinedLambdaFunction(_)) {
      continue
    }
    guard source.lambda >= 0 && source.lambda < count else {
      return Err(
        failure(
          101,
          count.to_uint64(),
          source.lambda.reinterpret_as_uint().to_uint64(),
          126UL,
          slot,
        ),
      )
    }
    guard kind_lambda == source.lambda else {
      return Err(
        failure(
          504,
          source.lambda.to_uint64(),
          kind_lambda.reinterpret_as_uint().to_uint64(),
          127UL,
          slot,
        ),
      )
    }
    if source.specialization_abi_key != "" {
      continue
    }
    let lambda = source.lambda
    guard plain[lambda] == -1 else {
      return Err(
        failure(504, plain[lambda].to_uint64(), slot.to_uint64(), 128UL, lambda),
      )
    }
    plain[lambda] = slot
    let selected = indices[lambda]
    // The forward pass checked this index before any selected-record read.
    guard selected >= 0 else {
      return Err(
        failure(
          503,
          slot.to_uint64(),
          selected.reinterpret_as_uint().to_uint64(),
          129UL,
          lambda,
        ),
      )
    }
    if module_.functions[selected].specialization_abi_key == "" &&
      selected != slot {
      return Err(
        failure(504, slot.to_uint64(), selected.to_uint64(), 129UL, lambda),
      )
    }
  }
  Ok(())
}
