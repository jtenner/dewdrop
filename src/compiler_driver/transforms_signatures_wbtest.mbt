///|
test "transform entry signatures use canonical resolved types" {
  let cases = [
    (
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn answer(node: I32, ctx: I32) -> @ast.FnNode {\n @ast.FnNode::{\n name: \"main\"\n body: @ast.integer(42i32)\n signature: @ast.SignatureNode::{\n parameters: []\n return_type: @ast.named_type(\"I32\")\n }\n call_adapter: None\n }\n}\n#answer\npub fn main() -> I32 {\n 0i32\n}\n",
      false,
    ),
    (
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntype Node = @ast.FnNode\ntype Context = @transform.TransformContext\ntransform fn answer(node: Node, ctx: Context) -> Node {\n @ast.with_body(node, @ast.integer(42i32))\n}\n#answer\npub fn main() -> I32 {\n 0i32\n}\n",
      true,
    ),
  ]
  for (source, expected) in cases {
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
      Ok(_) => assert_true(expected)
      Err(error) => {
        if expected {
          fail(error.message())
        }
        assert_true(error.message().contains("invalid transform signature"))
      }
    }
  }
}
