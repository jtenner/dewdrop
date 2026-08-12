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
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn choose(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  pair.right\n}\nfn choose_gap(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let marker = 0\n  pair.right\n}\nfn effect() -> I32 {\n  1 / 0\n}\nfn choose_effect(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let marker = effect()\n  pair.right\n}\npub fn main() -> I32 {\n  choose(1, 2) + choose_gap(3, 4)\n}\n",
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
    is PlannedElidedLetItem(_),
  )
  let choose_effect = collected.lookup_value("choose_effect").unwrap()
  let effect_source_body = collected.body_of(choose_effect).unwrap()
  let effect_body = optimized.modules[0].bodies[
    semantic_id_local(effect_source_body.id)
  ]
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
          "main.dew", b"enum Maybe {\n  Some(I32)\n  None\n}\nstruct Token {\n  value: I32\n}\nenum TokenMaybe {\n  Some(Token)\n  None\n}\nenum RecordMaybe {\n  Some {\n    left: I32\n    right: I32\n  }\n  None\n}\nfn project(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\nfn project_ref(value: Token) -> Token {\n  match TokenMaybe::Some(value) {\n    TokenMaybe::Some(item) => item\n    TokenMaybe::None => Token {\n      value: 0\n    }\n  }\n}\nfn project_local(value: I32) -> I32 {\n  let maybe = Maybe::Some(value)\n  match maybe {\n    Maybe::Some(item) => item\n    Maybe::None => 0\n  }\n}\nfn project_struct(left: I32, right: I32) -> I32 {\n  match (RecordMaybe::Some {\n    left: left\n    right: right\n  }) {\n    RecordMaybe::Some {\n      left\n      right\n    } => right\n    RecordMaybe::None => 0\n  }\n}\nfn reordered(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    Maybe::None => 0\n    Maybe::Some(item) => item\n  }\n}\nfn wildcard(value: I32) -> I32 {\n  match Maybe::Some(value) {\n    _ => 0\n    Maybe::Some(item) => item\n  }\n}\npub fn main() -> I32 {\n  project(5) + project_local(5) + project_struct(1, 10) + project_ref(Token {\n    value: 22\n  }).value + reordered(1) + wildcard(1)\n}\n",
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
    for expression in source_body.expressions.start..<(source_body.expressions.start + source_body.expressions.length) {
      match optimized.modules[0].expressions[expression].kind {
        PlannedVariantTupleNew(_, _, _) | PlannedVariantStructNew(_, _, _) =>
          optimized_variants += 1
        _ => ()
      }
      if optimized.modules[0].expressions[expression].kind is PlannedMatchExpression(_, _) {
        optimized_matches += 1
      }
      if optimized.modules[0].expressions[expression].kind is PlannedParameterSelect(_, _) {
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
  for expression in reordered_body.expressions.start..<(reordered_body.expressions.start + reordered_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedVariantTupleNew(_, _, _) {
      reordered_variants += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedMatchExpression(_, _) {
      reordered_matches += 1
    }
  }
  assert_eq(reordered_variants, 0)
  assert_eq(reordered_matches, 0)
  let wildcard = collected.lookup_value("wildcard").unwrap()
  let wildcard_body = collected.body_of(wildcard).unwrap()
  let mut wildcard_variants = 0
  let mut wildcard_matches = 0
  for expression in wildcard_body.expressions.start..<(wildcard_body.expressions.start + wildcard_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedVariantTupleNew(_, _, _) {
      wildcard_variants += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedMatchExpression(_, _) {
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
          "main.dew", b"struct Box {\n  left: I32\n  right: I32\n}\nenum Wrapped {\n  Some(Box)\n  None\n}\nfn nested(left: I32, right: I32) -> I32 {\n  match Wrapped::Some(Box {\n    left: left\n    right: right\n  }) {\n    Wrapped::Some(Box {\n      left\n      right\n    }) => right\n    Wrapped::None => 0\n  }\n}\npub fn main() -> I32 {\n  nested(20, 22)\n}\n",
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
  for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
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
  for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
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
  for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
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
  for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
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
    for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
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
test "single-field reference and generic boxes scalar replace when nonescaping" {
  let program = collect_program_manifest(
    22814UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box<t> {\n  value: t\n}\nfn unbox_text(value: String) -> String {\n  Box {\n    value: value\n  }.value\n}\nfn unbox<t>(value: t) -> t {\n  Box {\n    value: value\n  }.value\n}\nfn retain(value: Box<String>) -> Box<String> {\n  value\n}\nfn retained(value: String) -> String {\n  retain(Box {\n    value: value\n  }).value\n}\npub fn main() -> I32 {\n  let text = unbox_text(\"dew\")\n  unbox(42) + retained(text).byte_length().into()\n}\n",
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
    for expression in source_body.expressions.start..<(source_body.expressions.start + source_body.expressions.length) {
      if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
        optimized_fields += 1
      }
      if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
        optimized_structs += 1
      }
      if optimized.modules[0].expressions[expression].kind is PlannedParameterSelect(_, 0) {
        parameter_selects += 1
      }
      if unoptimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
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
  for expression in retained_body.expressions.start..<(retained_body.expressions.start + retained_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      retained_fields += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
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
          "main.dew", b"struct Quad {\n  first: I32\n  second: I32\n  third: I32\n  fourth: I32\n}\nfn selected(first: I32, second: I32, third: I32, fourth: I32) -> I32 {\n  let quad = Quad {\n    first: first\n    second: second\n    third: third\n    fourth: fourth\n  }\n  quad.first + quad.third\n}\npub fn main() -> I32 {\n  selected(20, 1, 22, 2)\n}\n",
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
  for expression in source_body.expressions.start..<(source_body.expressions.start + source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      structs += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
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
test "sole-use struct fields scalar replace across fresh if joins" {
  let program = collect_program_manifest(
    22813UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn identity(pair: Pair) -> Pair {\n  pair\n}\nfn choose(flag: Bool, left: I32, right: I32) -> I32 {\n  let pair = if flag {\n    Pair {\n      left: left\n      right: right\n    }\n  } else {\n    Pair {\n      left: right\n      right: left\n    }\n  }\n  pair.right\n}\nfn escaping(flag: Bool, left: I32, right: I32) -> I32 {\n  let pair = if flag {\n    Pair {\n      left: left\n      right: right\n    }\n  } else {\n    identity(Pair {\n      left: right\n      right: left\n    })\n  }\n  pair.right\n}\npub fn main() -> I32 {\n  choose(true, 1, 2) + choose(false, 3, 4) + escaping(true, 5, 6)\n}\n",
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
  let choose_body = optimized.modules[0].bodies[
    semantic_id_local(choose_source_body.id)
  ]
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
  for expression in choose_source_body.expressions.start..<(choose_source_body.expressions.start + choose_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      choose_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      choose_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
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
  for expression in escaping_source_body.expressions.start..<(escaping_source_body.expressions.start + escaping_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      escaping_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
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
          "main.dew", b"enum Choice {\n  First\n  Second\n}\nstruct Pair {\n  left: I32\n  right: I32\n}\nfn choose(choice: Choice, left: I32, right: I32) -> I32 {\n  let pair = match choice {\n    Choice::First => Pair {\n      left: left\n      right: right\n    }\n    Choice::Second => Pair {\n      left: right\n      right: left\n    }\n  }\n  pair.right\n}\npub fn main() -> I32 {\n  choose(Choice::First, 1, 2) + choose(Choice::Second, 3, 4)\n}\n",
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
  for expression in source_body.expressions.start..<(source_body.expressions.start + source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      optimized_fields += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      optimized_structs += 1
    }
    if unoptimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
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
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn split(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let first = pair.left\n  let second = pair.right\n  first + second\n}\nfn reversed(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let second = pair.right\n  let first = pair.left\n  first + second\n}\nfn missing(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  let second = pair.right\n  second\n}\npub fn main() -> I32 {\n  split(1, 2) + reversed(3, 4) + missing(5, 6)\n}\n",
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
  let split_body = optimized.modules[0].bodies[
    semantic_id_local(split_source_body.id)
  ]
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
  for expression in split_source_body.expressions.start..<(split_source_body.expressions.start + split_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      split_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      split_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
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
  for expression in reversed_source_body.expressions.start..<(reversed_source_body.expressions.start + reversed_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      reversed_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      reversed_struct_news += 1
    }
  }
  assert_eq(reversed_field_gets, 0)
  assert_eq(reversed_struct_news, 0)
  let missing = collected.lookup_value("missing").unwrap()
  let missing_source_body = collected.body_of(missing).unwrap()
  let mut missing_field_gets = 0
  let mut missing_struct_news = 0
  for expression in missing_source_body.expressions.start..<(missing_source_body.expressions.start + missing_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      missing_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
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
          "main.dew", b"struct Pair {\n  left: I32\n  right: I32\n}\nfn repeated(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  pair.right + pair.right + pair.right\n}\nfn mixed(left: I32, right: I32) -> I32 {\n  let pair = Pair {\n    left: left\n    right: right\n  }\n  pair.left + pair.right\n}\npub fn main() -> I32 {\n  repeated(1, 2) + mixed(3, 4)\n}\n",
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
  let repeated_body = optimized.modules[0].bodies[
    semantic_id_local(repeated_source_body.id)
  ]
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
  for expression in repeated_source_body.expressions.start..<(repeated_source_body.expressions.start + repeated_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      repeated_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      repeated_struct_news += 1
    }
    if unoptimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
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
  for expression in mixed_source_body.expressions.start..<(mixed_source_body.expressions.start + mixed_source_body.expressions.length) {
    if optimized.modules[0].expressions[expression].kind is PlannedFieldGet(_, _) {
      mixed_field_gets += 1
    }
    if optimized.modules[0].expressions[expression].kind is PlannedStructNew(_, _, _) {
      mixed_struct_news += 1
    }
  }
  assert_eq(mixed_field_gets, 0)
  assert_eq(mixed_struct_news, 0)
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
