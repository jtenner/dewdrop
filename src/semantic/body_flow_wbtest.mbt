///|
fn flow_test_module(
  module_id : UInt64,
  source : Bytes,
) -> (
  CollectedModule,
  ResolvedModuleTypes,
  InferredModuleBodies,
  AnalyzedModuleFlows,
) {
  let collected = collect_bytes(module_id, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let flows = analyze_module_flows(collected, resolved, inferred)
  (collected, resolved, inferred, flows)
}

///|
fn first_match_expression(collected : CollectedModule) -> ExprId {
  for index, expression in collected.expressions {
    match expression {
      HirMatchExpr(_, _, _) => return index
      _ => ()
    }
  }
  abort("expected match expression")
}

///|
test "enum match exhaustiveness records no missing cases" {
  let (_, _, _, flows) = flow_test_module(
    201UL, b"enum Maybe {\n  None\n  Some(I32)\n}\nfn read(value: Maybe) -> I32 {\n  match value {\n    None => 0\n    Some(_) => 1\n  }\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
}

///|
test "non-exhaustive enum match records stable missing variants" {
  let (collected, _, _, flows) = flow_test_module(
    202UL, b"enum Maybe {\n  None\n  Some(I32)\n}\nfn read(value: Maybe) -> I32 {\n  match value {\n    None => 0\n  }\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 1)
  match flows.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) => {
      assert_eq(missing.length, 1)
      match flows.missing_cases[missing.start] {
        MissingVariantCase(variant) =>
          assert_eq(variant, collected.variants[1].id)
        _ => fail("expected missing Some variant")
      }
    }
    _ => fail("expected non-exhaustive match")
  }
}

///|
test "guarded arms do not contribute unconditional coverage" {
  let (_, _, _, flows) = flow_test_module(
    203UL, b"enum Flag {\n  On\n  Off\n}\nfn read(value: Flag) -> I32 {\n  match value {\n    On if true => 1\n    Off => 0\n  }\n}\n",
  )
  match flows.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) => {
      assert_eq(missing.length, 1)
      match flows.missing_cases[missing.start] {
        MissingVariantCase(_) => ()
        _ => fail("expected missing guarded variant")
      }
    }
    _ => fail("expected guarded non-exhaustiveness")
  }
}

///|
test "redundant enum and catch-all arms are diagnosed" {
  let (_, _, _, flows) = flow_test_module(
    204UL, b"enum Flag {\n  On\n  Off\n}\nfn read(value: Flag) -> I32 {\n  match value {\n    On => 1\n    On => 2\n    _ => 0\n    Off => 3\n  }\n}\n",
  )
  let mut redundant = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      RedundantPatternArm(_, _) => redundant += 1
      _ => ()
    }
  }
  assert_eq(redundant, 2)
}

///|
test "complete constructor coverage makes a later catch-all redundant" {
  let (_, _, _, flows) = flow_test_module(
    211UL, b"enum Flag {\n  On\n  Off\n}\nfn read(value: Flag) -> I32 {\n  match value {\n    On => 1\n    Off => 0\n    _ => 2\n  }\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 1)
  match flows.diagnostics[0] {
    RedundantPatternArm(_, _) => ()
    _ => fail("expected redundant catch-all")
  }
}

///|
test "pattern alternatives contribute independent constructor coverage" {
  let (_, _, _, flows) = flow_test_module(
    212UL, b"enum Flag {\n  On\n  Off\n}\nfn read(value: Flag) -> I32 {\n  match value {\n    On, Off => 1\n  }\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
}

///|
test "Bool matches require both literal cases or a catch-all" {
  let (_, _, _, complete) = flow_test_module(
    205UL, b"fn complete(value: Bool) -> I32 {\n  match value {\n    true => 1\n    false => 0\n  }\n}\n",
  )
  assert_eq(complete.diagnostics.length(), 0)
  let (_, _, _, incomplete) = flow_test_module(
    206UL, b"fn incomplete(value: Bool) -> I32 {\n  match value {\n    true => 1\n  }\n}\n",
  )
  match incomplete.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) =>
      match incomplete.missing_cases[missing.start] {
        MissingBoolCase(false) => ()
        _ => fail("expected missing false case")
      }
    _ => fail("expected incomplete Bool match")
  }
}

///|
test "refutable variant payloads do not cover the whole variant" {
  let (_, _, _, flows) = flow_test_module(
    207UL, b"enum Maybe {\n  None\n  Some(I32)\n}\nfn read(value: Maybe) -> I32 {\n  match value {\n    None => 0\n    Some(0) => 1\n  }\n}\n",
  )
  match flows.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) =>
      match flows.missing_cases[missing.start] {
        MissingVariantCase(_) => ()
        _ => fail("expected incompletely covered Some")
      }
    _ => fail("expected non-exhaustive payload match")
  }
}

///|
test "irrefutable nominal struct patterns cover their value type" {
  let (_, _, _, flows) = flow_test_module(
    216UL, b"struct Pair {\n  first: I32\n  second: Bool\n}\nfn read(pair: Pair) -> I32 {\n  match pair {\n    Pair {\n      first\n      second: _\n    } => first\n  }\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
}

///|
test "constructor errors suppress dependent exhaustiveness diagnostics" {
  let (_, _, inferred, flows) = flow_test_module(
    217UL, b"enum Flag {\n  On\n  Off\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Missing(value) => 0\n  }\n}\n",
  )
  assert_true(inferred.diagnostics.length() > 0)
  assert_eq(flows.diagnostics.length(), 0)
}

///|
test "nested refutable enum payloads do not cover an outer variant" {
  let (_, _, _, flows) = flow_test_module(
    219UL, b"enum Inner {\n  A\n  B\n}\nenum Outer {\n  Wrap(Inner)\n}\nfn read(value: Outer) -> I32 {\n  match value {\n    Wrap(A) => 0\n  }\n}\n",
  )
  match flows.diagnostics[0] {
    NonExhaustiveMatch(_, missing, _) => {
      assert_eq(missing.length, 1)
      match flows.missing_cases[missing.start] {
        MissingVariantCase(_) => ()
        _ => fail("expected missing Wrap coverage")
      }
    }
    _ => fail("expected nested payload non-exhaustiveness")
  }
}

///|
test "functional loops use the same exhaustiveness analysis" {
  let (_, _, _, flows) = flow_test_module(
    208UL, b"enum State {\n  Stop\n  Next(I32)\n}\nfn run(state: State) -> I32 {\n  while state {\n    Stop => break 0\n  }\n}\n",
  )
  let mut found = false
  for diagnostic in flows.diagnostics {
    match diagnostic {
      NonExhaustiveFunctionalLoop(_, missing, _) => {
        found = true
        assert_eq(missing.length, 1)
      }
      _ => ()
    }
  }
  assert_true(found)
}

///|
test "flow summaries diagnose unreachable block items" {
  let (collected, _, _, flows) = flow_test_module(
    209UL, b"fn stop() -> I32 {\n  return 1\n  2\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 1)
  match flows.diagnostics[0] {
    UnreachableBlockItem(_, index, _) => assert_eq(index, 1)
    _ => fail("expected unreachable item")
  }
  let body_flow = flows.bodies[0].flow
  assert_true(body_flow.may_return())
  assert_false(body_flow.may_fall_through())
  let root = match collected.bodies[0].root {
    BlockBodyRoot(block) => block
    _ => abort("expected block body")
  }
  assert_true(flows.block_flows[root].may_return())
}

///|
test "if expressions with returning branches make later items unreachable" {
  let (_, _, _, flows) = flow_test_module(
    213UL, b"fn stop(flag: Bool) -> I32 {\n  if flag {\n    return 1\n  } else {\n    return 2\n  }\n  3\n}\n",
  )
  let mut unreachable_count = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      UnreachableBlockItem(_, _, _) => unreachable_count += 1
      _ => ()
    }
  }
  assert_eq(unreachable_count, 1)
  assert_true(flows.bodies[0].flow.may_return())
  assert_false(flows.bodies[0].flow.may_fall_through())
}

///|
test "static predicate call in if keeps the ordinary completion path" {
  let (_, _, _, flows) = flow_test_module(
    221UL, b"fn predicate(flag: Bool) -> Bool {\n  flag\n}\nfn run(flag: Bool) -> I32 {\n  if predicate(flag) {\n    return 1\n  }\n  2\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
  let body_flow = flows.bodies[1].flow
  assert_true(body_flow.may_return())
  assert_true(body_flow.may_fall_through())
}

///|
test "static predicate call in match keeps the ordinary completion path" {
  let (_, _, _, flows) = flow_test_module(
    222UL, b"fn predicate(flag: Bool) -> Bool {\n  flag\n}\nfn run(flag: Bool) -> I32 {\n  match predicate(flag) {\n    true => return 1\n    false => 0\n  }\n  2\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
  let body_flow = flows.bodies[1].flow
  assert_true(body_flow.may_return())
  assert_true(body_flow.may_fall_through())
}

///|
test "nested static call argument keeps the ordinary completion path" {
  let (_, _, _, flows) = flow_test_module(
    223UL, b"fn equal(left: U32, right: U32) -> Bool {\n  left == right\n}\nfn require(condition: Bool) -> Unit {\n  let _condition = condition\n}\nfn run(value: U32) -> Unit {\n  require(!equal(value, 4294967295u32))\n  let _after = value\n}\n",
  )
  assert_eq(flows.diagnostics.length(), 0)
  let body_flow = flows.bodies[2].flow
  assert_true(body_flow.may_fall_through())
}

///|
test "functional-loop summaries consume break and continue outcomes" {
  let (collected, _, _, flows) = flow_test_module(
    214UL, b"enum State {\n  Stop\n  Next(I32)\n}\nfn run(state: State) -> I32 {\n  while state {\n    Stop => break 0\n    Next(value) => continue state\n  }\n}\n",
  )
  let mut loop_expression = -1
  for index, expression in collected.expressions {
    match expression {
      HirWhileExpr(_, _, _) => loop_expression = index
      _ => ()
    }
  }
  let summary = flows.expression_flows[loop_expression]
  assert_true(summary.may_fall_through())
  assert_true(summary.may_diverge())
  assert_false(summary.may_break())
  assert_false(summary.may_continue())
}

///|
test "short-circuit operators retain skipped fallthrough paths" {
  let (collected, _, _, flows) = flow_test_module(
    220UL, b"fn run() -> I32 {\n  while true {\n    _ => true || break 1\n  }\n}\n",
  )
  let mut while_expression = -1
  for index, expression in collected.expressions {
    match expression {
      HirWhileExpr(_, _, _) => while_expression = index
      _ => ()
    }
  }
  let summary = flows.expression_flows[while_expression]
  assert_true(summary.may_fall_through())
  assert_true(summary.may_diverge())
  let mut fallthrough_count = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      FunctionalLoopArmFallsThrough(_, _) => fallthrough_count += 1
      _ => ()
    }
  }
  assert_eq(fallthrough_count, 1)
}

///|
test "Never-returning calls terminate block flow" {
  let (_, _, _, flows) = flow_test_module(
    218UL, b"fn stop() -> Never {\n  stop()\n}\nfn use() -> I32 {\n  stop()\n  1\n}\n",
  )
  let second = flows.bodies[1].flow
  assert_true(second.may_diverge())
  assert_false(second.may_fall_through())
  let mut unreachable_count = 0
  for diagnostic in flows.diagnostics {
    match diagnostic {
      UnreachableBlockItem(_, _, _) => unreachable_count += 1
      _ => ()
    }
  }
  assert_eq(unreachable_count, 1)
}

///|
test "flow body jobs merge deterministically in body order" {
  let collected = collect_bytes(
    215UL, b"enum Flag {\n  On\n  Off\n}\nfn first(value: Flag) -> I32 {\n  match value {\n    On => 1\n  }\n}\nfn second() -> I32 {\n  return 2\n  3\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let forward = analyze_module_flows_in_order(collected, resolved, inferred, [
    0, 1,
  ])
  let reverse = analyze_module_flows_in_order(collected, resolved, inferred, [
    1, 0,
  ])
  assert_eq(forward, reverse)
}

///|
test "match summaries retain return and ordinary completion paths" {
  let (collected, _, _, flows) = flow_test_module(
    210UL, b"fn choose(value: Bool) -> I32 {\n  match value {\n    true => {\n      return 1\n    }\n    false => 0\n  }\n}\n",
  )
  let expression = first_match_expression(collected)
  let flow = flows.expression_flows[expression]
  assert_true(flow.may_return())
  assert_true(flow.may_fall_through())
}

///|
test "nested single-variant payloads cover their outer variant" {
  let (_, _, inferred, flows) = flow_test_module(
    246UL, b"enum Leaf {\n  Value(I32)\n}\nenum Middle {\n  Wrap(Leaf)\n}\nenum Outer {\n  Wrap(Middle)\n}\nfn read(value: Outer) -> I32 {\n  match value {\n    Outer::Wrap(Middle::Wrap(Leaf::Value(result))) => result\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}
