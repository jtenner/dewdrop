///|
test "compile time pruning visits constructor values not type argument spans" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nopen dew.std.result\nfn make(ok: Bool) -> Result<Bool, String> {\n  if ok {\n    Result::Ok(true)\n  } else {\n    Result::Err(\"failure\")\n  }\n}\npub fn query() -> Bool {\n  is_unit::<Unit>()\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  let mut constructors = 0
  for source in module_.expressions {
    if source.kind is PlannedVariantTupleNew(_, _, arguments) {
      constructors += 1
      for offset in 0..<arguments.length {
        let value = module_.expression_children[arguments.start + offset]
        assert_false(module_.expressions[value].kind is PlannedPoisonExpression)
      }
    }
  }
  assert_eq(constructors, 2)
}

///|
test "compile time pruning keeps generic struct and named variant fields" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  value: t\n}\nenum Record<t> {\n  Named {\n    value: t\n  }\n}\nfn boxed() -> Box<I64> {\n  Box::{\n    value: 7i64\n  }\n}\nfn named() -> Record<I64> {\n  Record::Named::{\n    value: 8i64\n  }\n}\npub fn query() -> Bool {\n  is_unit::<Unit>()\n}\n",
  )
  let module_ = lowering.modules[0]
  let mut constructors = 0
  for source in module_.expressions {
    match source.kind {
      PlannedStructNew(_, _, fields) | PlannedVariantStructNew(_, _, fields) => {
        constructors += 1
        for offset in 0..<fields.length {
          let value = module_.object_fields[fields.start + offset].value
          assert_false(
            module_.expressions[value].kind is PlannedPoisonExpression,
          )
        }
      }
      _ => ()
    }
  }
  assert_eq(constructors, 2)
}
