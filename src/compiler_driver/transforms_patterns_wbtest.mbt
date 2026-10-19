///|
test "checked transform patterns distinguish cases from local bindings" {
  let prefix = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n"
  let suffix = b"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(choose()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  let helpers = [
    b"fn choose() -> I32 {\n match Option::Some(5i32) {\n None => 0i32\n Some(x) => x\n }\n}\n",
    b"enum Choice {\n Empty\n Item(I32)\n}\nfn choose() -> I32 {\n match Choice::Item(5i32) {\n Empty => 0i32\n Item(x) => x\n }\n}\n",
    b"fn choose() -> I32 {\n match 5i32 {\n captured => captured\n }\n}\n", b"fn choose() -> I32 {\n match Option::Some(5i32) {\n Option::None => 0i32\n Option::Some(x) => x\n }\n}\n",
  ]
  for helper in helpers {
    let source = prefix + helper + suffix
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
      Ok(compiled) => {
        let module_ = compiled.program.modules[0]
        let mut found = false
        for fi, path in module_.file_paths {
          if path.has_prefix("main.dew::transform[main@") {
            found = true
            assert_eq(
              module_.file_sources[fi],
              b"pub fn main() -> I32 {\n5i32\n}",
            )
          }
        }
        assert_true(found)
      }
      Err(error) => fail(error.message())
    }
  }
}
