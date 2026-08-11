///|
fn optimization_test_body_tail(
  module_ : PlannedModuleLowering,
  body_id : BodyId,
) -> ExprId {
  let body = module_.bodies[semantic_id_local(body_id)]
  match body.root {
    ExpressionBodyRoot(expression) => expression
    BlockBodyRoot(block) => {
      let items = module_.blocks[block].items
      match module_.block_items[items.start + items.length - 1].kind {
        PlannedExpressionItem(expression) | PlannedReturnItem(expression) =>
          expression
        _ => abort("expected optimization test body tail")
      }
    }
  }
}

///|
test "constant folding rewrites exact primitive operations only in the copy" {
  let program = collect_program_manifest(
    22805UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn arithmetic() -> I32 {\n  -(1 + 2 * 3)\n}\nfn comparison() -> Bool {\n  (-5 < 2) && (3u64 * 4u64 == 12u64)\n}\nfn wrapping() -> U32 {\n  4294967295u32 + 2u32\n}\npub fn main() -> Unit {\n  assert(arithmetic() == -7, \"arithmetic\")\n  assert(comparison(), \"comparison\")\n  assert(wrapping() == 1u32, \"wrapping\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let arithmetic = optimization_test_body_tail(
    unoptimized.modules[0],
    collected.body_of(collected.lookup_value("arithmetic").unwrap()).unwrap().id,
  )
  let comparison = optimization_test_body_tail(
    unoptimized.modules[0],
    collected.body_of(collected.lookup_value("comparison").unwrap()).unwrap().id,
  )
  let wrapping = optimization_test_body_tail(
    unoptimized.modules[0],
    collected.body_of(collected.lookup_value("wrapping").unwrap()).unwrap().id,
  )
  assert_true(
    unoptimized.modules[0].expressions[arithmetic].kind
    is PlannedPrefixExpression(_, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[comparison].kind
    is PlannedBinaryExpression(_, _, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[wrapping].kind
    is PlannedOperatorCall(_, _, _, _, _),
  )
  assert_eq(
    optimized.modules[0].expressions[arithmetic].kind,
    PlannedI32Const(4294967289UL),
  )
  assert_eq(
    optimized.modules[0].expressions[comparison].kind,
    PlannedBoolConst(true),
  )
  assert_eq(
    optimized.modules[0].expressions[wrapping].kind,
    PlannedU32Const(1UL),
  )
}

///|
test "immutable call summaries inline selectors and constant functions" {
  let program = collect_program_manifest(
    22806UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn second(left: I32, right: I32) -> I32 {\n  right\n}\nfn wrapper(left: I32, right: I32) -> I32 {\n  second(left, right)\n}\nfn answer() -> I32 {\n  6 * 7\n}\npub fn main() -> I32 {\n  wrapper(1, 2) + answer()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let wrapper = collected.lookup_value("wrapper").unwrap()
  let answer = collected.lookup_value("answer").unwrap()
  let calls = body_calls(collected, collected.body_of(main).unwrap())
  let mut wrapper_call = -1
  let mut answer_call = -1
  for call in calls {
    match unoptimized.modules[0].expressions[call].kind {
      PlannedDirectCall(target, _, _, _) if target == wrapper =>
        wrapper_call = call
      PlannedDirectCall(target, _, _, _) if target == answer =>
        answer_call = call
      _ => ()
    }
  }
  assert_true(wrapper_call >= 0)
  assert_true(answer_call >= 0)
  assert_true(
    optimized.modules[0].expressions[wrapper_call].kind
    is PlannedParameterSelect(_, 1),
  )
  assert_eq(
    optimized.modules[0].expressions[answer_call].kind,
    PlannedI32Const(42UL),
  )
  assert_true(
    unoptimized.modules[0].expressions[wrapper_call].kind
    is PlannedDirectCall(_, _, _, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[answer_call].kind
    is PlannedDirectCall(_, _, _, _),
  )
}

///|
test "scalar replacement selects fresh struct fields while preserving all inputs" {
  let program = collect_program_manifest(
    22809UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn choose(left: I32, right: I32) -> I32 {\n  Pair {\n    left: left\n    right: right\n  }.right\n}\npub fn main() -> I32 {\n  choose(1, 2)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let choose = collected.lookup_value("choose").unwrap()
  let body = collected.body_of(choose).unwrap()
  let mut field_get = -1
  let mut struct_new = -1
  for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
    match unoptimized.modules[0].expressions[expression].kind {
      PlannedFieldGet(_, base) => {
        field_get = expression
        struct_new = base
      }
      _ => ()
    }
  }
  assert_true(field_get >= 0)
  assert_true(struct_new >= 0)
  assert_true(
    optimized.modules[0].expressions[field_get].kind
    is PlannedParameterSelect(_, 1),
  )
  assert_true(
    optimized.modules[0].expressions[struct_new].kind
    is PlannedConsumedExpression,
  )
  assert_true(
    unoptimized.modules[0].expressions[field_get].kind
    is PlannedFieldGet(_, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[struct_new].kind
    is PlannedStructNew(_, _, _),
  )
}

///|
test "adjacent nonescaping struct locals scalar replace" {
  let program = collect_program_manifest(
    22810UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn choose(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  pair.right\n}\nfn choose_gap(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let marker = 0\n  pair.right\n}\npub fn main() -> I32 {\n  choose(1, 2) + choose_gap(3, 4)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let choose = collected.lookup_value("choose").unwrap()
  let source_body = collected.body_of(choose).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let block = match body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected block body")
  }
  let items = optimized.modules[0].blocks[block].items
  assert_true(
    optimized.modules[0].block_items[items.start].kind
    is PlannedElidedLetItem(_),
  )
  let field_expression = match
    optimized.modules[0].block_items[items.start + 1].kind {
    PlannedExpressionItem(value) => value
    _ => abort("expected field expression")
  }
  assert_true(
    optimized.modules[0].expressions[field_expression].kind
    is PlannedParameterSelect(_, 1),
  )
  assert_true(
    unoptimized.modules[0].block_items[items.start].kind
    is PlannedLetItem(_, false, _),
  )
  let choose_gap = collected.lookup_value("choose_gap").unwrap()
  let gap_source_body = collected.body_of(choose_gap).unwrap()
  let gap_body = optimized.modules[0].bodies[
    semantic_id_local(gap_source_body.id)
  ]
  let gap_block = match gap_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected gap block body")
  }
  let gap_items = optimized.modules[0].blocks[gap_block].items
  assert_true(
    optimized.modules[0].block_items[gap_items.start].kind
    is PlannedLetItem(_, false, _),
  )
}

///|
test "common field extraction reuses immutable scalar loads only in the copy" {
  let program = collect_program_manifest(
    22808UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Point {\n  x: I32\n}\nfn twice(point: Point) -> I32 {\n  let first = point.x\n  let second = point.x\n  first + second\n}\nfn mutable_twice(initial: Point) -> I32 {\n  let mut point = initial\n  let first = point.x\n  let second = point.x\n  first + second\n}\npub fn main() -> I32 {\n  twice(Point {\n    x: 21\n  }) + mutable_twice(Point {\n    x: 1\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let twice = collected.lookup_value("twice").unwrap()
  let mutable_twice = collected.lookup_value("mutable_twice").unwrap()
  let twice_body = collected.body_of(twice).unwrap()
  let mutable_body = collected.body_of(mutable_twice).unwrap()
  let mut optimized_field_gets = 0
  let mut mutable_field_gets = 0
  let mut unoptimized_field_gets = 0
  for expression in twice_body.expressions.start..<(twice_body.expressions.start + twice_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      optimized_field_gets += 1
    }
    if unoptimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      unoptimized_field_gets += 1
    }
  }
  for expression in mutable_body.expressions.start..<(mutable_body.expressions.start + mutable_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      mutable_field_gets += 1
    }
  }
  let planned_twice = optimized.modules[0].bodies[
    semantic_id_local(twice_body.id)
  ]
  let mut elided_aliases = 0
  for block in planned_twice.blocks.start..<(planned_twice.blocks.start + planned_twice.blocks.length) {
    let items = optimized.modules[0].blocks[block].items
    for index in 0..<items.length {
      if optimized.modules[0].block_items[items.start + index].kind is PlannedElidedLetItem(_) {
        elided_aliases += 1
      }
    }
  }
  assert_eq(optimized_field_gets, 1)
  assert_eq(unoptimized_field_gets, 2)
  assert_eq(mutable_field_gets, 2)
  assert_eq(elided_aliases, 1)
}

///|
test "tail recursion marks only exact non-generic scalar self calls in tail position" {
  let program = collect_program_manifest(
    22807UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn countdown(value: U32, total: U32) -> U32 {\n  if value == 0u32 {\n    total\n  } else {\n    countdown(value - 1u32, total + 1u32)\n  }\n}\nfn non_tail(value: U32) -> U32 {\n  if value == 0u32 {\n    0u32\n  } else {\n    1u32 + non_tail(value - 1u32)\n  }\n}\nfn reference_tail(value: String, remaining: U32) -> String {\n  if remaining == 0u32 {\n    value\n  } else {\n    reference_tail(value, remaining - 1u32)\n  }\n}\npub fn main() -> Unit {\n  assert(countdown(10u32, 0u32) == 10u32, \"tail\")\n  assert(non_tail(10u32) == 10u32, \"non-tail\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let countdown = collected.lookup_value("countdown").unwrap()
  let non_tail = collected.lookup_value("non_tail").unwrap()
  let reference_tail = collected.lookup_value("reference_tail").unwrap()
  let countdown_calls = body_calls(
    collected,
    collected.body_of(countdown).unwrap(),
  )
  let non_tail_calls = body_calls(
    collected,
    collected.body_of(non_tail).unwrap(),
  )
  let reference_tail_calls = body_calls(
    collected,
    collected.body_of(reference_tail).unwrap(),
  )
  assert_eq(countdown_calls.length(), 1)
  assert_eq(non_tail_calls.length(), 1)
  assert_eq(reference_tail_calls.length(), 1)
  assert_true(
    optimized.modules[0].expressions[countdown_calls[0]].kind
    is PlannedTailCall(_, _, _, _),
  )
  assert_true(
    optimized.modules[0].expressions[non_tail_calls[0]].kind
    is PlannedDirectCall(_, _, _, _),
  )
  assert_true(
    optimized.modules[0].expressions[reference_tail_calls[0]].kind
    is PlannedDirectCall(_, _, _, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[countdown_calls[0]].kind
    is PlannedDirectCall(_, _, _, _),
  )
}

///|
test "program optimization preserves its unoptimized input" {
  let program = collect_program_manifest(
    22804UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let result = callback(value)\n  result\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  assert_eq(
    unoptimized.index.module_index(program.modules[0].module_id),
    Some(0),
  )
  assert_eq(optimized.index.module_index(program.modules[0].module_id), Some(0))
  let collected = program.modules[0]
  let apply = collected.lookup_value("apply").unwrap()
  let increment = collected.lookup_value("increment").unwrap()
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let call = body_calls(collected, body)[0]
  match unoptimized.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, apply)
      assert_eq(arguments.length, 2)
    }
    _ => fail("expected unoptimized callback wrapper call")
  }
  match optimized.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, increment)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected optimized callback wrapper directization")
  }
  assert_eq(unoptimized.elided_trait_wrappers.length(), 0)
}
