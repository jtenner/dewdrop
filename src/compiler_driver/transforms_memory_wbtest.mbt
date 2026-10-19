///|
test "checked transform memory operations and packed integers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nbuiltin store_word(address: U32, value: U32) -> Unit = \"i32.store\"\nbuiltin read_byte(address: U32) -> U32 = \"i32.load8_u\"\nbuiltin read_signed_byte(address: U32) -> I32 = \"i32.load8_s\"\nbuiltin load_vector(address: U32) -> V128 = \"v128.load\"\nbuiltin load_splat(address: U32) -> V128 = \"v128.load8_splat\"\nbuiltin load_extended(address: U32) -> V128 = \"v128.load8x8_s\"\nbuiltin store_lane(address: U32, value: V128) -> Unit = \"v128.store32_lane 1\"\nbuiltin extract_word(value: V128) -> U32 = \"i32x4.extract_lane 0\"\nbuiltin extract_second_word(value: V128) -> U32 = \"i32x4.extract_lane 1\"\nbuiltin extract_half(value: V128) -> I32 = \"i16x8.extract_lane_s 0\"\n\nfn compute() -> I32 {\n  store_word(7u32, 4294967168u32)\n  let repeated = load_splat(7u32)\n  store_lane(100u32, repeated)\n  let vector = load_vector(96u32)\n  let packed32 = swar32_add_i8(swar32_splat_i8(20i8), swar32_splat_i8(1i8))\n  let packed64 = swar64_add_i16(swar64_splat_i16(20i16), swar64_splat_i16(1i16))\n  if read_byte(7u32) == 128u32 && read_signed_byte(7u32) == -128i32 && extract_word(repeated) == 2155905152u32 && extract_second_word(vector) == 2155905152u32 && extract_half(load_extended(7u32)) == -128i32 && swar32_extract_i8_s(packed32, 3u8) == 21i8 && swar64_extract_i16_s(packed64, 3u8) == 21i16 {\n    42i32\n  } else {\n    0i32\n  }\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("\n42i32\n}")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "checked transform memory resets between stacked transforms" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn reset(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let value = u32_load(0u32)\n  u32_store(0u32, 7u32)\n  node.with_body(@ast.integer(if value == 0u32 {\n    42i32\n  } else {\n    0i32\n  }))\n}\n#reset\n#reset\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("\n42i32\n}")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "checked transform all packed integer helpers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\n\nfn packed_type<t>(value: t) -> Bool {\n  let _ = value\n  @types.type_equal::<t, Swar32>()\n}\n\nfn compute() -> Bool {\n  swar32_to_bits(swar32_splat_i8(-5i8)) == 4227595259u32 &&\n  swar32_to_bits(swar32_splat_i16(-123i16)) == 4286971781u32 &&\n  swar32_extract_i8_s(swar32_from_bits(2147451009u32), 0u8) == -127i8 &&\n  swar32_extract_i8_u(swar32_from_bits(2147451009u32), 0u8) == 129u8 &&\n  swar32_extract_i16_s(swar32_from_bits(2147451009u32), 0u8) == -32639i16 &&\n  swar32_extract_i16_u(swar32_from_bits(2147451009u32), 0u8) == 32897u16 &&\n  swar32_to_bits(swar32_add_i8(swar32_from_bits(2147451009u32), swar32_from_bits(2147581823u32))) == 4278255360u32 &&\n  swar32_to_bits(swar32_sub_i8(swar32_from_bits(2147451009u32), swar32_from_bits(2147581823u32))) == 4294836482u32 &&\n  swar32_to_bits(swar32_add_i16(swar32_from_bits(2147451009u32), swar32_from_bits(2147581823u32))) == 0u32 &&\n  swar32_to_bits(swar32_sub_i16(swar32_from_bits(2147451009u32), swar32_from_bits(2147581823u32))) == 4294836482u32 &&\n  swar32_any_true(swar32_from_bits(2147451009u32)) == true &&\n  swar32_all_true_i8(swar32_from_bits(2147451009u32)) == true &&\n  swar32_bitmask_i8(swar32_from_bits(2147451009u32)) == 7u32 &&\n  swar32_to_bits(swar32_popcnt_i8(swar32_from_bits(2147451009u32))) == 117965058u32 &&\n  swar32_to_bits(swar32_eq_i8(swar32_from_bits(2147451009u32), swar32_from_bits(2147581823u32))) == 0u32 &&\n  swar64_to_bits(swar64_splat_i8(-5i8)) == 18157383382357244923u64 &&\n  swar64_to_bits(swar64_splat_i16(-123i16)) == 18412403602556845957u64 &&\n  swar64_to_bits(swar64_splat_i32(-1234567i32)) == 18441441653113563513u64 &&\n  swar64_extract_i8_s(swar64_from_bits(18303097644806799489u64), 0u8) == -127i8 &&\n  swar64_extract_i8_u(swar64_from_bits(18303097644806799489u64), 0u8) == 129u8 &&\n  swar64_extract_i16_s(swar64_from_bits(18303097644806799489u64), 0u8) == -32639i16 &&\n  swar64_extract_i16_u(swar64_from_bits(18303097644806799489u64), 0u8) == 32897u16 &&\n  swar64_extract_i32_s(swar64_from_bits(18303097644806799489u64), 1u8) == -33445291i32 &&\n  swar64_extract_i32_u(swar64_from_bits(18303097644806799489u64), 1u8) == 4261522005u32 &&\n  swar64_to_bits(swar64_add_i8(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18411183303555088128u64 &&\n  swar64_to_bits(swar64_sub_i8(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18267069584374628610u64 &&\n  swar64_to_bits(swar64_add_i16(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18411183299276832768u64 &&\n  swar64_to_bits(swar64_sub_i16(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18195011990336700674u64 &&\n  swar64_to_bits(swar64_add_i32(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18411464774253608960u64 &&\n  swar64_to_bits(swar64_sub_i32(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 18194730515359990018u64 &&\n  swar64_any_true(swar64_from_bits(18303097644806799489u64)) == true &&\n  swar64_all_true_i8(swar64_from_bits(18303097644806799489u64)) == true &&\n  swar64_bitmask_i8(swar64_from_bits(18303097644806799489u64)) == 167u32 &&\n  swar64_to_bits(swar64_popcnt_i8(swar64_from_bits(18303097644806799489u64))) == 504689048586551554u64 &&\n  swar64_to_bits(swar64_eq_i8(swar64_from_bits(18303097644806799489u64), swar64_from_bits(108367133741776767u64))) == 1095216660480u64 &&\n  swar32_to_bits(swar32_replace_i8(swar32_from_bits(2147451009u32), 3u8, -5i8)) == 4227825793u32 &&\n  swar32_to_bits(swar32_replace_i16(swar32_from_bits(2147451009u32), 1u8, -123i16)) == 4286939265u32 &&\n  swar32_to_bits(swar32_shl_i8(swar32_from_bits(2147451009u32), 9u8)) == 4278059010u32 &&\n  swar32_to_bits(swar32_shr_i8_u(swar32_from_bits(2147451009u32), 9u8)) == 1065304128u32 &&\n  swar32_to_bits(swar32_shr_i8_s(swar32_from_bits(2147451009u32), 9u8)) == 1073725632u32 &&\n  swar32_to_bits(swar32_shl_i16(swar32_from_bits(2147451009u32), 17u8)) == 4294836482u32 &&\n  swar32_to_bits(swar32_shr_i16_u(swar32_from_bits(2147451009u32), 17u8)) == 1073692736u32 &&\n  swar32_to_bits(swar32_shr_i16_s(swar32_from_bits(2147451009u32), 17u8)) == 1073725504u32 &&\n  swar64_to_bits(swar64_replace_i8(swar64_from_bits(18303097644806799489u64), 7u8, -5i8)) == 18086924862693015681u64 &&\n  swar64_to_bits(swar64_replace_i16(swar64_from_bits(18303097644806799489u64), 3u8, -123i16)) == 18412309935770534017u64 &&\n  swar64_to_bits(swar64_replace_i32(swar64_from_bits(18303097644806799489u64), 1u8, -1234567i32)) == 18441441650967281793u64 &&\n  swar64_to_bits(swar64_shl_i8(swar64_from_bits(18303097644806799489u64), 9u8)) == 18159169740910493698u64 &&\n  swar64_to_bits(swar64_shr_i8_u(swar64_from_bits(18303097644806799489u64), 9u8)) == 9151408082759139392u64 &&\n  swar64_to_bits(swar64_shr_i8_s(swar64_from_bits(18303097644806799489u64), 9u8)) == 18374920857110692032u64 &&\n  swar64_to_bits(swar64_shl_i16(swar64_from_bits(18303097644806799489u64), 17u8)) == 18159169740927271170u64 &&\n  swar64_to_bits(swar64_shr_i16_u(swar64_from_bits(18303097644806799489u64), 17u8)) == 9151408082767528000u64 &&\n  swar64_to_bits(swar64_shr_i16_s(swar64_from_bits(18303097644806799489u64), 17u8)) == 18374920857110691904u64 &&\n  swar64_to_bits(swar64_shl_i32(swar64_from_bits(18303097644806799489u64), 33u8)) == 18159451215904047362u64 &&\n  swar64_to_bits(swar64_shr_i32_u(swar64_from_bits(18303097644806799489u64), 33u8)) == 9151548820255916096u64 &&\n  swar64_to_bits(swar64_shr_i32_s(swar64_from_bits(18303097644806799489u64), 33u8)) == 18374920857110691904u64 &&\n  !swar32_any_true(swar32_from_bits(0u32)) &&\n  !swar64_any_true(swar64_from_bits(0u64)) &&\n  !swar32_all_true_i8(swar32_from_bits(1u32)) &&\n  !swar64_all_true_i8(swar64_from_bits(1u64)) &&\n  packed_type(swar32_from_bits(1u32)) &&\n  !packed_type(swar64_from_bits(1u64)) &&\n  !packed_type(1u32) &&\n  @types.bit_width::<Swar32>() == 32u32 &&\n  @types.bit_width::<Swar64>() == 64u32\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(if compute() {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("\n42i32\n}")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "checked transform packed storage" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nstruct Packed {\n  low: Swar32\n  high: Swar64\n}\nbuiltin read_low(value: Packed) -> Swar32 = \"struct.get 0\"\nbuiltin read_high(value: Packed) -> Swar64 = \"struct.get 1\"\n\nfn default_value<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\n\nfn compute() -> Bool {\n  let values = wasm_array_new_default::<Swar32>(2u32)\n  let zero = wasm_array_get(values, 0u32)\n  wasm_array_set(values, 1u32, swar32_from_bits(42u32))\n  let record = Packed::{\n    low: wasm_array_get(values, 1u32)\n    high: swar64_from_bits(42u64)\n  }\n  let array = [record.low, zero]\n  swar32_to_bits(read_low(record)) == 42u32 && swar64_to_bits(read_high(record)) == 42u64 && swar32_to_bits(array[0u32]) == 42u32 && swar32_to_bits(array[1u32]) == 0u32 && swar32_to_bits(default_value::<Swar32>()) == 0u32 && swar64_to_bits(default_value::<Swar64>()) == 0u64\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(if compute() {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          @utf8.decode_lossy(source).contains("\n42i32\n}")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "checked transform packed field cannot become float" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Packed {\n  value: Swar32\n}\nbuiltin wrong(value: Packed) -> F32 = \"struct.get 0\"\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = wrong(Packed::{\n    value: swar32_from_bits(42u32)\n  })\n  node.with_body(@ast.integer(42i32))\n}\n#calculate\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Ok(_) => fail("wrong packed field carrier must fail")
    Err(error) =>
      assert_true(
        error
        .message()
        .contains(
          "Wasm struct.get result carrier does not match its checked field",
        ),
        msg=error.message(),
      )
  }
}
