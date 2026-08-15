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
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn choose(left: I32, right: I32) -> I32 {\n  Pair::{\n    left: left\n    right: right\n  }.right\n}\npub fn main() -> I32 {\n  choose(1, 2)\n}\n",
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
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match unoptimized.modules[0].expressions[expression].kind {
      PlannedFieldGet(_, base, _) => {
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
    is PlannedFieldGet(_, _, _),
  )
  assert_true(
    unoptimized.modules[0].expressions[struct_new].kind
    is PlannedStructNew(_, _, _),
  )
}

///|
test "mutable field writes block immutable-field optimizations" {
  let program = collect_program_manifest(
    22830UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Counter {\n  mut value: I32\n}\nfn update(counter: Counter) -> I32 {\n  let before = counter.value\n  counter.value = before + 1\n  counter.value\n}\npub fn main() -> I32 {\n  update(Counter::{\n    value: 41\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let update = collected.lookup_value("update").unwrap()
  let body = collected.body_of(update).unwrap()
  let mut unoptimized_gets = 0
  let mut optimized_gets = 0
  let mut optimized_sets = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      unoptimized_gets += 1
    }
    match optimized.modules[0].expressions[expression].kind {
      PlannedFieldGet(_, _, _) => optimized_gets += 1
      PlannedFieldSet(_, _, _) => optimized_sets += 1
      _ => ()
    }
  }
  assert_eq(unoptimized_gets, 3)
  assert_eq(optimized_gets, unoptimized_gets)
  assert_eq(optimized_sets, 1)
}

///|
test "adjacent nonescaping struct locals scalar replace" {
  let program = collect_program_manifest(
    22810UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn choose(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  pair.right\n}\nfn choose_gap(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  let marker = 0\n  pair.right\n}\nfn effect() -> I32 {\n  1 / 0\n}\nfn choose_effect(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  let marker = effect()\n  pair.right\n}\npub fn main() -> I32 {\n  choose(1, 2) + choose_gap(3, 4)\n}\n",
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
  let gap_body = optimized.modules[0].bodies[semantic_id_local(
      gap_source_body.id,
    )]
  let gap_block = match gap_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected gap block body")
  }
  let gap_items = optimized.modules[0].blocks[gap_block].items
  assert_true(
    optimized.modules[0].block_items[gap_items.start].kind
    is PlannedElidedLetItem(_),
  )
  let choose_effect = collected.lookup_value("choose_effect").unwrap()
  let effect_source_body = collected.body_of(choose_effect).unwrap()
  let effect_body = optimized.modules[0].bodies[semantic_id_local(
      effect_source_body.id,
    )]
  let effect_block = match effect_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected effect block body")
  }
  let effect_items = optimized.modules[0].blocks[effect_block].items
  assert_true(
    optimized.modules[0].block_items[effect_items.start].kind
    is PlannedLetItem(_, false, _),
  )
}

///|
test "fresh tuple variant payload projections eliminate nonescaping enums" {
  let program = collect_program_manifest(
    22815UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32)\n  None\n}\nstruct Token {\n  value: I32\n}\nenum TokenMaybe {\n  Some(Token)\n  None\n}\nenum RecordMaybe {\n  Some {\n    left: I32\n    right: I32\n  }\n  None\n}\nfn project(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\nfn project_ref(value: Token) -> Token {\n  match TokenMaybe::Some(value) {\n    TokenMaybe::Some(item) => item\n    TokenMaybe::None => Token::{\n      value: 0\n    }\n  }\n}\nfn project_local(value: I32) -> I32 {\n  let maybe = Maybe::Some(value)\n  match maybe {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\nfn project_struct(left: I32, right: I32) -> I32 {\n  match (RecordMaybe::Some::{\n    left: left\n    right: right\n  }) {\n    RecordMaybe::Some {\n      left\n      right\n    } => right\n    RecordMaybe::None => 0\n  }\n}\nfn reordered(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    Maybe::None => 0\n    Maybe::Some(item) => item\n  }\n}\nfn wildcard(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    _ => 0\n    Maybe::Some(item) => item\n  }\n}\npub fn main() -> I32 {\n  project(5) + project_local(5) + project_struct(1, 10) + project_ref(Token::{\n    value: 22\n  }).value + reordered(1) + wildcard(1)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  for name in ["project", "project_ref", "project_local", "project_struct"] {
    let declaration = collected.lookup_value(name).unwrap()
    let source_body = collected.body_of(declaration).unwrap()
    let mut optimized_variants = 0
    let mut optimized_matches = 0
    let mut selects = 0
    let mut unoptimized_variants = 0
    for
      expression in source_body.expressions.start..<(source_body.expressions.start +
      source_body.expressions.length) {
      match optimized.modules[0].expressions[expression].kind {
        PlannedVariantTupleNew(_, _, _) | PlannedVariantStructNew(_, _, _) =>
          optimized_variants += 1
        _ => ()
      }
      if optimized.modules[0].expressions[expression].kind
        is PlannedMatchExpression(_, _) {
        optimized_matches += 1
      }
      if optimized.modules[0].expressions[expression].kind
        is PlannedParameterSelect(_, _) {
        selects += 1
      }
      match unoptimized.modules[0].expressions[expression].kind {
        PlannedVariantTupleNew(_, _, _) | PlannedVariantStructNew(_, _, _) =>
          unoptimized_variants += 1
        _ => ()
      }
    }
    assert_eq(optimized_variants, 0)
    assert_eq(optimized_matches, 0)
    assert_eq(selects, 1)
    assert_eq(unoptimized_variants, 1)
  }
  let reordered = collected.lookup_value("reordered").unwrap()
  let reordered_body = collected.body_of(reordered).unwrap()
  let mut reordered_variants = 0
  let mut reordered_matches = 0
  for
    expression in reordered_body.expressions.start..<(reordered_body.expressions.start +
    reordered_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      reordered_variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      reordered_matches += 1
    }
  }
  assert_eq(reordered_variants, 0)
  assert_eq(reordered_matches, 0)
  let wildcard = collected.lookup_value("wildcard").unwrap()
  let wildcard_body = collected.body_of(wildcard).unwrap()
  let mut wildcard_variants = 0
  let mut wildcard_matches = 0
  for
    expression in wildcard_body.expressions.start..<(wildcard_body.expressions.start +
    wildcard_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      wildcard_variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      wildcard_matches += 1
    }
  }
  assert_eq(wildcard_variants, 0)
  assert_eq(wildcard_matches, 0)
}

///|
test "nested fresh enum payload patterns eliminate aggregate wrappers" {
  let program = collect_program_manifest(
    22817UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box {\n  left: I32\n  right: I32\n}\nenum Wrapped {\n  Some(Box)\n  None\n}\nfn nested(left: I32, right: I32) -> I32 {\n  match Wrapped::Some(Box::{\n    left: left\n    right: right\n  }) {\n    Wrapped::Some(Box {\n      left\n      right\n    }) => right\n    Wrapped::None => 0\n  }\n}\npub fn main() -> I32 {\n  nested(20, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let nested = collected.lookup_value("nested").unwrap()
  let body = collected.body_of(nested).unwrap()
  let mut optimized_structs = 0
  let mut optimized_variants = 0
  let mut optimized_matches = 0
  let mut optimized_selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedStructNew(_, _, _) => optimized_structs += 1
      PlannedVariantTupleNew(_, _, _) => optimized_variants += 1
      PlannedMatchExpression(_, _) => optimized_matches += 1
      PlannedParameterSelect(_, _) => optimized_selects += 1
      _ => ()
    }
  }
  assert_eq(optimized_structs, 0)
  assert_eq(optimized_variants, 0)
  assert_eq(optimized_matches, 0)
  assert_eq(optimized_selects, 2)
}

///|
test "constructor-resolved alternative payload patterns eliminate variants" {
  let program = collect_program_manifest(
    22818UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Choice {\n  First(I32)\n  Second(I32)\n  Empty\n}\nfn alternative(value: I32) -> I32 {\n  match Choice::First(value) {\n    Choice::First(item), Choice::Second(item) => item\n    Choice::Empty => 0\n  }\n}\npub fn main() -> I32 {\n  alternative(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let alternative = collected.lookup_value("alternative").unwrap()
  let body = collected.body_of(alternative).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "constant matching-constructor guards preserve payload elimination" {
  let program = collect_program_manifest(
    22819UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32)\n  None\n}\nfn guarded(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    Maybe::Some(item) if false => 0\n    Maybe::Some(item) if 1 < 2 => item\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "constant-false catchalls do not intercept fresh payload elimination" {
  let program = collect_program_manifest(
    22821UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32)\n  None\n}\nfn guarded(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    _ if false => 0\n    ignored if false => 1\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "known fresh variants eliminate independent catchall selection" {
  let program = collect_program_manifest(
    22822UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn wildcard(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    _ => 42\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\nfn binding(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    ignored if true => 42\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  wildcard(1, 2) + binding(3, 4)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  for name in ["wildcard", "binding"] {
    let declaration = collected.lookup_value(name).unwrap()
    let body = collected.body_of(declaration).unwrap()
    let mut variants = 0
    let mut matches = 0
    let mut selects = 0
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match optimized.modules[0].expressions[expression].kind {
        PlannedVariantTupleNew(_, _, _) => variants += 1
        PlannedMatchExpression(_, _) => matches += 1
        PlannedParameterSelect(_, _) => selects += 1
        _ => ()
      }
    }
    assert_eq(variants, 0)
    assert_eq(matches, 0)
    assert_eq(selects, 1)
  }
}

///|
test "binding catchall may forward the exact fresh variant" {
  let program = collect_program_manifest(
    22824UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32)\n  None\n}\nfn identity(value: Maybe) -> Maybe {\n  match value {\n    Maybe::Some(item) => Maybe::Some(item)\n    Maybe::None => Maybe::None\n  }\n}\nfn forwarded(value: I32) -> Maybe {\n  match Maybe::Some(value) {\n    whole => whole\n    Maybe::Some(item) => Maybe::Some(item)\n    Maybe::None => Maybe::None\n  }\n}\npub fn main() -> I32 {\n  match identity(forwarded(42)) {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let forwarded = collected.lookup_value("forwarded").unwrap()
  let body = collected.body_of(forwarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedParameterSelect(_, 0) {
      selects += 1
    }
  }
  assert_eq(variants, 2)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "binding catchalls scalarize nested payload matches" {
  let program = collect_program_manifest(
    22827UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn projected(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    whole => match whole {\n      Maybe::Some(left, right) => right\n      Maybe::None => 0\n    }\n    Maybe::Some(left, right) => left\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  projected(20, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let projected = collected.lookup_value("projected").unwrap()
  let body = collected.body_of(projected).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "external nonconstant guards collapse identical payload arms" {
  let program = collect_program_manifest(
    22830UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn guarded(flag: Bool, first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if flag => right\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(true, 1, 20) + guarded(false, 2, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "composite pure guards collapse identical payload arms" {
  let program = collect_program_manifest(
    22831UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn guarded(first_flag: Bool, second_flag: Bool, first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if first_flag && !second_flag => right\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(true, false, 1, 20) + guarded(false, true, 2, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
}

///|
test "stable guarded struct variants collapse identical fields" {
  let program = collect_program_manifest(
    22832UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Record {\n  Some {\n    left: I32\n    right: I32\n  }\n  None\n}\nfn guarded(flag: Bool, left: I32, right: I32) -> I32 {\n  match (Record::Some::{\n    left: left\n    right: right\n  }) {\n    Record::Some {\n      left\n      right\n    } if flag => right\n    Record::Some {\n      left\n      right\n    } => right\n    Record::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(true, 1, 20) + guarded(false, 2, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantStructNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
}

///|
test "payload-dependent pure guards collapse identical payload arms" {
  let program = collect_program_manifest(
    22833UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn guarded(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if left > 0 => right\n    Maybe::Some(left, right) if right == 0 => right\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
}

///|
test "retained variants share guarded payload extraction" {
  let program = collect_program_manifest(
    22844UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn retain(value: Maybe) -> Maybe {\n  value\n}\nfn guarded(first: I32, second: I32) -> I32 {\n  match retain(Maybe::Some(first, second)) {\n    Maybe::Some(left, right) if left > 0 => right + 1\n    Maybe::Some(left, right) => right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut selected_arms = -1
  let mut selected_first_arm = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedMatchExpression(_, arms) => {
        selected_arms = arms.length
        selected_first_arm = optimized.modules[0].arm_children[arms.start]
      }
      _ => ()
    }
  }
  assert_eq(selected_arms, 2)
  assert_true(selected_first_arm >= 0)
  assert_eq(
    optimized.modules[0].pattern_arms[selected_first_arm].guard_condition,
    -1,
  )
  assert_true(
    optimized.modules[0].expressions[optimized.modules[0].pattern_arms[selected_first_arm].body].kind
    is PlannedIfExpression(_, _, _),
  )
}

///|
test "retained struct variants share guarded field extraction" {
  let program = collect_program_manifest(
    22845UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Record {\n  Some {\n    left: I32\n    right: I32\n  }\n  None\n}\nfn retain(value: Record) -> Record {\n  value\n}\nfn guarded(left: I32, right: I32) -> I32 {\n  match retain(Record::Some::{\n    left: left\n    right: right\n  }) {\n    Record::Some {\n      left\n      right\n    } if left > 0 => right + 1\n    Record::Some {\n      left\n      right\n    } => right\n    Record::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut selected_arms = -1
  let mut selected_first_arm = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedMatchExpression(_, arms) => {
        selected_arms = arms.length
        selected_first_arm = optimized.modules[0].arm_children[arms.start]
      }
      _ => ()
    }
  }
  assert_eq(selected_arms, 2)
  assert_true(selected_first_arm >= 0)
  assert_eq(
    optimized.modules[0].pattern_arms[selected_first_arm].guard_condition,
    -1,
  )
  assert_true(
    optimized.modules[0].expressions[optimized.modules[0].pattern_arms[selected_first_arm].body].kind
    is PlannedIfExpression(_, _, _),
  )
}

///|
test "retained nested variants share guarded payload extraction" {
  let program = collect_program_manifest(
    22846UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box {\n  left: I32\n  right: I32\n}\nenum Wrapped {\n  Some(Box)\n  None\n}\nfn retain(value: Wrapped) -> Wrapped {\n  value\n}\nfn guarded(left: I32, right: I32) -> I32 {\n  match retain(Wrapped::Some(Box::{\n    left: left\n    right: right\n  })) {\n    Wrapped::Some(Box {\n      left\n      right\n    }) if left > 0 => right + 1\n    Wrapped::Some(Box {\n      left\n      right\n    }) => right\n    Wrapped::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut selected_arms = -1
  let mut selected_first_arm = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedMatchExpression(_, arms) => {
        selected_arms = arms.length
        selected_first_arm = optimized.modules[0].arm_children[arms.start]
      }
      _ => ()
    }
  }
  assert_eq(selected_arms, 2)
  assert_true(selected_first_arm >= 0)
  assert_eq(
    optimized.modules[0].pattern_arms[selected_first_arm].guard_condition,
    -1,
  )
  assert_true(
    optimized.modules[0].expressions[optimized.modules[0].pattern_arms[selected_first_arm].body].kind
    is PlannedIfExpression(_, _, _),
  )
}

///|
test "retained alternative variants share guarded payload extraction" {
  let program = collect_program_manifest(
    22847UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Choice {\n  First(I32)\n  Second(I32)\n  Empty\n}\nfn retain(value: Choice) -> Choice {\n  value\n}\nfn guarded(value: I32) -> I32 {\n  match retain(Choice::First(value)) {\n    Choice::First(item), Choice::Second(item) if item > 0 => item + 1\n    Choice::First(item), Choice::Second(item) => item\n    Choice::Empty => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(20) + guarded(0)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut selected_arms = -1
  let mut selected_first_arm = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedMatchExpression(_, arms) => {
        selected_arms = arms.length
        selected_first_arm = optimized.modules[0].arm_children[arms.start]
      }
      _ => ()
    }
  }
  assert_eq(selected_arms, 2)
  assert_true(selected_first_arm >= 0)
  assert_eq(
    optimized.modules[0].pattern_arms[selected_first_arm].guard_condition,
    -1,
  )
  assert_true(
    optimized.modules[0].expressions[optimized.modules[0].pattern_arms[selected_first_arm].body].kind
    is PlannedIfExpression(_, _, _),
  )
}

///|
test "nonconstant payload guards retain conditional scalar results" {
  let program = collect_program_manifest(
    22841UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn guarded(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if left > 0 => right + 1\n    Maybe::Some(left, right) => left - right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      _ => ()
    }
  }
  let mut blocks = 0
  let mut conditionals = 0
  for expression in optimized.modules[0].expressions {
    match expression.kind {
      PlannedBlockExpression(_) => blocks += 1
      PlannedIfExpression(_, _, _) => conditionals += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(blocks, 1)
  assert_eq(conditionals, 1)
}

///|
test "nonconstant payload guards preserve ordered scalar chains" {
  let program = collect_program_manifest(
    22842UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn guarded(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if left > 0 => right + 1\n    Maybe::Some(left, right) if right > 0 => left + 2\n    Maybe::Some(left, right) => left - right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22) + guarded(0, 0)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      _ => ()
    }
  }
  let mut conditionals = 0
  for expression in optimized.modules[0].expressions {
    if expression.kind is PlannedIfExpression(_, _, _) {
      conditionals += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(conditionals, 2)
}

///|
test "effectful nonconstant payload guards remain conservative" {
  let program = collect_program_manifest(
    22843UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn choose(value: I32) -> Bool {\n  value > 0\n}\nfn guarded(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) if choose(left) => right + 1\n    Maybe::Some(left, right) => left - right\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  guarded(1, 20) + guarded(0, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let guarded = collected.lookup_value("guarded").unwrap()
  let body = collected.body_of(guarded).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      _ => ()
    }
  }
  assert_eq(variants, 1)
  assert_eq(matches, 1)
}

///|
test "fresh payload bindings inline exact primitive scalar transforms" {
  let program = collect_program_manifest(
    22834UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn transformed(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) => -right + 1\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  transformed(1, -41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let transformed = collected.lookup_value("transformed").unwrap()
  let body = collected.body_of(transformed).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "fresh payload bindings inline immutable scalar transform chains" {
  let program = collect_program_manifest(
    22839UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn transformed(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) => {\n      let negated = -right\n      let adjusted = negated + 1\n      adjusted * 2\n    }\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  transformed(1, -20)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let transformed = collected.lookup_value("transformed").unwrap()
  let body = collected.body_of(transformed).unwrap()
  let mut variants = 0
  let mut matches = 0
  let mut selects = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      PlannedParameterSelect(_, _) => selects += 1
      _ => ()
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
  assert_eq(selects, 1)
}

///|
test "effectful payload result blocks remain conservative" {
  let program = collect_program_manifest(
    22840UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn observe(value: I32) -> Unit {\n  ignore(value)\n}\nfn transformed(first: I32, second: I32) -> I32 {\n  match Maybe::Some(first, second) {\n    Maybe::Some(left, right) => {\n      observe(left)\n      let adjusted = right + 1\n      adjusted\n    }\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  transformed(1, 41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let transformed = collected.lookup_value("transformed").unwrap()
  let body = collected.body_of(transformed).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedVariantTupleNew(_, _, _) => variants += 1
      PlannedMatchExpression(_, _) => matches += 1
      _ => ()
    }
  }
  assert_eq(variants, 1)
  assert_eq(matches, 1)
}

///|
test "struct variant fields inline exact primitive scalar transforms" {
  let program = collect_program_manifest(
    22835UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Record {\n  Some {\n    left: I32\n    right: I32\n  }\n  None\n}\nfn transformed(left: I32, right: I32) -> I32 {\n  match (Record::Some::{\n    left: left\n    right: right\n  }) {\n    Record::Some {\n      left\n      right\n    } => -right + 1\n    Record::None => 0\n  }\n}\npub fn main() -> I32 {\n  transformed(1, -41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let transformed = collected.lookup_value("transformed").unwrap()
  let body = collected.body_of(transformed).unwrap()
  let mut variants = 0
  let mut matches = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantStructNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
}

///|
test "let-bound fresh payloads inline exact scalar transforms" {
  let program = collect_program_manifest(
    22836UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  Some(I32, I32)\n  None\n}\nfn transformed(first: I32, second: I32) -> I32 {\n  let value = Maybe::Some(first, second)\n  match value {\n    Maybe::Some(left, right) => -right + 1\n    Maybe::None => 0\n  }\n}\npub fn main() -> I32 {\n  transformed(1, -41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let transformed = collected.lookup_value("transformed").unwrap()
  let source_body = collected.body_of(transformed).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let block = match body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected transform block")
  }
  let items = optimized.modules[0].blocks[block].items
  assert_true(
    optimized.modules[0].block_items[items.start].kind
    is PlannedElidedLetItem(_),
  )
  let mut variants = 0
  let mut matches = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedVariantTupleNew(_, _, _) {
      variants += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedMatchExpression(_, _) {
      matches += 1
    }
  }
  assert_eq(variants, 0)
  assert_eq(matches, 0)
}

///|
test "single-field reference and generic boxes scalar replace when nonescaping" {
  let program = collect_program_manifest(
    22814UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box<t> {\n  value: t\n}\nfn unbox_text(value: String) -> String {\n  Box::{\n    value: value\n  }.value\n}\nfn unbox<t>(value: t) -> t {\n  Box::{\n    value: value\n  }.value\n}\nfn retain(value: Box<String>) -> Box<String> {\n  value\n}\nfn retained(value: String) -> String {\n  retain(Box::{\n    value: value\n  }).value\n}\npub fn main() -> I32 {\n  let text = unbox_text(\"dew\")\n  unbox(42) + retained(text).byte_length().into()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  for name in ["unbox_text", "unbox"] {
    let declaration = collected.lookup_value(name).unwrap()
    let source_body = collected.body_of(declaration).unwrap()
    let mut optimized_fields = 0
    let mut optimized_structs = 0
    let mut parameter_selects = 0
    let mut unoptimized_fields = 0
    for
      expression in source_body.expressions.start..<(source_body.expressions.start +
      source_body.expressions.length) {
      if optimized.modules[0].expressions[expression].kind
        is PlannedFieldGet(_, _, _) {
        optimized_fields += 1
      }
      if optimized.modules[0].expressions[expression].kind
        is PlannedStructNew(_, _, _) {
        optimized_structs += 1
      }
      if optimized.modules[0].expressions[expression].kind
        is PlannedParameterSelect(_, 0) {
        parameter_selects += 1
      }
      if unoptimized.modules[0].expressions[expression].kind
        is PlannedFieldGet(_, _, _) {
        unoptimized_fields += 1
      }
    }
    assert_eq(optimized_fields, 0)
    assert_eq(optimized_structs, 0)
    assert_eq(parameter_selects, 1)
    assert_eq(unoptimized_fields, 1)
  }
  let retained = collected.lookup_value("retained").unwrap()
  let retained_body = collected.body_of(retained).unwrap()
  let mut retained_fields = 0
  let mut retained_structs = 0
  for
    expression in retained_body.expressions.start..<(retained_body.expressions.start +
    retained_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      retained_fields += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      retained_structs += 1
    }
  }
  assert_eq(retained_fields, 1)
  assert_eq(retained_structs, 1)
}

///|
test "direct distinct struct reads synthesize component locals" {
  let program = collect_program_manifest(
    22820UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Quad {\n  first: I32\n  second: I32\n  third: I32\n  fourth: I32\n}\nfn selected(first: I32, second: I32, third: I32, fourth: I32) -> I32 {\n  let quad = Quad::{\n    first: first\n    second: second\n    third: third\n    fourth: fourth\n  }\n  quad.first + quad.third\n}\npub fn main() -> I32 {\n  selected(20, 1, 22, 2)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut structs = 0
  let mut fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      fields += 1
    }
  }
  assert_eq(structs, 0)
  assert_eq(fields, 0)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    2,
  )
}

///|
test "mixed source aliases and direct reads share component locals" {
  let program = collect_program_manifest(
    22825UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Triple {\n  first: I32\n  second: I32\n  third: I32\n}\nfn selected(first: I32, second: I32, third: I32) -> I32 {\n  let triple = Triple::{\n    first: first\n    second: second\n    third: third\n  }\n  let saved = triple.third\n  triple.first + saved\n}\npub fn main() -> I32 {\n  selected(20, 1, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut structs = 0
  let mut fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      fields += 1
    }
  }
  assert_eq(structs, 0)
  assert_eq(fields, 0)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    1,
  )
}

///|
test "direct distinct reference fields synthesize nominal component locals" {
  let program = collect_program_manifest(
    22823UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nstruct Pair {\n  first: Token\n  second: Token\n}\nfn selected(first: Token, second: Token) -> I32 {\n  let pair = Pair::{\n    first: first\n    second: second\n  }\n  pair.first.value + pair.second.value\n}\npub fn main() -> I32 {\n  selected(Token::{\n    value: 20\n  }, Token::{\n    value: 22\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut pair_structs = 0
  let mut pair_fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedStructNew(_, _, _) => pair_structs += 1
      PlannedFieldGet(_, _, _) => pair_fields += 1
      _ => ()
    }
  }
  assert_eq(pair_structs, 0)
  assert_eq(pair_fields, 2)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    2,
  )
}

///|
test "direct distinct generic fields synthesize erased component locals" {
  let program = collect_program_manifest(
    22826UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair<t> {\n  first: t\n  second: t\n}\nfn selected<t>(first: t, second: t, choose_first: Bool) -> t {\n  let pair = Pair::{\n    first: first\n    second: second\n  }\n  if choose_first {\n    pair.first\n  } else {\n    pair.second\n  }\n}\npub fn main() -> I32 {\n  selected(20, 22, false)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut structs = 0
  let mut fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      fields += 1
    }
  }
  assert_eq(structs, 0)
  assert_eq(fields, 0)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    2,
  )
}

///|
test "fresh nominal reference fields synthesize exact component locals" {
  let program = collect_program_manifest(
    22828UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nstruct Pair {\n  first: Token\n  second: Token\n}\nfn selected(first: I32, second: I32) -> I32 {\n  let pair = Pair::{\n    first: Token::{\n      value: first\n    }\n    second: Token::{\n      value: second\n    }\n  }\n  pair.first.value + pair.second.value\n}\npub fn main() -> I32 {\n  selected(20, 22)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut structs = 0
  let mut fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      fields += 1
    }
  }
  assert_eq(structs, 2)
  assert_eq(fields, 2)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    2,
  )
}

///|
test "nominal module values synthesize exact component locals" {
  let program = collect_program_manifest(
    22829UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nstruct Pair {\n  first: Token\n  second: Token\n}\npub let stored = Token::{\n  value: 20\n}\nfn selected(second: Token) -> I32 {\n  let pair = Pair::{\n    first: stored\n    second: second\n  }\n  pair.first.value + pair.second.value\n}\npub fn main() -> I32 {\n  selected(Token::{\n    value: 22\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let selected = collected.lookup_value("selected").unwrap()
  let source_body = collected.body_of(selected).unwrap()
  let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
  let mut structs = 0
  let mut fields = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      fields += 1
    }
  }
  assert_eq(structs, 0)
  assert_eq(fields, 2)
  assert_eq(
    body.locals.length,
    unoptimized.modules[0].bodies[semantic_id_local(source_body.id)].locals.length +
    2,
  )
}

///|
test "sole-use struct fields scalar replace across fresh if joins" {
  let program = collect_program_manifest(
    22813UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn identity(pair: Pair) -> Pair {\n  pair\n}\nfn choose(flag: Bool, left: I32, right: I32) -> I32 {\n  let pair = if flag {\n    Pair::{\n      left: left\n      right: right\n    }\n  } else {\n    Pair::{\n      left: right\n      right: left\n    }\n  }\n  pair.right\n}\nfn escaping(flag: Bool, left: I32, right: I32) -> I32 {\n  let pair = if flag {\n    Pair::{\n      left: left\n      right: right\n    }\n  } else {\n    identity(Pair::{\n      left: right\n      right: left\n    })\n  }\n  pair.right\n}\npub fn main() -> I32 {\n  choose(true, 1, 2) + choose(false, 3, 4) + escaping(true, 5, 6)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let choose = collected.lookup_value("choose").unwrap()
  let choose_source_body = collected.body_of(choose).unwrap()
  let choose_body = optimized.modules[0].bodies[semantic_id_local(
      choose_source_body.id,
    )]
  let choose_block = match choose_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected choose block")
  }
  let choose_items = optimized.modules[0].blocks[choose_block].items
  let (local_id, initializer) = match
    optimized.modules[0].block_items[choose_items.start].kind {
    PlannedLetItem(local_id, false, initializer) => (local_id, initializer)
    _ => abort("expected scalarized join local")
  }
  assert_true(
    optimized.modules[0].expressions[initializer].kind
    is PlannedIfExpression(_, _, _),
  )
  assert_eq(
    optimized.modules[0].expressions[initializer].shape,
    I32PlannedValueShape,
  )
  assert_eq(
    optimized.modules[0].locals[choose_body.locals.start + local_id].shape,
    I32PlannedValueShape,
  )
  let mut choose_field_gets = 0
  let mut choose_struct_news = 0
  let mut unoptimized_struct_news = 0
  for
    expression in choose_source_body.expressions.start..<(choose_source_body.expressions.start +
    choose_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      choose_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      choose_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      unoptimized_struct_news += 1
    }
  }
  assert_eq(choose_field_gets, 0)
  assert_eq(choose_struct_news, 0)
  assert_eq(unoptimized_struct_news, 2)
  let escaping = collected.lookup_value("escaping").unwrap()
  let escaping_source_body = collected.body_of(escaping).unwrap()
  let mut escaping_field_gets = 0
  let mut escaping_struct_news = 0
  for
    expression in escaping_source_body.expressions.start..<(escaping_source_body.expressions.start +
    escaping_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      escaping_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      escaping_struct_news += 1
    }
  }
  assert_eq(escaping_field_gets, 1)
  assert_eq(escaping_struct_news, 2)
}

///|
test "sole-use struct fields scalar replace across fresh match joins" {
  let program = collect_program_manifest(
    22816UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Choice {\n  First\n  Second\n}\nstruct Pair {\n  left: I32\n  right: I32\n}\nfn choose(choice: Choice, left: I32, right: I32) -> I32 {\n  let pair = match choice {\n    Choice::First => Pair::{\n      left: left\n      right: right\n    }\n    Choice::Second => Pair::{\n      left: right\n      right: left\n    }\n  }\n  pair.right\n}\npub fn main() -> I32 {\n  choose(Choice::First, 1, 2) + choose(Choice::Second, 3, 4)\n}\n",
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
    _ => abort("expected choose block")
  }
  let items = optimized.modules[0].blocks[block].items
  let (local_id, initializer) = match
    optimized.modules[0].block_items[items.start].kind {
    PlannedLetItem(local_id, false, initializer) => (local_id, initializer)
    _ => abort("expected match join local")
  }
  assert_true(
    optimized.modules[0].expressions[initializer].kind
    is PlannedMatchExpression(_, _),
  )
  assert_eq(
    optimized.modules[0].expressions[initializer].shape,
    I32PlannedValueShape,
  )
  assert_eq(
    optimized.modules[0].locals[body.locals.start + local_id].shape,
    I32PlannedValueShape,
  )
  let mut optimized_fields = 0
  let mut optimized_structs = 0
  let mut unoptimized_structs = 0
  for
    expression in source_body.expressions.start..<(source_body.expressions.start +
    source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      optimized_fields += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      optimized_structs += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      unoptimized_structs += 1
    }
  }
  assert_eq(optimized_fields, 0)
  assert_eq(optimized_structs, 0)
  assert_eq(unoptimized_structs, 2)
}

///|
test "component aliases scalar replace reordered and one-missing struct fields" {
  let program = collect_program_manifest(
    22812UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn split(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  let first = pair.left\n  let second = pair.right\n  first + second\n}\nfn reversed(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  let second = pair.right\n  let first = pair.left\n  first + second\n}\nfn missing(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  let second = pair.right\n  second\n}\npub fn main() -> I32 {\n  split(1, 2) + reversed(3, 4) + missing(5, 6)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let split = collected.lookup_value("split").unwrap()
  let split_source_body = collected.body_of(split).unwrap()
  let split_body = optimized.modules[0].bodies[semantic_id_local(
      split_source_body.id,
    )]
  let split_block = match split_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected split block")
  }
  let split_items = optimized.modules[0].blocks[split_block].items
  assert_true(
    optimized.modules[0].block_items[split_items.start].kind
    is PlannedLetItem(_, false, _),
  )
  let mut split_field_gets = 0
  let mut split_struct_news = 0
  let mut unoptimized_field_gets = 0
  for
    expression in split_source_body.expressions.start..<(split_source_body.expressions.start +
    split_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      split_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      split_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      unoptimized_field_gets += 1
    }
  }
  assert_eq(split_field_gets, 0)
  assert_eq(split_struct_news, 0)
  assert_eq(unoptimized_field_gets, 2)
  let reversed = collected.lookup_value("reversed").unwrap()
  let reversed_source_body = collected.body_of(reversed).unwrap()
  let mut reversed_field_gets = 0
  let mut reversed_struct_news = 0
  for
    expression in reversed_source_body.expressions.start..<(reversed_source_body.expressions.start +
    reversed_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      reversed_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      reversed_struct_news += 1
    }
  }
  assert_eq(reversed_field_gets, 0)
  assert_eq(reversed_struct_news, 0)
  let missing = collected.lookup_value("missing").unwrap()
  let missing_source_body = collected.body_of(missing).unwrap()
  let mut missing_field_gets = 0
  let mut missing_struct_news = 0
  for
    expression in missing_source_body.expressions.start..<(missing_source_body.expressions.start +
    missing_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      missing_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      missing_struct_news += 1
    }
  }
  assert_eq(missing_field_gets, 0)
  assert_eq(missing_struct_news, 0)
}

///|
test "repeated same-field struct locals scalar replace into the existing local" {
  let program = collect_program_manifest(
    22811UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn repeated(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  pair.right + pair.right + pair.right\n}\nfn mixed(left: I32, right: I32) -> I32 {\n  let pair = Pair::{\n    left: left\n    right: right\n  }\n  pair.left + pair.right\n}\npub fn main() -> I32 {\n  repeated(1, 2) + mixed(3, 4)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let repeated = collected.lookup_value("repeated").unwrap()
  let repeated_source_body = collected.body_of(repeated).unwrap()
  let repeated_body = optimized.modules[0].bodies[semantic_id_local(
      repeated_source_body.id,
    )]
  let repeated_block = match repeated_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected repeated block")
  }
  let repeated_items = optimized.modules[0].blocks[repeated_block].items
  let (local_id, initializer) = match
    optimized.modules[0].block_items[repeated_items.start].kind {
    PlannedLetItem(local_id, false, initializer) => (local_id, initializer)
    _ => abort("expected retained scalar local")
  }
  assert_true(
    optimized.modules[0].expressions[initializer].kind
    is PlannedParameterSelect(_, 1),
  )
  assert_eq(
    optimized.modules[0].locals[repeated_body.locals.start + local_id].shape,
    I32PlannedValueShape,
  )
  let mut repeated_field_gets = 0
  let mut repeated_struct_news = 0
  let mut unoptimized_field_gets = 0
  for
    expression in repeated_source_body.expressions.start..<(repeated_source_body.expressions.start +
    repeated_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      repeated_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      repeated_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      unoptimized_field_gets += 1
    }
  }
  assert_eq(repeated_field_gets, 0)
  assert_eq(repeated_struct_news, 0)
  assert_eq(unoptimized_field_gets, 3)
  let mixed = collected.lookup_value("mixed").unwrap()
  let mixed_source_body = collected.body_of(mixed).unwrap()
  let mut mixed_field_gets = 0
  let mut mixed_struct_news = 0
  for
    expression in mixed_source_body.expressions.start..<(mixed_source_body.expressions.start +
    mixed_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      mixed_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind
      is PlannedStructNew(_, _, _) {
      mixed_struct_news += 1
    }
  }
  assert_eq(mixed_field_gets, 0)
  assert_eq(mixed_struct_news, 0)
}

///|
test "immutable local aliases coalesce into source storage" {
  let program = collect_program_manifest(
    22838UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nfn coalesced(value: I32) -> I32 {\n  let source = value + 1\n  let alias = source\n  alias * 2\n}\nfn shared(value: I32) -> I32 {\n  let source = value + 1\n  let alias = source\n  source + alias\n}\nfn retained(value: Token) -> I32 {\n  let source = value\n  let alias = source\n  source.value + alias.value\n}\nfn sequential(value: Token) -> I32 {\n  let source = value\n  let first = source.value\n  let alias = source\n  first + alias.value\n}\nfn branched(value: Token, flag: Bool) -> I32 {\n  let source = value\n  let alias = source\n  if flag {\n    source.value\n  } else {\n    alias.value\n  }\n}\nfn looped(value: Token) -> I32 {\n  let source = value\n  let first = source.value\n  let alias = source\n  let second = while 0 {\n    0 => break alias.value\n    state => continue state - 1\n  }\n  first + second\n}\nfn select_second<t>(first: t, second: t) -> t {\n  second\n}\nfn generic_shared<t>(value: t) -> t {\n  let source = value\n  let alias = source\n  select_second(source, alias)\n}\nfn mutable_retained(value: Token) -> I32 {\n  let source = value\n  let mut alias = source\n  source.value + alias.value\n}\npub fn main() -> I32 {\n  coalesced(20) + shared(9) + retained(Token::{\n    value: 1\n  }) + sequential(Token::{\n    value: 2\n  }) + branched(Token::{\n    value: 3\n  }, true) + branched(Token::{\n    value: 4\n  }, false) + looped(Token::{\n    value: 5\n  }) + generic_shared(6) + mutable_retained(Token::{\n    value: 7\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let coalesced = collected.lookup_value("coalesced").unwrap()
  let coalesced_source = collected.body_of(coalesced).unwrap()
  let coalesced_body = optimized.modules[0].bodies[semantic_id_local(
      coalesced_source.id,
    )]
  let coalesced_block = match coalesced_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected coalesced block")
  }
  let coalesced_items = optimized.modules[0].blocks[coalesced_block].items
  assert_true(
    optimized.modules[0].block_items[coalesced_items.start + 1].kind
    is PlannedElidedLetItem(_),
  )
  let shared = collected.lookup_value("shared").unwrap()
  let shared_source = collected.body_of(shared).unwrap()
  let shared_body = optimized.modules[0].bodies[semantic_id_local(
      shared_source.id,
    )]
  let shared_block = match shared_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected shared block")
  }
  let shared_items = optimized.modules[0].blocks[shared_block].items
  assert_true(
    optimized.modules[0].block_items[shared_items.start + 1].kind
    is PlannedElidedLetItem(_),
  )
  let retained = collected.lookup_value("retained").unwrap()
  let retained_source = collected.body_of(retained).unwrap()
  let retained_body = optimized.modules[0].bodies[semantic_id_local(
      retained_source.id,
    )]
  let retained_block = match retained_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected retained block")
  }
  let retained_items = optimized.modules[0].blocks[retained_block].items
  assert_true(
    optimized.modules[0].block_items[retained_items.start + 1].kind
    is PlannedElidedLetItem(_),
  )
  let sequential = collected.lookup_value("sequential").unwrap()
  let sequential_source = collected.body_of(sequential).unwrap()
  let sequential_body = optimized.modules[0].bodies[semantic_id_local(
      sequential_source.id,
    )]
  let sequential_block = match sequential_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected sequential block")
  }
  let sequential_items = optimized.modules[0].blocks[sequential_block].items
  assert_true(
    optimized.modules[0].block_items[sequential_items.start + 2].kind
    is PlannedElidedLetItem(_),
  )
  let branched = collected.lookup_value("branched").unwrap()
  let branched_source = collected.body_of(branched).unwrap()
  let branched_body = optimized.modules[0].bodies[semantic_id_local(
      branched_source.id,
    )]
  let branched_block = match branched_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected branched block")
  }
  let branched_items = optimized.modules[0].blocks[branched_block].items
  assert_true(
    optimized.modules[0].block_items[branched_items.start + 1].kind
    is PlannedElidedLetItem(_),
  )
  let looped = collected.lookup_value("looped").unwrap()
  let looped_source = collected.body_of(looped).unwrap()
  let looped_body = optimized.modules[0].bodies[semantic_id_local(
      looped_source.id,
    )]
  let looped_block = match looped_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected looped block")
  }
  let looped_items = optimized.modules[0].blocks[looped_block].items
  assert_true(
    optimized.modules[0].block_items[looped_items.start + 2].kind
    is PlannedElidedLetItem(_),
  )
  let generic_shared = collected.lookup_value("generic_shared").unwrap()
  let generic_source = collected.body_of(generic_shared).unwrap()
  let generic_body = optimized.modules[0].bodies[semantic_id_local(
      generic_source.id,
    )]
  let generic_block = match generic_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected generic block")
  }
  let generic_items = optimized.modules[0].blocks[generic_block].items
  assert_true(
    optimized.modules[0].block_items[generic_items.start + 1].kind
    is PlannedElidedLetItem(_),
  )
  let mutable_retained = collected.lookup_value("mutable_retained").unwrap()
  let mutable_source = collected.body_of(mutable_retained).unwrap()
  let mutable_body = optimized.modules[0].bodies[semantic_id_local(
      mutable_source.id,
    )]
  let mutable_block = match mutable_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected mutable block")
  }
  let mutable_items = optimized.modules[0].blocks[mutable_block].items
  assert_true(
    optimized.modules[0].block_items[mutable_items.start + 1].kind
    is PlannedLetItem(_, true, _),
  )
  let unoptimized_body = unoptimized.modules[0].bodies[semantic_id_local(
      coalesced_source.id,
    )]
  let unoptimized_block = match unoptimized_body.root {
    BlockBodyRoot(block) => block
    _ => abort("expected unoptimized block")
  }
  let unoptimized_items = unoptimized.modules[0].blocks[unoptimized_block].items
  assert_true(
    unoptimized.modules[0].block_items[unoptimized_items.start + 1].kind
    is PlannedLetItem(_, false, _),
  )
}

///|
test "reference alias coalescing rejects mutation and captures" {
  let program = collect_program_manifest(
    22839UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nfn mutable_source(value: Token) -> I32 {\n  let mut source = value\n  let alias = source\n  source.value + alias.value\n}\nfn captured_source(value: Token) -> I32 {\n  let source = value\n  let alias = source\n  let read = fn() -> I32 {\n    source.value\n  }\n  read() + alias.value\n}\nfn captured_alias(value: Token) -> I32 {\n  let source = value\n  let alias = source\n  let read = fn() -> I32 {\n    alias.value\n  }\n  source.value + read()\n}\npub fn main() -> I32 {\n  mutable_source(Token::{\n    value: 1\n  }) + captured_source(Token::{\n    value: 2\n  }) + captured_alias(Token::{\n    value: 3\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let optimized = optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
  let collected = program.modules[0]
  for name in ["mutable_source", "captured_source", "captured_alias"] {
    let declaration = collected.lookup_value(name).unwrap()
    let source_body = collected.body_of(declaration).unwrap()
    let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
    let block = match body.root {
      BlockBodyRoot(block) => block
      _ => abort("expected block")
    }
    let items = optimized.modules[0].blocks[block].items
    assert_true(
      optimized.modules[0].block_items[items.start + 1].kind
      is PlannedLetItem(_, false, _),
    )
  }
}

///|
test "common field extraction reuses immutable scalar loads only in the copy" {
  let program = collect_program_manifest(
    22808UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Point {\n  x: I32\n}\nfn twice(point: Point) -> I32 {\n  let first = point.x\n  let second = point.x\n  first + second\n}\nfn mutable_twice(initial: Point) -> I32 {\n  let mut point = initial\n  let first = point.x\n  let second = point.x\n  first + second\n}\npub fn main() -> I32 {\n  twice(Point::{\n    x: 21\n  }) + mutable_twice(Point::{\n    x: 1\n  })\n}\n",
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
  for
    expression in twice_body.expressions.start..<(twice_body.expressions.start +
    twice_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      optimized_field_gets += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      unoptimized_field_gets += 1
    }
  }
  for
    expression in mutable_body.expressions.start..<(mutable_body.expressions.start +
    mutable_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      mutable_field_gets += 1
    }
  }
  let planned_twice = optimized.modules[0].bodies[semantic_id_local(
      twice_body.id,
    )]
  let mut elided_aliases = 0
  for
    block in planned_twice.blocks.start..<(planned_twice.blocks.start +
    planned_twice.blocks.length) {
    let items = optimized.modules[0].blocks[block].items
    for index in 0..<items.length {
      if optimized.modules[0].block_items[items.start + index].kind
        is PlannedElidedLetItem(_) {
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
test "common field extraction reuses exact nested reference loads" {
  let program = collect_program_manifest(
    22837UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Inner {\n  value: I32\n}\nstruct Outer {\n  inner: Inner\n}\nfn sum(outer: Outer) -> I32 {\n  let inner = outer.inner\n  let first = inner.value\n  let second = outer.inner.value\n  first + second\n}\npub fn main() -> I32 {\n  sum(Outer::{\n    inner: Inner::{\n      value: 21\n    }\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let sum = collected.lookup_value("sum").unwrap()
  let body = collected.body_of(sum).unwrap()
  let mut optimized_fields = 0
  let mut unoptimized_fields = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      optimized_fields += 1
    }
    if unoptimized.modules[0].expressions[expression].kind
      is PlannedFieldGet(_, _, _) {
      unoptimized_fields += 1
    }
  }
  assert_eq(unoptimized_fields, 4)
  assert_eq(optimized_fields, 2)
}

///|
test "private unit enum locals specialize to scalar tags" {
  let program = collect_program_manifest(
    22841UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum State {\n  Left\n  Right\n}\nfn choose(flag: Bool) -> I32 {\n  let state = if flag {\n    State::Left\n  } else {\n    State::Right\n  }\n  match state {\n    State::Left => 1\n    State::Right => 2\n  }\n}\npub fn main() -> I32 {\n  choose(true) + choose(false)\n}\n",
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
    _ => abort("expected choose block")
  }
  let items = optimized.modules[0].blocks[block].items
  let state_local = match optimized.modules[0].block_items[items.start].kind {
    PlannedLetItem(local_id, false, _) => local_id
    _ => abort("expected state local")
  }
  assert_true(
    optimized.modules[0].locals[body.locals.start + state_local].shape
    is I32PlannedValueShape,
  )
  let mut optimized_units = 0
  let mut optimized_tags = 0
  let mut match_expression = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match optimized.modules[0].expressions[expression].kind {
      PlannedUnitVariant(_, _) => optimized_units += 1
      PlannedI32Const(_) => optimized_tags += 1
      PlannedMatchExpression(_, _) => match_expression = expression
      _ => ()
    }
  }
  assert_eq(optimized_units, 0)
  assert_true(optimized_tags >= 2)
  assert_true(match_expression >= 0)
  let (_, arms) = match
    optimized.modules[0].expressions[match_expression].kind {
    PlannedMatchExpression(scrutinee, arms) => (scrutinee, arms)
    _ => abort("expected match")
  }
  for index in 0..<arms.length {
    let arm = optimized.modules[0].pattern_arms[optimized.modules[0].arm_children[arms.start +
      index]]
    assert_true(
      optimized.modules[0].patterns[arm.pattern].shape is I32PlannedValueShape,
    )
  }
  let unoptimized_body = unoptimized.modules[0].bodies[semantic_id_local(
      source_body.id,
    )]
  assert_true(
    unoptimized.modules[0].locals[unoptimized_body.locals.start + state_local].shape
    is RefPlannedValueShape,
  )
}

///|
test "private unit enum parameters specialize with complete direct call evidence" {
  let program = collect_program_manifest(
    22843UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum State {\n  Left\n  Right\n}\nfn classify(state: State) -> I32 {\n  match state {\n    State::Left => 1\n    State::Right => 2\n  }\n}\npub fn main(flag: Bool) -> I32 {\n  classify(if flag {\n    State::Left\n  } else {\n    State::Right\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let classify = collected.lookup_value("classify").unwrap()
  let classify_body = optimized.modules[0].bodies[semantic_id_local(
      collected.body_of(classify).unwrap().id,
    )]
  assert_true(
    optimized.modules[0].locals[classify_body.locals.start].shape
    is I32PlannedValueShape,
  )
  assert_true(
    unoptimized.modules[0].locals[classify_body.locals.start].shape
    is RefPlannedValueShape,
  )
  let main = collected.lookup_value("main").unwrap()
  let calls = body_calls(collected, collected.body_of(main).unwrap())
  assert_eq(calls.length(), 1)
  let (_, _, arguments, _) = match
    optimized.modules[0].expressions[calls[0]].kind {
    PlannedDirectCall(target, receiver, arguments, type_arguments) =>
      (target, receiver, arguments, type_arguments)
    _ => abort("expected direct call")
  }
  let argument = optimized.modules[0].expression_children[arguments.start]
  assert_true(
    optimized.modules[0].expressions[argument].shape is I32PlannedValueShape,
  )
  assert_true(
    unoptimized.modules[0].expressions[argument].shape is RefPlannedValueShape,
  )
}

///|
test "private unit enum results specialize with complete direct consumer evidence" {
  let program = collect_program_manifest(
    22845UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum State {\n  Left\n  Right\n}\nfn choose(flag: Bool) -> State {\n  if flag {\n    State::Left\n  } else {\n    State::Right\n  }\n}\npub fn main(flag: Bool) -> I32 {\n  match choose(flag) {\n    State::Left => 1\n    State::Right => 2\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let choose = collected.lookup_value("choose").unwrap()
  let optimized_callable = optimized.modules[0].functions
    .callable_of(choose)
    .unwrap()
  let unoptimized_callable = unoptimized.modules[0].functions
    .callable_of(choose)
    .unwrap()
  assert_true(optimized_callable.result_shape is I32PlannedValueShape)
  assert_true(unoptimized_callable.result_shape is RefPlannedValueShape)
  let choose_body = optimized.modules[0].bodies[semantic_id_local(
      collected.body_of(choose).unwrap().id,
    )]
  assert_true(choose_body.root_shape is I32PlannedValueShape)
  assert_true(choose_body.result_shape is I32PlannedValueShape)
  let main = collected.lookup_value("main").unwrap()
  let calls = body_calls(collected, collected.body_of(main).unwrap())
  assert_eq(calls.length(), 1)
  assert_true(
    optimized.modules[0].expressions[calls[0]].shape is I32PlannedValueShape,
  )
  assert_true(
    unoptimized.modules[0].expressions[calls[0]].shape is RefPlannedValueShape,
  )
}

///|
test "private unit enum result specialization rejects incomplete consumer evidence" {
  let program = collect_program_manifest(
    22846UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub enum PublicState {\n  Left\n  Right\n}\nenum State {\n  Left\n  Right\n}\nenum PayloadState {\n  Empty\n  Value(I32)\n}\nfn public_result(flag: Bool) -> PublicState {\n  if flag {\n    PublicState::Left\n  } else {\n    PublicState::Right\n  }\n}\nfn payload_result(flag: Bool) -> PayloadState {\n  if flag {\n    PayloadState::Empty\n  } else {\n    PayloadState::Value(2)\n  }\n}\nfn escaping_result(flag: Bool) -> State {\n  if flag {\n    State::Left\n  } else {\n    State::Right\n  }\n}\npub fn referenced_result(flag: Bool) -> State {\n  if flag {\n    State::Left\n  } else {\n    State::Right\n  }\n}\nfn accept(callback: fn(Bool) -> State, flag: Bool) -> State {\n  callback(flag)\n}\npub fn main(flag: Bool) -> I32 {\n  match public_result(flag) {\n    PublicState::Left => 1\n    PublicState::Right => 2\n  } + match payload_result(flag) {\n    PayloadState::Empty => 3\n    PayloadState::Value(value) => value\n  } + match {\n    let state = escaping_result(flag)\n    state\n  } {\n    State::Left => 4\n    State::Right => 5\n  } + match accept(referenced_result, flag) {\n    State::Left => 6\n    State::Right => 7\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let optimized = optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
  let collected = program.modules[0]
  for
    name in [
      "public_result", "payload_result", "escaping_result", "referenced_result",
    ] {
    let declaration = collected.lookup_value(name).unwrap()
    assert_true(
      optimized.modules[0].functions.callable_of(declaration).unwrap().result_shape
      is RefPlannedValueShape,
    )
  }
}

///|
test "private unit enum parameter specialization rejects incomplete call evidence" {
  let program = collect_program_manifest(
    22844UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub enum PublicState {\n  Left\n  Right\n}\nenum State {\n  Left\n  Right\n}\nenum PayloadState {\n  Empty\n  Value(I32)\n}\nfn public_parameter(state: PublicState) -> I32 {\n  match state {\n    PublicState::Left => 1\n    PublicState::Right => 2\n  }\n}\nfn payload_parameter(state: PayloadState) -> I32 {\n  match state {\n    PayloadState::Empty => 1\n    PayloadState::Value(value) => value\n  }\n}\nfn guarded_parameter(state: State) -> I32 {\n  match state {\n    State::Left if true => 1\n    State::Left => 2\n    State::Right => 3\n  }\n}\nfn escaping_parameter(state: State) -> State {\n  state\n}\npub fn referenced_parameter(state: State) -> I32 {\n  match state {\n    State::Left => 1\n    State::Right => 2\n  }\n}\nfn accept(callback: fn(State) -> I32, state: State) -> I32 {\n  callback(state)\n}\npub fn main() -> I32 {\n  public_parameter(PublicState::Left) + payload_parameter(PayloadState::Value(2)) +\n  guarded_parameter(State::Right) + match escaping_parameter(State::Left) {\n    State::Left => 4\n    State::Right => 5\n  } + accept(referenced_parameter, State::Right)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let optimized = optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
  let collected = program.modules[0]
  for name in ["guarded_parameter", "escaping_parameter"] {
    let declaration = collected.lookup_value(name).unwrap()
    let callable = optimized.modules[0].functions
      .callable_of(declaration)
      .unwrap()
    assert_true(
      optimized.modules[0].functions.parameters[callable.parameters.start].shape
      is RefPlannedValueShape,
    )
  }
  for name in ["public_parameter", "referenced_parameter"] {
    let declaration = collected.lookup_value(name).unwrap()
    let callable = optimized.modules[0].functions
      .callable_of(declaration)
      .unwrap()
    assert_true(
      optimized.modules[0].functions.parameters[callable.parameters.start].shape
      is RefPlannedValueShape,
    )
  }
  let payload_parameter = collected.lookup_value("payload_parameter").unwrap()
  let payload_callable = optimized.modules[0].functions
    .callable_of(payload_parameter)
    .unwrap()
  assert_true(
    optimized.modules[0].functions.parameters[payload_callable.parameters.start].shape
    is I64PlannedValueShape,
  )
}

///|
test "private scalar payload enum parameters and results specialize with complete evidence" {
  let program = collect_program_manifest(
    22847UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Maybe {\n  None\n  Some(I32)\n}\nfn classify(value: Maybe) -> I32 {\n  match value {\n    Maybe::None => 0\n    Maybe::Some(item) => item\n  }\n}\nfn choose(flag: Bool, value: I32) -> Maybe {\n  if flag {\n    Maybe::Some(value)\n  } else {\n    Maybe::None\n  }\n}\npub fn main(flag: Bool, value: I32) -> I32 {\n  classify(if flag {\n    Maybe::Some(value + 1)\n  } else {\n    Maybe::None\n  }) + match choose(flag, value + 2) {\n    Maybe::None => 0\n    Maybe::Some(item) => item\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  let classify = collected.lookup_value("classify").unwrap()
  let classify_callable = optimized.modules[0].functions
    .callable_of(classify)
    .unwrap()
  assert_true(
    optimized.modules[0].functions.parameters[classify_callable.parameters.start].shape
    is I64PlannedValueShape,
  )
  assert_true(
    unoptimized.modules[0].functions.parameters[classify_callable.parameters.start].shape
    is RefPlannedValueShape,
  )
  let choose = collected.lookup_value("choose").unwrap()
  assert_true(
    optimized.modules[0].functions.callable_of(choose).unwrap().result_shape
    is I64PlannedValueShape,
  )
  assert_true(
    unoptimized.modules[0].functions.callable_of(choose).unwrap().result_shape
    is RefPlannedValueShape,
  )
  let main = collected.lookup_value("main").unwrap()
  let calls = body_calls(collected, collected.body_of(main).unwrap())
  let mut specialized_calls = 0
  for call in calls {
    match optimized.modules[0].expressions[call].kind {
      PlannedDirectCall(target, _, arguments, _)
      | PlannedTailCall(target, _, arguments, _) =>
        if target == classify {
          specialized_calls += 1
          let argument = optimized.modules[0].expression_children[arguments.start]
          assert_true(
            optimized.modules[0].expressions[argument].shape
            is I64PlannedValueShape,
          )
        } else if target == choose {
          specialized_calls += 1
          assert_true(
            optimized.modules[0].expressions[call].shape is I64PlannedValueShape,
          )
        }
      _ => ()
    }
  }
  assert_eq(specialized_calls, 2)
}

///|
test "private scalar payload enum specialization rejects unsupported payload evidence" {
  let program = collect_program_manifest(
    22848UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum Wide {\n  Empty\n  Value(I64)\n}\nenum Pair {\n  Empty\n  Value(I32, I32)\n}\nfn wide(value: Wide) -> I64 {\n  match value {\n    Wide::Empty => 0i64\n    Wide::Value(item) => item\n  }\n}\nfn pair(value: Pair) -> I32 {\n  match value {\n    Pair::Empty => 0\n    Pair::Value(left, right) => left + right\n  }\n}\npub fn main() -> Unit {\n  assert(wide(Wide::Value(1i64)) == 1i64, \"wide\")\n  assert(pair(Pair::Value(2, 3)) == 5, \"pair\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let optimized = optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
  let collected = program.modules[0]
  for name in ["wide", "pair"] {
    let declaration = collected.lookup_value(name).unwrap()
    let callable = optimized.modules[0].functions
      .callable_of(declaration)
      .unwrap()
    assert_true(
      optimized.modules[0].functions.parameters[callable.parameters.start].shape
      is RefPlannedValueShape,
    )
  }
}

///|
test "scalar unit enum specialization rejects public payload guarded and escaping locals" {
  let program = collect_program_manifest(
    22842UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub enum PublicState {\n  Left\n  Right\n}\nenum PayloadState {\n  Left\n  Right(I32)\n}\nenum PrivateState {\n  Left\n  Right\n}\nfn public_state(flag: Bool) -> I32 {\n  let state = if flag {\n    PublicState::Left\n  } else {\n    PublicState::Right\n  }\n  match state {\n    PublicState::Left => 1\n    PublicState::Right => 2\n  }\n}\nfn payload_state(flag: Bool) -> I32 {\n  let state = if flag {\n    PayloadState::Left\n  } else {\n    PayloadState::Right(1)\n  }\n  match state {\n    PayloadState::Left => 1\n    PayloadState::Right(value) => value\n  }\n}\nfn guarded_state(flag: Bool) -> I32 {\n  let state = if flag {\n    PrivateState::Left\n  } else {\n    PrivateState::Right\n  }\n  match state {\n    PrivateState::Left if flag => 1\n    PrivateState::Left => 2\n    PrivateState::Right => 3\n  }\n}\nfn escaping_state(flag: Bool) -> PrivateState {\n  let state = if flag {\n    PrivateState::Left\n  } else {\n    PrivateState::Right\n  }\n  state\n}\nfn captured_state(flag: Bool) -> I32 {\n  let state = if flag {\n    PrivateState::Left\n  } else {\n    PrivateState::Right\n  }\n  let read = fn() -> I32 {\n    match state {\n      PrivateState::Left => 1\n      PrivateState::Right => 2\n    }\n  }\n  read()\n}\npub fn main() -> I32 {\n  public_state(true) + payload_state(false) + guarded_state(true) +\n  match escaping_state(false) {\n    PrivateState::Left => 1\n    PrivateState::Right => 2\n  } + captured_state(true)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let optimized = optimize_program_lowering(
    plan_unoptimized_program_lowering(program, analyzed),
  )
  let collected = program.modules[0]
  for
    name in [
      "public_state", "payload_state", "guarded_state", "escaping_state", "captured_state",
    ] {
    let declaration = collected.lookup_value(name).unwrap()
    let source_body = collected.body_of(declaration).unwrap()
    let body = optimized.modules[0].bodies[semantic_id_local(source_body.id)]
    let block = match body.root {
      BlockBodyRoot(block) => block
      _ => abort("expected block")
    }
    let items = optimized.modules[0].blocks[block].items
    let local_id = match optimized.modules[0].block_items[items.start].kind {
      PlannedLetItem(local_id, false, _) => local_id
      _ => abort("expected enum local")
    }
    assert_true(
      optimized.modules[0].locals[body.locals.start + local_id].shape
      is RefPlannedValueShape,
    )
  }
}

///|
test "tail calls mark scalar direct calls across branch tails" {
  let program = collect_program_manifest(
    22840UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32, enabled: Bool) -> I32 {\n  if enabled {\n    value + 1\n  } else {\n    value\n  }\n}\nfn decrement(value: I32, enabled: Bool) -> I32 {\n  if enabled {\n    value - 1\n  } else {\n    value\n  }\n}\nfn choose(value: I32, increase: Bool) -> I32 {\n  if increase {\n    increment(value, true)\n  } else {\n    decrement(value, true)\n  }\n}\nfn choose_match(value: I32, increase: Bool) -> I32 {\n  match increase {\n    true => increment(value, true)\n    false => decrement(value, true)\n  }\n}\nfn non_tail(value: I32) -> I32 {\n  increment(value, true) + 1\n}\nfn reference(value: String) -> String {\n  value\n}\nfn reference_tail(value: String) -> String {\n  reference(value)\n}\npub fn main() -> I32 {\n  choose(41, true) + choose_match(43, false) + non_tail(40)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let unoptimized = plan_unoptimized_program_lowering(program, analyzed)
  let optimized = optimize_program_lowering(unoptimized)
  let collected = program.modules[0]
  for name in ["choose", "choose_match"] {
    let declaration = collected.lookup_value(name).unwrap()
    let calls = body_calls(collected, collected.body_of(declaration).unwrap())
    assert_eq(calls.length(), 2)
    for call in calls {
      assert_true(
        optimized.modules[0].expressions[call].kind
        is PlannedTailCall(_, _, _, _),
      )
      assert_true(
        unoptimized.modules[0].expressions[call].kind
        is PlannedDirectCall(_, _, _, _),
      )
    }
  }
  let non_tail = collected.lookup_value("non_tail").unwrap()
  let non_tail_calls = body_calls(
    collected,
    collected.body_of(non_tail).unwrap(),
  )
  assert_eq(non_tail_calls.length(), 1)
  assert_true(
    optimized.modules[0].expressions[non_tail_calls[0]].kind
    is PlannedDirectCall(_, _, _, _),
  )
  let reference_tail = collected.lookup_value("reference_tail").unwrap()
  let reference_calls = body_calls(
    collected,
    collected.body_of(reference_tail).unwrap(),
  )
  assert_eq(reference_calls.length(), 1)
  assert_true(
    optimized.modules[0].expressions[reference_calls[0]].kind
    is PlannedDirectCall(_, _, _, _),
  )
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
