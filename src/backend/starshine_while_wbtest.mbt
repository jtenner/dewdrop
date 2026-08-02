///|
fn starshine_while_test_module(source : Bytes) -> @lib.Module {
  let program = @semantic.collect_program_manifest(
    24148UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  if program.diagnostics.length() != 0 ||
    analyzed.frozen.import_diagnostics.length() != 0 ||
    analyzed.modules[0].inferred.diagnostics.length() != 0 {
    abort("functional while semantic pipeline failed")
  }
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  if lowering.modules[0].diagnostics.length() != 0 {
    abort("functional while lowering pipeline failed")
  }
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  if link.diagnostics.length() != 0 {
    abort("functional while link pipeline failed")
  }
  emit_starshine_program_module(lowering, link).unwrap()
}

///|
test "functional while emits scalar state break and continue" {
  let module_ = starshine_while_test_module(
    b"pub fn main() -> I32 {\n  while 10 {\n    0 => break 42\n    value => continue value - 1\n  }\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "functional while emits enum state guards and reference joins" {
  let module_ = starshine_while_test_module(
    b"enum Step {\n  Next(I32)\n  Done(I32)\n}\npub fn main() -> I32 {\n  while (Step::Next(3)) {\n    Step::Next(value) if value > 0 => continue Step::Next(value - 1)\n    Step::Next(value) => break value\n    Step::Done(value) => break value\n  }\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "functional while emits unit nested if return and nested controls" {
  let module_ = starshine_while_test_module(
    b"fn unit() -> Unit {\n}\nfn unit_loop() -> Unit {\n  while unit() {\n    _ => break unit()\n  }\n}\nfn nested(initial: I32) -> I32 {\n  while initial {\n    0 => break 99\n    outer => {\n      let inner = while 2 {\n        0 => break outer - 1\n        value => continue value - 1\n      }\n      continue inner\n    }\n  }\n}\nfn through_if(initial: I32) -> I32 {\n  while initial {\n    value => if value > 0 {\n      continue value - 1\n    } else {\n      break 7\n    }\n  }\n}\nfn through_return(initial: I32) -> I32 {\n  while initial {\n    0 => {\n      return 5\n    }\n    value => continue value - 1\n  }\n}\npub fn main() -> I32 {\n  unit_loop()\n  nested(3) + through_if(3) + through_return(3)\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
}

///|
test "logical operators short circuit values and loop transfers" {
  let module_ = starshine_while_test_module(
    b"fn and_value(left: Bool, right: Bool) -> Bool {\n  left && right\n}\nfn or_value(left: Bool, right: Bool) -> Bool {\n  left || right\n}\nfn transfer(initial: I32) -> I32 {\n  while initial {\n    value => {\n      value > 0 && continue value - 1\n      break 9\n    }\n  }\n}\npub fn main() -> I32 {\n  if and_value(true, true) && or_value(false, true) {\n    transfer(3)\n  } else {\n    0\n  }\n}\n",
  )
  assert_eq(@validate.validate_module(module_), Ok(()))
}
