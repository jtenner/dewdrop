///|
test "transforms add checked imports types functions and methods" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  ctx.import_module(\"dew.std.option\", \"generated_option\")\n  ctx.add_type(\"struct Generated {\\n  value: I32\\n}\")\n  ctx.add_function(\"fn generated() -> Generated {\\n  Generated::{\\n    value: 42i32\\n  }\\n}\")\n  ctx.add_implementation(\"impl Generated {\\n  fn answer(self) -> I32 {\\n    self.value\\n  }\\n}\")\n  node.with_body(@ast.source(\"@generated_option.Option::Some(generated().answer())\"))\n}\n\n#generate\nfn answer() -> Option<I32> {\n  None\n}\n\npub fn main() -> I32 {\n  match answer() {\n    Some(value) => value\n    None => 0i32\n  }\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "generated multiple declarations is rejected" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.add_function(\"fn a() -> I32 {\\n 1i32\\n}\\nfn b() -> I32 {\\n 2i32\\n}\")\n node\n}\n#generate\npub fn main() -> I32 {\n 42i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("expected one valid generated declaration"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid generated declaration must fail")
  }
}

///|
test "generated wrong declaration kind is rejected" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.add_type(\"fn a() -> I32 {\\n 1i32\\n}\")\n node\n}\n#generate\npub fn main() -> I32 {\n 42i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("expected one valid generated declaration"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid generated declaration must fail")
  }
}

///|
test "generated invalid import alias is rejected" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n ctx.import_module(\"dew.std.option\", \"bad.alias\")\n node\n}\n#generate\npub fn main() -> I32 {\n 42i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("invalid generated import"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid generated declaration must fail")
  }
}
