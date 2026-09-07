///|
fn compile_time_evidence_test(
  source : Bytes,
) -> (CollectedProgram, PlannedProgramLowering) raise {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  let analyzed = analyze_program_semantics(program)
  for interface_ in analyzed.frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.imports.scope.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  (program, plan_unoptimized_program_lowering(program, analyzed))
}

///|
test "compile time implements proves generic prerequisites and ordinary absence" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Mark {\n}\nstruct Box<t> {\n  value: t\n}\nimpl Mark for I32 {\n}\nimpl<t: Mark> Mark for Box<t> {\n}\npub fn yes() -> Bool {\n  implements::<Box<I32>, Mark>()\n}\npub fn no() -> Bool {\n  implements::<Box<I64>, Mark>()\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let yes = program.modules[0]
    .body_of(program.modules[0].lookup_value("yes").unwrap())
    .unwrap()
  let no = program.modules[0]
    .body_of(program.modules[0].lookup_value("no").unwrap())
    .unwrap()
  assert_eq(
    lowering.modules[0].expressions[optimization_test_body_tail(
      lowering.modules[0],
      yes.id,
    )].kind,
    PlannedBoolConst(true),
  )
  assert_eq(
    lowering.modules[0].expressions[optimization_test_body_tail(
      lowering.modules[0],
      no.id,
    )].kind,
    PlannedBoolConst(false),
  )
}

///|
test "compile time implements rejects a non trait argument" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> Bool {\n  implements::<I32, I64>()\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics.length(), 1)
  assert_true(
    lowering.modules[0].diagnostics[0]
    is CompileTimeQueryDiagnostic(
      _,
      "CT-014 implements requires a trait as its second argument",
      _
    ),
  )
}

///|
test "compile time implements reports a cycle instead of ordinary absence" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Node {\n}\ntrait Loop<t> {\n}\nimpl<t: Loop<Node>> Loop<t> for Node {\n}\npub fn main() -> Bool {\n  implements::<Node, Loop<Node>>()\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics.length(), 1)
  match lowering.modules[0].diagnostics[0] {
    CompileTimeQueryDiagnostic(_, message, _) =>
      assert_true(message.has_prefix("CT-013"))
    _ => fail("trait search cycle did not report its compile-time diagnostic")
  }
}

///|
test "compile time implements reads imported generic implementation identities" {
  let program = collect_program_manifest(
    24012UL,
    ProgramManifest::new([
      ManifestModule::new("lib.model", [
        ManifestFile::new(
          "model.dew", b"pub trait Mark {\n}\npub struct Box<t> {\n  value: t\n}\nimpl Mark for I32 {\n}\nimpl<t: Mark> Mark for Box<t> {\n}\n",
        ),
      ]),
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open lib.model\nopen dew.std.types\npub fn main() -> Bool {\n  implements::<Box<I32>, Mark>() && !implements::<Box<I64>, Mark>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.imports.scope.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[1].diagnostics, [])
  let body = program.modules[1]
    .body_of(program.modules[1].lookup_value("main").unwrap())
    .unwrap()
  assert_eq(
    lowering.modules[1].expressions[optimization_test_body_tail(
      lowering.modules[1],
      body.id,
    )].kind,
    PlannedBoolConst(true),
  )
}

///|
test "compile time branch removal deletes discarded call requests from IR" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn other<t>(value: t) -> U32 {\n  2u32\n}\npub fn main() -> U32 {\n  if is_unit::<Unit>() {\n    1u32\n  } else {\n    other(3i64)\n  }\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  for expression in lowering.modules[0].expressions {
    assert_false(expression.kind is PlannedIfExpression(_, _, _))
    assert_false(expression.kind is PlannedDirectCall(_, _, _, _))
  }
}

///|
test "compile time structural matching enforces repeated generic arguments" {
  let bindings : Map[CompileTimeBindingKey, CompileTimeType] = Map([])
  assert_false(
    compile_time_match_type(
      CtProduct([CtParameter(5UL), CtParameter(5UL)]),
      CtProduct([CtPrimitive(I32Type), CtPrimitive(I64Type)]),
      bindings,
    ),
  )
}

///|
test "compile time static assertions run only in the selected branch" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> Unit {\n  if is_unit::<Unit>() {\n    static_assert(bit_width::<I16>() == 16u32, \"logical width\")\n  } else {\n    static_assert(false, \"discarded branch\")\n  }\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  for expression in lowering.modules[0].expressions {
    assert_false(expression.kind is PlannedDirectCall(_, _, _, _))
  }
}

///|
test "compile time static assertions preserve source failure messages" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> Unit {\n  static_assert(false, \"a clear failure\")\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics.length(), 1)
  assert_true(
    lowering.modules[0].diagnostics[0]
    is CompileTimeQueryDiagnostic(
      _,
      "CT-021 static assertion failed: a clear failure",
      _
    ),
  )
}

///|
test "compile time static assertions reject runtime conditions" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main(value: Bool) -> Unit {\n  static_assert(value, \"runtime value\")\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics.length(), 1)
  assert_true(
    lowering.modules[0].diagnostics[0]
    is CompileTimeQueryDiagnostic(
      _,
      "CT-022 static_assert condition is not a compile-time Boolean",
      _
    ),
  )
}
