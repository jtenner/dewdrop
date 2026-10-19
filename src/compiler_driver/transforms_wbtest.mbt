///|
test "compiler emits a transformed function" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> Result<@ast.FnNode, @transform.TransformError> {\n Result::Ok(@ast.with_body(node, @ast.integer(42i32)))\n}\n#answer\npub fn main() -> I32 {\n missing_name\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  let options = CompilerPipelineOptions::production(5100UL, 0, true)
  let compiled = compile_manifest_uncached(
    manifest,
    @semantic.StandardLibrarySources::bootstrap(),
    options,
  )
  match compiled {
    Ok(value) => assert_true(value.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "compiler rejects generated type errors" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.ExprNode::Boolean(true))\n}\n#wrong\npub fn main() -> I32 {\n 0i32\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Err(CompilerSourceError(_, diagnostics)) =>
      assert_true(diagnostics.length() > 0)
    _ => fail("generated type errors must stop compilation")
  }
}

///|
test "transform validation does not bind a target parameter named unreachable" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(42i32))\n}\n#answer\npub fn main(unreachable: I32) -> I32 {\n missing_name\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, false),
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "scalar helper proof offsets survive target body replacement" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n#answer\npub fn main() -> I32 {\n missing_name\n}\nfn helper() -> I32 {\n 6i32 * 7i32\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "custom scalar operators cannot silently use primitive transform behavior" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Add {\n fn add(self, right: Self) -> Self\n}\nimpl Add for I32 {\n fn add(self, right: I32) -> I32 {\n 77i32\n }\n}\nfn helper() -> I32 {\n 1i32 + 2i32\n}\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n#answer\npub fn main() -> I32 {\n 0i32\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, false),
    ) {
    Err(error) =>
      assert_true(
        error
        .message()
        .contains(
          "selected operator has no supported compile-time primitive proof",
        ),
      )
    Ok(_) => fail("custom Add must not produce 3 at compile time")
  }
}

///|
fn compile_transform_source(
  source : Bytes,
) -> Result[CompilerCompilation, CompilerCompilationError] {
  compile_manifest_uncached(
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
    @semantic.StandardLibrarySources::bootstrap(),
    CompilerPipelineOptions::production(5100UL, 0, true),
  )
}

///|
test "stacked transforms and syntax builders pass normal checks" {
  let source = b"open dew.std.array\nimport dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n value\n}\ntransform fn first(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(21i32))\n}\ntransform fn second(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.ExprNode::Block([\n @ast.ExprNode::Bind(ctx.fresh_name, @ast.call(@ast.ExprNode::Name(\"identity\"), [node.body])),\n @ast.ExprNode::If(@ast.ExprNode::Boolean(true), @ast.ExprNode::Return(@ast.ExprNode::Binary(\"*\", @ast.ExprNode::Name(ctx.fresh_name), @ast.integer(2i32))), @ast.integer(0i32))\n ]))\n}\n#first\n#second\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform errors report the user message" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn no(node: @ast.FnNode, ctx: @transform.TransformContext) -> Result<@ast.FnNode, @transform.TransformError> {\n Result::Err(@transform.error(\"cannot transform this function\"))\n}\n#no\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Err(error) =>
      assert_true(error.message().contains("cannot transform this function"))
    _ => fail("explicit transform error must fail compilation")
  }
}

///|
test "errors below a transformed function retain original source lines" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(42i32))\n}\n#replace\nfn target() -> I32 {\n 1i32\n 2i32\n 3i32\n}\nfn invalid() -> I32 {\n true\n}\n"
  match compile_transform_source(source) {
    Err(error) =>
      assert_true(error.message().contains("main.dew:12:"), msg=error.message())
    _ => fail("source error must remain visible")
  }
}

///|
test "early returns inside helper branches propagate" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn helper() -> I32 {\n if true {\n return 42i32\n }\n 0i32\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "signed minimum remainder by negative one is zero at compile time" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn helper() -> I32 {\n -2147483648i32 % -1i32\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(helper()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "transform lookup sees standard imports added by the test command" {
  let source = b"open dew.std.string\nopen dew.std.array\nimport dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: @ast.FnNode, ctx: @transform.TransformContext) -> Result<@ast.FnNode, @transform.TransformError> {\n Result::Ok(@ast.with_body(node, @ast.integer(42i32)))\n}\n#answer\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}
