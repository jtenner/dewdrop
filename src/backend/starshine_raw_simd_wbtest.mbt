///|
test "raw SIMD instructions validate every operand and result" {
  let cases = raw_simd_test_cases()
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
    let (opcode, inputs, _) = case_
    for function_ in planned.functions {
      if function_.name != @utf8.encode("operation\{index}") {
        continue
      }
      checked += 1
      let parameters = function_.parameters
      let results = function_.results
      assert_eq(parameters.length, inputs.length())
      assert_eq(results.length, 1)
      for position in 0..<=parameters.length {
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
  assert_eq(checked, 150)
}
