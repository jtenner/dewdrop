///|
test "raw arithmetic opcodes require exact operands and results" {
  let cases = [
    ("i32.add", "I32", "I32"),
    ("i32.sub", "I32", "I32"),
    ("i32.le_s", "I32", "I32"),
    ("i32.or", "I32", "I32"),
    ("i32.xor", "I32", "I32"),
    ("i32.and", "I32", "I32"),
    ("i32.eq", "I32", "I32"),
    ("i32.ne", "I32", "I32"),
    ("i32.lt_s", "I32", "I32"),
    ("i32.gt_s", "I32", "I32"),
    ("i32.ge_s", "I32", "I32"),
    ("i32.shl", "I32", "I32"),
    ("i32.shr_s", "I32", "I32"),
    ("i32.mul", "I32", "I32"),
    ("i32.div_s", "I32", "I32"),
    ("i32.rem_s", "I32", "I32"),
    ("i64.or", "I64", "I64"),
    ("i64.xor", "I64", "I64"),
    ("i64.and", "I64", "I64"),
    ("i64.eq", "I64", "I32"),
    ("i64.ne", "I64", "I32"),
    ("i64.lt_s", "I64", "I32"),
    ("i64.le_s", "I64", "I32"),
    ("i64.gt_s", "I64", "I32"),
    ("i64.ge_s", "I64", "I32"),
    ("i64.shl", "I64", "I64"),
    ("i64.shr_s", "I64", "I64"),
    ("i64.add", "I64", "I64"),
    ("i64.sub", "I64", "I64"),
    ("i64.mul", "I64", "I64"),
    ("i64.div_s", "I64", "I64"),
    ("i64.rem_s", "I64", "I64"),
    ("i32.lt_u", "I32", "I32"),
    ("i32.le_u", "I32", "I32"),
    ("i32.gt_u", "I32", "I32"),
    ("i32.ge_u", "I32", "I32"),
    ("i32.shr_u", "I32", "I32"),
    ("i32.div_u", "I32", "I32"),
    ("i32.rem_u", "I32", "I32"),
    ("i64.lt_u", "I64", "I32"),
    ("i64.le_u", "I64", "I32"),
    ("i64.gt_u", "I64", "I32"),
    ("i64.ge_u", "I64", "I32"),
    ("i64.shr_u", "I64", "I64"),
    ("i64.div_u", "I64", "I64"),
    ("i64.rem_u", "I64", "I64"),
    ("f32.eq", "F32", "I32"),
    ("f32.ne", "F32", "I32"),
    ("f32.lt", "F32", "I32"),
    ("f32.le", "F32", "I32"),
    ("f32.gt", "F32", "I32"),
    ("f32.ge", "F32", "I32"),
    ("f32.add", "F32", "F32"),
    ("f32.sub", "F32", "F32"),
    ("f32.mul", "F32", "F32"),
    ("f32.div", "F32", "F32"),
    ("f64.eq", "F64", "I32"),
    ("f64.ne", "F64", "I32"),
    ("f64.lt", "F64", "I32"),
    ("f64.le", "F64", "I32"),
    ("f64.gt", "F64", "I32"),
    ("f64.ge", "F64", "I32"),
    ("f64.add", "F64", "F64"),
    ("f64.sub", "F64", "F64"),
    ("f64.mul", "F64", "F64"),
    ("f64.div", "F64", "F64"),
  ]
  let source = Buffer(size_hint=16384)
  for index, case_ in cases {
    let (opcode, input, output) = case_
    source.write_string_utf8(
      "builtin operation\{index}(left: \{input}, right: \{input}) -> \{output} = \"\{opcode}\"\npub fn probe\{index}(left: \{input}, right: \{input}) -> \{output} {\n  operation\{index}(left, right)\n}\n",
    )
  }
  let stages = backend_test_single_module_stages(28212UL, source.to_bytes())
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
      assert_eq(parameters.length, 2)
      assert_eq(results.length, 1)
      for slot in [parameters.start, parameters.start + 1, results.start] {
        // Preserve the collected signature and mutate one copied physical cell.
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
            assert_eq(inputs, [
              types[parameters.start],
              types[parameters.start + 1],
            ])
            assert_eq(outputs, [types[results.start]])
          }
          _ => fail("invalid raw arithmetic signature was accepted")
        }
      }
    }
  }
  assert_eq(checked, 66)
}
