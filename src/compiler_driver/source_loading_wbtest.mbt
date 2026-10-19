///|
test "late transform imports use the selected standard source without extra modules" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew",
        b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.map\", \"generated_map\")\n node.with_body(@ast.source(\"@generated_map.selected_marker\"))\n}\n#generate\npub fn main() -> I32 {\n 0i32\n}\n",
      ),
    ]),
  ])
  let bootstrap = @semantic.StandardLibrarySources::bootstrap()
  let files : Array[@semantic.ManifestFile] = []
  for index, path in bootstrap.paths {
    let source = if path == "std/map.dew" {
      b"pub let selected_marker = 42i32\n"
    } else {
      bootstrap.sources[index]
    }
    files.push(@semantic.ManifestFile::new(path, source))
  }
  match compile_manifest_uncached(
    manifest,
    @semantic.StandardLibrarySources::new(files),
    CompilerPipelineOptions::production(5100UL, 0, true),
  ) {
    Err(error) => fail(error.message())
    Ok(compiled) => {
      assert_true(compiled.program.module_paths.contains("dew.std.map"))
      assert_false(compiled.program.module_paths.contains("dew.std.json"))
      let mut found = false
      for index, path in compiled.program.module_paths {
        if path == "dew.std.map" {
          found = compiled.program.modules[index].file_sources.contains(
            b"pub let selected_marker = 42i32\n",
          )
        }
      }
      assert_true(found)
      assert_true(compiled.emit_binary().unwrap().length() > 8)
    }
  }
}
