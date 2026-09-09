///|
test "test mode keeps assertion state out of globals" {
  let program = @semantic.collect_program_manifest(
    2380UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("test.main", [
        @semantic.ManifestFile::new(
          "assertion_test.dew", b"test \"failure\" {\n  assert(false, \"visible failure\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let production_link = @semantic.plan_program_wasmgc_link(
    analyzed, lowering, 0,
  )
  let production = emit_starshine_program_module(lowering, production_link).unwrap()
  assert_eq(production.global_sec, None)

  let test_link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::test_mode(),
  )
  assert_true(test_link.modules[0].emit_tests)
  let test_module = emit_starshine_program_module(lowering, test_link).unwrap()
  assert_eq(@validate.validate_module(test_module), Ok(()))
  assert_eq(test_module.global_sec, None)
}

///|
test "Dew test assertions reach ordinary WASI write dependencies" {
  let program = @semantic.collect_program_manifest(
    2379UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("test.main", [
        @semantic.ManifestFile::new(
          "__dew_test_runtime.dew", b"open dew.std.string\nopen dew.std.wasi\nfn assert(condition: Bool, message: String) -> Unit {\n  if !condition {\n    let _ = wasi_fd_write(1u32, message.as_bytes())\n    unreachable()\n  }\n}\n",
        ),
        @semantic.ManifestFile::new(
          "assertion_test.dew", b"open dew.std.string\ntest \"failure\" {\n  let prefix = \"dynamic \"\n  assert(false, prefix.concat(\"message\"))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::test_mode(),
  )
  assert_eq(link.diagnostics.length(), 0)
  let mut found_assert_runtime = false
  let mut found_wasi_import = false
  let mut found_string_as_bytes = false
  let mut found_wasi_write = false
  let mut assertion_declaration = 0UL
  for callable in lowering.modules[0].functions.callables {
    if callable.name == b"assert" {
      assertion_declaration = callable.declaration
    }
  }
  assert_true(assertion_declaration != 0UL)
  let mut found_defined_assertion = false
  for function_ in link.functions {
    if function_.elided {
      continue
    }
    match function_.kind {
      @semantic.PlannedWasmDefinedFunction(_) =>
        if function_.declaration == assertion_declaration {
          found_defined_assertion = true
        }
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if name == b"dew_test_assert" {
          found_assert_runtime = true
        } else if name == b"dew_string_as_bytes" {
          found_string_as_bytes = true
        } else if name == b"dew_wasi_fd_write" {
          found_wasi_write = true
        }
      @semantic.PlannedWasmImportedFunction(identity) =>
        if identity.module_name == b"wasi_snapshot_preview1" &&
          identity.field == b"fd_write" {
          match identity.kind {
            @semantic.WasiWasmImport | @semantic.ForeignHostWasmImport =>
              found_wasi_import = true
            _ => ()
          }
        }
      _ => ()
    }
  }
  assert_false(found_assert_runtime)
  assert_false(found_string_as_bytes)
  assert_false(found_wasi_write)
  assert_true(found_defined_assertion)
  assert_true(found_wasi_import)
  let mut uses_linear_memory = false
  for module_ in link.modules {
    uses_linear_memory = uses_linear_memory || module_.uses_linear_memory
  }
  assert_true(uses_linear_memory)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_eq(module_.global_sec, None)
  assert_true(module_.mem_sec is Some(_))
}
