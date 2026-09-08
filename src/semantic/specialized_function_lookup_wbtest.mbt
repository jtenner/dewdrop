///|
fn ambiguous_specialization_test_link(
  two? : Bool = true,
) -> (PlannedProgramWasmGCLink, DeclId) raise {
  let program = collect_program_manifest(
    24912UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
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
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_unoptimized_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics, [])
  let declaration = program.modules[0].lookup_value("signed").unwrap()
  assert_eq(declaration, 24912UL << 32)
  (link, declaration)
}

///|
test "same carrier cannot select the first logical query instance" {
  let (link, declaration) = ambiguous_specialization_test_link()
  let mut count = 0
  let keys : Array[String] = []
  for function_ in link.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length == 1 &&
      !function_.elided {
      count += 1
      keys.push(function_.specialization_abi_key)
    }
  }
  assert_eq(count, 2)
  assert_true(keys[0] != keys[1])
  assert_eq(
    check_program_specialized_function_lookup(
      link,
      declaration,
      [I32PlannedValueShape],
      { start: 0, length: 1, },
    ),
    Err({
      code: 304,
      phase: 5,
      module_id: 24912UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: 1UL,
      actual: 2UL,
      detail: 0UL,
    }),
  )
}

///|
fn specialization_lookup_assert_failure(
  result : Result[PlannedProgramWasmFunction?, ProgramFunctionLookupFailure],
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> Unit raise {
  assert_eq(
    result,
    Err({
      code,
      phase: 5,
      module_id: 24912UL,
      declaration: 24912UL << 32,
      body: 0UL,
      expression: 0xffffffffU,
      expected,
      actual,
      detail,
    }),
  )
}

///|
test "one source specialization is selected and a missing shape stays missing" {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  let selected = link
    .specialized_function_of_exact_shapes(declaration, [I32PlannedValueShape])
    .unwrap()
  assert_eq(selected.declaration, declaration)
  assert_eq(selected.specialization_shapes.length, 1)
  assert_eq(
    link.specialized_function_of(
      declaration,
      [ErrorPlannedValueShape, U32PlannedValueShape],
      { start: 1, length: 1, },
    ),
    Some(selected),
  )
  assert_eq(
    link.specialized_function_of_exact_shapes(declaration, [
      I64PlannedValueShape,
    ]),
    None,
  )
  assert_eq(link.specialized_function_of_exact_shapes(declaration, []), None)
}

///|
test "exact call mappings keep distinct same-carrier instances" {
  let (link, declaration) = ambiguous_specialization_test_link()
  let keys : Array[String] = []
  for key, index in link.specialized_call_lookup {
    let function_ = link.functions[index]
    if function_.declaration == declaration {
      assert_eq(
        link.specialized_call_function(
          key.body,
          key.specialization_abi_key,
          key.expression,
        ),
        Some(function_),
      )
      keys.push(function_.specialization_abi_key)
    }
  }
  assert_eq(keys.length(), 2)
  assert_true(keys[0] != keys[1])
}

///|
test "specialization lookup checks input spans before indexing" {
  let (link, declaration) = ambiguous_specialization_test_link()
  for
    span in [
      { start: -1, length: 1, },
      { start: 0, length: -1, },
      { start: 1, length: 1, },
      { start: 2147483647, length: 1, },
    ] {
    specialization_lookup_assert_failure(
      check_program_specialized_function_lookup(
        link,
        declaration,
        [I32PlannedValueShape],
        span,
      ),
      101,
      1UL,
      (span.start.reinterpret_as_uint().to_uint64() << 32) |
      span.length.reinterpret_as_uint().to_uint64(),
      1UL << 32,
    )
  }
}

///|
test "specialization lookup cannot compare invalid shape evidence" {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  for
    item in [
      (GenericPlannedValueShape, 1UL),
      (ErrorPlannedValueShape, 2UL),
      (
        ProductPlannedValueShape([I64PlannedValueShape, ErrorPlannedValueShape]),
        2UL,
      ),
    ] {
    let (shape, actual) = item
    specialization_lookup_assert_failure(
      check_program_specialized_function_lookup(link, declaration, [shape], {
        start: 0,
        length: 1,
      }),
      301,
      0UL,
      actual,
      2UL << 32,
    )
  }
}

///|
test "specialization lookup checks stored owner and shape spans" {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  let mut checked = 0
  for slot, function_ in link.functions {
    if function_.declaration != declaration ||
      function_.specialization_shapes.length == 0 ||
      function_.elided {
      continue
    }
    checked += 1
    link.functions[slot] = { ..function_, module_index: -1, }
    specialization_lookup_assert_failure(
      check_program_specialized_function_lookup(
        link,
        declaration,
        [I32PlannedValueShape],
        { start: 0, length: 1, },
      ),
      101,
      link.modules.length().to_uint64(),
      0xffffffffUL,
      (3UL << 32) | slot.to_uint64(),
    )
    let values = link.modules[function_.module_index].specialization_shapes
    link.functions[slot] = {
      ..function_,
      specialization_shapes: { start: -1, length: 1, },
    }
    specialization_lookup_assert_failure(
      check_program_specialized_function_lookup(
        link,
        declaration,
        [I32PlannedValueShape],
        { start: 0, length: 1, },
      ),
      101,
      values.length().to_uint64(),
      (0xffffffffUL << 32) | 1UL,
      4UL << 32,
    )
    link.functions[slot] = function_
    let index = function_.specialization_shapes.start
    let original = values[index]
    values[index] = ErrorPlannedValueShape
    specialization_lookup_assert_failure(
      check_program_specialized_function_lookup(
        link,
        declaration,
        [I32PlannedValueShape],
        { start: 0, length: 1, },
      ),
      301,
      0UL,
      2UL,
      (5UL << 32) | index.to_uint64(),
    )
    values[index] = original
  }
  assert_eq(checked, 1)
}

///|
test "elided functions and export adapters are not source candidates" {
  let (link, declaration) = ambiguous_specialization_test_link(two=false)
  let mut checked = 0
  for slot, function_ in link.functions {
    if function_.declaration != declaration ||
      function_.specialization_shapes.length == 0 ||
      function_.elided {
      continue
    }
    checked += 1
    link.functions[slot] = { ..function_, elided: true, }
    assert_eq(
      link.specialized_function_of_exact_shapes(declaration, [
        I32PlannedValueShape,
      ]),
      None,
    )
    link.functions[slot] = { ..function_, erased_adapter_target: 0, }
    assert_eq(
      link.specialized_function_of_exact_shapes(declaration, [
        I32PlannedValueShape,
      ]),
      None,
    )
    link.functions[slot] = function_
  }
  assert_eq(checked, 1)
}
