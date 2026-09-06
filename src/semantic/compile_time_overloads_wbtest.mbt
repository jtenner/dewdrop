///|
test "compile time overloads: qualified failures retain source diagnostics" {
  let program = collect_program_manifest(24010UL, ProgramManifest::new([
    ManifestModule::new("app.main", [ManifestFile::new("main.dew", b"open dew.std.types\nimport app.library as @raw\nfn select<T>(value: T) -> T {\n  if is_integer::<T>() {\n    @raw.consume(value, true)\n  } else {\n    value\n  }\n}\npub fn main() -> I64 {\n  select(7i32)\n  select(())\n  select(7i64)\n}\n")]),
    ManifestModule::new("app.library", [ManifestFile::new("library.dew", b"pub builtin consume(value: I32, right: I32) -> I32 = \"i32.add\"\npub builtin consume(value: I64, right: I64) -> I64 = \"i64.add\"\n")]),
  ]))
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  let analyzed = analyze_program_semantics(program)
  assert_true(analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
    diagnostic is NoMatchingCallOverload(_, _, _)
  }))
}

///|
test "compile time overloads: imported overloads wait for exact logical types" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nopen app.library\nfn select<T>(value: T) -> T {\n  if is_integer::<T>() {\n    consume(value, value)\n  } else {\n    value\n  }\n}\npub fn main() -> I64 {\n  select(7i32)\n  select(())\n  select(7i64)\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub builtin consume(value: I32, right: I32) -> I32 = \"i32.add\"\npub builtin consume(value: I64, right: I64) -> I64 = \"i64.add\"\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time overloads: selected logical arguments choose the exact overload" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nbuiltin consume(value: I32, right: I32) -> I32 = \"i32.add\"\nbuiltin consume(value: I64, right: I64) -> I64 = \"i64.add\"\nfn select<T>(value: T) -> T {\n  if is_integer::<T>() {\n    consume(value, value)\n  } else {\n    value\n  }\n}\npub fn main() -> I64 {\n  select(7i32)\n  select(())\n  select(7i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time overloads: independent bad operands cannot be deferred" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nbuiltin consume(value: I32, right: I32) -> I32 = \"i32.add\"\nbuiltin consume(value: I64, right: I64) -> I64 = \"i64.add\"\nfn select<T>(value: T) -> T {\n  if is_integer::<T>() {\n    consume(value, true)\n  } else {\n    value\n  }\n}\npub fn main() -> I64 {\n  select(7i32)\n  select(())\n  select(7i64)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is NoMatchingCallOverload(_, _, _)
    }),
  )
}
