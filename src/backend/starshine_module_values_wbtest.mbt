///|
fn starshine_module_value_test_module(
  source : Bytes,
  test_mode? : Bool = false,
) -> @lib.Module {
  let program = @semantic.collect_program_manifest(
    24149UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  if program.diagnostics.length() != 0 ||
    analyzed.frozen.import_diagnostics.length() != 0 ||
    analyzed.modules[0].inferred.diagnostics.length() != 0 {
    abort("module value semantic pipeline failed")
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  if lowering.modules[0].diagnostics.length() != 0 {
    abort("module value lowering pipeline failed")
  }
  let options = if test_mode {
    @semantic.WasmGCPlanningOptions::test_mode()
  } else {
    @semantic.WasmGCPlanningOptions::optimized_subtype_families()
  }
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed, lowering, 0, options,
  )
  if link.diagnostics.length() != 0 {
    abort("module value link pipeline failed")
  }
  emit_starshine_program_module(lowering, link).unwrap()
}

///|
test "module values emit globals dependency-ordered initializers and start" {
  let module_ = starshine_module_value_test_module(
    b"let base = 40\nlet answer = base + 2\npub fn main() -> I32 {\n  answer\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(module_.global_sec is Some(_))
  assert_eq(module_.start_sec, None)
}

///|
test "module value initializers support calls and nominal references" {
  let module_ = starshine_module_value_test_module(
    b"struct Box {\n  value: I32\n}\nfn make(value: I32) -> Box {\n  Box::{\n    value: value\n  }\n}\nlet box = make(41)\npub fn main() -> I32 {\n  box.value + 1\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(module_.global_sec is Some(_))
  assert_eq(module_.start_sec, None)
}

///|
test "production links omit test-only module value initialization" {
  let program = @semantic.collect_program_manifest(
    24150UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"let production = 41\npub fn main() -> I32 {\n  production + 1\n}\n",
        ),
        @semantic.ManifestFile::new(
          "values_test.dew", b"let fixture = production + 1\ntest \"uses fixture\" {\n  assert(fixture == 42, \"wrong fixture\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let production_link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::optimized_subtype_families(),
  )
  assert_eq(production_link.initializers.length(), 1)
  let production = emit_starshine_program_module(lowering, production_link).unwrap()
  assert_eq(@validate.validate_module(production), Ok(()))

  let test_link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::test_mode(),
  )
  assert_eq(test_link.initializers.length(), 2)
  let testing = emit_starshine_program_module(lowering, test_link).unwrap()
  assert_eq(@validate.validate_module(testing), Ok(()))
}

///|
test "imported module values retain scalar nominal and applied types" {
  let program = @semantic.collect_program_manifest(
    24151UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open app.values\nfn read(value: Box) -> I32 {\n  value.value\n}\npub fn main() -> I32 {\n  let optional = match maybe {\n    Option::Some(value) => value\n    Option::None => 0\n  }\n  read(box) + answer + optional\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.values", [
        @semantic.ManifestFile::new(
          "values.dew", b"pub struct Box {\n  value: I32\n}\nfn make(value: I32) -> Box {\n  Box::{\n    value: value\n  }\n}\npub let answer = 40 + 2\npub let box = make(answer - 1)\npub let maybe = Option::Some(answer)\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.initializers.length(), 3)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "cross-module eager value cycles are link diagnostics" {
  let program = @semantic.collect_program_manifest(
    24152UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.a", [
        @semantic.ManifestFile::new(
          "a.dew", b"open app.b\npub let first = get_b()\npub fn get_a() -> I32 {\n  first\n}\npub fn main() -> I32 {\n  0\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.b", [
        @semantic.ManifestFile::new(
          "b.dew", b"open app.a\npub let second = get_a()\npub fn get_b() -> I32 {\n  second\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 1)
  match link.diagnostics[0] {
    @semantic.EagerProgramInitializationCycle(first, second) =>
      assert_true(first != second)
    _ => fail("expected cross-module eager initialization cycle")
  }
}
