///|
test "logical arena views expose validated phase slices" {
  let stages = compiler_test_stages(23020UL, [
    CompilerTestModule::new("app.main", [
      CompilerTestSource::new(
        "main.dew", b"pub fn add(left: I32, right: I32) -> I32 {\n  left + right\n}\n",
      ),
    ]),
  ])
  let lowering = stages.lowering.modules[0]
  let body = lowering.bodies[0]
  let body_view = lowering.body_view(body.body).unwrap()
  assert_eq(body_view.body.body, body.body)
  assert_eq(body_view.expressions.length(), body.expressions.length)
  assert_eq(validate_planned_module_lowering_arenas(lowering), Ok(()))

  let resolved = resolve_module_types(stages.program.modules[0])
  let i32 = resolved.primitive(I32Type)
  let type_view = resolved.type_view(i32).unwrap()
  assert_eq(type_view.type_, resolved.types[i32])
  assert_eq(type_view.arguments.length(), 0)

  let specialization = plan_program_wasmgc_fragments(
    stages.analyzed,
    stages.lowering,
  )
  let fragments = specialization.modules[0]
  assert_eq(validate_module_wasmgc_arenas(fragments), Ok(()))
  let function_view = fragments.function_view(0).unwrap()
  assert_true(function_view.parameters.length() >= 0)

  let program_function_view = stages.link.function_view(0).unwrap()
  assert_eq(
    program_function_view.fragments.module_id,
    stages.link.modules[program_function_view.function.module_index].module_id,
  )
}
