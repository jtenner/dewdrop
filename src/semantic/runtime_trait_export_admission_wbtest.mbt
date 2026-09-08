///|
test "external trait admission keeps proven recursive call cycles" {
  let (program, lowering) = compile_time_evidence_test(
    b"trait Read {\n  fn read(self) -> I64\n}\nfn first<t: Read>(value: t) -> I64 {\n  value.read() + second(value)\n}\nfn second<t: Read>(value: t) -> I64 {\n  first(value)\n}\n",
  )
  for order in [["first", "second"], ["second", "first"]] {
    let states = {}
    for name in order {
      assert_true(
        program_runtime_trait_callable_supports_external_evidence_for_classes(
          lowering,
          lowering.index.module_lookup,
          program.modules[0].lookup_value(name).unwrap(),
          [ProgramExternalDirectRuntimeEvidence],
          states,
        ),
      )
    }
  }
}

///|
test "external trait admission does not invent a lambda witness capture" {
  let (program, lowering) = compile_time_evidence_test(
    b"trait Read {\n  fn read(self) -> I64\n}\nfn forward<t: Read>(value: t) -> I64 {\n  value.read()\n}\nfn reader<t: Read>() -> fn(t) -> I64 {\n  fn(value: t) -> I64 {\n    forward(value)\n  }\n}\n",
  )
  assert_false(
    program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      lowering.index.module_lookup,
      program.modules[0].lookup_value("reader").unwrap(),
      [ProgramExternalDirectRuntimeEvidence],
      {},
    ),
  )
}

///|
test "external trait admission rejects all callers of an unproved cycle member" {
  let (program, lowering) = compile_time_evidence_test(
    b"trait Read {\n  fn read(self) -> I64\n}\nfn first<t: Read>(value: t) -> I64 {\n  let answer = second(value)\n  let callback = fn(input: t) -> I64 {\n    input.read()\n  }\n  callback(value) + answer\n}\nfn second<t: Read>(value: t) -> I64 {\n  first(value)\n}\n",
  )
  for order in [["first", "second"], ["second", "first"]] {
    let states = {}
    for name in order {
      assert_false(
        program_runtime_trait_callable_supports_external_evidence_for_classes(
          lowering,
          lowering.index.module_lookup,
          program.modules[0].lookup_value(name).unwrap(),
          [ProgramExternalDirectRuntimeEvidence],
          states,
        ),
      )
    }
  }
}

///|
test "external trait admission keeps lambdas with no runtime witness use" {
  let (program, lowering) = compile_time_evidence_test(
    b"trait Read {\n  fn read(self) -> I64\n}\nfn reader<t: Read>() -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    value + 1i64\n  }\n}\n",
  )
  assert_true(
    program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      lowering.index.module_lookup,
      program.modules[0].lookup_value("reader").unwrap(),
      [ProgramExternalDirectRuntimeEvidence],
      {},
    ),
  )
}
