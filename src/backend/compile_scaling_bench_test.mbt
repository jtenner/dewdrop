///|
test "bench compiler facts forward chain functions=128" (it : @bench.T) {
  let source = Buffer()
  source.write_string_utf8(
    "foreign impl \"host\" as Host {\n fn value() -> I32 = \"value\"\n}\n",
  )
  for i in 0..<128 {
    source.write_string_utf8("pub fn call_\{i}() -> I32 {\n ")
    if i + 1 == 128 {
      source.write_string_utf8("Host.value()")
    } else {
      source.write_string_utf8("call_\{i + 1}()")
    }
    source.write_string_utf8("\n}\n")
  }
  let program = @semantic.collect_program_manifest(
    260831UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("bench.main", [
        @semantic.ManifestFile::new("main.dew", source.to_bytes()),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  if !@semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ).is_empty() {
    abort("invalid benchmark source")
  }
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  it.bench(fn() {
    it.keep(
      attach_starshine_program_compiler_facts(module_, lowering, link).unwrap(),
    )
  })
}

///|
test "bench compiler facts forward chain functions=512" (it : @bench.T) {
  let source = Buffer()
  source.write_string_utf8(
    "foreign impl \"host\" as Host {\n fn value() -> I32 = \"value\"\n}\n",
  )
  for i in 0..<512 {
    source.write_string_utf8("pub fn call_\{i}() -> I32 {\n ")
    if i + 1 == 512 {
      source.write_string_utf8("Host.value()")
    } else {
      source.write_string_utf8("call_\{i + 1}()")
    }
    source.write_string_utf8("\n}\n")
  }
  let program = @semantic.collect_program_manifest(
    260831UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("bench.main", [
        @semantic.ManifestFile::new("main.dew", source.to_bytes()),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  if !@semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ).is_empty() {
    abort("invalid benchmark source")
  }
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  it.bench(fn() {
    it.keep(
      attach_starshine_program_compiler_facts(module_, lowering, link).unwrap(),
    )
  })
}
