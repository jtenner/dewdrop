///|
fn nested_call_type(output : Buffer, depth : Int, leaf : String) -> Unit {
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8(leaf)
  for _ in 0..<depth {
    output.write_byte(b'>')
  }
}

///|
fn deep_generic_call_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 10 + 192)
  output.write_string_utf8("struct Box<t> {\n  value: t\n}\n")
  output.write_string_utf8("builtin extract<t>(value: ")
  nested_call_type(output, depth, "t")
  output.write_string_utf8(") -> t = \"extract\"\n")
  output.write_string_utf8("fn use(value: ")
  nested_call_type(output, depth, "I32")
  output.write_string_utf8(") -> I32 {\n  extract(value)\n}\n")
  output.to_bytes()
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "generic call instantiation remains iterative through 1024 applied types" {
  let collected = collect_bytes(108UL, deep_generic_call_source(1024))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let body = collected.bodies[0]
  let mut call = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirCallExpr(_, _, _) => call = expression
      _ => ()
    }
  }
  assert_true(call >= 0)
  match inferred.call_targets[call] {
    SelectedInferredCallTarget(declaration, arguments) => {
      assert_eq(declaration, collected.declarations[1].id)
      assert_eq(arguments.length, 1)
      match inferred.type_term(inferred.call_type_arguments[arguments.start]) {
        BodyResolvedType(type_) => assert_eq(type_, resolved.primitive(I32Type))
        _ => fail("expected inferred deep generic argument")
      }
    }
    _ => fail("expected selected deep generic call")
  }
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "call inference artifacts are independent of body job order" {
  let collected = collect_bytes(
    109UL, b"builtin convert(value: I32) -> I64 = \"i32_to_i64\"\nbuiltin convert(value: F32) -> F64 = \"f32_to_f64\"\nfn identity<t>(value: t) -> t {\n  value\n}\nfn first() -> I64 {\n  convert(1)\n}\nfn second() -> Bool {\n  identity(true)\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let forward = infer_module_bodies_in_order(collected, resolved, names, [
    0, 1, 2,
  ])
  let reverse = infer_module_bodies_in_order(collected, resolved, names, [
    2, 1, 0,
  ])
  assert_eq(forward, reverse)
}
