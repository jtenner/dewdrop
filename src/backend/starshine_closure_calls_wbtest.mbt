///|
test "generic callback signature matching requires full erased types" {
  let stages = backend_test_single_module_stages(
    28126UL, b"struct Item {\n  value: I64\n}\nfn identity<t>(value: t) -> t {\n  value\n}\nfn reader() -> fn(Item) -> Item {\n  identity\n}\npub fn run(value: I64) -> I64 {\n  let callback = reader()\n  callback(Item::{\n    value: value\n  }).value\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let mut seen = 0
  for type_ in stages.link.modules[0].function_value_types {
    match type_ {
      @semantic.WasmNullableEqRefValue => {
        assert_true(starshine_program_value_matches_code(type_, 5))
        seen = seen | 1
      }
      @semantic.WasmNominalRefValue(_) => {
        assert_false(starshine_program_value_matches_code(type_, 5))
        seen = seen | 2
      }
      @semantic.WasmI64Value => {
        assert_true(starshine_program_value_matches_code(type_, 1))
        assert_false(starshine_program_value_matches_code(type_, 0))
        seen = seen | 4
      }
      _ => ()
    }
  }
  assert_eq(seen, 7)
}

///|
test "missing callback signatures report the original call expression" {
  let stages = backend_test_single_module_stages(
    28127UL, b"pub fn run(value: I32) -> I32 {\n  value\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let plan : StarshineClosureCallPlan = {
    expression: 42,
    direct_type: -1,
    entry_type: 3,
    erased_direct_type: 4,
    erased_entry_type: 5,
    closure_type: 1,
    closure_local: 0,
    result_shape: stages.lowering.modules[0].expressions[0].shape,
    result_local: -1,
    result_cast_type: -1,
    argument_casts: [],
  }
  match starshine_emit_closure_call(123UL, plan, [[]]) {
    Err(UnsupportedExpression(body, expression)) => {
      assert_eq(body, 123UL)
      assert_eq(expression, 42)
    }
    _ => fail("missing callback signature must report its call site")
  }
}

///|
test "a diverging callback argument prevents operand planning and call emission" {
  let stages = backend_test_single_module_stages(
    28128UL, b"builtin stop() -> Never = \"unreachable\"\nfn later() -> I32 {\n  42i32\n}\npub fn run(operation: fn(I32, I32) -> I64) -> I64 {\n  operation(stop(), later())\n}\n",
  )
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      stages.program,
      stages.analyzed,
      stages.lowering,
      stages.link,
    ),
    [],
  )
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => {
      assert_eq(@validate.validate_module(module_), Ok(()))
      let declaration = stages.program.modules[0].lookup_value("run").unwrap()
      let function_ = stages.link.function_of(declaration).unwrap()
      let code = module_.pretty_print_func(
        @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
      )
      assert_false(code.contains("(call"), msg=code)
      assert_false(code.contains("I32(42)"), msg=code)
    }
    Err(error) => fail(@debug.to_string(error))
  }
}
