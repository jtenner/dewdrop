///|
test "raw math instructions validate inputs and results" {
  let cases = [
    ("i32.reinterpret_f32", "F32", "I32"),
    ("f32.reinterpret_i32", "I32", "F32"),
    ("f32.abs", "F32", "F32"),
    ("f32.sqrt", "F32", "F32"),
    ("f32.ceil", "F32", "F32"),
    ("f32.floor", "F32", "F32"),
    ("f32.trunc", "F32", "F32"),
    ("f32.nearest", "F32", "F32"),
    ("i64.reinterpret_f64", "F64", "I64"),
    ("f64.reinterpret_i64", "I64", "F64"),
    ("f64.abs", "F64", "F64"),
    ("f64.sqrt", "F64", "F64"),
    ("f64.ceil", "F64", "F64"),
    ("f64.floor", "F64", "F64"),
    ("f64.trunc", "F64", "F64"),
    ("f64.nearest", "F64", "F64"),
    ("i32.ctz", "I32", "I32"),
    ("i32.popcnt", "U32", "U32"),
  ]
  let source = Buffer(size_hint=4096)
  for index, case_ in cases {
    let (opcode, input, output) = case_
    source.write_string_utf8(
      "builtin operation\{index}(value: \{input}) -> \{output} = \"\{opcode}\"\npub fn probe\{index}(value: \{input}) -> \{output} {\n  operation\{index}(value)\n}\n",
    )
  }
  let stages = backend_test_single_module_stages(28213UL, source.to_bytes())
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
  let planned = stages.link.modules[0]
  let i32 = @semantic.raw_wasm_builtin_signature(b"i32.add").unwrap().inputs[0]
  let i64 = @semantic.raw_wasm_builtin_signature(b"i64.add").unwrap().inputs[0]
  let mut checked = 0
  for index, case_ in cases {
    let (opcode, _, _) = case_
    for function_ in planned.functions {
      if function_.name != @utf8.encode("operation\{index}") {
        continue
      }
      checked += 1
      let parameters = function_.parameters
      let results = function_.results
      assert_eq(parameters.length, 1)
      assert_eq(results.length, 1)
      for slot in [parameters.start, results.start] {
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
          Err(InvalidBuiltinSignature(actual, inputs, outputs)) => {
            assert_eq(actual, @utf8.encode(opcode))
            assert_eq(inputs, [types[parameters.start]])
            assert_eq(outputs, [types[results.start]])
          }
          _ => fail("invalid raw math signature was accepted")
        }
      }
    }
  }
  assert_eq(checked, cases.length())
}
