///|
fn backend_link_chain_manifest(module_count : Int) -> @semantic.ProgramManifest {
  let modules : Array[@semantic.ManifestModule] = []
  for index in 0..<module_count {
    let source = Buffer(size_hint=128)
    if index > 0 {
      source.write_string_utf8("import bench.module_")
      source.write_string_utf8((index - 1).to_string())
      source.write_byte(b'\n')
    }
    source.write_string_utf8("pub fn step_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8("(value: I32) -> I32 {\n  ")
    if index == 0 {
      source.write_string_utf8("value + 1")
    } else {
      source.write_string_utf8("step_")
      source.write_string_utf8((index - 1).to_string())
      source.write_string_utf8("(value)")
    }
    source.write_string_utf8("\n}\n")
    modules.push(
      @semantic.ManifestModule::new("bench.module_" + index.to_string(), [
        @semantic.ManifestFile::new("module.dew", source.to_bytes()),
      ]),
    )
  }
  @semantic.ProgramManifest::new(modules)
}

///|
test "bench program fragment planning modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8000UL,
    backend_link_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  it.bench(fn() {
    let fragments = @semantic.plan_program_wasmgc_fragments(analyzed, lowering)
    it.keep(fragments.modules.length())
  })
}

///|
test "bench stable program link merge modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8050UL,
    backend_link_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let fragments = @semantic.plan_program_wasmgc_fragments(analyzed, lowering)
  it.bench(fn() {
    let link = @semantic.link_program_wasmgc_fragments(fragments, lowering, 63)
    it.keep(link.defined_function_count)
  })
}

///|
test "bench program module emission modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8100UL,
    backend_link_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 63)
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench program binary emission modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8200UL,
    backend_link_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 63)
  it.bench(fn() {
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
fn backend_aggregate_chain_manifest(
  module_count : Int,
) -> @semantic.ProgramManifest {
  let modules : Array[@semantic.ManifestModule] = []
  for index in 0..<module_count {
    let source = Buffer(size_hint=192)
    if index > 0 {
      source.write_string_utf8("import aggregate.module_")
      source.write_string_utf8((index - 1).to_string())
      source.write_byte(b'\n')
    }
    source.write_string_utf8("pub struct Item_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8(" {\n  value: I32\n}\n")
    source.write_string_utf8("pub fn step_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8("(value: I32) -> I32 {\n  ")
    if index == 0 {
      source.write_string_utf8("value")
    } else {
      source.write_string_utf8("step_")
      source.write_string_utf8((index - 1).to_string())
      source.write_string_utf8("(value)")
    }
    source.write_string_utf8("\n}\n")
    modules.push(
      @semantic.ManifestModule::new("aggregate.module_" + index.to_string(), [
        @semantic.ManifestFile::new("module.dew", source.to_bytes()),
      ]),
    )
  }
  @semantic.ProgramManifest::new(modules)
}

///|
test "bench aggregate stable link merge modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8250UL,
    backend_aggregate_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let fragments = @semantic.plan_program_wasmgc_fragments(analyzed, lowering)
  it.bench(fn() {
    let link = @semantic.link_program_wasmgc_fragments(fragments, lowering, 63)
    it.keep(link.type_count)
  })
}

///|
test "bench aggregate module emission modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8275UL,
    backend_aggregate_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 63)
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported struct semantic backend pipeline fields=32" (it : @bench.T) {
  let fields = Buffer(size_hint=1024)
  let construction = Buffer(size_hint=1024)
  fields.write_string_utf8("pub struct Wide {\n")
  construction.write_string_utf8(
    "open aggregate.library\nfn make(value: I32) -> Wide {\n  Wide {\n",
  )
  for index in 0..<32 {
    fields.write_string_utf8("  field_")
    fields.write_string_utf8(index.to_string())
    fields.write_string_utf8(": I32\n")
    construction.write_string_utf8("    field_")
    construction.write_string_utf8(index.to_string())
    construction.write_string_utf8(": value\n")
  }
  fields.write_string_utf8("}\n")
  construction.write_string_utf8(
    "  }\n}\nfn read(value: Wide) -> I32 {\n  value.field_31\n}\npub fn run(value: I32) -> I32 {\n  read(make(value))\n}\n",
  )
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("aggregate.main", [
      @semantic.ManifestFile::new("main.dew", construction.to_bytes()),
    ]),
    @semantic.ManifestModule::new("aggregate.library", [
      @semantic.ManifestFile::new("library.dew", fields.to_bytes()),
    ]),
  ])
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(8290UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
fn backend_enum_chain_manifest(count : Int) -> @semantic.ProgramManifest {
  let modules : Array[@semantic.ManifestModule] = []
  for index in 0..<count {
    let source = Buffer(size_hint=192)
    source.write_string_utf8("pub enum State_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8(" {\n  None\n  Some(I32)\n}\npub fn value_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8("(value: I32) -> I32 {\n  value\n}\n")
    modules.push(
      @semantic.ManifestModule::new("enum.module." + index.to_string(), [
        @semantic.ManifestFile::new("module.dew", source.to_bytes()),
      ]),
    )
  }
  @semantic.ProgramManifest::new(modules)
}

///|
fn backend_imported_enum_manifest(
  variant_count : Int,
) -> @semantic.ProgramManifest {
  let library = Buffer(size_hint=1024)
  library.write_string_utf8("pub enum Message {\n  Idle\n")
  for index in 0..<variant_count {
    library.write_string_utf8("  Value_")
    library.write_string_utf8(index.to_string())
    library.write_string_utf8("(I32)\n")
  }
  library.write_string_utf8("}\n")
  let main = Buffer(size_hint=256)
  main.write_string_utf8(
    "open app.enum_library\npub fn build(value: I32) -> Message {\n  Message::Value_",
  )
  main.write_string_utf8((variant_count - 1).to_string())
  main.write_string_utf8("(value)\n}\n")
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.enum_main", [
      @semantic.ManifestFile::new("main.dew", main.to_bytes()),
    ]),
    @semantic.ManifestModule::new("app.enum_library", [
      @semantic.ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
fn backend_imported_struct_variant_manifest(
  field_count : Int,
) -> @semantic.ProgramManifest {
  let library = Buffer(size_hint=field_count * 24 + 64)
  let main = Buffer(size_hint=field_count * 28 + 128)
  library.write_string_utf8("pub enum Event {\n  Data {\n")
  main.write_string_utf8(
    "open app.event_library\npub fn build(value: I32) -> Event {\n  Event::Data {\n",
  )
  for index in 0..<field_count {
    library.write_string_utf8("    field_")
    library.write_string_utf8(index.to_string())
    library.write_string_utf8(": I32\n")
    main.write_string_utf8("    field_")
    main.write_string_utf8(index.to_string())
    main.write_string_utf8(": value\n")
  }
  library.write_string_utf8("  }\n}\n")
  main.write_string_utf8("  }\n}\n")
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.event_main", [
      @semantic.ManifestFile::new("main.dew", main.to_bytes()),
    ]),
    @semantic.ManifestModule::new("app.event_library", [
      @semantic.ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
fn backend_imported_enum_match_manifest() -> @semantic.ProgramManifest {
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.match_main", [
      @semantic.ManifestFile::new(
        "main.dew", b"open app.match_library\nfn read(value: OptionI32) -> I32 {\n  match value {\n    OptionI32::Some(item) if false => 0\n    OptionI32::None => 0\n    OptionI32::Some(item) => item\n  }\n}\npub fn run(value: I32) -> I32 {\n  read(OptionI32::Some(value))\n}\n",
      ),
    ]),
    @semantic.ManifestModule::new("app.match_library", [
      @semantic.ManifestFile::new(
        "library.dew", b"pub enum OptionI32 {\n  None\n  Some(I32)\n}\n",
      ),
    ]),
  ])
}

///|
fn backend_dense_enum_match_manifest(
  variant_count : Int,
) -> @semantic.ProgramManifest {
  let library = Buffer(size_hint=variant_count * 16 + 48)
  let main = Buffer(size_hint=variant_count * 32 + 160)
  library.write_string_utf8("pub enum Dense {\n")
  for index in 0..<variant_count {
    library.write_string_utf8("  Variant_")
    library.write_string_utf8(index.to_string())
    library.write_byte(b'\n')
  }
  library.write_string_utf8("}\n")
  main.write_string_utf8(
    "open app.dense_library\nfn read(value: Dense) -> I32 {\n  match value {\n",
  )
  for index in 0..<variant_count {
    main.write_string_utf8("    Dense::Variant_")
    main.write_string_utf8(index.to_string())
    main.write_string_utf8(" => ")
    main.write_string_utf8(index.to_string())
    main.write_byte(b'\n')
  }
  main.write_string_utf8(
    "  }\n}\npub fn run(value: I32) -> I32 {\n  read(Dense::Variant_",
  )
  main.write_string_utf8((variant_count - 1).to_string())
  main.write_string_utf8(")\n}\n")
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.dense_main", [
      @semantic.ManifestFile::new("main.dew", main.to_bytes()),
    ]),
    @semantic.ManifestModule::new("app.dense_library", [
      @semantic.ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
fn backend_repeated_enum_shape_manifest(
  enum_count : Int,
) -> @semantic.ProgramManifest {
  let source = Buffer(size_hint=enum_count * 48 + 48)
  for index in 0..<enum_count {
    source.write_string_utf8("pub enum Repeated_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8(" {\n  Value(I32)\n}\n")
  }
  source.write_string_utf8("pub fn run() -> I32 {\n  0\n}\n")
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.repeated_enums", [
      @semantic.ManifestFile::new("main.dew", source.to_bytes()),
    ]),
  ])
}

///|
test "bench default enum stable link merge modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8295UL,
    backend_enum_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let fragments = @semantic.plan_program_wasmgc_fragments(analyzed, lowering)
  it.bench(fn() {
    let link = @semantic.link_program_wasmgc_fragments(fragments, lowering, 63)
    it.keep(link.type_count)
  })
}

///|
test "bench enum subtype stable link merge modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8296UL,
    backend_enum_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let fragments = @semantic.plan_program_wasmgc_fragments_with_options(
    analyzed,
    lowering,
    @semantic.WasmGCPlanningOptions::subtype_families(),
  )
  it.bench(fn() {
    let link = @semantic.link_program_wasmgc_fragments(fragments, lowering, 63)
    it.keep(link.type_count)
  })
}

///|
test "bench enum optimized subtype stable link merge modules=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    82965UL,
    backend_enum_chain_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let fragments = @semantic.plan_program_wasmgc_fragments_with_options(
    analyzed,
    lowering,
    @semantic.WasmGCPlanningOptions::optimized_subtype_families(),
  )
  it.bench(fn() {
    let link = @semantic.link_program_wasmgc_fragments(fragments, lowering, 63)
    it.keep(link.type_count)
  })
}

///|
test "bench default imported enum module emission variants=32" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    8297UL,
    backend_imported_enum_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported enum subtype module emission variants=32" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    82970UL,
    backend_imported_enum_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported enum optimized subtype emission variants=32" (
  it : @bench.T,
) {
  let program = @semantic.collect_program_manifest(
    82972UL,
    backend_imported_enum_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::optimized_subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench default imported enum struct payload emission fields=32" (
  it : @bench.T,
) {
  let program = @semantic.collect_program_manifest(
    82975UL,
    backend_imported_struct_variant_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported enum subtype struct payload emission fields=32" (
  it : @bench.T,
) {
  let program = @semantic.collect_program_manifest(
    82976UL,
    backend_imported_struct_variant_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported enum match emission subtypes" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    82978UL,
    backend_imported_enum_match_manifest(),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench repeated cross enum subtype shapes enums=64" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    829783UL,
    backend_repeated_enum_shape_manifest(64),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench linear enum match emission variants=32" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    829784UL,
    backend_dense_enum_match_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench dense enum match emission variants=32" (it : @bench.T) {
  let program = @semantic.collect_program_manifest(
    829785UL,
    backend_dense_enum_match_manifest(32),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    @semantic.WasmGCPlanningOptions::optimized_subtype_families(),
  )
  it.bench(fn() {
    let module_ = emit_starshine_program_module(lowering, link).unwrap()
    it.keep(module_)
  })
}

///|
test "bench imported enum match full pipeline subtypes" (it : @bench.T) {
  let manifest = backend_imported_enum_match_manifest()
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(82980UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      0,
      @semantic.WasmGCPlanningOptions::subtype_families(),
    )
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
test "bench default imported enum full pipeline variants=32" (it : @bench.T) {
  let manifest = backend_imported_enum_manifest(32)
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(8298UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
test "bench imported enum subtype full pipeline variants=32" (it : @bench.T) {
  let manifest = backend_imported_enum_manifest(32)
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(8299UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      0,
      @semantic.WasmGCPlanningOptions::subtype_families(),
    )
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
test "bench imported enum optimized subtype full pipeline variants=32" (
  it : @bench.T,
) {
  let manifest = backend_imported_enum_manifest(32)
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(82992UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link_with_options(
      analyzed,
      lowering,
      0,
      @semantic.WasmGCPlanningOptions::optimized_subtype_families(),
    )
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}

///|
test "bench full linked semantic backend pipeline modules=32" (it : @bench.T) {
  let manifest = backend_link_chain_manifest(32)
  it.bench(fn() {
    let program = @semantic.collect_program_manifest(8300UL, manifest)
    let analyzed = @semantic.analyze_program_semantics(program)
    let lowering = @semantic.plan_program_lowering(program, analyzed)
    let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 31)
    let bytes = emit_starshine_program_binary(lowering, link).unwrap()
    it.keep(bytes.length())
  })
}
