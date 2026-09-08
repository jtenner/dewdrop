///|
// Function values and calls have separate type-argument arenas. A direct call
// replacement must copy the selected arguments and trait roots as one recipe.
fn directized_function_reference_arguments(
  module_ : PlannedModuleLowering,
  reference : ExprId,
  call : ExprId,
  arguments : HirSpan,
) -> HirSpan {
  guard reference >= 0 &&
    reference < module_.expressions.length() &&
    call >= 0 &&
    call < module_.expressions.length() else {
    abort("ARN-102 directized function reference expression ownership")
  }
  guard program_specialization_span_is_valid(
      arguments,
      module_.expression_type_arguments.length(),
    ) &&
    module_.expression_type_arguments.length() ==
    module_.expression_type_argument_shapes.length() &&
    module_.call_type_arguments.length() ==
    module_.call_type_argument_shapes.length() else {
    abort("ARN-103 directized function reference type arguments")
  }
  guard module_.expression_evidence.is_empty() ||
    module_.expression_evidence.length() == module_.expressions.length() else {
    abort("ARN-103 directized function reference evidence table")
  }
  let roots = if module_.expression_evidence.is_empty() {
    { start: 0, length: 0, }
  } else {
    module_.expression_evidence[reference]
  }
  guard program_specialization_span_is_valid(
    roots,
    module_.trait_evidence_roots.length(),
  ) else {
    abort("ARN-101 directized function reference evidence roots")
  }
  let start = module_.call_type_arguments.length()
  for offset in 0..<arguments.length {
    module_.call_type_arguments.push(
      module_.expression_type_arguments[arguments.start + offset],
    )
    module_.call_type_argument_shapes.push(
      module_.expression_type_argument_shapes[arguments.start + offset],
    )
  }
  if !module_.expression_evidence.is_empty() {
    module_.expression_evidence[call] = roots
  }
  { start, length: arguments.length, }
}
