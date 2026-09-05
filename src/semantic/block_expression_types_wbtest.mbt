///|
test "Unit elements in generic products retain their shared type variables" {
  for source in [
    b"fn identity<t>(value: t) -> t {\n  value\n}\npub fn run(value: I64) -> I64 {\n  let (_, selected, _) = identity(((), value, ()))\n  selected\n}\n",
    b"fn identity<t>(value: t) -> t {\n  value\n}\npub fn run(value: I64) -> I64 {\n  let (_, (selected, _)) = identity(((), (value, ())))\n  selected\n}\n",
  ] {
    let program = collect_program_manifest(22906UL, ProgramManifest::new([
      ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
    ]))
    let analyzed = analyze_program_semantics(program)
    assert_eq(program.diagnostics.length(), 0)
    assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  }
}
