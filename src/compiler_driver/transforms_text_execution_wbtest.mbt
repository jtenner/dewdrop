///|
test "checked transforms execute arbitrary bytes and source text helpers" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.bytes\nopen dew.std.string\n\ntransform fn inspect_bytes(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let raw = b\"\\xff\\x00A\\x80\"\n  let text = b\"Hello world, from a source transform\"\n  let part = text.view(6u32, 5u32)\n  let valid = raw.byte_length() == 4u32 && raw.byte_at(0u32) == 255u8 && raw.byte_at(1u32) == 0u8 && !raw.is_valid_utf8() && part == b\"world\" && part.concat(b\"!\").to_string() == \"world!\" && match text.find(b\"source\") {\n    Some(20u32) => true\n    _ => false\n  }\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#inspect_bytes\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => {
      source == b"pub fn main() -> I32 {\n42i32\n}"
    }))
    Err(error) => fail(error.message())
  }
}

///|
test "checked source vector instructions include saturating float conversions" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nbuiltin lanes(value: I32) -> V128 = \"i32x4.splat\"\nbuiltin add(left: V128, right: V128) -> V128 = \"i32x4.add\"\nbuiltin first(value: V128) -> I32 = \"i32x4.extract_lane 0\"\nbuiltin narrow(low: V128, high: V128) -> V128 = \"i16x8.narrow_i32x4_s\"\nbuiltin first_short(value: V128) -> I32 = \"i16x8.extract_lane_s 0\"\nbuiltin convert(value: V128) -> V128 = \"f64x2.convert_low_i32x4_s\"\nbuiltin first_float(value: V128) -> F64 = \"f64x2.extract_lane 0\"\nbuiltin truncate(value: V128) -> V128 = \"i32x4.trunc_sat_f64x2_s_zero\"\nbuiltin leading_zeros(value: I32) -> I32 = \"i32.clz\"\nbuiltin rotate(value: I32, count: I32) -> I32 = \"i32.rotl\"\n\nfn twice(value: V128) -> V128 {\n  add(value, value)\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let answer = first(twice(lanes(21i32)))\n  let valid = first_short(narrow(lanes(40000i32), lanes(0i32))) == 32767i32 && first_float(convert(lanes(answer))) == 42.0f64 && first(truncate(convert(lanes(answer)))) == 42i32 && leading_zeros(0i32) == 32i32 && rotate(1i32, 42i32) == 1024i32\n  node.with_body(@ast.integer(if valid {\n    answer\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => {
      source == b"pub fn main() -> I32 {\n42i32\n}"
    }))
    Err(error) => fail(error.message())
  }
}

///|
test "checked source byte builders retain non UTF8 bits and escapes" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn emit(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.bytes(b\"\\x00\\xff\\x22\\x5c\"))\n}\n#emit\npub fn main() -> Bytes {\n  b\"\"\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => {
      source == b"pub fn main() -> Bytes {\nb\"\\x00\\xff\\x22\\x5c\"\n}"
    }))
    Err(error) => fail(error.message())
  }
}
