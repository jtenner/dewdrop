///|
fn selected_operator_test_lowering(
  source : Bytes,
) -> PlannedProgramLowering raise {
  let program = collect_program_manifest_with_standard_sources(
    99502UL,
    ProgramManifest::new([
      ManifestModule::new("app.operators", [
        ManifestFile::new("operators.dew", source),
      ]),
    ]),
    StandardLibrarySources::bootstrap(),
    false,
  )
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
    assert_eq(module_.inferred.impl_index.diagnostics, [])
  }
  plan_unoptimized_program_lowering(program, analyzed)
}

///|
fn selected_operator_test_expression(
  lowering : PlannedProgramLowering,
) -> ExprId raise {
  let mut selected = -1
  for index, expression in lowering.modules[0].expressions {
    if expression.kind is PlannedOperatorCall(_, _, _, _, _) {
      assert_eq(selected, -1)
      selected = index
    }
  }
  assert_true(selected >= 0)
  selected
}

///|
test "constant folding preserves a selected custom scalar result" {
  let original = selected_operator_test_lowering(
    b"trait Add {\n  fn add(self, right: Self) -> Self\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    77\n  }\n}\npub fn run() -> I32 {\n  1 + 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}

///|
test "constant folding preserves a selected custom scalar trap" {
  let original = selected_operator_test_lowering(
    b"builtin stop() -> Never = \"unreachable\"\ntrait Add {\n  fn add(self, right: Self) -> Self\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    stop()\n  }\n}\npub fn run() -> I32 {\n  1 + 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}

///|
test "constant folding preserves a selected custom Bool equality" {
  let original = selected_operator_test_lowering(
    b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nimpl Eq for Bool {\n  fn eq(self, right: Bool) -> Bool {\n    false\n  }\n}\npub fn run() -> Bool {\n  true == true\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}

///|
test "constant folding proves the opcode rather than the operator spelling" {
  let original = selected_operator_test_lowering(
    b"builtin different(left: I32, right: I32) -> I32 = \"i32.sub\"\ntrait Add {\n  fn add(self, right: Self) -> Self\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    different(self, right)\n  }\n}\npub fn run() -> I32 {\n  1 + 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}

///|
test "constant folding retains exact intrinsic forwarding with arbitrary names" {
  let original = selected_operator_test_lowering(
    b"builtin arbitrary(left: I32, right: I32) -> I32 = \"i32.add\"\ntrait Add {\n  fn add(self, right: Self) -> Self\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    arbitrary(self, right)\n  }\n}\npub fn run() -> I32 {\n  1 + 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    PlannedI32Const(3UL),
  )
  assert_true(
    original.modules[0].expressions[expression].kind
    is PlannedOperatorCall(_, _, _, _, _),
  )
}

///|
test "constant folding does not change reversed intrinsic arguments" {
  let original = selected_operator_test_lowering(
    b"builtin arbitrary(left: I32, right: I32) -> I32 = \"i32.sub\"\ntrait Sub {\n  fn sub(self, right: Self) -> Self\n}\nimpl Sub for I32 {\n  fn sub(self, right: I32) -> I32 {\n    arbitrary(right, self)\n  }\n}\npub fn run() -> I32 {\n  1 - 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}

///|
test "type query folding keeps imported standard operator evidence" {
  let program = compiler_test_single_module_program(
    99503UL, b"builtin width<T>() -> U32 = \"types.bit_width\"\npub fn run() -> U32 {\n  if width::<I32>() == 32u32 {\n    7u32\n  } else {\n    9u32\n  }\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let module_ = lowering.modules[0]
  let run = program.modules[0].lookup_value("run").unwrap()
  let root = optimization_test_body_tail(
    module_,
    program.modules[0].body_of(run).unwrap().id,
  )
  let selected = match module_.expressions[root].kind {
    PlannedBlockExpression(block) => block
    kind => fail("query did not select a branch: " + @debug.to_string(kind))
  }
  let items = module_.blocks[selected].items
  let value = match module_.block_items[items.start + items.length - 1].kind {
    PlannedExpressionItem(value) => value
    _ => fail("selected branch has no value")
  }
  assert_eq(module_.expressions[value].kind, PlannedU32Const(7UL))
}

///|
test "Boolean query checks retain proven source equality" {
  let program = compiler_test_single_module_program(
    99504UL, b"builtin unit<T>() -> Bool = \"types.is_unit\"\npub fn run() -> Bool {\n  unit::<Unit>() == true\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let run = program.modules[0].lookup_value("run").unwrap()
  let root = optimization_test_body_tail(
    lowering.modules[0],
    program.modules[0].body_of(run).unwrap().id,
  )
  assert_eq(lowering.modules[0].expressions[root].kind, PlannedBoolConst(true))
}

///|
test "constant folding and intrinsic forwarding retain a result trait coercion" {
  let original = selected_operator_test_lowering(
    b"builtin sum(left: I32, right: I32) -> I32 = \"i32.add\"\ntrait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Add {\n  fn add(self, right: Self) -> Value\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> Value {\n    sum(self, right)\n  }\n}\npub fn run() -> I32 {\n  (1 + 2).value()\n}\n",
  )
  let module_ = original.modules[0]
  let expression = selected_operator_test_expression(original)
  let target = match module_.expressions[expression].kind {
    PlannedOperatorCall(target, _, _, _, _) => target
    _ => fail("missing operator call")
  }
  assert_true(module_.expressions.any(expression => {
    expression.trait_object_coercion is SelectedInferredTraitObjectCoercion(_, _)
  }))
  let builtins : Map[DeclId, Bytes] = {}
  for callable in module_.functions.callables {
    if callable.kind is PlannedBuiltinCallable(name) {
      builtins[callable.declaration] = name
    }
  }
  assert_eq(
    wasmgc_direct_builtin_of(
      module_, module_.functions.callable_of(target).unwrap(), builtins,
    ),
    b"",
  )
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    module_.expressions[expression].kind,
  )
}

///|
test "constant folding keeps the selected signed to unsigned result type" {
  let original = selected_operator_test_lowering(
    b"builtin sum(left: I32, right: I32) -> U32 = \"i32.add\"\ntrait Add {\n  fn add(self, right: Self) -> U32\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> U32 {\n    sum(self, right)\n  }\n}\npub fn run() -> U32 {\n  1 + 2\n}\n",
  )
  let expression = selected_operator_test_expression(original)
  let optimized = optimize_program_lowering(original)
  assert_eq(
    optimized.modules[0].expressions[expression].kind,
    original.modules[0].expressions[expression].kind,
  )
}
