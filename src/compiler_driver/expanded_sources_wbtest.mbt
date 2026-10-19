///|
test "expanded source view does not require generated code to type check" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "view.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.add_function(\"fn generated() -> I32 {\\n 42i32\\n}\")\n node.with_body(@ast.text(\"inspect this type error\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let expanded = match
    expand_manifest_sources(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(9200UL, 0, true),
    ) {
    Ok(value) => value
    Err(error) => {
      fail(error.message())
      abort("unreachable")
    }
  }
  let app = expanded.modules[0]
  assert_eq(app.path, "app")
  assert_true(
    app.files.any(file => file.path.has_prefix("view.dew::transform[")),
  )
  assert_true(
    app.files.any(file => {
      @utf8.decode_lossy(file.source).contains("inspect this type error")
    }),
  )
  assert_true(
    app.files.any(file => @utf8.decode_lossy(file.source).contains("fn generated")),
  )
}
