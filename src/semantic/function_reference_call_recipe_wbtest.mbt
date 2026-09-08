///|
test "directized callback copies its own type arguments and evidence" {
  let (_, lowering) = compile_time_evidence_test(
    b"trait Read {\n  fn read(self) -> I64\n}\nimpl Read for I64 {\n  fn read(self) -> I64 {\n    self\n  }\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\nfn invoke(callback: fn(I64) -> I64, value: I64) -> I64 {\n  callback(value)\n}\npub fn main(value: I64) -> I64 {\n  invoke(forward, value)\n}\n",
  )
  let module_ = lowering.modules[0]
  let mut reference = -1
  let mut call = -1
  let mut arguments = { start: 0, length: 0, }
  for index, expression in module_.expressions {
    match expression.kind {
      PlannedFunctionReference(_, span) => {
        reference = index
        arguments = span
      }
      PlannedDirectCall(_, _, _, _) => call = index
      _ => ()
    }
  }
  assert_true(reference >= 0 && call >= 0)
  assert_eq(arguments.length, 1)
  let roots = module_.expression_evidence[reference]
  assert_eq(roots.length, 1)
  let expected_type = module_.expression_type_arguments[arguments.start]
  let expected_shape = module_.expression_type_argument_shapes[arguments.start]
  // Deliberately separate the two arena positions. Reusing the reference span
  // as a call span would now select this unrelated scalar argument.
  module_.call_type_arguments.push(-1)
  module_.call_type_argument_shapes.push(I32PlannedValueShape)
  let start = module_.call_type_arguments.length()
  let copied = directized_function_reference_arguments(
    module_, reference, call, arguments,
  )
  assert_eq(copied, { start, length: 1, })
  assert_eq(module_.call_type_arguments[copied.start], expected_type)
  assert_eq(module_.call_type_argument_shapes[copied.start], expected_shape)
  assert_eq(module_.expression_evidence[call], roots)
  assert_eq(module_.expression_evidence[reference], roots)
}
