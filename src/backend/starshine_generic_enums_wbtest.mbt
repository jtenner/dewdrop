///|
test "generic Option and Result enums use one specialized carrier field" {
  let program = @semantic.collect_program_manifest(
    2393UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dew.std.string\nfn make_option() -> Option<I64> {\n  Option::Some(42i64)\n}\nfn make_option_i32() -> Option<I32> {\n  Option::Some(7)\n}\nfn make_result() -> Result<U32, String> {\n  Result::Err(\"bad\")\n}\nfn make_i32_result(flag: Bool) -> Result<I32, I32> {\n  if flag {\n    Result::Ok(41)\n  } else {\n    Result::Err(42)\n  }\n}\npub fn option_value() -> I64 {\n  match make_option() {\n    Option::Some(value) => value\n    Option::None => 0i64\n  }\n}\npub fn option_i32_value() -> I32 {\n  match make_option_i32() {\n    Option::Some(value) => value\n    Option::None => 0\n  }\n}\npub fn result_value() -> U32 {\n  match make_result() {\n    Result::Ok(value) => value\n    Result::Err(message) => message.byte_length()\n  }\n}\npub fn result_i32_value() -> I32 {\n  match make_i32_result(false) {\n    Result::Ok(value) => value\n    Result::Err(value) => value\n  }\n}\n",
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
  let option_fragments = link.modules[option_module]
  let result_fragments = link.modules[result_module]
  let mut saw_option_i32 = false
  let mut saw_option_i64 = false
  for physical in option_fragments.physical_types {
    match physical.kind {
      @semantic.PlannedWasmEnumSubtypeType(_, variant, _) if variant ==
        @semantic.standard_option_some_variant() => {
        assert_eq(physical.fields.length, 2)
        match option_fragments.fields[physical.fields.start + 1].storage {
          @semantic.WasmI32Storage => saw_option_i32 = true
          @semantic.WasmI64Storage => saw_option_i64 = true
          _ => ()
        }
      }
      _ => ()
    }
  }
  assert_true(saw_option_i32)
  assert_true(saw_option_i64)
  for physical in result_fragments.physical_types {
    match physical.kind {
      @semantic.PlannedWasmEnumSubtypeType(owner, _, _) if owner == result =>
        assert_eq(physical.fields.length, 2)
      _ => ()
    }
  }
  let module_ = match emit_starshine_program_module(lowering, link) {
    Ok(value) => value
    Err(_) => fail("failed to emit compact generic enums")
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "generic enum adapters convert compact scalar and erased payloads" {
  let program = @semantic.collect_program_manifest(
    2517UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub fn keep_option<t>(value: Option<t>, first: Bool) -> Option<t> {\n  if first {\n    value\n  } else {\n    value\n  }\n}\npub fn keep_result<t, e>(value: Result<t, e>, first: Bool) -> Result<t, e> {\n  if first {\n    value\n  } else {\n    value\n  }\n}\nfn make_error() -> Result<I32, I32> {\n  Result::Err(2)\n}\npub fn main() -> I32 {\n  let option = keep_option(Option::Some(40), true)\n  let result = keep_result(make_error(), false)\n  let left = match option {\n    Some(value) => value\n    None => 0\n  }\n  let right = match result {\n    Ok(value) => value\n    Err(value) => value\n  }\n  left + right\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = match emit_starshine_program_module(lowering, link) {
    Ok(value) => value
    Err(_) => fail("failed to emit generic enum adapters")
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, link).unwrap().length() > 8,
  )
}
