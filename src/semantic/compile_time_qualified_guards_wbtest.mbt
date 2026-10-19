///|
fn qualified_guard_fixture(
  source : Bytes,
) -> (CollectedProgram, PlannedProgramLowering) raise {
  let program = collect_program_manifest(
    24970UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
      ManifestModule::new("app.queries", [
        ManifestFile::new(
          "queries.dew", b"pub builtin test_unit<t>() -> Bool = \"types.is_unit\"\npub builtin test_integer<t>() -> Bool = \"types.is_integer\"\npub builtin test_implements<t, bound>() -> Bool = \"types.implements\"\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.imports.scope.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  (program, plan_unoptimized_program_lowering(program, analyzed))
}

///|
test "qualified Unit guard refines a fixed call argument" {
  let (program, lowering) = qualified_guard_fixture(
    b"import app.queries as @queries\nfn accept(value: Unit) -> I32 {\n  42i32\n}\nfn read<t>(value: t) -> I32 {\n  if @queries.test_unit::<t>() {\n    accept(value)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(()) + read(7i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 0)
}

///|
test "qualified integer guard defers selected method checks" {
  let (program, lowering) = qualified_guard_fixture(
    b"import app.queries as @queries\nimpl I32 {\n  fn answer(self) -> I32 {\n    self\n  }\n}\nfn read<t>(value: t) -> I32 {\n  if @queries.test_integer::<t>() {\n    value.answer()\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(()) + read(42i32)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 0)
}

///|
test "qualified trait guard supplies selected evidence" {
  let (program, lowering) = qualified_guard_fixture(
    b"import app.queries as @queries\ntrait Read {\n  fn answer(self) -> I32\n}\nimpl Read for I32 {\n  fn answer(self) -> I32 {\n    self\n  }\n}\nfn read<t>(value: t) -> I32 {\n  if @queries.test_implements::<t, Read>() {\n    value.answer()\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read(7i64) + read(42i32)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
  assert_true(lowering.compile_time.unwrap().instances.length() > 0)
}

///|
test "qualified Unit guard does not enter its false branch" {
  let (program, lowering) = qualified_guard_fixture(
    b"import app.queries as @queries\nfn accept(value: Unit) -> I32 {\n  42i32\n}\nfn read<t>(value: t) -> I32 {\n  if @queries.test_unit::<t>() {\n    accept(value)\n  } else {\n    accept(value)\n  }\n}\npub fn main() -> I32 {\n  read(7i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_true(
    linked.diagnostics.any(diagnostic => {
      match diagnostic {
        ProgramCompileTimeFailure(_, _, _, _, message, _) =>
          message.has_prefix("CT-041")
        _ => false
      }
    }),
  )
}
