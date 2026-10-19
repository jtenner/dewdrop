///|
test "source transforms execute ordinary String equality" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let answer = if ctx.fn_name == \"main\" && ctx.fn_name != \"other\" {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "source transforms compare UTF8 and multi-chunk Strings" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let answer = if \"\" == \"\" && \"\" != \"x\" && \"λ🧪\" == \"λ🧪\" && \"λ🧪\" != \"μ🧪\" && \"abcdefghijklmnopq\" == \"abcdefghijklmnopq\" && \"abcdefghijklmnopq\" != \"abcdefghijklmnOpq\" && \"abcdefghijklmnopq\" != \"abcdefghijklmnopx\" {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "source transforms render concat source through ordinary String code" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\nopen dew.std.string_builder\nopen dew.std.array\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.source(\"4\".concat(\"2i32\")))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(fn(source) {
      source == b"pub fn main() -> I32 {\n42i32\n}"
    }))
    Err(error) => fail(error.message())
  }
}

///|
test "source transforms render finished StringBuilder through ordinary String code" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\nopen dew.std.string_builder\nopen dew.std.array\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let builder = StringBuilder::new()\n  builder.append(\"4\")\n  builder.append(\"2i32\")\n  node.with_body(@ast.source(builder.finish()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(fn(source) {
      source == b"pub fn main() -> I32 {\n42i32\n}"
    }))
    Err(error) => fail(error.message())
  }
}

///|
test "source transforms render concat name through ordinary String code" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\nopen dew.std.string_builder\nopen dew.std.array\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.block([@ast.integer(42i32).bind(\"an\".concat(\"swer\")), @ast.name(\"answer\")]))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(fn(source) {
      source == b"pub fn main() -> I32 {\nmatch () {\n_ => {\nlet answer = 42i32\nanswer\n}\n}\n}"
    }))
    Err(error) => fail(error.message())
  }
}

///|
test "source transforms match checked cast view fields" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nstruct View {\n data: WasmArray<I8x16>\n begin: U32\n size: U32\n}\nbuiltin text_view(value: String) -> View = \"ref.cast\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let size = match text_view(\"aλ🧪\") {\n  View {\n   size: count\n   ...\n  } => count\n }\n let answer = if size == 7u32 {\n  42i32\n } else {\n  0i32\n }\n node.with_body(@ast.integer(answer))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(fn(source) {
      source == b"pub fn main() -> I32 {\n42i32\n}"
    }))
    Err(error) => fail(error.message())
  }
}
