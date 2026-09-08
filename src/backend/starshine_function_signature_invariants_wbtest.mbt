///|
test "emission rejects a duplicate linked source fragment before writing sections" {
  let stages = exact_call_target_test_stages()
  let link = stages.link
  assert_eq(
    @validate.validate_module(
      emit_starshine_program_module(stages.lowering, link).unwrap(),
    ),
    Ok(()),
  )
  let declaration = stages.program.modules[0].lookup_value("signed").unwrap()
  let selected : Array[Int] = []
  for _, index in link.specialized_call_lookup {
    if link.functions[index].declaration == declaration {
      selected.push(index)
    }
  }
  assert_eq(selected.length(), 1)
  let index = selected[0]
  let original = link.functions[index]
  assert_eq(original.results.length, 1)
  let duplicate_index = link.functions.length()
  link.functions.push(original)
  match emit_starshine_program_module(stages.lowering, link) {
    Err(error) =>
      assert_eq(
        error,
        CompilerInvariantFailure({
          code: 404U,
          phase: 7U,
          module_id: 28121UL,
          declaration,
          body: 0UL,
          expression: 0xffffffffU,
          expected: 1UL,
          actual: 2UL,
          detail: duplicate_index.to_uint64(),
        }),
      )
    Ok(_) => fail("a duplicate source fragment reached module emission")
  }
}
