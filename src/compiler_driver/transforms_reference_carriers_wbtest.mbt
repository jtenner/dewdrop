///|
test "checked transforms function aliases retain reference identity" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n  value\n}\nbuiltin operation(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let value = identity\n  let result = if operation(value, value) {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(result))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked transforms tuple operands follow the builtin Wasm ABI" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin operation(value: (I32, I32)) -> I32 = \"i32.add\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(operation((40i32, 2i32))))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked transforms function null tests retain reference operands" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n  value\n}\nbuiltin operation(value: fn(I32) -> I32) -> Bool = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = operation(identity)\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked transforms integer tuple null tests fail before output" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin operation(value: (I32, I32)) -> Bool = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = operation((1i32, 2i32))\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(_) => fail("invalid null operand must fail before transform output")
    Err(error) => assert_true(error.message().contains("one reference operand"), msg=error.message())
  }
}

///|
test "checked transforms reference tuple null tests fail before output" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin operation(value: (String, String)) -> Bool = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = operation((\"left\", \"right\"))\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(_) => fail("invalid null operand must fail before transform output")
    Err(error) => assert_true(error.message().contains("one reference operand"), msg=error.message())
  }
}

///|
test "checked transforms generic tuple null tests require reference proof" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin operation<t>(value: t) -> Bool = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = operation::<(I32, I32)>((1i32, 2i32))\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(_) => fail("invalid null operand must fail before transform output")
    Err(error) => assert_true(error.message().contains("checked reference carrier"), msg=error.message())
  }
}
