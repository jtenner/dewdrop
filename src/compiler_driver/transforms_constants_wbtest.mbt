///|
test "source transforms read module constants" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nlet factor = 6i32\nlet answer = factor * 7i32\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "module initialization runs once and resets for each transform" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nstruct Counter {\n  mut value: I32\n}\n\nlet counter = Counter::{\n  value: 40i32\n}\n\nfn next() -> I32 {\n  counter.value = counter.value + 1i32\n  counter.value\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = next()\n  node.with_body(@ast.integer(next()))\n}\n\n#replace\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "mutable module bindings remain unavailable at compile time" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nlet mut answer = 42i32\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("mutable module bindings"),
        msg=error.message(),
      )
    Ok(_) => fail("mutable module bindings must fail")
  }
}

///|
test "imported public module constants retain their checked declaration" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport example.constant_tools as @constants\n\nlet multiplier = 7i32\nlet answer = @constants.factor * multiplier\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
      ),
    ]),
    @semantic.ManifestModule::new("example.constant_tools", [
      @semantic.ManifestFile::new("tools.dew", b"pub let factor = 6i32\n"),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}
