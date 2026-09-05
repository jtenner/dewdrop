///|
test "raw memory opcodes require exact address, value, and result carriers" {
  let cases = [
    ("i32.load8_s", "I32", false),
    ("i32.store8", "I32", true),
    ("i32.load8_u", "I32", false),
    ("i32.load16_s", "I32", false),
    ("i32.store16", "I32", true),
    ("i32.load16_u", "I32", false),
    ("i32.load", "I32", false),
    ("i32.store", "I32", true),
    ("i64.load", "I64", false),
    ("i64.store", "I64", true),
    ("f32.load", "F32", false),
    ("f32.store", "F32", true),
    ("f64.load", "F64", false),
    ("f64.store", "F64", true),
    ("v128.load", "V128", false),
    ("v128.store", "V128", true),
  ]
  for case_ in cases {
    let (opcode, carrier, store) = case_
    for mutation in 0..<3 {
      let invalid = mutation != 0
      let address = if mutation == 1 { "I64" } else { "I32" }
      let actual_carrier = if mutation == 2 {
        if carrier == "I32" {
          "I64"
        } else {
          "I32"
        }
      } else {
        carrier
      }
      let parameters = if store {
        "address: \{address}, value: \{actual_carrier}"
      } else {
        "address: \{address}"
      }
      let arguments = if store { "address, value" } else { "address" }
      let result = if store { "Unit" } else { actual_carrier }
      let source = Buffer(size_hint=256)
      source.write_string_utf8(
        "builtin operation(\{parameters}) -> \{result} = \"\{opcode}\"\npub fn main(\{parameters}) -> \{result} {\n  operation(\{arguments})\n}\n",
      )
      let stages = backend_test_single_module_stages(28211UL, source.to_bytes())
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
        _ => fail("unexpected raw memory emission failure")
      }
    }
  }
}
