///|
test "product scalar result rejects scalar-two-leaf" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wasm_unsafe_bitcast::<I32, (I32, I32)>(1i32)\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(_) => fail("scalar value must not bypass product validation")
    Err(error) => assert_true(error.message().contains("checked tuple layout"), msg=error.message())
  }
}

///|
test "product scalar result rejects scalar-unit-product" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wasm_unsafe_bitcast::<I32, (Unit, Unit)>(1i32)\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(_) => fail("scalar value must not bypass product validation")
    Err(error) => assert_true(error.message().contains("checked tuple layout"), msg=error.message())
  }
}

///|
test "product scalar result rejects scalar-one-leaf" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wasm_unsafe_bitcast::<I32, (I32, Unit)>(42i32)\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(_) => fail("scalar value must not bypass product validation")
    Err(error) => assert_true(error.message().contains("checked tuple layout"), msg=error.message())
  }
}

///|
test "product scalar result rejects scalar-direct-product" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nbuiltin wrong(value: I32) -> (I32, I32) = \"unsafe.bitcast\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wrong(1i32)\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(_) => fail("scalar value must not bypass product validation")
    Err(error) => assert_true(error.message().contains("checked tuple layout"), msg=error.message())
  }
}

///|
test "product scalar result rejects struct-get-product" {
  match compile_transform_source(
    b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Cell {\n  value: I32\n}\nbuiltin wrong(value: Cell) -> (I32, I32) = \"struct.get 0\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wrong(Cell::{\n    value: 1i32\n  })\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
  ) {
    Ok(_) => fail("scalar value must not bypass product validation")
    Err(error) => assert_true(error.message().contains("checked tuple layout"), msg=error.message())
  }
}
