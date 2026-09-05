///|
test "raw SIMD instructions validate every operand and result" {
  let cases = raw_simd_test_cases()
  for
    opcode in [
      "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15", "i8x16.shuffle 31 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24",
      "i8x16.shuffle 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31",
    ] {
    cases.push((opcode, ["V128", "V128"], "V128"))
  }
  let source = Buffer(size_hint=32768)
  for index, case_ in cases {
    let (opcode, inputs, output) = case_
    let parameters = inputs
      .mapi((position, type_) => "value\{position}: \{type_}")
      .join(", ")
    let arguments = inputs.mapi((position, _) => "value\{position}").join(", ")
    source.write_string_utf8(
      "builtin operation\{index}(\{parameters}) -> \{output} = \"\{opcode}\"\npub fn probe\{index}(\{parameters}) -> \{output} {\n  operation\{index}(\{arguments})\n}\n",
    )
  }
  let stages = backend_test_single_module_stages(28214UL, source.to_bytes())
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  let planned = stages.link.modules[0]
  let i32 = @semantic.raw_wasm_builtin_signature(b"i32.add").unwrap().inputs[0]
  let i64 = @semantic.raw_wasm_builtin_signature(b"i64.add").unwrap().inputs[0]
  let mut checked = 0
  for index, case_ in cases {
    let (opcode, inputs, output) = case_
    for function_ in planned.functions {
      if function_.name != @utf8.encode("operation\{index}") {
        continue
      }
      checked += 1
      let parameters = function_.parameters
      let results = function_.results
      assert_eq(parameters.length, inputs.length())
      assert_eq(results.length, if output == "Unit" { 0 } else { 1 })
      for position in 0..<(parameters.length + results.length) {
        let slot = if position == parameters.length {
          results.start
        } else {
          parameters.start + position
        }
        let types = planned.function_value_types.map(value => value)
        types[slot] = if types[slot] == i32 { i64 } else { i32 }
        match
          starshine_verify_raw_builtin_signature(
            function_.kind,
            function_.direct_builtin,
            types,
            parameters,
            results,
          ) {
          Err(InvalidBuiltinSignature(actual, _, _)) =>
            assert_eq(actual, @utf8.encode(opcode))
          _ => fail("raw SIMD accepted a one-slot type mutation")
        }
      }
    }
  }
  assert_eq(checked, 365)
}

///|
test "invalid SIMD immediates fail before Wasm emission" {
  for
    opcode in [
      "i8x16.extract_lane_s 16", "i16x8.replace_lane 8", "i8x16.shuffle 32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15",
      "i8x16.shuffle 00 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15", "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14",
      "i8x16.shuffle 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16", "v128.load8_lane 16",
      "v128.store64_lane 2",
    ] {
    let name = @utf8.encode(opcode)
    assert_eq(@semantic.raw_wasm_builtin_signature(name), None)
    let stages = backend_test_single_module_stages(
      28215UL,
      @utf8.encode(
        "builtin operation(value: V128) -> V128 = \"\{opcode}\"\npub fn main(value: V128) -> V128 {\n  operation(value)\n}\n",
      ),
    )
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(UnsupportedBuiltin(actual)) => assert_eq(actual, name)
      Err(error) => {
        debug_inspect(error)
        fail("invalid SIMD immediate did not report UnsupportedBuiltin")
      }
      Ok(_) => fail("invalid SIMD immediate was accepted")
    }
  }
}
