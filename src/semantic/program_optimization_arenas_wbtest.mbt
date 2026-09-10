///|
test "scalar replacement keeps all local records in their owner spans" {
  let program = compiler_test_single_module_program(
    6046UL, b"struct Token {\n  value: I32\n}\n\nstruct Pair {\n  first: Token\n  second: Token\n}\n\nfn selected(first: Token, second: Token) -> I32 {\n  let pair = Pair::{\n    first: first\n    second: second\n  }\n  pair.first.value + pair.second.value\n}\n\npub fn main() -> I32 {\n  selected(Token::{\n    value: 20\n  }, Token::{\n    value: 22\n  })\n}\n\npub fn maker(value: I32) -> fn() -> I32 {\n  fn() -> I32 {\n    value\n  }\n}\n",
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let original = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(original)
  assert_eq(check_planned_capture_metadata(original.modules[0], 4), Ok(()))
  assert_eq(check_planned_capture_metadata(optimized.modules[0], 4), Ok(()))
  // Require the useful rewrite, not just acceptance of an unchanged input.
  let mut before = 0
  let mut after = 0
  for expression in original.modules[0].expressions {
    if expression.kind is PlannedStructNew(_, _, _) {
      before += 1
    }
  }
  for expression in optimized.modules[0].expressions {
    if expression.kind is PlannedStructNew(_, _, _) {
      after += 1
    }
  }
  assert_true(after < before)
}

///|
test "payload guard factoring keeps generated control nodes in their body" {
  let program = compiler_test_single_module_program(
    6046UL, b"enum Maybe {\n  Some(I32, I32)\n  None\n}\n\nfn retain(value: Maybe) -> Maybe {\n  value\n}\n\nfn guarded(first: I32, second: I32) -> I32 {\n  match retain(Maybe::Some(first, second)) {\n    Maybe::Some(left, right) if left > 0 => right + 1\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\n\npub fn maker(value: I32) -> fn() -> I32 {\n  fn() -> I32 {\n    guarded(value, 22)\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let original = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(original)
  for module_ in [original.modules[0], optimized.modules[0]] {
    for body in module_.bodies {
      assert_eq(check_planned_body_arenas(module_, body, 7), Ok(()))
    }
    for index in 0..<module_.lambdas.length() {
      assert_eq(
        check_planned_body_arenas(
          module_,
          module_.lambda_body(index).unwrap(),
          7,
          lambda=index,
        ),
        Ok(()),
      )
    }
  }
  assert_true(
    optimized.modules[0].expressions.length() >
    original.modules[0].expressions.length(),
  )
}

///|
test "known payload guards keep generated control nodes in their body" {
  let program = compiler_test_single_module_program(
    6046UL, b"enum Maybe {\n  Some(I32, I32)\n  None\n}\n\nfn retain(value: Maybe) -> Maybe {\n  value\n}\n\nfn guarded(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if left > 0 => right + 1\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\n\npub fn maker(value: I32) -> fn() -> I32 {\n  fn() -> I32 {\n    guarded(value, 22)\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let original = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(original)
  for module_ in [original.modules[0], optimized.modules[0]] {
    for body in module_.bodies {
      assert_eq(check_planned_body_arenas(module_, body, 7), Ok(()))
    }
    for index in 0..<module_.lambdas.length() {
      assert_eq(
        check_planned_body_arenas(
          module_,
          module_.lambda_body(index).unwrap(),
          7,
          lambda=index,
        ),
        Ok(()),
      )
    }
  }
  assert_true(
    optimized.modules[0].expressions.length() >
    original.modules[0].expressions.length(),
  )
}
