///|
test "compile time generic queries keep logical identity across equal ABI shapes" {
  let program = collect_program_manifest(
    24020UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn signed<t>() -> Bool {\n  is_signed_integer::<t>()\n}\nfn forwarded<t>() -> Bool {\n  signed::<t>()\n}\npub fn main() -> Bool {\n  forwarded::<I8>() && !forwarded::<U8>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let signed = program.modules[0].lookup_value("signed").unwrap()
  let mut count = 0
  let values : Array[Bool] = []
  for function_ in fragments.modules[0].functions {
    if function_.declaration != signed ||
      function_.specialization_shapes.length == 0 {
      continue
    }
    count += 1
    let instance = program_function_lowering(
      lowering,
      0,
      function_.specialization_abi_key,
    )
    let body = program.modules[0].body_of(signed).unwrap()
    match
      instance.expressions[optimization_test_body_tail(instance, body.id)].kind {
      PlannedBoolConst(value) => values.push(value)
      other =>
        fail("query remained in specialized body: " + @debug.to_string(other))
    }
  }
  assert_eq(count, 2)
  assert_true(values.contains(true))
  assert_true(values.contains(false))
}

///|
test "compile time specialized assertion failures reach source diagnostics" {
  let program = collect_program_manifest(
    24021UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn require_unit<t>() -> Unit {\n  static_assert(is_unit::<t>(), \"Unit is required\")\n}\npub fn main() -> Unit {\n  require_unit::<I64>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let link = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(link.diagnostics.length(), 1)
  assert_true(
    link.diagnostics[0]
    is ProgramCompileTimeFailure(
      _,
      _,
      _,
      _,
      "CT-021 static assertion failed: Unit is required",
      _
    ),
  )
}

///|
test "compile time branch removal ignores invalid queries in discarded arms" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> U32 {\n  if is_unit::<Unit>() {\n    7u32\n  } else {\n    bit_width::<Unit>()\n  }\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
}

///|
test "compile time nested false branches are removed in postorder" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> U32 {\n  if is_unit::<I64>() {\n    1u32\n  } else if is_unit::<Unit>() {\n    2u32\n  } else {\n    bit_width::<Unit>()\n  }\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  for expression in lowering.modules[0].expressions {
    assert_false(expression.kind is PlannedIfExpression(_, _, _))
    assert_false(expression.kind is PlannedDirectCall(_, _, _, _))
  }
}

///|
test "compile time selected else keeps both coercion boundaries and source identity" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main(flag: Bool) -> I32 {\n  if flag {\n    1i32\n  } else {\n    2i32\n  }\n}\n",
  )
  let module_ = lowering.modules[0]
  let body = program.modules[0]
    .body_of(program.modules[0].lookup_value("main").unwrap())
    .unwrap()
  let expression = optimization_test_body_tail(module_, body.id)
  let source = module_.expressions[expression]
  let (condition, alternative) = match source.kind {
    PlannedIfExpression(condition, _, alternative) => (condition, alternative)
    _ => fail("expected an unreduced if expression")
  }
  // Conversion identities are deliberately different; this is an IR rewrite
  // test, not an attempt to emit these synthetic trait declarations.
  let outer = SelectedInferredTraitObjectCoercion(1UL, 0)
  let inner = SelectedInferredTraitObjectCoercion(2UL, 1)
  module_.expressions[expression] = { ..source, trait_object_coercion: outer, }
  module_.expressions[alternative] = {
    ..module_.expressions[alternative],
    trait_object_coercion: inner,
  }
  module_.expressions[condition] = {
    ..module_.expressions[condition],
    kind: PlannedBoolConst(false),
  }
  prune_compile_time_branches(module_, None)
  let result = module_.expressions[expression]
  assert_eq(result.type_, source.type_)
  assert_eq(result.offset, source.offset)
  assert_eq(result.trait_object_coercion, outer)
  match result.kind {
    PlannedParameterSelect(arguments, 0) => {
      assert_eq(arguments.length, 1)
      assert_eq(module_.expression_children[arguments.start], alternative)
    }
    _ => fail("selected branch must retain the original child expression")
  }
  assert_eq(module_.expressions[alternative].trait_object_coercion, inner)
}

///|
test "compile time discarded lambdas are not emitted" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\npub fn main() -> Bool {\n  if is_unit::<Unit>() {\n    true\n  } else {\n    let unused = fn() -> Bool {\n      static_assert(false, \"discarded lambda\")\n      false\n    }\n    unused()\n  }\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  assert_eq(lowering.modules[0].lambdas.length(), 1)
  assert_true(lowering.modules[0].lambdas[0].elided)
}

///|
test "compile time generic lambda entries retain their owner logical key" {
  let program = collect_program_manifest(
    24022UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn choose<t>() -> Bool {\n let read = fn() -> Bool {\n is_unit::<t>()\n }\n read()\n}\npub fn main() -> Bool {\n choose::<Unit>() && !choose::<I32>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let link = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(link.diagnostics, [])
  let values : Array[Bool] = []
  for function_ in link.functions {
    if function_.elided {
      continue
    }
    match function_.kind {
      PlannedWasmDefinedLambdaFunction(lambda) => {
        assert_true(function_.specialization_abi_key != "")
        let instance = program_function_lowering(
          lowering,
          function_.module_index,
          function_.specialization_abi_key,
        )
        let body = instance.lambda_body(lambda).unwrap()
        for offset in 0..<body.expressions.length {
          match instance.expressions[body.expressions.start + offset].kind {
            PlannedBoolConst(value) => values.push(value)
            PlannedDirectCall(_, _, _, _) =>
              fail("query call survives in lambda")
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
  assert_eq(values.length(), 2)
  assert_true(values.contains(true) && values.contains(false))
}
