///|
test "generic Option and Result enums use deterministic erased carrier fields" {
  let program = @semantic.collect_program_manifest(
    2393UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nfn make_option() -> Option<I64> {\n  Option::Some(42i64)\n}\nfn make_result() -> Result<U32, String> {\n  Result::Err(\"bad\")\n}\npub fn option_value() -> I64 {\n  match make_option() {\n    Option::Some(value) => value\n    Option::None => 0i64\n  }\n}\npub fn result_value() -> U32 {\n  match make_result() {\n    Result::Ok(value) => value\n    Result::Err(message) => message.byte_length()\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let option_module = program.module_index("dew.std.option").unwrap()
  let result_module = program.module_index("dew.std.result").unwrap()
  let option = program.modules[option_module].lookup_type("Option").unwrap()
  let result = program.modules[result_module].lookup_type("Result").unwrap()
  assert_true(link.type_lookup.get(option) is Some(_))
  assert_true(link.type_lookup.get(result) is Some(_))
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
