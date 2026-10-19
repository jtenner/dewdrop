///|
fn pool_test_module(path : String, source : Bytes) -> @semantic.ManifestModule {
  @semantic.ManifestModule::new(path, [
    @semantic.ManifestFile::new(path + ".dew", source),
  ])
}

///|
test "source pool follows transitive imports and leaves unused invalid source untouched" {
  let root = pool_test_module(
    "app", b"open dep.first\npub fn main() -> I32 {\n first()\n}\n",
  )
  let unused = pool_test_module("unused.invalid", b"\xff definitely invalid")
  let first = pool_test_module(
    "dep.first", b"open dep.second\npub fn first() -> I32 {\n second()\n}\n",
  )
  let second = pool_test_module(
    "dep.second", b"pub fn second() -> I32 {\n 42i32\n}\n",
  )
  let pool = @semantic.ProgramManifest::new([unused, second, first])
  let manifest = @semantic.ProgramManifest::new([root])
  let selected = compiler_manifest_import_closure(manifest, pool)
  assert_eq(selected.modules.map(module_ => module_.path), [
    "app", "dep.first", "dep.second",
  ])
  let compiled = match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  assert_eq(compiled.program.module_index("unused.invalid"), None)
  assert_true(compiled.program.module_index("dep.second") is Some(_))
}

///|
test "late generated imports resolve pooled user sources and their dependencies" {
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module(
      "app", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dep.first\", \"generated\")\n node.with_body(@ast.source(\"@generated.first()\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ),
  ])
  let pool = @semantic.ProgramManifest::new([
    pool_test_module("unused.invalid", b"\xff invalid"),
    pool_test_module(
      "dep.first", b"open dep.second\npub fn first() -> I32 {\n second()\n}\n",
    ),
    pool_test_module("dep.second", b"pub fn second() -> I32 {\n 42i32\n}\n"),
  ])
  let compiled = match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  assert_true(compiled.program.module_index("dep.first") is Some(_))
  assert_true(compiled.program.module_index("dep.second") is Some(_))
  assert_eq(compiled.program.module_index("unused.invalid"), None)
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Err(error) =>
      assert_true(error.message().contains("dep.first"), msg=error.message())
    Ok(_) => fail("a missing late import must fail")
  }
}

///|
test "late pooled modules run their own source transforms" {
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module(
      "app", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dep.generated\", \"generated\")\n node.with_body(@ast.source(\"@generated.answer()\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ),
  ])
  let pool = @semantic.ProgramManifest::new([
    pool_test_module(
      "dep.generated", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn answer() -> I32 {\n 0i32\n}\n",
    ),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(compiled) => {
      assert_true(compiled.program.module_index("dep.generated") is Some(_))
      assert_eq(compiled.program.module_paths[0], "app")
    }
    Err(error) => fail(error.message())
  }
}

///|
test "late pooled targets can use an earlier imported transform" {
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module(
      "app", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.add_function(\"fn once_marker() -> I32 {\\n 0i32\\n}\")\n ctx.import_module(\"dep.generated\", \"generated\")\n node.with_body(@ast.source(\"@generated.answer()\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ),
    pool_test_module(
      "early.tools", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\npub transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n",
    ),
  ])
  let pool = @semantic.ProgramManifest::new([
    pool_test_module(
      "dep.generated", b"import early.tools as @tools\n#@tools.replace\npub fn answer() -> I32 {\n 0i32\n}\n",
    ),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(compiled) =>
      assert_true(compiled.program.module_index("dep.generated") is Some(_))
    Err(error) => fail(error.message())
  }
}

///|
test "repeated preparation trusts only tracked exact compiler API sources" {
  let api = @transforms.transform_library_sources()[0]
  let active : @transforms.SourceModule = {
    path: "app",
    files: [
      { path: "app.dew", source: b"transform fn mark() -> I32 {\n 0i32\n}\n", },
    ],
  }
  assert_true(@transforms.prepare([api, active]) is Err(_))
  assert_true(
    @transforms.prepare([api, active], trusted_library_indices=[1]) is Err(_),
  )
  assert_true(
    @transforms.prepare([api, active], trusted_library_indices=[0]) is Ok(_),
  )
  let changed_path : @transforms.SourceModule = {
    path: api.path,
    files: [{ path: "spoof.dew", source: api.files[0].source, }],
  }
  assert_true(
    @transforms.prepare([changed_path, active], trusted_library_indices=[0])
    is Err(_),
  )
  let changed_source : @transforms.SourceModule = {
    path: api.path,
    files: [{ path: api.files[0].path, source: b"", }],
  }
  assert_true(
    @transforms.prepare([changed_source, active], trusted_library_indices=[0])
    is Err(_),
  )
}

///|
test "pooled standard modules retain arbitrary file paths extra files and user dependencies" {
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module(
      "app", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.map\", \"selected\")\n node.with_body(@ast.source(\"@selected.answer()\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ),
  ])
  let pool = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("dew.std.map", [
      @semantic.ManifestFile::new(
        "custom-map.dew", b"open dep.helper\npub fn answer() -> I32 {\n helper() + extra()\n}\n",
      ),
      @semantic.ManifestFile::new(
        "helpers.dew", b"fn extra() -> I32 {\n 2i32\n}\n",
      ),
    ]),
    pool_test_module("dep.helper", b"pub fn helper() -> I32 {\n 40i32\n}\n"),
    pool_test_module("dew.std.json", b"\xff unused invalid standard source"),
  ])
  let compiled = match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  let index = compiled.program.module_index("dew.std.map").unwrap()
  assert_eq(compiled.program.modules[index].file_paths, [
    "custom-map.dew", "helpers.dew",
  ])
  assert_eq(compiled.program.modules[index].module_id, 0xffff000bUL)
  assert_eq(
    compiled.program.module_paths.filter(path => path == "dew.std.map").length(),
    1,
  )
  assert_eq(compiled.program.module_index("dew.std.json"), None)
  assert_true(compiled.program.module_index("dep.helper") is Some(_))
}

///|
test "explicit standard modules retain the root index and canonical identities" {
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module("dew.std.map", b"pub let selected_marker = 42i32\n"),
    pool_test_module(
      "app", b"import dew.std.map as @selected\npub fn main() -> I32 {\n @selected.selected_marker\n}\n",
    ),
  ])
  let compiled = match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 1, true),
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  assert_eq(compiled.program.module_paths[0], "dew.std.map")
  assert_eq(compiled.program.module_paths[1], "app")
  assert_eq(compiled.program.modules[0].module_id, 0xffff000bUL)
  assert_eq(
    compiled.program.module_paths.filter(path => path == "dew.std.map").length(),
    1,
  )
}

///|
test "injected API dependencies preserve custom files without extending API trust" {
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let mut array_source = b""
  for index, path in sources.paths {
    if path == "std/array.dew" {
      array_source = sources.sources[index]
    }
  }
  assert_true(array_source.length() > 0)
  let manifest = @semantic.ProgramManifest::new([
    pool_test_module(
      "app", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.array\", \"selected\")\n node.with_body(@ast.source(\"@selected.selected_marker\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ),
  ])
  let pool = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("dew.std.array", [
      @semantic.ManifestFile::new("custom-array.dew", array_source),
      @semantic.ManifestFile::new(
        "array-marker.dew", b"pub let selected_marker = 42i32\n",
      ),
    ]),
  ])
  let compiled = match
    compile_manifest_uncached(
      manifest,
      sources,
      CompilerPipelineOptions::production(5100UL, 0, true),
      source_pool=pool,
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  assert_eq(compiled.program.module_paths[0], "app")
  assert_eq(compiled.program.module_paths[1], "dewdrop.ast")
  assert_eq(compiled.program.module_paths[2], "dewdrop.transform")
  assert_eq(compiled.program.module_paths[3], "dew.std.array")
  assert_eq(compiled.program.modules[3].file_paths, [
    "custom-array.dew", "array-marker.dew",
  ])
}
