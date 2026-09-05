///|
test "assignment expressions preserve explicit call argument arenas" {
  for statement in ["value = 2", "value[0] = 2"] {
    let collected = collect_bytes(
      29UL,
      @utf8.encode(
        "fn mutate() -> Unit {\n let mut value = 1\n \{statement}\n}\nfn later() -> I32 {\n identity::<I32>(3)\n}\n",
      ),
    )
    assert_eq(collected.diagnostics.length(), 0)
    assert_eq(
      collected.expressions.length(),
      collected.expression_files.length(),
    )
    assert_eq(
      collected.expressions.length(),
      collected.explicit_call_type_argument_spans.length(),
    )
    let mut explicit_calls = 0
    for expression in 0..<collected.expressions.length() {
      let span = collected.explicit_call_type_argument_spans[expression]
      if span.length != 0 {
        match collected.expressions[expression] {
          HirCallExpr(_, _, _) => ()
          _ => fail("explicit type arguments belong to a call expression")
        }
        assert_eq(span.length, 1)
        assert_true(
          span.start < collected.explicit_call_type_arguments.length(),
        )
        explicit_calls += 1
      }
    }
    assert_eq(explicit_calls, 1)
  }
}

///|
test "collection assigns stable bodies to lets functions and impl methods" {
  let collected = collect_bytes(
    21UL, b"let answer = left + right * 2\ntrait Empty {\n  fn read(self) -> I32\n}\nfn choose(value: I32) -> I32 {\n  let next = value + 1\n  next\n}\nimpl State {\n  fn step(self) -> State {\n    self\n  }\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 3)
  assert_eq(semantic_id_module(collected.bodies[0].id), 21UL)
  assert_eq(semantic_id_local(collected.bodies[0].id), 0)
  assert_eq(semantic_id_local(collected.bodies[2].id), 2)
  assert_eq(collected.bodies[0].kind, ModuleLetBody)
  assert_eq(collected.bodies[1].kind, FunctionBody)
  assert_eq(collected.bodies[2].kind, ImplMethodBody)
  assert_eq(
    collected.body_of(collected.declarations[0].id),
    Some(collected.bodies[0]),
  )
  assert_eq(collected.body_of(collected.methods[0].id), None)
  assert_eq(
    collected.body_of(collected.methods[1].id),
    Some(collected.bodies[2]),
  )
}

///|
test "lambda bodies lower into isolated source-ordered HIR fragments" {
  let collected = collect_bytes(
    22UL, b"fn make() -> fn(I32) -> fn(I32) -> I32 {\n  fn(first: I32) -> fn(I32) -> I32 {\n    fn(second: I32) -> I32 {\n      first + second\n    }\n  }\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 1)
  assert_eq(collected.lambdas.length(), 2)
  let function_root = match collected.bodies[0].root {
    BlockBodyRoot(block) => collected.blocks[block].items
    _ => fail("expected function block")
  }
  let outer_expression = match collected.block_items[function_root.start] {
    HirExpressionItem(expression, _) => expression
    _ => fail("expected outer lambda expression")
  }
  assert_eq(collected.expressions[outer_expression], HirLambdaExpr(0, 43UL))
  let outer = collected.lambdas[0]
  assert_eq(outer.parent, -1)
  assert_eq(outer.root_body, collected.bodies[0].id)
  assert_eq(outer.parameters.length, 1)
  assert_eq(
    collected.name(collected.lambda_parameters[outer.parameters.start].name),
    "first",
  )
  assert_true(
    outer.body.expressions.start > collected.bodies[0].expressions.start,
  )
  let outer_items = collected.blocks[outer.body.root].items
  let nested_expression = match collected.block_items[outer_items.start] {
    HirExpressionItem(expression, _) => expression
    _ => fail("expected nested lambda expression")
  }
  assert_eq(collected.expressions[nested_expression], HirLambdaExpr(1, 82UL))
  let nested = collected.lambdas[1]
  assert_eq(nested.parent, 0)
  assert_eq(nested.root_body, collected.bodies[0].id)
  assert_eq(nested.parameters.length, 1)
  let nested_items = collected.blocks[nested.body.root].items
  let nested_tail = match collected.block_items[nested_items.start] {
    HirExpressionItem(expression, _) => expression
    _ => fail("expected nested lambda body tail")
  }
  match collected.expressions[nested_tail] {
    HirBinaryExpr(HirAdd, _, _, _) => ()
    _ => fail("expected nested lambda addition")
  }
  assert_true(nested.body.expressions.start > outer.body.expressions.start)
}

///|
test "body HIR emits expression children before parents" {
  let collected = collect_bytes(22UL, b"let answer = left + right * 2\n")
  assert_eq(collected.bodies.length(), 1)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected expression body")
  }
  match collected.expressions[root] {
    HirBinaryExpr(HirAdd, left, multiply, _) => {
      assert_true(left < root)
      assert_true(multiply < root)
      match collected.expressions[multiply] {
        HirBinaryExpr(HirMultiply, right, literal, _) => {
          assert_true(right < multiply)
          assert_true(literal < multiply)
          match collected.expressions[left] {
            HirNameExpr(name, _) => assert_eq(collected.name(name), "left")
            _ => fail("expected left name")
          }
        }
        _ => fail("expected multiply child")
      }
    }
    _ => fail("expected add root")
  }
}

///|
test "function blocks lower items into contiguous spans" {
  let collected = collect_bytes(
    23UL, b"fn choose(value: I32) -> I32 {\n  let next = value + 1\n  return next\n}\n",
  )
  let body = collected.bodies[0]
  let root = match body.root {
    BlockBodyRoot(root) => root
    _ => fail("expected block body")
  }
  let block = collected.blocks[root]
  assert_eq(block.items.length, 2)
  match collected.block_items[block.items.start] {
    HirLetItem(false, name, _, value, _) => {
      assert_eq(collected.name(name), "next")
      assert_true(value >= body.expressions.start)
    }
    _ => fail("expected lowered let item")
  }
  match collected.block_items[block.items.start + 1] {
    HirExpressionItem(expression, _) =>
      match collected.expressions[expression] {
        HirReturnExpr(value, _) => assert_true(value >= 0)
        _ => fail("expected lowered return expression")
      }
    _ => fail("expected return expression item")
  }
}

///|
test "match and functional while share lowered pattern arms" {
  let collected = collect_bytes(
    24UL, b"let matched = match state {\n  Some(value), Ok(value) if ready => value\n  _ => 0\n}\nlet looped = while initial {\n  Next(value) => continue value\n  Done(value) => break value\n}\n",
  )
  assert_eq(collected.bodies.length(), 2)
  let match_root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected match body")
  }
  match collected.expressions[match_root] {
    HirMatchExpr(_, arms, _) => {
      assert_eq(arms.length, 2)
      let first = collected.pattern_arms[collected.arm_children[arms.start]]
      assert_true(first.guard_condition >= 0)
      match collected.patterns[first.pattern] {
        HirAlternativePattern(_, alternatives, _) =>
          assert_eq(alternatives.length, 1)
        _ => fail("expected alternative pattern")
      }
    }
    _ => fail("expected match expression")
  }
  let while_root = match collected.bodies[1].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected while body")
  }
  match collected.expressions[while_root] {
    HirWhileExpr(_, arms, _) => {
      assert_eq(arms.length, 2)
      let first = collected.pattern_arms[collected.arm_children[arms.start]]
      match collected.expressions[first.body] {
        HirContinueExpr(_, _) => ()
        _ => fail("expected continue body")
      }
      let second = collected.pattern_arms[collected.arm_children[arms.start + 1]]
      match collected.expressions[second.body] {
        HirBreakExpr(_, _) => ()
        _ => fail("expected break body")
      }
    }
    _ => fail("expected functional while expression")
  }
}

///|
test "body HIR preserves every literal kind and empty returns" {
  let collected = collect_bytes(
    31UL, b"let literals = {\n  i32: 1\n  u32: 1U\n  i64: 1L\n  u64: 1UL\n  f32: 1.0F\n  f64: 1.0\n  bool: true\n  string: \"value\"\n}\nfn stop() -> Unit {\n  return\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected literal object")
  }
  let fields = match collected.expressions[root] {
    HirObjectExpr(fields, _) => fields
    _ => fail("expected literal object expression")
  }
  assert_eq(fields.length, 8)
  match collected.expressions[collected.object_fields[fields.start].value] {
    HirI32Expr(1UL, _) => ()
    _ => fail("expected i32 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 1].value] {
    HirU32Expr(1UL, _) => ()
    _ => fail("expected u32 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 2].value] {
    HirI64Expr(1UL, _) => ()
    _ => fail("expected i64 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 3].value] {
    HirU64Expr(1UL, _) => ()
    _ => fail("expected u64 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 4].value] {
    HirF32Expr(_, _) => ()
    _ => fail("expected f32 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 5].value] {
    HirF64Expr(_, _) => ()
    _ => fail("expected f64 literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 6].value] {
    HirBoolExpr(true, _) => ()
    _ => fail("expected bool literal")
  }
  match collected.expressions[collected.object_fields[fields.start + 7].value] {
    HirStringExpr(b"value", _) => ()
    _ => fail("expected string literal")
  }
  let function_root = match collected.bodies[1].root {
    BlockBodyRoot(root) => root
    _ => fail("expected function block")
  }
  let function_block = collected.blocks[function_root]
  match collected.block_items[function_block.items.start] {
    HirExpressionItem(expression, _) =>
      match collected.expressions[expression] {
        HirReturnExpr(-1, _) => ()
        _ => fail("expected empty return expression sentinel")
      }
    _ => fail("expected empty return expression item")
  }
}

///|
test "body HIR lowers object construction and postfix expressions" {
  let collected = collect_bytes(
    26UL, b"let object = {\n  text: \"value\"\n  count: 1U\n  intrinsic: @operation\n}\nlet message = Message::Data::{\n  value: item\n}.value(1)\nlet indexed = values[1 + 2]\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 3)
  let object_root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected object root")
  }
  match collected.expressions[object_root] {
    HirObjectExpr(fields, _) => {
      assert_eq(fields.length, 3)
      let text = collected.object_fields[fields.start]
      assert_eq(collected.name(text.name), "text")
      match collected.expressions[text.value] {
        HirStringExpr(value, _) => assert_eq(value, b"value")
        _ => fail("expected string object field")
      }
      match
        collected.expressions[collected.object_fields[fields.start + 2].value] {
        HirImportAliasExpr(name, _) =>
          assert_eq(collected.name(name), "operation")
        _ => fail("expected intrinsic object field")
      }
    }
    _ => fail("expected object expression")
  }
  let message_root = match collected.bodies[1].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected message root")
  }
  match collected.expressions[message_root] {
    HirCallExpr(target, arguments, _) => {
      assert_eq(arguments.length, 1)
      match collected.expressions[target] {
        HirFieldExpr(construct, name, _) => {
          assert_eq(collected.name(name), "value")
          match collected.expressions[construct] {
            HirConstructExpr(qualified, fields, _) => {
              assert_eq(fields.length, 1)
              match collected.expressions[qualified] {
                HirQualifiedExpr(_, property, _) =>
                  assert_eq(collected.name(property), "Data")
                _ => fail("expected qualified constructor")
              }
            }
            _ => fail("expected construction")
          }
        }
        _ => fail("expected field target")
      }
    }
    _ => fail("expected call expression")
  }
  let index_root = match collected.bodies[2].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected index root")
  }
  match collected.expressions[index_root] {
    HirIndexExpr(_, index, _) =>
      match collected.expressions[index] {
        HirBinaryExpr(HirAdd, _, _, _) => ()
        _ => fail("expected binary index")
      }
    _ => fail("expected index expression")
  }
}

///|
test "if blocks and struct rest patterns lower without recursive AST retention" {
  let collected = collect_bytes(
    27UL, b"let selected = if ready {\n  first\n} else {\n  second\n}\nlet payload = match state {\n  Message::Data {\n    value\n    metadata: details\n    ...\n  } => value\n  Packet(head, ..., tail) => head\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  let if_root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected if root")
  }
  match collected.expressions[if_root] {
    HirIfExpr(_, then_block, alternative, _) => {
      assert_true(then_block >= 0)
      match collected.expressions[alternative] {
        HirBlockExpr(else_block, offset) => {
          assert_true(else_block >= 0)
          assert_true(offset > 0UL)
        }
        _ => fail("expected else block expression")
      }
    }
    _ => fail("expected if expression")
  }
  let match_root = match collected.bodies[1].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected match root")
  }
  match collected.expressions[match_root] {
    HirMatchExpr(_, arms, _) => {
      let first = collected.pattern_arms[collected.arm_children[arms.start]]
      match collected.patterns[first.pattern] {
        HirStructPattern(_, fields, true, rest_offset, _) => {
          assert_eq(fields.length, 2)
          assert_true(rest_offset > 0UL)
          assert_eq(
            collected.name(collected.pattern_fields[fields.start].name),
            "value",
          )
        }
        _ => fail("expected struct rest pattern")
      }
      let second = collected.pattern_arms[collected.arm_children[arms.start + 1]]
      match collected.patterns[second.pattern] {
        HirTuplePattern(_, arguments, _) => {
          assert_eq(arguments.length, 3)
          match
            collected.patterns[collected.pattern_children[arguments.start + 1]] {
            HirRestPattern(_) => ()
            _ => fail("expected tuple rest pattern")
          }
        }
        _ => fail("expected tuple pattern")
      }
    }
    _ => fail("expected match expression")
  }
}

///|
fn large_object_body(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 28 + 24)
  output.write_string_utf8("let object = {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "large object bodies lower iteratively by field count" {
  let collected = collect_bytes(28UL, large_object_body(512))
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies[0].object_fields.length, 512)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected object body")
  }
  match collected.expressions[root] {
    HirObjectExpr(fields, _) => assert_eq(fields.length, 512)
    _ => fail("expected large object expression")
  }
}

///|
fn large_match_body(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 24 + 48)
  output.write_string_utf8("let result = match state {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  _ => 0\n}\n")
  output.to_bytes()
}

///|
test "large match bodies lower iteratively by arm count" {
  let collected = collect_bytes(29UL, large_match_body(512))
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies[0].pattern_arms.length, 513)
  assert_eq(collected.bodies[0].arm_children.length, 513)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected match body")
  }
  match collected.expressions[root] {
    HirMatchExpr(_, arms, _) => assert_eq(arms.length, 513)
    _ => fail("expected large match expression")
  }
}

///|
fn deeply_nested_if_body(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 36 + 32)
  output.write_string_utf8("let result = ")
  for index in 0..<depth {
    if index == 0 {
      output.write_string_utf8("if condition_")
    } else {
      output.write_string_utf8(" else if condition_")
    }
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n}")
  }
  output.write_string_utf8(" else {\n  0\n}\n")
  output.to_bytes()
}

///|
test "deep else-if body lowering remains iterative" {
  let collected = collect_bytes(30UL, deeply_nested_if_body(512))
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 1)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected if body")
  }
  match collected.expressions[root] {
    HirIfExpr(_, _, alternative, _) => assert_true(alternative >= 0)
    _ => fail("expected nested if root")
  }
}

///|
fn deeply_prefixed_let(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth + 24)
  output.write_string_utf8("let deep = ")
  for _ in 0..<depth {
    output.write_byte(b'!')
  }
  output.write_string_utf8("true\n")
  output.to_bytes()
}

///|
test "body HIR lowering remains iterative at depth 1024" {
  let collected = collect_bytes(25UL, deeply_prefixed_let(1024))
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(collected.bodies.length(), 1)
  assert_eq(collected.bodies[0].expressions.length, 1025)
  let root = match collected.bodies[0].root {
    ExpressionBodyRoot(root) => root
    _ => fail("expected expression root")
  }
  match collected.expressions[root] {
    HirPrefixExpr(HirLogicalNot, child, _) => assert_true(child < root)
    _ => fail("expected prefix root")
  }
}
