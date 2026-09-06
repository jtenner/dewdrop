///|
test "compile time builtin calls become IR constants without optimizer" {
  let program = collect_program_manifest(
    24001UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
        "main.dew", b"builtin query<t>() -> Bool = \"types.is_unit\"\ntype Nothing = Unit\npub fn yes() -> Bool {\n  query::<Nothing>()\n}\npub fn no() -> Bool {\n  query::<I32>()\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  assert_eq(program.modules[0].diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let mut constants = 0
  let mut calls = 0
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedBoolConst(_) => constants += 1
      PlannedDirectCall(_, _, _, _) => calls += 1
      _ => ()
    }
  }
  assert_eq(constants, 2)
  assert_eq(calls, 0)
  let yes = program.modules[0].body_of(program.modules[0].lookup_value("yes").unwrap()).unwrap()
  let tail = optimization_test_body_tail(lowering.modules[0], yes.id)
  assert_eq(lowering.modules[0].expressions[tail].kind, PlannedBoolConst(true))
}

///|
test "compile time builtin declaration result mismatch is a source diagnostic" {
  let program = collect_program_manifest(
    24002UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
        "main.dew", b"builtin query<t>() -> I32 = \"types.is_unit\"\npub fn main() -> I32 {\n  query::<Unit>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics.length(), 1)
  assert_true(
    lowering.modules[0].diagnostics[0]
    is CompileTimeQueryDiagnostic(
      _,
      "CT-003 query declaration has the wrong result type",
      _
    ),
  )
}

///|
test "ordinary functions named is_unit are not compile time builtins" {
  let program = collect_program_manifest(
    24003UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
        "main.dew", b"fn is_unit() -> Bool {\n  false\n}\npub fn main() -> Bool {\n  is_unit()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let mut calls = 0
  for expression in lowering.modules[0].expressions {
    if expression.kind is PlannedDirectCall(_, _, _, _) {
      calls += 1
    }
  }
  assert_eq(calls, 1)
}
