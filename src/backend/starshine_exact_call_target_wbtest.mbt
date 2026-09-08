///|
fn exact_call_target_test_stages(
  two? : Bool = false,
) -> BackendCompilerTestStages raise {
  let program = @semantic.collect_program_manifest(
    28121UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew",
          if two {
            b"open dew.std.types\nfn signed<t>() -> Bool {\n  is_signed_integer::<t>()\n}\npub fn main() -> Bool {\n  signed::<I32>() && !signed::<U32>()\n}\n"
          } else {
            b"open dew.std.types\nfn signed<t>() -> Bool {\n  is_signed_integer::<t>()\n}\npub fn main() -> Bool {\n  signed::<I32>()\n}\n"
          },
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ),
    [],
  )
  assert_eq(
    @validate.validate_module(
      emit_starshine_program_module(lowering, link).unwrap(),
    ),
    Ok(()),
  )
  { program, analyzed, lowering, link, }
}

///|
test "a missing exact generic call cannot fall back to its only carrier match" {
  let stages = exact_call_target_test_stages()
  let program = stages.program
  let lowering = stages.lowering
  let link = stages.link
  let declaration = program.modules[0].lookup_value("signed").unwrap()
  let keys : Array[@semantic.ProgramSpecializedCallKey] = []
  for key, index in link.specialized_call_lookup {
    if link.functions[index].declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 1)
  let key = keys[0]
  let types = match lowering.modules[0].expressions[key.expression].kind {
    @semantic.PlannedDirectCall(_, _, _, types) => types
    other => fail(@debug.to_string(other))
  }
  assert_eq(types.length, 1)
  let original_index = link.specialized_call_lookup[key]
  let _ = link.specialized_call_lookup.remove(key)
  assert_eq(
    starshine_finish_program_call(
      Some(lowering.modules[0]),
      link,
      link.modules[0],
      key.body,
      key.expression,
      declaration,
      Some(types),
      None,
      [],
      false,
    ),
    Err(
      CompilerInvariantFailure({
        code: 304U,
        phase: 7U,
        module_id: 28121UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: 1UL,
        actual: 0UL,
        detail: 0UL,
      }),
    ),
  )
  for index in [-1, link.functions.length()] {
    link.specialized_call_lookup[key] = index
    assert_eq(
      starshine_planned_call_target(
        link,
        28121UL,
        key.body,
        key.expression,
        declaration,
        "",
        true,
      ),
      Err(
        CompilerInvariantFailure({
          code: 101U,
          phase: 7U,
          module_id: 28121UL,
          declaration,
          body: key.body,
          expression: key.expression.reinterpret_as_uint(),
          expected: link.functions.length().to_uint64(),
          actual: index.reinterpret_as_uint().to_uint64(),
          detail: 0UL,
        }),
      ),
    )
  }
  let other = program.modules[0].lookup_value("main").unwrap()
  let other_index = link.function_lookup[other]
  link.specialized_call_lookup[key] = other_index
  assert_eq(
    starshine_planned_call_target(
      link,
      28121UL,
      key.body,
      key.expression,
      declaration,
      "",
      true,
    ),
    Err(
      CompilerInvariantFailure({
        code: 701U,
        phase: 7U,
        module_id: 28121UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: declaration,
        actual: other,
        detail: other_index.to_uint64(),
      }),
    ),
  )
  link.specialized_call_lookup[key] = original_index
  assert_eq(
    starshine_planned_call_target(
      link,
      28121UL,
      key.body,
      key.expression,
      declaration,
      "",
      true,
    ),
    Ok(Some(link.functions[original_index])),
  )
}

///|
test "a frozen query call cannot select another same-carrier instance" {
  let stages = exact_call_target_test_stages(two=true)
  let link = stages.link
  let declaration = stages.program.modules[0].lookup_value("signed").unwrap()
  let keys : Array[@semantic.ProgramSpecializedCallKey] = []
  for key, index in link.specialized_call_lookup {
    if link.functions[index].declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 2)
  let key = keys[0]
  let original = link.specialized_call_lookup[key]
  let other = link.specialized_call_lookup[keys[1]]
  assert_true(original != other)
  assert_eq(
    link.functions[original].declaration,
    link.functions[other].declaration,
  )
  assert_true(
    link.functions[original].specialization_abi_key !=
    link.functions[other].specialization_abi_key,
  )
  link.specialized_call_lookup[key] = other
  assert_eq(
    starshine_planned_call_target(
      link,
      28121UL,
      key.body,
      key.expression,
      declaration,
      "",
      true,
    ),
    Err(
      CompilerInvariantFailure({
        code: 701U,
        phase: 7U,
        module_id: 28121UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: 1UL,
        actual: 0UL,
        detail: (1UL << 32) | other.to_uint64(),
      }),
    ),
  )
  link.specialized_call_lookup[key] = original
  let witness = link.specialized_call_targets[key]
  let _ = link.specialized_call_targets.remove(key)
  assert_eq(
    starshine_planned_call_target(
      link,
      28121UL,
      key.body,
      key.expression,
      declaration,
      "",
      true,
    ),
    Err(
      CompilerInvariantFailure({
        code: 304U,
        phase: 7U,
        module_id: 28121UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: 1UL,
        actual: 0UL,
        detail: 1UL,
      }),
    ),
  )
  link.specialized_call_targets[key] = witness
  assert_eq(
    starshine_planned_call_target(
      link,
      28121UL,
      key.body,
      key.expression,
      declaration,
      "",
      true,
    ),
    Ok(Some(link.functions[original])),
  )
}
