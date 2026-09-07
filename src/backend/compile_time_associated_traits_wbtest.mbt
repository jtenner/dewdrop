///|
test "library compile time queries find implementations owned by a supplied type" {
  let program = @semantic.collect_program_manifest(
    28120UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", b"open app.library\nstruct Key {\n  value: I32\n}\nimpl Read for Key {\n  fn read(self) -> I32 {\n    self.value\n  }\n}\npub fn run() -> I32 {\n  read(Key::{\n    value: 42i32\n  })\n}\n"),
      ]),
      @semantic.ManifestModule::new("app.library", [
        @semantic.ManifestFile::new("library.dew", b"open dew.std.types\npub trait Read {\n  fn read(self) -> I32\n}\npub fn read<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    value.read()\n  } else {\n    static_assert(false, \"Read implementation missing\")\n    0i32\n  }\n}\n"),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(@semantic.collect_compiler_source_diagnostics(program, analyzed, lowering, link), [])
  match emit_starshine_program_binary(lowering, link) {
    Ok(_) => ()
    Err(error) => fail(@debug.to_string(error))
  }
}
