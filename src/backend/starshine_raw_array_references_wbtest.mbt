///|
test "raw array reads returned as function values have typed wrappers" {
  let stages = backend_test_single_module_stages(
    28114UL, b"pub struct Slots<t> {}\nbuiltin create<t>(length: U32, value: t) -> Slots<t> = \"array.new\"\nbuiltin read<t>(value: Slots<t>, index: U32) -> t = \"array.get\"\nfn reader() -> fn(Slots<I64>, U32) -> I64 {\n  read\n}\npub fn run() -> I64 {\n  let values = create(1u32, 42i64)\n  let operation = reader()\n  operation(values, 0u32)\n}\n",
  )
  assert_eq(stages.program.diagnostics, [])
  for module_ in stages.analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  for module_ in stages.lowering.modules {
    assert_eq(module_.diagnostics, [])
  }
  assert_eq(stages.link.diagnostics, [])
  match emit_starshine_program_module(stages.lowering, stages.link) {
    Ok(module_) => assert_eq(@validate.validate_module(module_), Ok(()))
    Err(error) => fail(@debug.to_string(error))
  }
}

///|
test "raw array getter factories retain storage without an inline producer" {
  for
    type_ in [
      "I8", "U8", "I16", "U16", "I32", "I64", "F32", "F64", "Unit", "(I32, (Unit, I64))",
    ] {
    let source = "pub struct Slots<t> {}\nbuiltin read<t>(value: Slots<t>, index: U32) -> t = \"array.get\"\npub fn factory() -> fn(Slots<\{type_}>, U32) -> \{type_} {\n  read\n}\n"
    let stages = backend_test_single_module_stages(
      28115UL,
      @utf8.encode(source),
    )
    assert_eq(
      @semantic.collect_compiler_source_diagnostics(
        stages.program,
        stages.analyzed,
        stages.lowering,
        stages.link,
      ),
      [],
    )
    assert_eq(stages.program.diagnostics, [])
    for module_ in stages.analyzed.modules {
      assert_eq(module_.inferred.diagnostics, [])
    }
    for module_ in stages.lowering.modules {
      assert_eq(module_.diagnostics, [])
    }
    assert_eq(stages.link.diagnostics, [])
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Ok(module_) =>
        assert_eq(@validate.validate_module(module_), Ok(()), msg=type_)
      Err(error) => fail("\{type_}: \{@debug.to_string(error)}")
    }
  }
}

///|
test "raw array getter wrappers reject changed index and result types" {
  let stages = backend_test_single_module_stages(
    28116UL, b"pub struct Slots<t> {}\nbuiltin read<t>(values: Slots<t>, index: U32) -> t = \"array.get\"\npub fn factory() -> fn(Slots<I64>, U32) -> I64 {\n  read\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  let owner = stages.link.modules[0]
  let mut checked = 0
  for function_ in owner.functions {
    if !function_.elided &&
      function_.kind
      is @semantic.PlannedWasmOutlinedHeapFunction(
        @semantic.RawArrayGetInstruction(recipe)
      ) {
      ignore(
        starshine_outlined_array_get(
          recipe,
          owner,
          Some(stages.link),
          owner.function_value_types,
          function_.parameters,
          function_.results,
          function_.declaration,
        ).unwrap(),
      )
      for mutation in [0, 1] {
        let values = owner.function_value_types.copy()
        if mutation == 0 {
          values[function_.parameters.start + 1] = values[function_.results.start]
        } else {
          values[function_.results.start] = values[function_.parameters.start +
            1]
        }
        let result = starshine_outlined_array_get(
          recipe,
          owner,
          Some(stages.link),
          values,
          function_.parameters,
          function_.results,
          function_.declaration,
        )
        assert_eq(
          result,
          Err(
            CompilerInvariantFailure({
              code: if mutation == 0 {
                705U
              } else {
                709U
              },
              phase: 7U,
              module_id: 28116UL,
              declaration: (28116UL << 32) | 1UL,
              body: 0UL,
              expression: 0xffffffffU,
              expected: if mutation == 0 {
                4UL
              } else {
                5UL
              },
              actual: if mutation == 0 {
                5UL
              } else {
                4UL
              },
              detail: if mutation == 0 {
                1UL
              } else {
                0UL
              },
            }),
          ),
        )
        checked += 1
      }
    }
  }
  assert_eq(checked, 2)
}
