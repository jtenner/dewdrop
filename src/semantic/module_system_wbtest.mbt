///|
test "collection distinguishes qualified and open imports" {
  let module_id = 1000UL
  let file = make_program_file_id(module_id, 0)
  let collected = collect_program_files(module_id, [
    ProgramFile::new(
      file, b"open dew.std.preamble\nimport dew.std.map\npub fn run() -> Unit {}\n",
    ),
  ])
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.imports, [
    {
      path: "dew.std.preamble",
      open_: true,
      wildcard: false,
      import_alias: None,
      import_alias_offset: 0UL,
      file,
      offset: 0UL,
    },
    {
      path: "dew.std.map",
      open_: false,
      wildcard: false,
      import_alias: Some("map"),
      import_alias_offset: 22UL,
      file,
      offset: 22UL,
    },
  ])
}

///|
test "collection retains explicit import aliases" {
  let module_id = 1001UL
  let file = make_program_file_id(module_id, 0)
  let collected = collect_program_files(module_id, [
    ProgramFile::new(
      file, b"import custom.sub.package as @custom\npub fn run() -> Unit {}\n",
    ),
  ])
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.imports, [
    {
      path: "custom.sub.package",
      open_: false,
      wildcard: false,
      import_alias: Some("custom"),
      import_alias_offset: 29UL,
      file,
      offset: 0UL,
    },
  ])
}

///|
test "collection retains wildcard import prefixes" {
  let module_id = 1001UL
  let file = make_program_file_id(module_id, 0)
  let collected = collect_program_files(module_id, [
    ProgramFile::new(file, b"open dew.std.*\npub fn run() -> Unit {}\n"),
  ])
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.imports, [
    {
      path: "dew.std",
      open_: true,
      wildcard: true,
      import_alias: None,
      import_alias_offset: 0UL,
      file,
      offset: 0UL,
    },
  ])
}

///|
test "standard imports append deterministic compiler-owned modules" {
  let program = collect_program_manifest(
    1190UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.f32x4\nopen dew.std.i8x8\nopen dew.std.string\nopen dew.std.string_builder\nopen dew.std.bytes\nopen dew.std.bytes_builder\nopen dew.std.wasi\npub fn splat(value: F32) -> F32x4 {\n  f32x4_splat(value)\n}\n",
        ),
      ]),
    ]),
  )
  let graph = build_module_dependency_graph(program)
  assert_eq(graph.diagnostics.length(), 0)
  assert_true(program.module_index("dew.std.preamble") is Some(_))
  assert_true(program.module_index("dew.std.f32x4") is Some(_))
  assert_true(program.module_index("dew.std.i8x8") is Some(_))
  assert_true(program.module_index("dew.std.string") is Some(_))
  assert_true(program.module_index("dew.std.wasi") is Some(_))
  assert_true(graph.dependencies[0].length > 1)
  let interfaces = freeze_program_interfaces(program)
  assert_eq(interfaces.graph.diagnostics.length(), 0)
  assert_eq(interfaces.import_diagnostics.length(), 0)
}

///|
test "dew std wildcard selects every public standard module deterministically" {
  let program = collect_program_manifest(
    1191UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.*\npub fn build() -> U32 {\n  let builder = StringBuilder::new()\n  builder.append(\"wildcard\")\n  builder.finish().byte_length()\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(program.modules.length(), 37)
  assert_true(program.module_index("dew.std.string") is Some(_))
  assert_true(program.module_index("dew.std.array") is Some(_))
  assert_true(program.module_index("dew.std.map") is Some(_))
  assert_true(program.module_index("dew.std.set") is Some(_))
  assert_true(program.module_index("dew.std.wasm.intrinsics") is Some(_))
  assert_true(program.module_index("dew.std.wasi") is Some(_))
  assert_true(program.module_index("dew.std.i8x4") is Some(_))
  assert_true(program.module_index("dew.std.f64x2") is Some(_))
  let graph = build_module_dependency_graph(program)
  assert_eq(graph.diagnostics.length(), 0)
  assert_eq(graph.dependencies[0].length, 35)
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "wildcard imports expand over deterministic manifest module paths" {
  let program = collect_program_manifest(
    1195UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library.*\npub fn main() -> I32 {\n  left() + right()\n}\n",
        ),
      ]),
      ManifestModule::new("app.library.left", [
        ManifestFile::new("left.dew", b"pub fn left() -> I32 {\n  20\n}\n"),
      ]),
      ManifestModule::new("app.library.right", [
        ManifestFile::new("right.dew", b"pub fn right() -> I32 {\n  22\n}\n"),
      ]),
    ]),
  )
  let graph = build_module_dependency_graph(program)
  assert_eq(graph.diagnostics.length(), 0)
  assert_eq(graph.dependencies[0].length, 5)
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "missing wildcard import prefixes are diagnosed canonically" {
  let program = collect_program_manifest(
    1196UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open missing.prefix.*\npub fn main() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
  )
  match build_module_dependency_graph(program).diagnostics[0] {
    MissingImportedModule(_, "missing.prefix.*", _, 0UL) => ()
    _ => fail("expected missing wildcard-prefix diagnostic")
  }
}

///|
test "caller standard sources override bootstrap bytes without changing identities" {
  let manifest = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new(
        "main.dew", b"open dew.std.option\npub fn keep(value: Option<U32>) -> Option<U32> {\n  value\n}\n",
      ),
    ]),
  ])
  let bootstrap = collect_program_manifest(1192UL, manifest)
  let on_disk = collect_program_manifest_with_standard_sources(
    1192UL,
    manifest,
    StandardLibrarySources::new([
      ManifestFile::new(
        "std/option.dew",
        @standard_sources.standard_option_source(),
      ),
    ]),
    true,
  )
  assert_eq(on_disk.module_paths, bootstrap.module_paths)
  assert_eq(on_disk.modules.length(), bootstrap.modules.length())
  let bootstrap_option = bootstrap.module_index("dew.std.option").unwrap()
  let on_disk_option = on_disk.module_index("dew.std.option").unwrap()
  assert_eq(
    on_disk.modules[on_disk_option].declarations.length(),
    bootstrap.modules[bootstrap_option].declarations.length(),
  )
  assert_eq(
    freeze_program_interfaces(on_disk).import_diagnostics.length(),
    freeze_program_interfaces(bootstrap).import_diagnostics.length(),
  )
}

///|
test "no default preamble retains explicit standard imports only" {
  let without_default = collect_program_manifest_with_standard_sources(
    1193UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new("main.dew", b"pub fn value() -> I32 {\n  1\n}\n"),
      ]),
    ]),
    StandardLibrarySources::bootstrap(),
    false,
  )
  let graph = build_module_dependency_graph(without_default)
  assert_eq(graph.diagnostics.length(), 0)
  assert_eq(graph.dependencies[0].length, 0)
  let with_explicit = collect_program_manifest_with_standard_sources(
    1194UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.preamble\npub fn value() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
    StandardLibrarySources::bootstrap(),
    false,
  )
  assert_eq(
    build_module_dependency_graph(with_explicit).dependencies[0].length,
    1,
  )
}

///|
test "manifest assigns deterministic module and file identities" {
  let program = collect_program_manifest(
    1200UL,
    ProgramManifest::new([
      ManifestModule::new("app.alpha", [
        ManifestFile::new("a.dew", b"pub fn alpha() -> I32 {\n  1\n}\n"),
        ManifestFile::new("b.dew", b"fn helper() -> I32 {\n  alpha()\n}\n"),
      ]),
      ManifestModule::new("app.beta", [
        ManifestFile::new("main.dew", b"pub fn beta() -> I32 {\n  2\n}\n"),
      ]),
    ]),
  )
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(program.module_paths[0], "app.alpha")
  assert_eq(program.module_paths[1], "app.beta")
  assert_eq(program.module_paths[2], "dew.std.preamble")
  assert_eq(program.modules[0].module_id, 1200UL)
  assert_eq(program.modules[1].module_id, 1201UL)
  let alpha_files = program.modules[0].files
  let beta_files = program.modules[1].files
  assert_eq(
    alpha_files[alpha_files.length() - 2],
    make_program_file_id(1200UL, 0),
  )
  assert_eq(
    alpha_files[alpha_files.length() - 1],
    make_program_file_id(1200UL, 1),
  )
  assert_eq(
    beta_files[beta_files.length() - 1],
    make_program_file_id(1201UL, 0),
  )
}

///|
test "module graph resolves imports and groups cycles deterministically" {
  let program = collect_program_manifest(
    1300UL,
    ProgramManifest::new([
      ManifestModule::new("app.a", [
        ManifestFile::new(
          "a.dew", b"open app.b\nopen missing.module\npub fn a() -> I32 {\n  1\n}\n",
        ),
      ]),
      ManifestModule::new("app.b", [
        ManifestFile::new("b.dew", b"open app.a\npub fn b() -> I32 {\n  2\n}\n"),
      ]),
      ManifestModule::new("app.c", [
        ManifestFile::new("c.dew", b"open app.b\npub fn c() -> I32 {\n  3\n}\n"),
      ]),
    ]),
  )
  let graph = build_module_dependency_graph(program)
  assert_eq(graph.module_ids[0], 1300UL)
  assert_eq(graph.module_ids[1], 1301UL)
  assert_eq(graph.module_ids[2], 1302UL)
  assert_eq(graph.module_ids[3], 0xffff0000UL)
  assert_eq(graph.dependencies[0].length, 4)
  assert_eq(graph.dependencies[1].length, 4)
  assert_eq(graph.dependencies[2].length, 4)
  assert_eq(graph.dependencies[3].length, 0)
  assert_eq(graph.dependencies[4].length, 1)
  assert_eq(graph.dependencies[5].length, 1)
  assert_eq(graph.diagnostics.length(), 1)
  match graph.diagnostics[0] {
    MissingImportedModule(1300UL, "missing.module", _, 11UL) => ()
    _ => fail("expected missing import diagnostic")
  }
  assert_eq(graph.sccs.length(), 5)
  let mut found_cycle = false
  for scc in graph.sccs {
    if scc.length == 2 {
      found_cycle = true
    }
  }
  assert_true(found_cycle)
}

///|
test "frozen interfaces retain only public user declarations and signatures" {
  let collected = collect_program_bytes(
    1400UL, b"pub struct Item {}\nstruct Hidden {}\npub trait Read {\n  fn read(self) -> I32\n}\npub fn expose(value: I32) -> I32 {\n  value\n}\nfn hidden(value: I32) -> I32 {\n  value\n}\nimpl Add for I32 {\n  fn add(self, right: I32) -> I32 {\n    i32_add(self, right)\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let interface = freeze_module_interface(
    "app.api", collected, resolved, functions,
  )
  let names = interface.declarations.map(value => value.name)
  assert_eq(names, ["Item", "Read", "expose"])
  let callable_names = interface.callables.map(value => value.name)
  assert_eq(callable_names, ["read", "expose", "add"])
  assert_eq(interface.parameters.length(), 4)
  assert_eq(interface.implementations.length(), 1)
  assert_eq(interface.path, "app.api")
  assert_eq(
    interface.declaration_named("Item", FrozenTypeDeclaration),
    collected.lookup_type("Item"),
  )
  assert_eq(interface.callables_named("expose").length(), 1)
}

///|
test "frozen interfaces exclude test-only implementation evidence" {
  let module_id = 1425UL
  let collected = collect_program_files(module_id, [
    ProgramFile::named(
      make_program_file_id(module_id, 0),
      "library.dew",
      b"pub struct Item {}\npub trait Mark {\n  fn mark(self) -> I32\n}\n",
    ),
    ProgramFile::named(
      make_program_file_id(module_id, 1),
      "evidence_test.dew",
      b"impl Mark for Item {\n  fn mark(self) -> I32 {\n    7\n  }\n}\ntest \"uses local evidence\" {\n  assert(Item {}.mark() == 7, \"wrong mark\")\n}\n",
    ),
  ])
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let interface = freeze_module_interface(
    "app.evidence", collected, resolved, functions,
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(interface.implementations.length(), 0)
  assert_eq(interface.callables.map(value => value.name), ["mark"])
}

///|
test "frozen interfaces retain public fields and enum variants" {
  let collected = collect_program_bytes(
    1450UL, b"pub struct Box<t> {\n  value: t\n}\npub enum Maybe<t> {\n  None\n  Some(t)\n  Named {\n    value: t\n  }\n}\nstruct Hidden {\n  value: I32\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let functions = plan_module_functions(collected, resolved)
  let interface = freeze_module_interface(
    "app.aggregate", collected, resolved, functions,
  )
  assert_eq(interface.fields.length(), 2)
  assert_eq(interface.fields[0].name, "value")
  assert_eq(interface.fields[1].name, "value")
  assert_eq(interface.variants.length(), 3)
  assert_eq(interface.variants.map(value => value.name), [
    "None", "Some", "Named",
  ])
  assert_eq(interface.variants[1].payload_types.length, 1)
  assert_eq(interface.variant_payload_types.length(), 1)
}

///|
test "program interfaces freeze in graph order and remain manifest indexed" {
  let program = collect_program_manifest(
    1500UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub fn consume(value: I32) -> I32 {\n  value\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Item {}\npub fn identity(value: I32) -> I32 {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.graph.diagnostics.length(), 0)
  assert_eq(frozen.interfaces.length(), program.modules.length())
  assert_eq(frozen.interfaces[0].path, "app.consumer")
  assert_eq(frozen.interfaces[1].path, "app.library")
  assert_true(
    frozen.interfaces[1].declaration_named("Item", FrozenTypeDeclaration)
    is Some(_),
  )
  assert_eq(frozen.interfaces[1].callables_named("identity").length(), 1)
}

///|
test "interface value inference is required only by exported lets" {
  let function_only = collect_program_manifest(
    1550UL,
    ProgramManifest::new([
      ManifestModule::new("app.functions", [
        ManifestFile::new(
          "functions.dew", b"pub fn identity(value: I32) -> I32 {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  assert_false(
    frozen_module_requires_value_inference(
      "app.functions",
      function_only.modules[0],
    ),
  )
  let private_value = collect_program_manifest(
    1551UL,
    ProgramManifest::new([
      ManifestModule::new("app.private_value", [
        ManifestFile::new("private.dew", b"let hidden = 42\n"),
      ]),
    ]),
  )
  assert_false(
    frozen_module_requires_value_inference(
      "app.private_value",
      private_value.modules[0],
    ),
  )
  let public_value = collect_program_manifest(
    1552UL,
    ProgramManifest::new([
      ManifestModule::new("app.public_value", [
        ManifestFile::new("public.dew", b"pub let answer = 42\n"),
      ]),
    ]),
  )
  assert_true(
    frozen_module_requires_value_inference(
      "app.public_value",
      public_value.modules[0],
    ),
  )
  let interface_ = freeze_program_interfaces(public_value).interfaces[0]
  let mut answer_type = -1
  for declaration in interface_.declarations {
    if declaration.name == "answer" {
      answer_type = declaration.semantic_type
      break
    }
  }
  assert_true(answer_type >= 0)
  assert_eq(
    interface_.resolved_types.types[answer_type],
    PrimitiveType(I32Type),
  )
}

///|
test "imported public types and traits resolve in consumer signatures" {
  let program = collect_program_manifest(
    1600UL,
    ProgramManifest::new([
      ManifestModule::new("app.consumer", [
        ManifestFile::new(
          "consumer.dew", b"open app.library\npub struct Local {}\npub fn keep(value: Item<I32>) -> Item<I32> {\n  value\n}\nimpl Show for Local {\n  fn show(self) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Item<t> {}\npub trait Show {\n  fn show(self) -> I32\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  let item = frozen.interfaces[1]
    .declaration_named("Item", FrozenTypeDeclaration)
    .unwrap()
  let show = frozen.interfaces[1]
    .declaration_named("Show", FrozenTraitDeclaration)
    .unwrap()
  let keep = frozen.interfaces[0].callables_named("keep")[0]
  let parameter = frozen.interfaces[0].parameters[keep.parameters.start]
  match frozen.interfaces[0].resolved_types.types[parameter.type_] {
    AppliedType(base, _) =>
      assert_eq(
        frozen.interfaces[0].resolved_types.types[base],
        NominalType(item),
      )
    _ => fail("expected imported applied nominal type")
  }
  let trait_type = frozen.interfaces[0].implementations[0].trait_type
  assert_eq(
    frozen.interfaces[0].resolved_types.types[trait_type],
    TraitType(show),
  )
}

///|
test "frozen callable ABI fingerprints ignore external module ID assignment" {
  let freeze = fn(seed : ModuleId) -> String {
    let program = collect_program_manifest(
      seed,
      ProgramManifest::new([
        ManifestModule::new("app.main", [
          ManifestFile::new(
            "main.dew", b"open app.library\npub fn keep(value: Item) -> Item {\n  value\n}\n",
          ),
        ]),
        ManifestModule::new("app.library", [
          ManifestFile::new(
            "library.dew", b"pub struct Item {\n  value: I32\n}\n",
          ),
        ]),
      ]),
    )
    let frozen = freeze_program_interfaces(program)
    if frozen.import_diagnostics.length() != 0 {
      abort("unexpected external ABI fingerprint import diagnostics")
    }
    frozen.interfaces[0].callables_named("keep")[0].abi_fingerprint
  }
  assert_eq(freeze(1640UL), freeze(2640UL))
}

///|
test "frozen callable ABI fingerprints are stable and signature sensitive" {
  let freeze = fn(seed : ModuleId, source : Bytes) -> String {
    let program = collect_program_manifest(
      seed,
      ProgramManifest::new([
        ManifestModule::new("abi.library", [
          ManifestFile::new("library.dew", source),
        ]),
      ]),
    )
    let frozen = freeze_program_interfaces(program)
    if frozen.import_diagnostics.length() != 0 {
      abort("unexpected ABI fingerprint import diagnostics")
    }
    frozen.interfaces[0].callables_named("identity")[0].abi_fingerprint
  }
  let generic_source = b"pub fn identity<t>(value: t) -> t {\n  value\n}\n"
  let first = freeze(1650UL, generic_source)
  let repeated = freeze(2650UL, generic_source)
  let changed = freeze(
    1650UL, b"pub fn identity(value: I64) -> I64 {\n  value\n}\n",
  )
  assert_eq(first.length(), 64)
  assert_eq(first, repeated)
  assert_true(first != changed)
}

///|
test "nominal declaration ABI fingerprints are stable and content sensitive" {
  let freeze = fn(seed : ModuleId, source : Bytes) -> String {
    let program = collect_program_manifest(
      seed,
      ProgramManifest::new([
        ManifestModule::new("abi.nominal", [
          ManifestFile::new("nominal.dew", source),
        ]),
      ]),
    )
    let interface_ = freeze_program_interfaces(program).interfaces[0]
    for index, declaration in interface_.declarations {
      if declaration.name == "Item" {
        return interface_.declaration_abi_fingerprints[index]
      }
    }
    abort("missing Item declaration fingerprint")
  }
  let i32 = b"pub struct Item {\n  value: I32\n}\n"
  let i64 = b"pub struct Item {\n  value: I64\n}\n"
  assert_eq(freeze(1660UL, i32), freeze(2660UL, i32))
  assert_true(freeze(1660UL, i32) != freeze(1660UL, i64))
}

///|
test "generic bounds participate in callable and implementation fingerprints" {
  let freeze_callable = fn(seed : ModuleId, bound : String) -> String {
    let source = Buffer()
    source.write_string_utf8(
      "pub trait First {}\npub trait Second {}\npub fn keep<t: ",
    )
    source.write_string_utf8(bound)
    source.write_string_utf8(">(value: t) -> t {\n  value\n}\n")
    let program = collect_program_manifest(
      seed,
      ProgramManifest::new([
        ManifestModule::new("abi.bounds", [
          ManifestFile::new("bounds.dew", source.to_bytes()),
        ]),
      ]),
    )
    freeze_program_interfaces(program).interfaces[0].callables_named("keep")[0].abi_fingerprint
  }
  assert_eq(freeze_callable(1665UL, "First"), freeze_callable(2665UL, "First"))
  assert_true(
    freeze_callable(1665UL, "First") != freeze_callable(1665UL, "Second"),
  )

  let freeze_implementation = fn(seed : ModuleId, bound : String) -> String {
    let source = Buffer()
    source.write_string_utf8(
      "pub trait First {}\npub trait Second {}\npub trait Mark {}\npub struct Box<t> {\n  value: t\n}\nimpl<t: ",
    )
    source.write_string_utf8(bound)
    source.write_string_utf8("> Mark for Box<t> {}\n")
    let program = collect_program_manifest(
      seed,
      ProgramManifest::new([
        ManifestModule::new("abi.impl_bounds", [
          ManifestFile::new("bounds.dew", source.to_bytes()),
        ]),
      ]),
    )
    freeze_program_interfaces(program).interfaces[0].content_fingerprint
  }
  assert_eq(
    freeze_implementation(1666UL, "First"),
    freeze_implementation(2666UL, "First"),
  )
  assert_true(
    freeze_implementation(1666UL, "First") !=
    freeze_implementation(1666UL, "Second"),
  )
}

///|
test "frozen interfaces retain conditional derived evidence" {
  let program = collect_program_manifest(
    1667UL,
    ProgramManifest::new([
      ManifestModule::new("abi.derived", [
        ManifestFile::new(
          "derived.dew", b"pub struct Box<t> {\n  value: t\n} derive(Eq, Debug, Hash)\n",
        ),
      ]),
    ]),
  )
  let interface_ = freeze_program_interfaces(program).interfaces[0]
  assert_eq(interface_.implementations.length(), 4)
  let mut method_count = 0
  for implementation in interface_.implementations {
    assert_eq(implementation.generic_parameters.length, 1)
    let bounds = interface_.generic_parameter_bounds[implementation.generic_parameters.start]
    assert_eq(bounds.length, 1)
    for callable in interface_.callables {
      match callable.kind {
        FrozenImplCallable(owner) if owner == implementation.declaration =>
          method_count += 1
        _ => ()
      }
    }
  }
  assert_eq(method_count, 5)
}

///|
test "module interface fingerprints ignore private implementation changes" {
  let freeze = fn(source : Bytes) -> String {
    let program = collect_program_manifest(
      1670UL,
      ProgramManifest::new([
        ManifestModule::new("abi.private", [
          ManifestFile::new("private.dew", source),
        ]),
      ]),
    )
    freeze_program_interfaces(program).interfaces[0].interface_fingerprint
  }
  let first = b"pub struct Item {\n  value: I32\n}\nfn hidden() -> I32 {\n  1\n}\n"
  let second = b"pub struct Item {\n  value: I32\n}\nfn hidden() -> I32 {\n  2\n}\n"
  assert_eq(freeze(first), freeze(second))
}

///|
test "module interface fingerprints include transitive dependency content" {
  let freeze = fn(field_type : Bytes) -> String {
    let library = Buffer()
    library.write_bytes(b"pub struct Item {\n  value: ")
    library.write_bytes(field_type)
    library.write_bytes(b"\n}\n")
    let program = collect_program_manifest(
      1680UL,
      ProgramManifest::new([
        ManifestModule::new("abi.main", [
          ManifestFile::new(
            "main.dew", b"open abi.library\npub fn keep(value: Item) -> Item {\n  value\n}\n",
          ),
        ]),
        ManifestModule::new("abi.library", [
          ManifestFile::new("library.dew", library.to_bytes()),
        ]),
      ]),
    )
    freeze_program_interfaces(program).interfaces[0].interface_fingerprint
  }
  assert_true(freeze(b"I32") != freeze(b"I64"))
}

///|
test "cyclic module interfaces resolve imported nominal signatures" {
  let program = collect_program_manifest(
    1700UL,
    ProgramManifest::new([
      ManifestModule::new("cycle.a", [
        ManifestFile::new(
          "a.dew", b"open cycle.b\npub struct A {}\npub fn from_b(value: B) -> B {\n  value\n}\n",
        ),
      ]),
      ManifestModule::new("cycle.b", [
        ManifestFile::new(
          "b.dew", b"open cycle.a\npub struct B {}\npub fn from_a(value: A) -> A {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.graph.sccs.length(), 4)
  let mut found_cycle = false
  for scc in frozen.graph.sccs {
    if scc.length == 2 {
      found_cycle = true
    }
  }
  assert_true(found_cycle)
  assert_eq(frozen.import_diagnostics.length(), 0)
  assert_eq(frozen.interfaces[0].resolved_types.diagnostics.length(), 0)
  assert_eq(frozen.interfaces[1].resolved_types.diagnostics.length(), 0)
  let b = frozen.interfaces[1]
    .declaration_named("B", FrozenTypeDeclaration)
    .unwrap()
  let from_b = frozen.interfaces[0].callables_named("from_b")[0]
  let parameter = frozen.interfaces[0].parameters[from_b.parameters.start]
  assert_eq(
    frozen.interfaces[0].resolved_types.types[parameter.type_],
    NominalType(b),
  )
}
