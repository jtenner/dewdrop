///|
test "qualified imported function references retain their checked declaration" {
  for
    consumer in [
      b"import app.library as @lib\npub fn run() -> I64 {\n  let callback = @lib.read\n  callback(42i64)\n}\n",
      b"import app.library as @lib\nfn apply(callback: fn(I64) -> I64) -> I64 {\n  callback(42i64)\n}\npub fn run() -> I64 {\n  apply(@lib.read)\n}\n",
      b"import app.library as @lib\npub fn factory() -> fn(I64) -> I64 {\n  @lib.read\n}\n",
    ] {
    let (program, frozen, _, names, inferred) = imported_semantic_program(
      consumer, b"fn hidden(value: I32) -> I32 {\n  value\n}\npub fn read(value: I64) -> I64 {\n  value\n}\n",
    )
    assert_eq(program.diagnostics, [])
    assert_eq(program.modules[0].diagnostics, [])
    assert_eq(program.modules[1].diagnostics, [])
    assert_eq(frozen.import_diagnostics, [])
    assert_eq(names.diagnostics, [])
    assert_eq(inferred.diagnostics, [])
    let declaration = frozen.interfaces[1].callables_named("read")[0].declaration
    let mut selected = 0
    for expression, selection in inferred.expression_selections {
      if program.modules[0].expressions[expression] is HirQualifiedExpr(_, _, _) &&
        selection is FunctionReferenceSelection(actual, arguments) {
        assert_eq(actual, declaration)
        assert_eq(arguments.length, 0)
        selected += 1
      }
    }
    assert_eq(selected, 1)
  }
}

///|
test "qualified generic references use the expected signature" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"import app.library as @lib\npub fn factory() -> fn(I64) -> I64 {\n  @lib.read\n}\n",
    b"pub fn read<t>(value: t) -> t {\n  value\n}\n",
  )
  assert_eq(program.modules[0].diagnostics, [])
  assert_eq(program.modules[1].diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  let declaration = frozen.interfaces[1].callables_named("read")[0].declaration
  let mut selected = 0
  for selection in inferred.expression_selections {
    if selection is FunctionReferenceSelection(actual, arguments) {
      assert_eq(actual, declaration)
      assert_eq(arguments.length, 1)
      selected += 1
    }
  }
  assert_eq(selected, 1)
}

///|
test "qualified overloaded references use the expected signature" {
  let (program, frozen, imports, names, inferred) = imported_semantic_program(
    b"import app.library as @lib\npub fn factory() -> fn(I64) -> I64 {\n  @lib.read\n}\n",
    b"pub builtin read(value: I32) -> I32 = \"i32.clz\"\npub builtin read(value: I64) -> I64 = \"i64.clz\"\n",
  )
  assert_eq(program.modules[0].diagnostics, [])
  assert_eq(program.modules[1].diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  let resolved = frozen.interfaces[0].resolved_types
  let mut selected = 0
  for selection in inferred.expression_selections {
    if selection is FunctionReferenceSelection(declaration, arguments) {
      assert_eq(arguments.length, 0)
      let callable = imports.callable(declaration).unwrap()
      match resolved.types[callable.function_type] {
        FunctionType(parameters, result) => {
          assert_eq(parameters.length, 1)
          assert_eq(
            resolved.types[resolved.type_arguments[parameters.start]],
            PrimitiveType(I64Type),
          )
          assert_eq(resolved.types[result], PrimitiveType(I64Type))
        }
        _ => fail("expected an imported function signature")
      }
      selected += 1
    }
  }
  assert_eq(selected, 1)
}

///|
test "qualified private function references remain unavailable" {
  let (program, _, _, names, inferred) = imported_semantic_program(
    b"import app.library as @lib\npub fn factory() -> fn(I64) -> I64 {\n  @lib.hidden\n}\n",
    b"fn hidden(value: I64) -> I64 {\n  value\n}\n",
  )
  assert_eq(program.modules[0].diagnostics, [])
  assert_eq(program.modules[1].diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics.length(), 1)
  assert_true(inferred.diagnostics[0] is UnsupportedExpressionInference(_, _))
  for selection in inferred.expression_selections {
    assert_false(selection is FunctionReferenceSelection(_, _))
  }
}

///|
test "qualified references distinguish equal logical file paths" {
  let program = collect_program_manifest(
    1803UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "shared.dew", b"import app.left as @left\nimport app.right as @right\npub fn run() -> I64 {\n  let first = @left.read\n  let second = @right.read\n  first(second(42i64))\n}\n",
        ),
      ]),
      ManifestModule::new("app.left", [
        ManifestFile::new(
          "shared.dew", b"pub fn read(value: I64) -> I64 {\n  value\n}\n",
        ),
      ]),
      ManifestModule::new("app.right", [
        ManifestFile::new(
          "shared.dew", b"pub fn read(value: I64) -> I64 {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let declarations = [
    program.modules[1].lookup_value("read").unwrap(),
    program.modules[2].lookup_value("read").unwrap(),
  ]
  let mut selected = 0
  for selection in analyzed.modules[0].inferred.expression_selections {
    if selection is FunctionReferenceSelection(declaration, arguments) {
      assert_eq(declaration, declarations[selected])
      assert_eq(arguments.length, 0)
      selected += 1
    }
  }
  assert_eq(selected, 2)
}

///|
test "qualified overloaded references diagnose absent and wrong expected types" {
  let (program, _, _, names, inferred) = imported_semantic_program(
    b"import app.library as @lib\nfn missing() -> Unit {\n  let callback = @lib.read\n}\nfn mismatch() -> fn(Bool) -> Bool {\n  @lib.read\n}\n",
    b"pub builtin read(value: I32) -> I32 = \"i32.clz\"\npub builtin read(value: I64) -> I64 = \"i64.clz\"\n",
  )
  assert_eq(program.modules[0].diagnostics, [])
  assert_eq(program.modules[1].diagnostics, [])
  assert_eq(names.diagnostics, [])
  let mut expected_required = 0
  let mut no_match = 0
  for diagnostic in inferred.diagnostics {
    match diagnostic {
      FunctionReferenceExpectedTypeRequired(_, _, _) => expected_required += 1
      NoMatchingFunctionReference(_, _, _) => no_match += 1
      _ => ()
    }
  }
  assert_eq(expected_required, 1)
  assert_eq(no_match, 1)
}
