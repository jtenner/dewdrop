///|
test "compile time method bounds: an imported method rejects a bad bound" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nopen app.library\nfn guarded<T>(value: T) -> I32 {\n  if implements::<T, Reader<Unit>>() {\n    value.apply(true)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64) + guarded(())\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Mark<X> {\n}\nimpl Mark<Unit> for I32 {\n}\npub trait Reader<X> {\n  fn apply<U: Mark<X>>(self, item: U) -> I32\n}\nimpl Reader<Unit> for I64 {\n  fn apply<U: Mark<Unit>>(self, item: U) -> I32 {\n    42i32\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is UnsatisfiedTraitObligation(_, _, _, _, _)
    }),
  )
}

///|
test "compile time method bounds: imported owners and method bounds use their own slots" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nopen app.library\nfn guarded<T>(value: T) -> I32 {\n  if implements::<T, Reader<Unit>>() {\n    value.apply(7i32)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64) + guarded(())\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub trait Mark<X> {\n}\nimpl Mark<Unit> for I32 {\n}\npub trait Reader<X> {\n  fn apply<U: Mark<X>>(self, item: U) -> I32\n}\nimpl Reader<Unit> for I64 {\n  fn apply<U: Mark<Unit>>(self, item: U) -> I32 {\n    42i32\n  }\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
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
test "compile time method bounds: a method bound can refer to its trait owner argument" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Mark<X> {\n}\nimpl Mark<Unit> for I32 {\n}\ntrait Reader<X> {\n  fn apply<U: Mark<X>>(self, item: U) -> I32\n}\nimpl Reader<Unit> for I64 {\n  fn apply<U: Mark<Unit>>(self, item: U) -> I32 {\n    42i32\n  }\n}\nfn guarded<T>(value: T) -> I32 {\n  if implements::<T, Reader<Unit>>() {\n    value.apply(7i32)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64) + guarded(())\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time method bounds: owner and method arguments keep separate slots" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Mark {\n}\nimpl Mark for I32 {\n}\ntrait Reader<X> {\n  fn apply<U: Mark>(self, item: U) -> I32\n}\nimpl Reader<Unit> for I64 {\n  fn apply<U: Mark>(self, item: U) -> I32 {\n    42i32\n  }\n}\nfn guarded<T>(value: T) -> I32 {\n  if implements::<T, Reader<Unit>>() {\n    value.apply(7i32)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64) + guarded(())\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time method bounds: an independent bad method argument is rejected" {
  let program = collect_program_manifest(
    24010UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\ntrait Mark {\n}\nimpl Mark for I32 {\n}\ntrait Reader<X> {\n  fn apply<U: Mark>(self, item: U) -> I32\n}\nimpl Reader<Unit> for I64 {\n  fn apply<U: Mark>(self, item: U) -> I32 {\n    42i32\n  }\n}\nfn guarded<T>(value: T) -> I32 {\n  if implements::<T, Reader<Unit>>() {\n    value.apply(true)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64) + guarded(())\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is UnsatisfiedTraitObligation(_, _, _, _, _)
    }),
  )
}
