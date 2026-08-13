///|
test "Disposable standard module has stable identity and generic dispatch" {
  let program = collect_program_manifest(
    2640UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.disposable\nstruct Resource {\n  value: I32\n}\nimpl Disposable for Resource {\n  fn dispose(self) -> Unit {\n    assert(self.value == 7, \"dispose\")\n  }\n}\nfn close<t: Disposable>(value: t) -> Unit {\n  dispose(value)\n}\npub fn run() -> Unit {\n  close(Resource::{\n    value: 7\n  })\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program.module_index("dew.std.disposable").unwrap()
  let disposable = program.modules[module_index]
  assert_eq(disposable.diagnostics, [])
  let trait_id = disposable.lookup_trait("Disposable").unwrap()
  assert_eq(semantic_id_module(trait_id), standard_library_module_id(45))
  assert_true(disposable.lookup_value("dispose") is Some(_))
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
