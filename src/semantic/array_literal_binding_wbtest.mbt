///|
fn check_array_literal_binding(source : Bytes) -> Unit raise {
  let program = collect_program_manifest(
    2632UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
}

///|
test "array literals do not use a local value named Array" {
  check_array_literal_binding(
    b"open dew.std.array\npub fn run() -> I32 {\n  let Array = 2i32\n  let values = [40i32]\n  values[0u32] + Array\n}\n",
  )
}

///|
test "array literals do not require an open Array name" {
  check_array_literal_binding(
    b"pub fn run() -> Unit {\n  let values = [42i32]\n}\n",
  )
}

///|
test "array literal type does not come from a user declaration named Array" {
  check_array_literal_binding(
    b"struct Array {\n  tag: I64\n}\npub fn run() -> Unit {\n  let values = [42i32]\n}\n",
  )
}

///|
test "array literals retain expected types for empty nested and Unit values" {
  check_array_literal_binding(
    b"open dew.std.array\nfn empty<t>() -> Array<t> {\n  []\n}\nfn nested() -> Array<Array<I64>> {\n  [[], [42i64]]\n}\nfn units() -> Array<Unit> {\n  [(), ()]\n}\npub fn run() -> I64 {\n  let values = empty::<I64>()\n  values.push(nested()[1u32][0u32])\n  values[0u32]\n}\n",
  )
}
