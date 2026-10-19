///|
test "unread initializers retain constructor and field layouts" {
  let stages = backend_test_single_module_stages(
    28130UL, b"struct Payload {\n value: I32\n}\nfn identity<t>(value: t) -> t {\n value\n}\nlet unread = identity(Payload::{\n value: 1i32\n}).value\npub fn main() -> I32 {\n 42i32\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let declaration = stages.program.modules[0].lookup_type("Payload").unwrap()
  assert_true(stages.link.type_lookup.contains(declaration))
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "unread initializers retain layouts through an imported generic helper" {
  let program = @semantic.collect_program_manifest(
    28131UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app", [
        @semantic.ManifestFile::new(
          "main.dew", b"import helpers as @helpers\nstruct Payload {\n value: I32\n}\nlet unread = @helpers.identity(Payload::{\n value: 1i32\n}).value\npub fn main() -> I32 {\n 42i32\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("helpers", [
        @semantic.ManifestFile::new(
          "helpers.dew", b"pub fn identity<t>(value: t) -> t {\n value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ),
    [],
  )
  let declaration = program.modules[0].lookup_type("Payload").unwrap()
  assert_true(link.type_lookup.contains(declaration))
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
