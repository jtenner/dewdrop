///|
test "transform signatures add a parameter and repair function values" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\n// Add a parameter. Existing calls get an explicit default through the adapter.\ntransform fn add_bonus(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let parameters = [@ast.parameter(\"value\", @ast.named_type(\"I32\")), @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))]\n  let changed = node.with_signature(parameters, @ast.named_type(\"I32\"))\n  let body = changed.with_body(@ast.name(\"value\").binary(\"+\", @ast.name(\"bonus\")))\n  body.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(2i32)]))\n}\n\n#add_bonus\nfn answer(value: I32) -> I32 {\n  value\n}\n\npub fn main() -> I32 {\n  let callback = answer\n  callback(40i32)\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("__dew_transform_adapter_")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures change result type with an explicit adapter" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.ExprNode::If(@ast.name(node.name).call([]), @ast.integer(42i32), @ast.integer(0i32)))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\npub fn main() -> I32 {\n  answer()\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("__dew_transform_adapter_")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures repair retained recursive source through wrappers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let parameters = [ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))]\n  let changed = node.with_parameters(parameters).prepend(@ast.unit())\n  changed.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(2i32)]))\n}\n#extend\nfn answer(value: I32) -> I32 {\n  if value == 0i32 {\n    40i32\n  } else {\n    answer(0i32) + 2i32\n  }\n}\npub fn main() -> I32 {\n  answer(1i32)\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("__dew_transform_adapter_")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures leave same named locals unchanged" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  changed.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(0i32)]))\n}\n#extend\nfn answer(value: I32) -> I32 {\n  value\n}\npub fn main() -> I32 {\n  let answer = fn(value: I32) -> I32 {\n    value + 2i32\n  }\n  answer(40i32)\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("__dew_transform_adapter_")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures reject duplicate generated parameter names" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_parameters([@ast.parameter(\"value\", @ast.named_type(\"I32\")), @ast.parameter(\"value\", @ast.named_type(\"I32\"))])\n}\n#bad\npub fn main() -> I32 {\n  42i32\n}\n",
    ) {
    Ok(_) => fail("invalid transform signature was accepted")
    Err(error) =>
      assert_true(
        error
        .message()
        .contains("invalid or duplicate generated parameter name"),
      )
  }
}

///|
test "transform signatures reject invalid generated type names" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_return_type(@ast.named_type(\"I32; fn injected()\"))\n}\n#bad\npub fn main() -> I32 {\n  42i32\n}\n",
    ) {
    Ok(_) => fail("invalid transform signature was accepted")
    Err(error) =>
      assert_true(error.message().contains("invalid generated named type"))
  }
}

///|
test "transform signatures reject deep source adapters" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn bad(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.source(\"(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((42i32)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))\"))\n}\n#bad\nfn answer() -> I32 {\n  42i32\n}\npub fn main() -> I32 {\n  answer()\n}\n",
    ) {
    Ok(_) => fail("invalid transform signature was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("generated syntax nesting limit exceeded"),
      )
  }
}

///|
test "transform signatures generic parameter preserved" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  changed.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(0i32)]))\n}\n#extend\nfn answer<t>(value: t) -> t {\n  value\n}\npub fn main() -> I32 {\n  answer(42i32)\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures stack preserves changed signature and adapter" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  changed.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(0i32)]))\n}\ntransform fn keep(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.prepend(@ast.unit())\n}\n#extend\n#keep\nfn answer(value: I32) -> I32 {\n  value\n}\npub fn main() -> I32 {\n  answer(42i32)\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform signatures repair earlier imported calls and references" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import helper as @h\npub fn main() -> I32 {\n  let callback = @h.answer\n  callback(40i32) + @h.answer(2i32)\n}\n",
      ),
    ]),
    @semantic.ManifestModule::new("helper", [
      @semantic.ManifestFile::new(
        "helper.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  changed.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(0i32)]))\n}\n#extend\npub fn answer(value: I32) -> I32 {\n  value\n}\n",
      ),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Ok(compiled) => {
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("@h.__dew_transform_adapter_")
        }),
      )
      assert_true(compiled.emit_binary().unwrap().length() > 8)
    }
    Err(error) => fail(error.message())
  }
}
