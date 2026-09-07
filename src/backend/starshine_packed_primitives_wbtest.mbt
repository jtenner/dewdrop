///|
fn backend_packed_primitive_pipeline(
  source : Bytes,
) -> (@semantic.PlannedProgramLowering, @semantic.PlannedProgramWasmGCLink, Int) {
  let program = @semantic.collect_program_manifest(
    2520UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  (
    lowering,
    link,
    program.diagnostics.length() +
    program.modules[0].diagnostics.length() +
    analyzed.frozen.graph.diagnostics.length() +
    analyzed.frozen.import_diagnostics.length() +
    analyzed.frozen.interfaces[0].resolved_types.diagnostics.length() +
    analyzed.modules[0].names.diagnostics.length() +
    analyzed.modules[0].inferred.diagnostics.length() +
    lowering.modules[0].diagnostics.length() +
    link.diagnostics.length(),
  )
}

///|
fn backend_program_uses_linear_memory(
  link : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  for module_ in link.modules {
    if module_.uses_linear_memory {
      return true
    }
  }
  false
}

///|
test "nested pattern reference bindings are initialized across control frames" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"struct Item {\n  value: U64\n}\nenum Inner {\n  Item(Item)\n  Other\n}\nenum Maybe {\n  Some(Inner)\n  None\n}\npub fn run(input: Maybe) -> U64 {\n  match input {\n    Maybe::Some(Inner::Item(item)) => {\n      let _ = while 0u32 {\n        current => if current < 2u32 {\n          if item.value > 0u64 {\n            return item.value\n          }\n          continue current + 1u32\n        } else {\n          break ()\n        }\n      }\n      0u64\n    }\n    _ => 0u64\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "early array returns use the linked result reference type" {
  let stages = backend_test_single_module_stages(
    28118UL, b"open dew.std.array\npub fn run(flag: Bool, input: Array<I32>) -> Array<I32> {\n  let result = input\n  if flag {\n    return result\n  }\n  result\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let module_ = emit_starshine_program_module(stages.lowering, stages.link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Swar32 and Swar64 bit carriers compile without wrappers or imports" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn mask32(left: U32, right: U32) -> U32 {\n  swar32_to_bits(swar32_from_bits(left) & swar32_from_bits(right))\n}\npub fn mask64(left: U64, right: U64) -> U64 {\n  swar64_to_bits(swar64_from_bits(left) ^ swar64_from_bits(right))\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode SWAR bit-carrier module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "all scalar numeric operator families validate through Starshine" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn i8_math(a: I8, b: I8) -> I8 {\n  ((a + b) * (a - b)) / b % b\n}\npub fn i16_bits(a: I16, b: I16) -> I16 {\n  (a ^ b) << 1i16\n}\npub fn i32_order(a: I32, b: I32) -> Bool {\n  a < b\n}\npub fn i64_math(a: I64, b: I64) -> I64 {\n  a + b * a\n}\npub fn u8_bits(a: U8, b: U8) -> U8 {\n  (a | b) >> 1u8\n}\npub fn u16_order(a: U16, b: U16) -> Bool {\n  a >= b\n}\npub fn u32_math(a: U32, b: U32) -> U32 {\n  a / b + a % b\n}\npub fn u64_order(a: U64, b: U64) -> Bool {\n  a <= b\n}\npub fn f32_math(a: F32, b: F32) -> F32 {\n  (a + b) * (a - b) / b\n}\npub fn f64_order(a: F64, b: F64) -> Bool {\n  a != b\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode scalar numeric operator module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "small integer aggregate fields use valid packed signed and unsigned gets" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub struct Tiny {\n  signed8: I8\n  unsigned8: U8\n  signed16: I16\n  unsigned16: U16\n}\npub enum TinyValue {\n  Signed(I8)\n  Unsigned(U16)\n}\npub fn read_struct(value: Tiny) -> I16 {\n  value.signed16\n}\npub fn read_enum(value: TinyValue) -> I16 {\n  match value {\n    TinyValue::Signed(item) => i8_into_i16(item)\n    TinyValue::Unsigned(item) => u16_into_i16(item)\n  }\n}\npub fn build(value: I8) -> Tiny {\n  Tiny::{\n    signed8: value\n    unsigned8: 255u8\n    signed16: i8_into_i16(value)\n    unsigned16: 65535u16\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode packed small-integer aggregate module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Swar32 and Swar64 core lane functions compile as reachable scalar code" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn lane32(value: I8) -> I8 {\n  swar32_splat_i8(value).add_i8(swar32_splat_i8(1i8)).extract_i8_s(3u8)\n}\npub fn lane64(value: I16) -> I16 {\n  swar64_splat_i16(value).sub_i16(swar64_splat_i16(1i16)).extract_i16_s(2u8)\n}\npub fn mask64(left: I8, right: I8) -> U32 {\n  swar64_splat_i8(left).eq_i8(swar64_splat_i8(right)).bitmask_i8()\n}\npub fn count32(value: I8) -> U8 {\n  swar32_splat_i8(value).popcnt_i8().extract_i8_u(0u8)\n}\npub fn replace_shift32(value: I8) -> I8 {\n  swar32_splat_i8(value).replace_i8(2u8, 7i8).shl_i8(1u8).shr_i8_s(1u8).extract_i8_s(2u8)\n}\npub fn replace_shift64(value: I32) -> I32 {\n  swar64_splat_i32(value).replace_i32(1u8, 9i32).shl_i32(2u8).shr_i32_u(1u8).extract_i32_s(1u8)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  assert_true(fragments.defined_function_count > 4)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode SWAR core lane module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "numeric Into implementations cover scalar conversion instruction classes" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn i8_to_u64(value: I8) -> U64 {\n  value.into()\n}\npub fn u64_to_i16(value: U64) -> I16 {\n  value.into()\n}\npub fn u32_to_i64(value: U32) -> I64 {\n  value.into()\n}\npub fn i64_to_f32(value: I64) -> F32 {\n  value.into()\n}\npub fn u64_to_f64(value: U64) -> F64 {\n  value.into()\n}\npub fn f32_to_f64(value: F32) -> F64 {\n  value.into()\n}\npub fn f64_to_f32(value: F64) -> F32 {\n  value.into()\n}\npub fn f32_to_i32(value: F32) -> I32 {\n  value.into()\n}\npub fn f64_to_u64(value: F64) -> U64 {\n  value.into()\n}\npub fn f64_to_i8(value: F64) -> I8 {\n  value.into()\n}\npub fn f32_to_u16(value: F32) -> U16 {\n  value.into()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode numeric Into module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "GC-backed v128 strings and utf8 algorithms validate" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\npub fn string_bytes() -> U32 {\n  \"hello λ 🌍\".byte_length()\n}\npub fn bytes_length() -> U32 {\n  b\"abc\\x00\\xFF\".byte_length()\n}\npub fn valid_ascii() -> Bool {\n  b\"plain ascii\".is_valid_utf8()\n}\npub fn valid_mixed() -> Bool {\n  b\"λ 世界 🌍\".is_valid_utf8()\n}\npub fn invalid_overlong() -> Bool {\n  b\"\\xC0\\x80\".is_valid_utf8()\n}\npub fn invalid_surrogate() -> Bool {\n  b\"\\xED\\xA0\\x80\".is_valid_utf8()\n}\npub fn units() -> U32 {\n  \"aλ🌍\".utf16_length()\n}\npub fn shared() -> U32 {\n  \"shared\".as_bytes().byte_length()\n}\npub fn string_units() -> U32 {\n  \"aλ🌍\".utf16_length()\n}\npub fn equal() -> Bool {\n  b\"0123456789abcdef-A\".equals(b\"0123456789abcdef-A\")\n}\npub fn at() -> U8 {\n  b\"0123456789abcdef-A\".byte_at(16u32)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "nominal aggregate results survive if-expression eqref joins" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub enum EdgeChoice {\n  None\n  Item(I32)\n}\npub struct EdgeBox {\n  value: I32\n}\nfn edge_one() -> EdgeBox {\n  EdgeBox::{\n    value: 1\n  }\n}\nfn edge_two() -> EdgeBox {\n  EdgeBox::{\n    value: 2\n  }\n}\npub fn choose(flag: Bool) -> EdgeChoice {\n  if flag {\n    EdgeChoice::None\n  } else {\n    EdgeChoice::Item(7)\n  }\n}\npub fn boxed(flag: Bool) -> EdgeBox {\n  if flag {\n    edge_one()\n  } else {\n    edge_two()\n  }\n}\n",
  )
  assert_eq(diagnostics, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "Bytes search primitives and Option<U32> validate through Starshine" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\npub fn find() -> Option<U32> {\n  b\"xx0123456789abcdef-tail\".view(2u32, 21u32).find_byte(116u8)\n}\npub fn starts() -> Bool {\n  b\"xx0123456789abcdef-tailzz\".view(2u32, 21u32).starts_with(b\"0123456789abcdef\")\n}\npub fn ends() -> Bool {\n  b\"xx0123456789abcdef-tailzz\".view(2u32, 21u32).ends_with(b\"tail\")\n}\npub fn contains() -> Bool {\n  b\"xx0123456789abcdef-tailzz\".view(2u32, 21u32).contains_byte(45u8)\n}\npub fn find_substring() -> Option<U32> {\n  b\"xx0123456789abcdef-tailzz\".view(2u32, 21u32).find(b\"cdef-tail\")\n}\npub fn contains_substring() -> Bool {\n  b\"xx0123456789abcdef-tailzz\".view(2u32, 21u32).contains(b\"6789abcdef\")\n}\npub fn string_find() -> Option<U32> {\n  \"xxprefix λ世界🌍 suffixyy\".view(2u32, 26u32).to_string().find(\"🌍 suffix\")\n}\npub fn string_find_view() -> Option<U32> {\n  \"prefix λ世界🌍 suffix\".find_view(\"xxλ世界yy\".view(2u32, 8u32))\n}\npub fn view_find() -> Option<U32> {\n  \"xxprefix λ世界🌍 suffixyy\".view(2u32, 26u32).find(\"zz🌍 suffixqq\".view(2u32, 11u32))\n}\npub fn view_find_string() -> Option<U32> {\n  \"xxprefix λ世界🌍 suffixyy\".view(2u32, 26u32).find_string(\"λ世界\")\n}\npub fn string_affix() -> Bool {\n  \"λ世界 body 🌍\".starts_with_view(\"xxλ世界yy\".view(2u32, 8u32))\n}\npub fn view_affix() -> Bool {\n  \"xxλ世界 body 🌍yy\".view(2u32, 18u32).ends_with_string(\"🌍\")\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let module_ = match emit_starshine_program_module(lowering, fragments) {
    Err(InvalidBuiltinSignature(_, _, _)) => fail("invalid builtin signature")
    Ok(module_) => module_
    Err(MissingBody(_)) => abort("missing body")
    Err(MissingFunction(_)) => abort("missing function")
    Err(SignatureOnlyCall(_)) => abort("signature-only call")
    Err(InvalidLocal(_, _)) => abort("invalid local")
    Err(UnsupportedExpression(body, expression)) =>
      abort("unsupported expression \{body} \{expression}")
    Err(UnsupportedBuiltin(_)) => abort("unsupported builtin")
    Err(InvalidFunctionBody(_)) => abort("invalid function body")
    Err(ProgramLinkDiagnostics(_)) => abort("program link diagnostics")
  }
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "flat text concatenation validates through Starshine" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\npub fn strings() -> String {\n  let source = \"0123456789λ世界suffix\"\n  source.view(3u32, 12u32).to_string().concat_view(source.view(15u32, 6u32))\n}\npub fn bytes() -> Bytes {\n  b\"prefix-0123456789\".view(7u32, 10u32).concat(b\"-tail\\x00\\xFF\")\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "UTF8-safe StringBuilder producers validate through Starshine" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.string_builder\npub fn build() -> String {\n  let builder = StringBuilder::with_capacity(1u32)\n  builder.append_ascii(65u8)\n  builder.append_scalar(128u32)\n  builder.append_scalar(1114111u32)\n  builder.append_checked(b\"λ\")\n  builder.finish()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "GC-backed BytesBuilder validates through Starshine" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.bytes_builder\npub fn build() -> Bytes {\n  let builder = BytesBuilder::with_capacity(1u32)\n  builder.append(b\"0123456789abcdef-tail\")\n  builder.append_byte(255u8)\n  builder.finish()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "checked Bytes to String links the ordinary Dew UTF8 validator" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.string\nopen dew.std.bytes\npub fn convert() -> U32 {\n  b\"checked λ 🌍\".to_string().byte_length()\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_false(backend_program_uses_linear_memory(fragments))
  let mut validator_reachable = false
  let mut conversion_reachable = false
  for function_ in fragments.functions {
    if !function_.elided && function_.name == b"bytes_is_valid_utf8" {
      assert_true(function_.kind is @semantic.PlannedWasmDefinedFunction(_))
      validator_reachable = true
    }
    if !function_.elided && function_.name == b"bytes_to_string" {
      assert_true(function_.kind is @semantic.PlannedWasmDefinedFunction(_))
      conversion_reachable = true
    }
    match function_.kind {
      @semantic.PlannedWasmRuntimeFunction(name) => {
        assert_false(name == b"dew_bytes_is_valid_utf8")
        assert_false(name == b"dew_bytes_to_string")
      }
      _ => ()
    }
  }
  assert_true(validator_reachable)
  assert_true(conversion_reachable)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  assert_true(
    emit_starshine_program_binary(lowering, fragments).unwrap().length() > 8,
  )
}

///|
test "unchecked Bytes to String is one reference cast without allocation" {
  let actual = emit_starshine_text_runtime_function(
    b"dew_bytes_to_string_unchecked", 17, -1, -1,
  ).unwrap()
  let expected = @lib.Func::new(
    @lib.Locals::empty(),
    @lib.Expr::new([
      @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
      @lib.Instruction::ref_cast(
        false,
        @lib.HeapType::new(@lib.TypeIdx::new(18U)),
      ),
    ]),
  )
  assert_eq(actual, expected)
}

///|
test "StringView to Bytes is one reference cast without allocation" {
  let actual = emit_starshine_text_runtime_function(
    b"dew_string_view_as_bytes", 17, -1, -1,
  ).unwrap()
  let expected = @lib.Func::new(
    @lib.Locals::empty(),
    @lib.Expr::new([
      @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
      @lib.Instruction::ref_cast(
        false,
        @lib.HeapType::new(@lib.TypeIdx::new(19U)),
      ),
    ]),
  )
  assert_eq(actual, expected)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "WASI Bytes marshalling freezes imports memory and runtime bodies" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"open dew.std.bytes\nopen dew.std.wasi\npub fn write(fd: U32) -> U32 {\n  wasi_fd_write(fd, b\"xxpayloadyy\".view(2u32, 7u32))\n}\npub fn read(fd: U32, limit: U32) -> Bytes {\n  wasi_fd_read(fd, limit)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 2)
  assert_true(backend_program_uses_linear_memory(fragments))
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode WASI Bytes marshalling module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "typed scalar SWAR and V128 memory intrinsics add one valid memory" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn roundtrip_i8(address: U32, value: I8) -> I8 {\n  i8_store(address, value)\n  i8_load(address)\n}\npub fn roundtrip_u16(address: U32, value: U16) -> U16 {\n  u16_store(address, value)\n  u16_load(address)\n}\npub fn roundtrip_i32(address: U32, value: I32) -> I32 {\n  i32_store(address, value)\n  i32_load(address)\n}\npub fn roundtrip_i64(address: U32, value: I64) -> I64 {\n  i64_store(address, value)\n  i64_load(address)\n}\npub fn roundtrip_f32(address: U32, value: F32) -> F32 {\n  f32_store(address, value)\n  f32_load(address)\n}\npub fn roundtrip_f64(address: U32, value: F64) -> F64 {\n  f64_store(address, value)\n  f64_load(address)\n}\npub fn roundtrip_swar64(address: U32, value: Swar64) -> Swar64 {\n  swar64_store(address, value)\n  swar64_load(address)\n}\npub fn roundtrip_v128(address: U32, value: V128) -> V128 {\n  v128_store(address, value)\n  v128_load(address)\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_true(backend_program_uses_linear_memory(fragments))
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode typed memory intrinsic module")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "V128 bitwise and lane functions use native SIMD instructions" {
  let (lowering, fragments, diagnostics) = backend_packed_primitive_pipeline(
    b"pub fn mask(left: V128, right: V128) -> V128 {\n  left & right\n}\npub fn byte_math(left: I8, right: I8) -> V128 {\n  v128_splat_i8(left).add_i8(v128_splat_i8(right)).popcnt_i8()\n}\npub fn word_compare(left: I16, right: I16) -> V128 {\n  v128_splat_i16(left).lt_s_i16(v128_splat_i16(right))\n}\npub fn float_math(left: F32, right: F32) -> V128 {\n  v128_splat_f32(left).mul_f32(v128_splat_f32(right))\n}\n",
  )
  assert_eq(diagnostics, 0)
  assert_eq(fragments.imported_function_count, 0)
  let module_ = emit_starshine_program_module(lowering, fragments).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
  match emit_starshine_program_binary(lowering, fragments) {
    Ok(bytes) => assert_true(bytes.length() > 8)
    Err(_) => fail("failed to encode V128 bitwise module")
  }
}
