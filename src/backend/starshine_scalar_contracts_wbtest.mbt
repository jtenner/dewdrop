///|
test "new scalar contracts reject wrong widths and reference results" {
  for (opcode, parameters, result, arguments) in [
    ("i32.eqz", "value: I64", "Bool", "value"),
    ("i64.eqz", "value: I64", "I64", "value"),
    ("f32.min", "left: F32, right: F32", "String", "left, right"),
    ("f64.copysign", "left: F64, right: F32", "F64", "left, right"),
    ("i32.trunc_sat_f64_s", "value: F64", "I64", "value"),
    ("i64.trunc_sat_f32_u", "value: F64", "I64", "value"),
  ] {
    let stages = backend_test_single_module_stages(
      28216UL,
      @utf8.encode("builtin operation(\{parameters}) -> \{result} = \"\{opcode}\"\npub fn run(\{parameters}) -> \{result} {\n operation(\{arguments})\n}\n"),
    )
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidBuiltinSignature(name, _, _)) => assert_eq(name, @utf8.encode(opcode))
      Err(error) => fail(@debug.to_string(error))
      Ok(_) => fail("bad scalar instruction contract emitted: " + opcode)
    }
  }
}
