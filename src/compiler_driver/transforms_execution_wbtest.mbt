///|
test "checked transform source executes floats" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nbuiltin to_i32(value: F64) -> I32 = \"i32.trunc_f64_s\"\n\nfn default_float<t>() -> Option<t> {\n  Some(wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32))\n}\n\nfn answer(value: F64) -> F64 {\n  wasm_f64_nearest(value) * 7.0f64\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let first = match default_float::<F64>() {\n    Some(value) => -value\n    None => 1.0f64\n  }\n  let zero = wasm_unsafe_bitcast::<F64, F64>(first)\n  let correct_zero = wasm_f64_to_bits(zero) == 9223372036854775808u64\n  let rounded = wasm_f32_nearest(2.5f32) == 2.0f32\n  let result = if correct_zero && rounded {\n    to_i32(answer(5.5f64))\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(result))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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

///|
test "checked transform source executes nullable raw defaults" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nforeign type Handle\n\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let value = default_slot::<NullableRef<Handle>>()\n  let explicit = wasm_ref_null::<Handle>()\n  let values = wasm_array_new_default::<NullableRef<Handle>>(2u32)\n  wasm_array_set(values, 1u32, explicit)\n  let result = if wasm_ref_is_null(value) && wasm_ref_is_null(explicit) && wasm_ref_is_null(wasm_array_get(values, 0u32)) && wasm_ref_is_null(wasm_array_get(values, 1u32)) {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(result))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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

///|
test "non-null raw default reads fail before a null test" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nforeign type Handle\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let value = wasm_array_get(wasm_array_new_default::<Handle>(1u32), 0u32)\n node\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("uninitialized non-null reference must fail")
    Err(error) =>
      assert_true(
        error.message().contains("null reference"),
        msg=error.message(),
      )
  }
}

///|
test "checked transforms use folded type queries and fresh name arrays" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nopen dew.std.array\n\nstruct Payload {\n  value: I32\n  flag: Bool\n}\n\nenum Mode {\n  Ready\n  Value(I32)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  @types.static_assert(@types.type_equal::<I32, I32>(), \"I32 identity\")\n  let names = @types.field_names::<Payload>()\n  let _ = names.pop()\n  let fresh = @types.field_names::<Payload>()\n  let modes = @types.variant_names::<Mode>()\n  let valid = @types.is_unit::<Unit>() && @types.is_never::<Never>() && @types.is_integer::<I32>() && @types.is_signed_integer::<I32>() && @types.is_float::<F64>() && @types.bit_width::<U64>() == 64u32 && @types.can_bitcast::<I32, U32>() && @types.lane_count::<I8x16>() == 16u32 && @types.lane_bit_width::<I8x16>() == 8u32 && @types.tuple_length::<(I32, Bool)>() == 2u32 && @types.size_of::<(U8, I32)>() == 8u32 && @types.align_of::<(U8, I32)>() == 4u32 && @types.field_offset::<(U8, I32)>(1u32) == 4u32 && fresh.length() == 2u32 && modes.length() == 2u32\n  let answer = if valid {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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

///|
test "checked transforms reject invalid null builtin foo-u32" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Foo<t> {}\nbuiltin absent<t>() -> Foo<t> = \"ref_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = absent::<U32>()\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("invalid null builtin must fail")
    Err(error) =>
      assert_true(
        error.message().contains("null reference"),
        msg=error.message(),
      )
  }
}

///|
test "checked transforms reject invalid null builtin foo-handle" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nforeign type Handle\nstruct Foo<t> {}\nbuiltin absent<t>() -> Foo<t> = \"ref_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = absent::<Handle>()\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("invalid null builtin must fail")
    Err(error) =>
      assert_true(
        error.message().contains("null reference"),
        msg=error.message(),
      )
  }
}

///|
test "checked transforms reject invalid null builtin bad-is-null-result" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin wrong(value: String) -> String = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(\"x\")\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("invalid null builtin must fail")
    Err(error) =>
      assert_true(
        error.message().contains("result carrier"),
        msg=error.message(),
      )
  }
}

///|
test "checked transforms reject invalid null builtin bad-is-null-unit" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin wrong(value: String) -> Unit = \"ref_is_null\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let _ = wrong(\"x\")\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("invalid null builtin must fail")
    Err(error) =>
      assert_true(
        error.message().contains("result carrier"),
        msg=error.message(),
      )
  }
}

///|
test "checked transforms preserve explicit unit values" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn touch() -> Unit {\n  ()\n}\nfn loop_touch() -> Unit {\n  while 0u32 {\n    _ => break ()\n  }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = touch()\n  let _ = loop_touch()\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}
