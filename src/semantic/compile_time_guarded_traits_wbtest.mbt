///|
test "compile time implements guards a trait method without a hard bound" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    value.read()\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read_or_zero::<I32>(42i32) + read_or_zero::<I64>(7i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  let link = link_program_wasmgc_fragments(plan, lowering, 0)
  assert_eq(link.diagnostics, [])
  let mut concrete_calls = 0
  for _, instance in lowering.compile_time.unwrap().instances {
    assert_eq(instance.module_.diagnostics, [])
    for expression in instance.module_.expressions {
      if expression.kind is PlannedDirectCall(target, _, _, _) {
        if instance.module_.functions.callable_of(target) is Some(callable) && callable.kind is PlannedImplMethodCallable(_, _) {
          concrete_calls += 1
        }
      }
    }
  }
  assert_true(concrete_calls > 0)
}

///|
test "compile time implements guard does not leak into the false branch" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    0i32\n  } else {\n    value.read()\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.modules[0].diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].names.diagnostics, [])
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is NoMatchingMethod(_, _, _)
    }),
  )
}

///|
test "compile time implements negated guard checks the else branch" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if !implements::<t, Read>() {\n    0i32\n  } else {\n    value.read()\n  }\n}\npub fn main() -> I32 {\n  read_or_zero::<I32>(42i32)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}
