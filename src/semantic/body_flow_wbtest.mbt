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

///|
test "opaque type coverage requires an unconditional catch-all" {
  let sources = [
    b"fn run<t>(value: t) -> I32 {\n  match value {\n  }\n}\n", b"fn run<t>(value: t) -> I32 {\n  match value {\n    _ if false => 42\n  }\n}\n",
    b"trait Mark {\n}\nfn run(value: Mark) -> I32 {\n  match value {\n    _ if false => 42\n  }\n}\n",
    b"fn run<t>(value: t) -> I32 {\n  while value {\n    _ if false => break 42\n  }\n}\n",
  ]
  for source in sources {
    let (_, _, inferred, flows) = flow_test_module(247UL, source)
    assert_eq(inferred.diagnostics, [])
    assert_eq(flows.diagnostics.length(), 1)
    match flows.diagnostics[0] {
      NonExhaustiveMatch(_, missing, _)
      | NonExhaustiveFunctionalLoop(_, missing, _) => {
        assert_eq(missing.length, 1)
        assert_eq(flows.missing_cases[missing.start], MissingCatchAllCase)
      }
      _ => fail("expected missing opaque catch-all")
    }
  }
}

///|
test "opaque type coverage accepts unconditional catch-all patterns" {
  let sources = [
    b"fn run<t>(value: t) -> I32 {\n  match value {\n    _ => 42\n  }\n}\n", b"trait Mark {\n}\nfn run(value: Mark) -> I32 {\n  match value {\n    _ => 42\n  }\n}\n",
    b"fn run<t>(value: t) -> I32 {\n  while value {\n    _ => break 42\n  }\n}\n",
  ]
  for source in sources {
    let (_, _, inferred, flows) = flow_test_module(248UL, source)
    assert_eq(inferred.diagnostics, [])
    assert_eq(flows.diagnostics, [])
  }
}

///|
test "nested pattern matrix nested-complete" {
  let (_, _, inferred, flows) = flow_test_module(
    260UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box {\n  Wrap(Bit)\n}\nfn read(value: Box) -> I32 {\n  match value {\n    Wrap(Zero) => 0\n    Wrap(One) => 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix nested-incomplete" {
  let (_, _, inferred, flows) = flow_test_module(
    261UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box {\n  Wrap(Bit)\n}\nfn read(value: Box) -> I32 {\n  match value {\n    Wrap(Zero) => 0\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "nested pattern matrix nested-guarded" {
  let (_, _, inferred, flows) = flow_test_module(
    262UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box {\n  Wrap(Bit)\n}\nfn read(value: Box) -> I32 {\n  match value {\n    Wrap(Zero) => 0\n    Wrap(One) if true => 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "nested pattern matrix tuple-bool-complete" {
  let (_, _, inferred, flows) = flow_test_module(
    263UL, b"fn read(value: (Bool, Bool)) -> I32 {\n  match value {\n    (true, _) => 0\n    (false, true) => 1\n    (false, false) => 2\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix tuple-bool-incomplete" {
  let (_, _, inferred, flows) = flow_test_module(
    264UL, b"fn read(value: (Bool, Bool)) -> I32 {\n  match value {\n    (true, _) => 0\n    (false, true) => 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "nested pattern matrix sum-of-products-complete" {
  let (_, _, inferred, flows) = flow_test_module(
    265UL, b"enum Value {\n  Empty\n  Pair(Bool, Bool)\n}\nfn read(value: Value) -> I32 {\n  match value {\n    Empty => 0\n    Pair(true, _) => 1\n    Pair(false, true) => 2\n    Pair(false, false) => 3\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix struct-bool-complete" {
  let (_, _, inferred, flows) = flow_test_module(
    266UL, b"struct Pair {\n  a: Bool\n  b: Bool\n}\nfn read(value: Pair) -> I32 {\n  match value {\n    Pair {\n      a: true\n      b: _\n    } => 0\n    Pair {\n      b: true\n      a: false\n    } => 1\n    Pair {\n      a: false\n      b: false\n    } => 2\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix generic-enum" {
  let (_, _, inferred, flows) = flow_test_module(
    270UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box<t> {\n  Wrap(t)\n}\nfn read(value: Box<Bit>) -> I32 {\n  match value {\n    Wrap(Zero) => 0\n    Wrap(One) => 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix alternatives" {
  let (_, _, inferred, flows) = flow_test_module(
    271UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box {\n  Wrap(Bit)\n}\nfn read(value: Box) -> I32 {\n  match value {\n    Wrap(Zero), Wrap(One) => 42\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix functional-loop" {
  let (_, _, inferred, flows) = flow_test_module(
    272UL, b"enum Bit {\n  Zero\n  One\n}\nenum Box {\n  Wrap(Bit)\n}\nfn read(value: Box) -> I32 {\n  while value {\n    Wrap(Zero) => break 0\n    Wrap(One) => break 1\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "nested pattern matrix reports its depth budget" {
  let (collected, resolved, inferred, flows) = flow_test_module(
    273UL, b"fn read(value: (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, (Bool, Bool)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) -> I32 {\n  match value {\n    (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, true))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) => 1\n    (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, (_, false))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) => 2\n  }\n}\n",
  )
  assert_eq(collected.diagnostics, [])
  assert_eq(resolved.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_eq(flows.missing_cases, [])
  match flows.diagnostics[0] {
    PatternCoverageBudgetExceeded(_, cells, depth, _) => {
      assert_eq(cells, 65536)
      assert_eq(depth, 64)
    }
    _ => fail("expected a visible coverage budget error")
  }
}

///|
test "matrix variant collection charges before materialization" {
  let (collected, resolved, inferred, _) = flow_test_module(
    274UL, b"enum Noise {\n  N0\n  N1\n  N2\n  N3\n  N4\n  N5\n  N6\n  N7\n  N8\n  N9\n  N10\n  N11\n  N12\n  N13\n  N14\n  N15\n  N16\n  N17\n  N18\n  N19\n  N20\n  N21\n  N22\n  N23\n  N24\n  N25\n  N26\n  N27\n  N28\n  N29\n  N30\n  N31\n}\nenum Bit {\n  Zero\n  One\n}\nfn read(value: Bit) -> I32 {\n  match value {\n    Zero => 0\n    One => 1\n  }\n}\n",
  )
  let analyzer = BodyFlowAnalyzer::new(
    collected,
    resolved,
    inferred,
    None,
    collected.bodies[0],
    flow_variant_spans(collected),
    [],
  )
  let declaration = collected.lookup_type("Bit").unwrap()
  let limited : PatternCoverageWork = { remaining: 2, exhausted: false, }
  assert_true(analyzer.matrix_enum_variants(declaration, limited) is None)
  assert_true(limited.exhausted)
  assert_false(limited.spend(0))
  let sufficient : PatternCoverageWork = { remaining: 3, exhausted: false, }
  let variants = analyzer.matrix_enum_variants(declaration, sufficient).unwrap()
  assert_eq(variants.length(), 2)
  assert_eq(sufficient.remaining, 0)
  assert_false(sufficient.exhausted)
}

///|
test "matrix stability mutable guard" {
  let (_, _, inferred, flows) = flow_test_module(
    280UL, b"struct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    _ if false => 20\n    Flag {\n      value: false\n    } => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "matrix stability immutable guard" {
  let (_, _, inferred, flows) = flow_test_module(
    281UL, b"struct Flag {\n  value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    _ if false => 20\n    Flag {\n      value: false\n    } => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "matrix stability mutable without guard" {
  let (_, _, inferred, flows) = flow_test_module(
    282UL, b"struct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    Flag {\n      value: false\n    } => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "matrix stability mutable guard fallback" {
  let (_, _, inferred, flows) = flow_test_module(
    283UL, b"struct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    _ if false => 20\n    Flag {\n      value: false\n    } => 30\n    _ => 40\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "matrix stability nested mutable enum guard" {
  let (_, _, inferred, flows) = flow_test_module(
    284UL, b"struct Flag {\n  mut value: Bool\n}\nenum Box {\n  Wrap(Flag)\n}\nfn read(flag: Flag) -> I32 {\n  match Wrap(flag) {\n    Wrap(Flag {\n      value: true\n    }) => 10\n    _ if false => 20\n    Wrap(Flag {\n      value: false\n    }) => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "matrix stability nested mutable product guard" {
  let (_, _, inferred, flows) = flow_test_module(
    285UL, b"struct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  match (flag, true) {\n    (Flag {\n      value: true\n    }, _) => 10\n    _ if false => 20\n    (Flag {\n      value: false\n    }, _) => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "matrix stability nested mutable immutable field guard" {
  let (_, _, inferred, flows) = flow_test_module(
    286UL, b"struct Flag {\n  mut value: Bool\n}\nstruct Holder {\n  flag: Flag\n}\nfn read(flag: Flag) -> I32 {\n  match Holder::{\n    flag: flag\n  } {\n    Holder {\n      flag: Flag {\n      value: true\n    }\n    } => 10\n    _ if false => 20\n    Holder {\n      flag: Flag {\n      value: false\n    }\n    } => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "matrix stability mutable wildcard stable field guard" {
  let (_, _, inferred, flows) = flow_test_module(
    287UL, b"struct Pair {\n  mut changing: Bool\n  stable: Bool\n}\nfn read(value: Pair) -> I32 {\n  match value {\n    Pair {\n      changing: _\n      stable: true\n    } => 10\n    _ if false => 20\n    Pair {\n      changing: _\n      stable: false\n    } => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics, [])
}

///|
test "matrix stability imported mutable guard" {
  let (program, frozen, imports, _, inferred) = imported_semantic_program(
    b"open app.library\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    _ if false => 20\n    Flag {\n      value: false\n    } => 30\n  }\n}\n",
    b"pub struct Flag {\n  mut value: Bool\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  let flows = analyze_module_flows_with_imports(
    program.modules[0],
    frozen.interfaces[0].resolved_types,
    inferred,
    imports,
  )
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}

///|
test "matrix stability imported immutable guard" {
  let (program, frozen, imports, _, inferred) = imported_semantic_program(
    b"open app.library\nfn read(flag: Flag) -> I32 {\n  match flag {\n    Flag {\n      value: true\n    } => 10\n    _ if false => 20\n    Flag {\n      value: false\n    } => 30\n  }\n}\n",
    b"pub struct Flag {\n  value: Bool\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  let flows = analyze_module_flows_with_imports(
    program.modules[0],
    frozen.interfaces[0].resolved_types,
    inferred,
    imports,
  )
  assert_eq(flows.diagnostics, [])
}

///|
test "matrix stability mutable functional loop guard" {
  let (_, _, inferred, flows) = flow_test_module(
    292UL, b"struct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag) -> I32 {\n  while flag {\n    Flag {\n      value: true\n    } => break 10\n    _ if false => break 20\n    Flag {\n      value: false\n    } => break 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveFunctionalLoop(_, _, _))
}

///|
test "matrix stability mutable selected string comparison" {
  let (_, _, inferred, flows) = flow_test_module(
    293UL, b"trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nimpl Eq for String {\n  fn eq(self, right: String) -> Bool {\n    false\n  }\n}\nstruct Flag {\n  mut value: Bool\n}\nfn read(flag: Flag, text: String) -> I32 {\n  match (flag, text) {\n    (Flag {\n      value: true\n    }, _) => 10\n    (_, \"x\") => 20\n    (Flag {\n      value: false\n    }, _) => 30\n  }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_eq(flows.diagnostics.length(), 1)
  assert_true(flows.diagnostics[0] is NonExhaustiveMatch(_, _, _))
}
