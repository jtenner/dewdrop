///|
fn transform_cache_test_manifest() -> @semantic.ProgramManifest {
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
}

///|
test "transform result cache survives a new session with equal source and reports" {
  let manifest = transform_cache_test_manifest()
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let cold = CompilerTransformCache::new("test compiler build")
  let options = CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
    cold,
  )
  let first = match compile_manifest_uncached(manifest, sources, options) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(cold.status(), "miss")
  assert_true(cold.snapshot().length() > 76)
  let warm = CompilerTransformCache::new(
    "test compiler build",
    prior_bytes=cold.snapshot(),
  )
  let warm_options = CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
    warm,
  )
  let second = match
    compile_manifest_uncached(manifest, sources, warm_options) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(warm.status(), "hit")
  assert_eq(options.transform_reports, warm_options.transform_reports)
  assert_eq(
    first.program.modules[0].file_sources,
    second.program.modules[0].file_sources,
  )
  assert_eq(first.emit_binary().unwrap(), second.emit_binary().unwrap())
}

///|
test "transform cache keys include files pools standard sources compiler and options" {
  let input = transform_cache_test_manifest()
  let empty = @semantic.ProgramManifest::new([])
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let options = CompilerPipelineOptions::production(5100UL, 0, true)
  let key = compiler_transform_cache_key(
    input, empty, sources, options, "build A",
  )
  let changed = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", input.modules[0].files[0].source),
      @semantic.ManifestFile::new(
        "helper.dew", b"fn helper() -> I32 { 42i32 }\n",
      ),
    ]),
  ])
  let moved = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("moved.dew", input.modules[0].files[0].source),
    ]),
  ])
  let source_changed = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew",
        input.modules[0].files[0].source + b"\n",
      ),
    ]),
  ])
  for manifest in [changed, moved, source_changed] {
    assert_not_eq(
      compiler_transform_cache_key(manifest, empty, sources, options, "build A"),
      key,
    )
    assert_not_eq(
      compiler_transform_cache_key(input, manifest, sources, options, "build A"),
      key,
    )
  }
  assert_not_eq(
    compiler_transform_cache_key(input, empty, sources, options, "build B"),
    key,
  )
  for
    changed_options in [
      CompilerPipelineOptions::production(5101UL, 0, true),
      CompilerPipelineOptions::production(5100UL, 1, true),
      CompilerPipelineOptions::production(5100UL, 0, false),
      CompilerPipelineOptions::test_mode(5100UL, 0, true),
    ] {
    assert_not_eq(
      compiler_transform_cache_key(
        input, empty, sources, changed_options, "build A",
      ),
      key,
    )
  }
  let changed_standard = @semantic.StandardLibrarySources::new([
    @semantic.ManifestFile::new("std/custom.dew", b"pub let answer = 42i32\n"),
  ])
  assert_not_eq(
    compiler_transform_cache_key(
      input, empty, changed_standard, options, "build A",
    ),
    key,
  )
}

///|
fn transform_cache_test_patch(
  bytes : Bytes,
  index : Int32,
  value : Byte,
) -> Bytes {
  let out = Buffer(size_hint=bytes.length())
  for i in 0..<bytes.length() {
    out.write_byte(if i == index { value } else { bytes[i] })
  }
  out.to_bytes()
}

///|
test "transform cache rejects damaged truncated excessive and mismatched artifacts" {
  let manifest = transform_cache_test_manifest()
  let key = @cache_binary.blake3(b"key")
  let bytes = transform_cache_encode(key, manifest, []).unwrap()
  assert_true(transform_cache_decode(bytes, key) is Some(_))
  assert_true(
    transform_cache_decode(bytes, @cache_binary.blake3(b"other")) is None,
  )
  for index in [0, 4, 8, 40, 72, bytes.length() - 1] {
    assert_true(
      transform_cache_decode(
        transform_cache_test_patch(bytes, index, bytes[index] ^ 1),
        key,
      )
      is None,
    )
  }
  for length in [0, 4, 39, 75, 76, bytes.length() - 1] {
    let out = Buffer(size_hint=length)
    for i in 0..<length {
      out.write_byte(bytes[i])
    }
    assert_true(transform_cache_decode(out.to_bytes(), key) is None)
  }
  assert_true(transform_cache_decode(bytes + b"\x00", key) is None)
  let excessive = Buffer()
  transform_cache_u32(excessive, 4294967295U)
  let payload = excessive.to_bytes()
  let malformed = Buffer()
  malformed.write_bytes(b"DWTC")
  transform_cache_u32(malformed, 1U)
  transform_cache_digest(malformed, key)
  transform_cache_digest(malformed, @cache_binary.blake3(payload))
  transform_cache_u32(malformed, payload.length().reinterpret_as_uint())
  malformed.write_bytes(payload)
  assert_true(transform_cache_decode(malformed.to_bytes(), key) is None)
}

///|
test "transform cache hit still rejects generated type errors" {
  let input = transform_cache_test_manifest()
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let options = CompilerPipelineOptions::production(5100UL, 0, true)
  let key = compiler_transform_cache_key(
    input,
    @semantic.ProgramManifest::new([]),
    sources,
    options,
    "build",
  )
  let bad = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"pub fn main() -> I32 {\n true\n}\n",
      ),
    ]),
  ])
  let bytes = transform_cache_encode(key, bad, []).unwrap()
  let cache = CompilerTransformCache::new("build", prior_bytes=bytes)
  match
    compile_manifest_uncached(
      input,
      sources,
      options.with_transform_cache(cache),
    ) {
    Err(CompilerSourceError(_, diagnostics)) =>
      assert_true(diagnostics.length() > 0)
    Err(error) => fail(error.message())
    Ok(_) => fail("cached generated code must still pass the source checker")
  }
  assert_eq(cache.status(), "hit")
  assert_eq(cache.snapshot(), bytes)
}

///|
test "a failed expansion result cannot replace the saved transform artifact" {
  let input = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.ExprNode::Boolean(true))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let cache = CompilerTransformCache::new(
    "build",
    prior_bytes=b"keep the last artifact",
  )
  match
    compile_manifest_uncached(
      input,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
        cache,
      ),
    ) {
    Err(CompilerSourceError(_, diagnostics)) =>
      assert_true(diagnostics.length() > 0)
    Err(error) => fail(error.message())
    Ok(_) => fail("invalid generated source must fail")
  }
  assert_eq(cache.snapshot(), b"keep the last artifact")
}

///|
test "late initializer source errors cannot publish a transform artifact" {
  let input = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn keep(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node\n}\nbuiltin is_unit<t>() -> Bool = \"types.is_unit\"\nfn choose<t>() -> I64 {\n if is_unit::<t>() {\n answer\n } else {\n 42i64\n }\n}\nlet answer = choose::<Unit>()\n#keep\npub fn main() -> I64 {\n answer\n}\n",
      ),
    ]),
  ])
  let cache = CompilerTransformCache::new(
    "build",
    prior_bytes=b"keep the last artifact",
  )
  let compiled = match
    compile_manifest_uncached(
      input,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
        cache,
      ),
    ) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_true(compiled.link.diagnostics.length() > 0)
  assert_true(compiled.has_errors())
  assert_eq(cache.snapshot(), b"keep the last artifact")
}

///|
test "damaged transform artifact falls back to a checked expansion" {
  let cache = CompilerTransformCache::new("build", prior_bytes=b"DWTC broken")
  let result = compile_manifest_uncached(
    transform_cache_test_manifest(),
    @semantic.StandardLibrarySources::bootstrap(),
    CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
      cache,
    ),
  ).unwrap()
  assert_false(result.has_errors())
  assert_eq(cache.status(), "miss")
  assert_true(cache.snapshot().length() > 76)
}

///|
test "a transform in the source pool can use the saved expansion" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import example.tools as @tools\n#@tools.replace\npub fn main() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let pool = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("example.tools", [
      @semantic.ManifestFile::new(
        "tools.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\npub transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n",
      ),
    ]),
  ])
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let cold = CompilerTransformCache::new("build")
  let first = compile_manifest_uncached(
    manifest,
    sources,
    CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
      cold,
    ),
    source_pool=pool,
  ).unwrap()
  assert_false(first.has_errors())
  let warm = CompilerTransformCache::new("build", prior_bytes=cold.snapshot())
  let second = compile_manifest_uncached(
    manifest,
    sources,
    CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
      warm,
    ),
    source_pool=pool,
  ).unwrap()
  assert_eq(warm.status(), "hit")
  assert_eq(first.emit_binary().unwrap(), second.emit_binary().unwrap())
}

///|
test "pool-only transform syntax can hit the expansion cache" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import example.tools as @tools\npub fn main() -> I32 {\n @tools.answer()\n}\n",
      ),
    ]),
  ])
  let pool = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("example.tools", [
      @semantic.ManifestFile::new(
        "tools.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn answer() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let sources = @semantic.StandardLibrarySources::bootstrap()
  let cold = CompilerTransformCache::new("build")
  let first = compile_manifest_uncached(
    manifest,
    sources,
    CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
      cold,
    ),
    source_pool=pool,
  ).unwrap()
  assert_false(first.has_errors())
  assert_eq(cold.status(), "miss")
  let warm = CompilerTransformCache::new("build", prior_bytes=cold.snapshot())
  let second = compile_manifest_uncached(
    manifest,
    sources,
    CompilerPipelineOptions::production(5100UL, 0, true).with_transform_cache(
      warm,
    ),
    source_pool=pool,
  ).unwrap()
  assert_eq(warm.status(), "hit")
  assert_eq(first.emit_binary().unwrap(), second.emit_binary().unwrap())
}
