///|
test "body names resolve parameters sequential lets shadowing and module values" {
  let collected = collect_bytes(
    60UL, b"let answer = 1\nfn choose(value: I32) -> I32 {\n  let first = value\n  let mut value = first\n  value + answer\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let body = collected.bodies[1]
  let info = names.body(body.id).unwrap()
  assert_eq(info.locals.length, 3)
  assert_eq(names.parameter_locals[0], 0)
  let root = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected function block")
  }
  let items = collected.blocks[root].items
  let first_initializer = match collected.block_items[items.start] {
    HirLetItem(false, _, _, value, _) => value
    _ => fail("expected first let")
  }
  assert_eq(
    names.expression_references[first_initializer],
    LocalNameReference(0),
  )
  assert_eq(names.block_item_locals[items.start], 1)
  let shadow_initializer = match collected.block_items[items.start + 1] {
    HirLetItem(true, _, _, value, _) => value
    _ => fail("expected mutable shadow let")
  }
  assert_eq(
    names.expression_references[shadow_initializer],
    LocalNameReference(1),
  )
  assert_eq(names.block_item_locals[items.start + 1], 2)
  let final_expression = match collected.block_items[items.start + 2] {
    HirExpressionItem(value, _) => value
    _ => fail("expected final expression")
  }
  match collected.expressions[final_expression] {
    HirBinaryExpr(HirAdd, local_value, module_value, _) => {
      assert_eq(names.expression_references[local_value], LocalNameReference(2))
      let answer = collected.find_name("answer").unwrap()
      assert_eq(
        names.expression_references[module_value],
        ModuleValueNameReference(answer),
      )
    }
    _ => fail("expected final addition")
  }
  assert_eq(names.local_info(body.id, 2).unwrap().mutable_, true)
}

///|
test "body names diagnose unknown values without hiding resolved module names" {
  let collected = collect_bytes(
    61UL, b"let answer = 1\nfn use() -> I32 {\n  answer + missing\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 1)
  match names.diagnostics[0] {
    UnknownValueName(name, _, _) => assert_eq(collected.name(name), "missing")
    _ => fail("expected unknown value diagnostic")
  }
  let body = collected.bodies[1]
  let root = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected function block")
  }
  let expression = match
    collected.block_items[collected.blocks[root].items.start] {
    HirExpressionItem(value, _) => value
    _ => fail("expected expression item")
  }
  match collected.expressions[expression] {
    HirBinaryExpr(_, answer, missing, _) => {
      assert_eq(
        names.expression_references[answer],
        ModuleValueNameReference(collected.find_name("answer").unwrap()),
      )
      assert_eq(names.expression_references[missing], ErrorNameReference)
    }
    _ => fail("expected binary expression")
  }
}

///|
test "unit variant names resolve as deferred constructor candidates" {
  let collected = collect_bytes(
    70UL, b"enum State {\n  Done\n}\nfn done() -> State {\n  Done\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let root = match body.root {
    BlockBodyRoot(block) =>
      match collected.block_items[collected.blocks[block].items.start] {
        HirExpressionItem(expression, _) => expression
        _ => fail("expected unit variant expression")
      }
    _ => fail("expected function block")
  }
  assert_eq(
    names.expression_references[root],
    VariantNameReference(collected.find_name("Done").unwrap()),
  )
}

///|
test "qualified and unqualified constructor roots retain namespace candidates" {
  let collected = collect_bytes(
    62UL, b"enum Message {\n  Data(I32)\n}\nfn qualified(value: I32) -> Message {\n  Message::Data(value)\n}\nfn inferred(value: I32) -> Message {\n  Data(value)\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let message_declaration = collected.declarations[0].id
  let qualified_body = collected.bodies[0]
  let qualified_root = match qualified_body.root {
    BlockBodyRoot(block) =>
      match collected.block_items[collected.blocks[block].items.start] {
        HirExpressionItem(expression, _) => expression
        _ => fail("expected qualified expression")
      }
    _ => fail("expected block body")
  }
  match collected.expressions[qualified_root] {
    HirCallExpr(target, _, _) =>
      match collected.expressions[target] {
        HirQualifiedExpr(base, _, _) =>
          assert_eq(
            names.expression_references[base],
            ModuleTypeNameReference(message_declaration),
          )
        _ => fail("expected qualified call target")
      }
    _ => fail("expected call expression")
  }
  let inferred_body = collected.bodies[1]
  let inferred_root = match inferred_body.root {
    BlockBodyRoot(block) =>
      match collected.block_items[collected.blocks[block].items.start] {
        HirExpressionItem(expression, _) => expression
        _ => fail("expected inferred expression")
      }
    _ => fail("expected block body")
  }
  match collected.expressions[inferred_root] {
    HirCallExpr(target, _, _) =>
      assert_eq(
        names.expression_references[target],
        VariantNameReference(collected.find_name("Data").unwrap()),
      )
    _ => fail("expected variant call")
  }
}

///|
fn tuple_pattern_first_argument(
  collected : CollectedModule,
  pattern : PatternId,
) -> PatternId {
  match collected.patterns[pattern] {
    HirTuplePattern(_, arguments, _) =>
      collected.pattern_children[arguments.start]
    _ => abort("expected tuple pattern")
  }
}

///|
fn qualified_pattern_root(
  collected : CollectedModule,
  pattern : PatternId,
) -> PatternId {
  let base = match collected.patterns[pattern] {
    HirTuplePattern(base, _, _) | HirStructPattern(base, _, _, _, _) => base
    _ => pattern
  }
  match collected.patterns[base] {
    HirQualifiedPattern(root, _, _) => root
    _ => base
  }
}

///|
test "alternative pattern bindings share one local in guards and bodies" {
  let collected = collect_bytes(
    63UL, b"enum State {\n  A(I32)\n  B(I32)\n}\nfn read(state: State) -> I32 {\n  match state {\n    State::A(value), State::B(value) if value > 0 => value\n    _ => 0\n  }\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let info = names.body(body.id).unwrap()
  assert_eq(info.locals.length, 2)
  let root_block = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected function block")
  }
  let match_expression = match
    collected.block_items[collected.blocks[root_block].items.start] {
    HirExpressionItem(expression, _) => expression
    _ => fail("expected match expression")
  }
  let arms = match collected.expressions[match_expression] {
    HirMatchExpr(_, arms, _) => arms
    _ => fail("expected match")
  }
  let first_arm = collected.pattern_arms[collected.arm_children[arms.start]]
  let (first_pattern, second_pattern) = match
    collected.patterns[first_arm.pattern] {
    HirAlternativePattern(first, remaining, _) =>
      (first, collected.pattern_children[remaining.start])
    _ => fail("expected alternatives")
  }
  let first_binding = tuple_pattern_first_argument(collected, first_pattern)
  let second_binding = tuple_pattern_first_argument(collected, second_pattern)
  assert_eq(names.pattern_references[first_binding], PatternBindingReference(1))
  assert_eq(
    names.pattern_references[second_binding],
    PatternBindingReference(1),
  )
  let state_root = qualified_pattern_root(collected, first_pattern)
  assert_eq(
    names.pattern_references[state_root],
    PatternTypeReference(collected.declarations[0].id),
  )
  match collected.expressions[first_arm.guard_condition] {
    HirBinaryExpr(_, guard_name, _, _) =>
      assert_eq(names.expression_references[guard_name], LocalNameReference(1))
    _ => fail("expected guard comparison")
  }
  assert_eq(names.expression_references[first_arm.body], LocalNameReference(1))
}

///|
test "alternative sets and duplicate pattern bindings receive diagnostics" {
  let collected = collect_bytes(
    64UL, b"enum State {\n  A(I32, I32)\n  B(I32)\n}\nfn invalid(state: State) -> I32 {\n  match state {\n    A(left, left) => 0\n    A(left, left), B(right) => 1\n    _ => 2\n  }\n}\n",
  )
  let names = resolve_module_names(collected)
  let mut duplicate_count = 0
  let mut missing_count = 0
  let mut extra_count = 0
  for diagnostic in names.diagnostics {
    match diagnostic {
      DuplicatePatternBinding(_, _, _) => duplicate_count += 1
      AlternativeMissingBinding(_, _, _) => missing_count += 1
      AlternativeExtraBinding(_, _, _) => extra_count += 1
      _ => ()
    }
  }
  assert_eq(duplicate_count, 2)
  assert_eq(missing_count, 1)
  assert_eq(extra_count, 1)
}

///|
test "pattern bindings are arm-local and do not leak" {
  let collected = collect_bytes(
    65UL, b"enum State {\n  A(I32)\n}\nfn invalid(state: State) -> I32 {\n  match state {\n    A(value) => value\n  }\n  value\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 1)
  match names.diagnostics[0] {
    UnknownValueName(name, _, _) => assert_eq(collected.name(name), "value")
    _ => fail("expected leaked binding diagnostic")
  }
}

///|
test "nested functional loops resolve nearest transfer controls" {
  let collected = collect_bytes(
    66UL, b"enum State {\n  Next(I32)\n  Done(I32)\n}\nfn run(initial: State) -> I32 {\n  while initial {\n    Next(value) => {\n      let nested = while value {\n        _ => break value\n      }\n      continue nested\n    }\n    Done(value) => break value\n  }\n}\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let info = names.body(body.id).unwrap()
  assert_eq(info.controls.length, 2)
  let mut outer_transfers = 0
  let mut inner_transfers = 0
  let mut while_count = 0
  let mut saw_outer_control = false
  let mut saw_inner_control = false
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirWhileExpr(_, _, _) => {
        let control = names.expression_controls[expression]
        if control == 0 {
          saw_outer_control = true
        } else if control == 1 {
          saw_inner_control = true
        } else {
          fail("unexpected while control")
        }
        while_count += 1
      }
      HirBreakExpr(_, _) | HirContinueExpr(_, _) => {
        let target = names.transfer_targets[expression]
        if target == 0 {
          outer_transfers += 1
        } else if target == 1 {
          inner_transfers += 1
        } else {
          fail("unexpected transfer target")
        }
      }
      _ => ()
    }
  }
  assert_eq(while_count, 2)
  assert_true(saw_outer_control)
  assert_true(saw_inner_control)
  assert_eq(outer_transfers, 2)
  assert_eq(inner_transfers, 1)
}

///|
test "unknown qualified and pattern constructors remain diagnostic" {
  let collected = collect_bytes(
    71UL, b"fn invalid(value: I32) -> I32 {\n  let missing_alias = @operation\n  Missing::call(value)\n  match value {\n    Missing(bound) => bound\n  }\n}\n",
  )
  let names = resolve_module_names(collected)
  let mut qualified_count = 0
  let mut pattern_count = 0
  for diagnostic in names.diagnostics {
    match diagnostic {
      UnknownQualifiedRoot(name, _, _) => {
        assert_eq(collected.name(name), "Missing")
        qualified_count += 1
      }
      UnknownPatternConstructor(name, _, _) => {
        assert_eq(collected.name(name), "Missing")
        pattern_count += 1
      }
      _ => ()
    }
  }
  assert_eq(qualified_count, 1)
  assert_eq(pattern_count, 1)
  let alias_name = collected.find_name("operation").unwrap()
  let mut found_alias_diagnostic = false
  for
    expression in collected.bodies[0].expressions.start..<(collected.bodies[0].expressions.start +
    collected.bodies[0].expressions.length) {
    if names.expression_references[expression] == ErrorNameReference {
      for diagnostic in names.diagnostics {
        if diagnostic is UnknownImportAlias(name, _, _) && name == alias_name {
          found_alias_diagnostic = true
        }
      }
    }
  }
  assert_true(found_alias_diagnostic)
}

///|
test "out-of-loop break and continue remain visible diagnostics" {
  let collected = collect_bytes(
    67UL, b"let stopped = break 1\nlet continued = continue 2\n",
  )
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 2)
  let mut break_count = 0
  let mut continue_count = 0
  for diagnostic in names.diagnostics {
    match diagnostic {
      BreakOutsideLoop(_, _) => break_count += 1
      ContinueOutsideLoop(_, _) => continue_count += 1
      _ => ()
    }
  }
  assert_eq(break_count, 1)
  assert_eq(continue_count, 1)
}

///|
test "body job merge is independent of execution order" {
  let collected = collect_bytes(
    68UL, b"let first = missing_first\nfn second(value: I32) -> I32 {\n  let next = value\n  next\n}\nlet third = missing_third\n",
  )
  let forward = resolve_module_names_in_order(collected, [0, 1, 2])
  let reverse = resolve_module_names_in_order(collected, [2, 1, 0])
  assert_eq(forward, reverse)
}

///|
fn wide_alternative_pattern(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 96 + 256)
  output.write_string_utf8("enum Record {\n  A {\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("  }\n  B {\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8(
    "  }\n}\nfn read(record: Record) -> I32 {\n  match record {\n    A {\n",
  )
  for index in 0..<field_count {
    output.write_string_utf8("      field_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    }, B {\n")
  for index in 0..<field_count {
    output.write_string_utf8("      field_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    } => field_")
  output.write_string_utf8((field_count - 1).to_string())
  output.write_string_utf8("\n  }\n}\n")
  output.to_bytes()
}

///|
test "wide alternative binding lookup uses the large-scope path" {
  let collected = collect_bytes(72UL, wide_alternative_pattern(64))
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  assert_eq(names.body(collected.bodies[0].id).unwrap().locals.length, 65)
}

///|
fn deep_local_body(local_count : Int) -> Bytes {
  let output = Buffer(size_hint=local_count * 40 + 96)
  output.write_string_utf8("fn deep(initial: I32) -> I32 {\n")
  for index in 0..<local_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    if index == 0 {
      output.write_string_utf8("initial")
    } else {
      output.write_string_utf8("value_")
      output.write_string_utf8((index - 1).to_string())
    }
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((local_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "body name resolution remains iterative for 1024 sequential locals" {
  let collected = collect_bytes(69UL, deep_local_body(1024))
  let names = resolve_module_names(collected)
  assert_eq(names.diagnostics.length(), 0)
  let body = collected.bodies[0]
  assert_eq(names.body(body.id).unwrap().locals.length, 1025)
  let root = match body.root {
    BlockBodyRoot(block) => block
    _ => fail("expected deep function block")
  }
  let items = collected.blocks[root].items
  let final_expression = match
    collected.block_items[items.start + items.length - 1] {
    HirExpressionItem(expression, _) => expression
    _ => fail("expected final expression")
  }
  assert_eq(
    names.expression_references[final_expression],
    LocalNameReference(1024),
  )
}
