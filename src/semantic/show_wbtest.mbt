///|
test "Show standard module has stable identity and generic evidence lowering" {
  let program = collect_program_manifest(
    2639UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.show\nstruct Point {\n  value: I32\n}\nimpl Show for Point {\n  fn append_show(self, formatter: ShowFormatter) -> Unit {\n    show_append_ascii(formatter, 60u8)\n    show_append(formatter, self.value)\n    show_append_ascii(formatter, 62u8)\n  }\n}\nfn render<t: Show>(value: t) -> String {\n  show(value)\n}\npub fn run() -> String {\n  render(Point {\n    value: 7\n  })\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program.module_index("dew.std.show").unwrap()
  let show_module = program.modules[module_index]
  assert_eq(show_module.diagnostics, [])
  assert_true(show_module.lookup_type("ShowFormatter") is Some(_))
  let show_trait = show_module.lookup_trait("Show").unwrap()
  assert_eq(semantic_id_module(show_trait), standard_library_module_id(44))
  assert_true(show_module.lookup_value("show") is Some(_))
  assert_true(show_module.lookup_value("show_append") is Some(_))
  assert_true(program.module_index("dew.std.string_builder") is Some(_))
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowered, 0)
  assert_eq(link.diagnostics, [])
}
