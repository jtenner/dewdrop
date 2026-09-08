///|
test "production assertions link an ordinary Dew body" {
  let program = @semantic.collect_program_manifest(
    2381UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.assertion", [
        @semantic.ManifestFile::new(
          "assertion.dew", b"pub fn run(condition: Bool, message: String) -> Unit {\n  assert(condition, message)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut declaration = 0UL
  let mut declarations = 0
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      if callable.name == b"assert" {
        declaration = callable.declaration
        declarations += 1
      }
    }
  }
  assert_eq(declarations, 1)
  let mut bodies = 0
  for function_ in link.functions {
    if function_.declaration == declaration && !function_.elided {
      assert_true(function_.kind is @semantic.PlannedWasmDefinedFunction(_))
      bodies += 1
    }
  }
  assert_eq(bodies, 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "removed production assertion is not an inline Wasm intrinsic" {
  assert_eq(
    starshine_inline_builtin_instructions(b"dew_assert"),
    Err(UnsupportedBuiltin(b"dew_assert")),
  )
}
