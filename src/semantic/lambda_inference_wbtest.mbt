///|
fn assert_inferred_resolved_type(
  inferred : InferredModuleBodies,
  type_ : BodyTypeId,
  expected : ResolvedTypeId,
) -> Unit {
  match inferred.type_term(type_) {
    BodyResolvedType(actual) =>
      if actual != expected {
        abort("unexpected resolved inferred type")
      }
    _ => abort("expected resolved inferred type")
  }
}

///|
test "isolated lambda bodies infer parameters captures results and value calls" {
  let collected = collect_bytes(
    620UL, b"fn main() -> Unit {\n  let amount = 1\n  let add = fn(value: I32) -> I32 {\n    value + amount\n  }\n  let result = add(41)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(inferred.lambdas.length(), 1)
  let lambda = collected.lambdas[0]
  let lambda_info = inferred.lambda(0).unwrap()
  assert_inferred_resolved_type(
    inferred,
    lambda_info.root_type,
    resolved.primitive(I32Type),
  )
  let name_info = names.lambda(0).unwrap()
  assert_eq(name_info.locals.length, 1)
  assert_eq(name_info.captures.length, 1)
  assert_inferred_resolved_type(
    inferred,
    inferred.local_types[name_info.locals.start],
    resolved.primitive(I32Type),
  )
  assert_inferred_resolved_type(
    inferred,
    inferred.capture_types[name_info.captures.start],
    resolved.primitive(I32Type),
  )
  let value_expression = lambda_name_expression(collected, lambda, "value")
  let amount_expression = lambda_name_expression(collected, lambda, "amount")
  assert_inferred_resolved_type(
    inferred,
    inferred.expression_types[value_expression],
    resolved.primitive(I32Type),
  )
  assert_inferred_resolved_type(
    inferred,
    inferred.expression_types[amount_expression],
    resolved.primitive(I32Type),
  )
  let body = collected.bodies[0]
  let block = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected root block")
  }
  let items = collected.blocks[block].items
  let result_call = match collected.block_items[items.start + 2] {
    HirLetItem(_, _, _, expression, _) => expression
    _ => fail("expected result binding")
  }
  match inferred.call_targets[result_call] {
    SelectedFunctionValueCallTarget(_) => ()
    _ => fail("expected function-valued lambda call")
  }
}

///|
test "nested lambda inference imports routed root and parent local types" {
  let collected = collect_bytes(
    621UL, b"fn main(seed: I32) -> Unit {\n  let outer = fn(offset: I32) -> I32 {\n    let inner = fn(value: I32) -> I32 {\n      value + offset + seed\n    }\n    inner(1)\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(inferred.lambdas.length(), 2)
  let outer_names = names.lambda(0).unwrap()
  let inner_names = names.lambda(1).unwrap()
  assert_eq(outer_names.captures.length, 1)
  assert_eq(inner_names.captures.length, 2)
  for index in 0..<outer_names.captures.length {
    assert_inferred_resolved_type(
      inferred,
      inferred.capture_types[outer_names.captures.start + index],
      resolved.primitive(I32Type),
    )
  }
  for index in 0..<inner_names.captures.length {
    assert_inferred_resolved_type(
      inferred,
      inferred.capture_types[inner_names.captures.start + index],
      resolved.primitive(I32Type),
    )
  }
  assert_inferred_resolved_type(
    inferred,
    inferred.lambda(0).unwrap().root_type,
    resolved.primitive(I32Type),
  )
  assert_inferred_resolved_type(
    inferred,
    inferred.lambda(1).unwrap().root_type,
    resolved.primitive(I32Type),
  )
}

///|
test "function values returned from calls can be invoked directly and later" {
  let collected = collect_bytes(
    623UL, b"fn make(amount: I32) -> fn(I32) -> I32 {\n  fn(value: I32) -> I32 {\n    value + amount\n  }\n}\nfn main() -> Unit {\n  let callback = make(1)\n  let first = callback(41)\n  let second = make(2)(40)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let mut function_value_calls = 0
  for target in inferred.call_targets {
    match target {
      SelectedFunctionValueCallTarget(_) => function_value_calls += 1
      _ => ()
    }
  }
  assert_eq(function_value_calls, 2)
}

///|
test "lambda bodies diagnose declared result mismatches" {
  let collected = collect_bytes(
    622UL, b"fn main() -> Unit {\n  let invalid = fn(value: I32) -> Bool {\n    value + 1\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.lambdas.length(), 1)
  assert_eq(inferred.lambda(0).unwrap().diagnostics.length, 1)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    BodyConstraintDiagnostic(LocalTypeMismatch(_, _, origin)) =>
      assert_eq(origin.kind, ReturnTypeConstraint)
    _ => fail("expected lambda result mismatch")
  }
}
