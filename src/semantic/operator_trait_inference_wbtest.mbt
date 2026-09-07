///|
fn operator_trait_test_source() -> Bytes {
  b"builtin i32_add(left: I32, right: I32) -> I32 = \"i32.add\"\nbuiltin i32_sub(left: I32, right: I32) -> I32 = \"i32.sub\"\nbuiltin i32_lte(left: I32, right: I32) -> Bool = \"i32.le_s\"\ntrait Add {\n  fn add(self, right: Self) -> Self\n}\ntrait Sub {\n  fn sub(self, right: Self) -> Self\n}\ntrait Lte {\n  fn lte(self, right: Self) -> Bool\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    i32_add(self, right)\n  }\n}\nimpl Sub for I32 {\n  fn sub(self, right: I32) -> I32 {\n    i32_sub(self, right)\n  }\n}\nimpl Lte for I32 {\n  fn lte(self, right: I32) -> Bool {\n    i32_lte(self, right)\n  }\n}\npub fn fib(value: I32) -> I32 {\n  if value <= 1 {\n    value\n  } else {\n    fib(value - 1) + fib(value - 2)\n  }\n}\n"
}

///|
test "binary operators select exact standard trait implementations" {
  let collected = collect_bytes(991UL, operator_trait_test_source())
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  let fib = collected.lookup_value("fib").unwrap()
  let body = collected.body_of(fib).unwrap()
  let selected : Array[DeclId] = []
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirBinaryExpr(_, _, _, _) =>
        match inferred.operator_targets[expression] {
          SelectedInferredCallTarget(declaration, _) =>
            selected.push(declaration)
          _ => fail("expected selected operator implementation")
        }
      _ => ()
    }
  }
  assert_eq(selected.length(), 4)
  let add_method = collected.methods[3].id
  let sub_method = collected.methods[4].id
  let lte_method = collected.methods[5].id
  assert_eq(selected[0], lte_method)
  assert_eq(selected[1], sub_method)
  assert_eq(selected[2], sub_method)
  assert_eq(selected[3], add_method)
}

///|
test "lowering preserves operator implementation evidence" {
  let collected = collect_bytes(992UL, operator_trait_test_source())
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  let lowering = plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  let fib = collected.lookup_value("fib").unwrap()
  let body = collected.body_of(fib).unwrap()
  let mut calls = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match lowering.expressions[expression].kind {
      PlannedOperatorCall(_, _, _, _, _) => calls += 1
      _ => ()
    }
  }
  assert_eq(calls, 4)
}

///|
test "String literal patterns select Eq without changing the literal type" {
  let collected = collect_bytes(
    993UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nimpl Eq for String {\n  fn eq(self, right: String) -> Bool {\n    true\n  }\n}\npub fn run(value: String) -> I32 {\n  match value {\n    \"ready\" => 1\n    _ => 0\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let inferred = infer_module_bodies(
    collected,
    resolved,
    resolve_module_names(collected),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let mut comparisons = 0
  for pattern in collected.patterns {
    match pattern {
      HirLiteralPattern(expression, _) => {
        assert_eq(
          planned_value_shape(
            resolved,
            inferred,
            inferred.expression_types[expression],
          ),
          RefPlannedValueShape,
        )
        match inferred.operator_targets[expression] {
          SelectedInferredCallTarget(declaration, arguments) => {
            assert_eq(declaration, collected.methods[1].id)
            assert_eq(arguments.length, 0)
            comparisons += 1
          }
          target => fail(@debug.to_string(target))
        }
      }
      _ => ()
    }
  }
  assert_eq(comparisons, 1)
}

///|
test "String literal patterns select an imported Eq without an explicit operator" {
  let program = collect_program_manifest_with_standard_sources(
    1800UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn run(value: String) -> I32 {\n  match value {\n    \"ready\" => 1\n    _ => 0\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nimpl Eq for String {\n  fn eq(self, right: String) -> Bool {\n    true\n  }\n}\n",
        ),
      ]),
    ]),
    StandardLibrarySources::bootstrap(),
    false,
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.import_diagnostics.length(), 0)
  let collected = program.modules[0]
  let resolved = frozen.interfaces[0].resolved_types
  let scope = frozen.import_scopes[0]
  let imports = resolve_module_imports(resolved, scope)
  let inferred = infer_module_bodies_with_imports(
    collected,
    resolved,
    imports,
    resolve_module_names_with_imports(collected, scope),
  )
  assert_true(program.modules[0].find_name("eq") is Some(_))
  assert_true(imports.scope.lookup_trait("Eq") is Some(_))
  assert_eq(inferred.diagnostics.length(), 0)
  let mut comparisons = 0
  for pattern in program.modules[0].patterns {
    match pattern {
      HirLiteralPattern(expression, _) =>
        match inferred.operator_targets[expression] {
          SelectedInferredCallTarget(declaration, _) => {
            assert_eq(declaration, program.modules[1].methods[1].id)
            comparisons += 1
          }
          target => fail(@debug.to_string(target))
        }
      _ => ()
    }
  }
  assert_eq(comparisons, 1)
}

///|
test "String literal patterns report a missing Eq implementation" {
  let collected = collect_bytes(
    994UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\npub fn run(value: String) -> I32 {\n  match value {\n    \"ready\" => 1\n    _ => 0\n  }\n}\n",
  )
  let inferred = infer_module_bodies(
    collected,
    resolve_module_types(collected),
    resolve_module_names(collected),
  )
  let mut comparisons = 0
  for pattern in collected.patterns {
    match pattern {
      HirLiteralPattern(expression, offset) => {
        assert_eq(
          inferred.operator_targets[expression],
          ErrorInferredCallTarget,
        )
        assert_eq(inferred.diagnostics, [
          NoMatchingMethod(
            collected.find_name("eq").unwrap(),
            expression,
            offset,
          ),
        ])
        comparisons += 1
      }
      _ => ()
    }
  }
  assert_eq(comparisons, 1)
}
