///|
test "transform rejects discarded invalid vector opcode 0" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin wrong(left: V128, right: V128) -> V128 = \"i8x16.mul\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(make(2i32), make(3i32))\n node.with_body(@ast.integer(42i32))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) =>
      fail("a discarded invalid instruction must not produce transform output")
    Err(error) =>
      assert_true(
        error.message().contains("unsupported Wasm vector"),
        msg=error.message(),
      )
  }
}

///|
test "transform rejects discarded invalid vector opcode 1" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin wrong(value: V128) -> V128 = \"i64x2.popcnt\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(make(2i32))\n node.with_body(@ast.integer(42i32))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) =>
      fail("a discarded invalid instruction must not produce transform output")
    Err(error) =>
      assert_true(
        error.message().contains("unsupported Wasm vector"),
        msg=error.message(),
      )
  }
}

///|
test "transform rejects discarded invalid vector opcode 2" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin wrong(left: V128, right: V128) -> V128 = \"f32x4.copysign\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(make(2i32), make(3i32))\n node.with_body(@ast.integer(42i32))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) =>
      fail("a discarded invalid instruction must not produce transform output")
    Err(error) =>
      assert_true(
        error.message().contains("unsupported Wasm vector"),
        msg=error.message(),
      )
  }
}

///|
test "transform rejects discarded invalid vector opcode 3" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin wrong(value: V128) -> I32 = \"i32x4.extract_lane_s 0\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(make(2i32))\n node.with_body(@ast.integer(42i32))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) =>
      fail("a discarded invalid instruction must not produce transform output")
    Err(error) =>
      assert_true(
        error.message().contains("unsupported Wasm vector"),
        msg=error.message(),
      )
  }
}

///|
test "transform rejects discarded invalid vector opcode 4" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin wrong(left: V128, right: V128) -> V128 = \"i8x16.shuffle 01 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(make(2i32), make(3i32))\n node.with_body(@ast.integer(42i32))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) =>
      fail("a discarded invalid instruction must not produce transform output")
    Err(error) =>
      assert_true(
        error.message().contains("invalid Wasm vector shuffle"),
        msg=error.message(),
      )
  }
}

///|
test "transform accepts valid dynamic vector shuffle" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin make(value: I32) -> V128 = \"i8x16.splat\"\nbuiltin shuffle(left: V128, right: V128) -> V128 = \"i8x16.shuffle 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24 7\"\nbuiltin first(value: V128) -> I32 = \"i8x16.extract_lane_u 0\"\nbuiltin second(value: V128) -> I32 = \"i8x16.extract_lane_u 1\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let value = shuffle(make(40i32), make(2i32))\n node.with_body(@ast.integer(first(value) + second(value)))\n}\n\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}
