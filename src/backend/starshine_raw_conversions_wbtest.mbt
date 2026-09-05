///|
test "all raw conversion opcodes validate their physical signatures" {
  let cases = [
    ("i32.extend8_s", "I32", "I32"),
    ("i32.extend16_s", "I32", "I32"),
    ("i32.wrap_i64", "I64", "I32"),
    ("i64.extend_i32_s", "I32", "I64"),
    ("i64.extend_i32_u", "I32", "I64"),
    ("f32.convert_i32_s", "I32", "F32"),
    ("i32.trunc_f32_s", "F32", "I32"),
    ("f32.convert_i32_u", "I32", "F32"),
    ("i32.trunc_f32_u", "F32", "I32"),
    ("f32.convert_i64_s", "I64", "F32"),
    ("i64.trunc_f32_s", "F32", "I64"),
    ("f32.convert_i64_u", "I64", "F32"),
    ("i64.trunc_f32_u", "F32", "I64"),
    ("f64.convert_i32_s", "I32", "F64"),
    ("i32.trunc_f64_s", "F64", "I32"),
    ("f64.convert_i32_u", "I32", "F64"),
    ("i32.trunc_f64_u", "F64", "I32"),
    ("f64.convert_i64_s", "I64", "F64"),
    ("i64.trunc_f64_s", "F64", "I64"),
    ("f64.convert_i64_u", "I64", "F64"),
    ("i64.trunc_f64_u", "F64", "I64"),
    ("f32.demote_f64", "F64", "F32"),
    ("f64.promote_f32", "F32", "F64"),
  ]
  for case_ in cases {
    let (opcode, input, output) = case_
    for invalid in [false, true] {
      let actual_input = if invalid {
        if input == "I32" {
          "I64"
        } else {
          "I32"
        }
      } else {
        input
      }
      let source = Buffer(size_hint=256)
      source.write_string_utf8(
        "builtin convert(value: \{actual_input}) -> \{output} = \"\{opcode}\"\npub fn main(value: \{actual_input}) -> \{output} {\n  convert(value)\n}\n",
      )
      let stages = backend_test_single_module_stages(28210UL, source.to_bytes())
      assert_eq(stages.diagnostic_count(), 0)
      match emit_starshine_program_module(stages.lowering, stages.link) {
        Ok(module_) => {
          assert_false(invalid)
          assert_eq(@validate.validate_module(module_), Ok(()))
        }
        Err(InvalidBuiltinSignature(name, _, _)) => {
          assert_true(invalid)
          assert_eq(name, @utf8.encode(opcode))
        }
        _ => fail("unexpected raw conversion emission failure")
      }
    }
  }
}
