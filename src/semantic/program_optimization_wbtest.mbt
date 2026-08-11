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
