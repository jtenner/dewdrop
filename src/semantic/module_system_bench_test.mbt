///|
fn module_system_benchmark_manifest(
  module_count : Int,
  functions_per_module : Int,
) -> ProgramManifest {
  let modules : Array[ManifestModule] = []
  for module_index in 0..<module_count {
    let source = Buffer(size_hint=functions_per_module * 72 + 48)
    if module_index > 0 {
      source.write_string_utf8("import bench.module_")
      source.write_string_utf8((module_index - 1).to_string())
      source.write_byte(b'\n')
    }
    for function_index in 0..<functions_per_module {
      source.write_string_utf8("pub fn function_")
      source.write_string_utf8(function_index.to_string())
      source.write_string_utf8("(value: I32) -> I32 {\n  value\n}\n")
    }
    modules.push(
      ManifestModule::new("bench.module_" + module_index.to_string(), [
        ManifestFile::new("module.dew", source.to_bytes()),
      ]),
    )
  }
  ProgramManifest::new(modules)
}

///|
test "bench module graph chain modules=256" (it : @bench.T) {
  let program = collect_program_manifest(
    2000UL,
    module_system_benchmark_manifest(256, 1),
  )
  it.bench(fn() {
    let graph = build_module_dependency_graph(program)
    it.keep(graph.sccs.length())
  })
}

///|
test "bench module interface freeze modules=64 functions=32" (it : @bench.T) {
  let program = collect_program_manifest(
    3000UL,
    module_system_benchmark_manifest(64, 32),
  )
  it.bench(fn() {
    let frozen = freeze_program_interfaces(program)
    it.keep(frozen.interfaces.length())
  })
}

///|
test "bench module full manifest pipeline modules=64 functions=32" (
  it : @bench.T,
) {
  let manifest = module_system_benchmark_manifest(64, 32)
  it.bench(fn() {
    let program = collect_program_manifest(4000UL, manifest)
    let frozen = freeze_program_interfaces(program)
    it.keep(frozen.interfaces.length())
  })
}

///|
fn imported_call_benchmark_manifest(call_count : Int) -> ProgramManifest {
  let library = Buffer(size_hint=call_count * 64)
  let consumer = Buffer(size_hint=call_count * 48 + 64)
  consumer.write_string_utf8("open bench.library\npub fn run() -> I32 {\n")
  for index in 0..<call_count {
    library.write_string_utf8("pub fn imported_")
    library.write_string_utf8(index.to_string())
    library.write_string_utf8("<t>(value: t) -> t {\n  value\n}\n")
    consumer.write_string_utf8("  let value_")
    consumer.write_string_utf8(index.to_string())
    consumer.write_string_utf8(" = imported_")
    consumer.write_string_utf8(index.to_string())
    consumer.write_string_utf8("(")
    consumer.write_string_utf8(index.to_string())
    consumer.write_string_utf8(")\n")
  }
  consumer.write_string_utf8("  value_")
  consumer.write_string_utf8((call_count - 1).to_string())
  consumer.write_string_utf8("\n}\n")
  ProgramManifest::new([
    ManifestModule::new("bench.consumer", [
      ManifestFile::new("consumer.dew", consumer.to_bytes()),
    ]),
    ManifestModule::new("bench.library", [
      ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
test "bench imported signature resolution calls=128" (it : @bench.T) {
  let program = collect_program_manifest(
    5000UL,
    imported_call_benchmark_manifest(128),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let scope = frozen.import_scopes[0]
  it.bench(fn() {
    let resolved = resolve_module_types_with_imports(collected, scope)
    let imports = resolve_module_imports(resolved, scope)
    it.keep(imports.callables.length())
  })
}

///|
test "bench imported call inference calls=128" (it : @bench.T) {
  let program = collect_program_manifest(
    6000UL,
    imported_call_benchmark_manifest(128),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let scope = frozen.import_scopes[0]
  let resolved = resolve_module_types_with_imports(collected, scope)
  let imports = resolve_module_imports(resolved, scope)
  let names = resolve_module_names_with_imports(collected, scope)
  it.bench(fn() {
    let inferred = infer_module_bodies_with_imports(
      collected, resolved, imports, names,
    )
    it.keep(inferred.call_type_arguments.length())
  })
}

///|
fn imported_enum_benchmark_manifest(
  enum_count : Int,
  variants_per_enum : Int,
) -> ProgramManifest {
  let library = Buffer(size_hint=enum_count * variants_per_enum * 24)
  for enum_index in 0..<enum_count {
    library.write_string_utf8("pub enum Imported_")
    library.write_string_utf8(enum_index.to_string())
    library.write_string_utf8(" {\n")
    for variant_index in 0..<variants_per_enum {
      library.write_string_utf8("  Variant_")
      library.write_string_utf8(variant_index.to_string())
      library.write_string_utf8("(I32)\n")
    }
    library.write_string_utf8("}\n")
  }
  ProgramManifest::new([
    ManifestModule::new("bench.consumer", [
      ManifestFile::new(
        "consumer.dew", b"open bench.enum_library\npub fn run() -> I32 {\n  1\n}\n",
      ),
    ]),
    ManifestModule::new("bench.enum_library", [
      ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
test "bench imported enum evidence enums=64 variants=8" (it : @bench.T) {
  let program = collect_program_manifest(
    6950UL,
    imported_enum_benchmark_manifest(64, 8),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let scope = frozen.import_scopes[0]
  let resolved = resolve_module_types_with_imports(collected, scope)
  it.bench(fn() {
    let imports = resolve_module_imports(resolved, scope)
    it.keep(imports.variants.length())
  })
}

///|
fn imported_struct_benchmark_manifest(
  struct_count : Int,
  fields_per_struct : Int,
) -> ProgramManifest {
  let library = Buffer(size_hint=struct_count * fields_per_struct * 24)
  for struct_index in 0..<struct_count {
    library.write_string_utf8("pub struct Imported_")
    library.write_string_utf8(struct_index.to_string())
    library.write_string_utf8(" {\n")
    for field_index in 0..<fields_per_struct {
      library.write_string_utf8("  field_")
      library.write_string_utf8(field_index.to_string())
      library.write_string_utf8(": I32\n")
    }
    library.write_string_utf8("}\n")
  }
  ProgramManifest::new([
    ManifestModule::new("bench.consumer", [
      ManifestFile::new(
        "consumer.dew", b"open bench.struct_library\npub fn run() -> I32 {\n  1\n}\n",
      ),
    ]),
    ManifestModule::new("bench.struct_library", [
      ManifestFile::new("library.dew", library.to_bytes()),
    ]),
  ])
}

///|
test "bench imported struct evidence structs=1024 fields=8" (it : @bench.T) {
  let program = collect_program_manifest(
    6975UL,
    imported_struct_benchmark_manifest(1024, 8),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let scope = frozen.import_scopes[0]
  let resolved = resolve_module_types_with_imports(collected, scope)
  it.bench(fn() {
    let imports = resolve_module_imports(resolved, scope)
    it.keep(imports.fields.length())
  })
}

///|
test "bench imported semantic pipeline calls=128" (it : @bench.T) {
  let program = collect_program_manifest(
    7000UL,
    imported_call_benchmark_manifest(128),
  )
  let frozen = freeze_program_interfaces(program)
  let collected = program.modules[0]
  let scope = frozen.import_scopes[0]
  it.bench(fn() {
    let resolved = resolve_module_types_with_imports(collected, scope)
    let imports = resolve_module_imports(resolved, scope)
    let names = resolve_module_names_with_imports(collected, scope)
    let inferred = infer_module_bodies_with_imports(
      collected, resolved, imports, names,
    )
    it.keep(inferred.call_type_arguments.length())
  })
}
