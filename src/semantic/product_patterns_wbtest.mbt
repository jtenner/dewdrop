///|
test "imported short constructors carry nested product payload types" {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    b"open app.library\npub fn run(value: Choice) -> I64 {\n match value {\n Present((left, right)) => right\n Missing => 0i64\n }\n}\n",
    b"pub enum Choice {\n Present((I32, I64))\n Missing\n}\n",
  )
  assert_eq(frozen.import_diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
  let locals = names.body(program.modules[0].bodies[0].id).unwrap().locals
  assert_eq(locals.length, 3)
  assert_call_primitive(
    inferred,
    frozen.interfaces[0].resolved_types,
    inferred.local_types[locals.start + 1],
    I32Type,
  )
  assert_call_primitive(
    inferred,
    frozen.interfaces[0].resolved_types,
    inferred.local_types[locals.start + 2],
    I64Type,
  )
  let selected = inferred.pattern_constructors.filter(fn(pattern) {
    pattern is VariantInferredPatternConstructor(_, _)
  })
  assert_eq(selected.length(), 2)
  for pattern in selected {
    guard pattern is VariantInferredPatternConstructor(variant, _) else {
      fail("selected imported constructor")
    }
    assert_eq(semantic_id_module(variant), program.modules[1].module_id)
  }
}

///|
test "product pattern inference carries outer payload types into nested bindings" {
  let (collected, resolved, names, inferred) = call_test_module(
    140UL, b"enum Maybe<t> {\n None\n Some(t)\n}\nfn read(value: Maybe<(I32, I64)>) -> I64 {\n match value {\n Some((left, right)) => right\n None => 0i64\n }\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  let locals = names.body(collected.bodies[0].id).unwrap().locals
  assert_eq(locals.length, 3)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 1],
    I32Type,
  )
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 2],
    I64Type,
  )
  let products = collected.patterns.filter(fn(pattern) {
    pattern is HirProductPattern(_, _)
  })
  assert_eq(products.length(), 1)
}

///|
test "product pattern arity errors retain expected and actual field counts" {
  let (_, _, _, inferred) = call_test_module(
    140UL, b"fn read(value: (I32, I64)) -> I32 {\n match value {\n (left, middle, right) => left\n }\n}\n",
  )
  assert_true(
    inferred.diagnostics.any(fn(diagnostic) {
      diagnostic is PatternPayloadArityMismatch(_, 2, 3, _)
    }),
  )
}

///|
test "product pattern cannot destructure a scalar" {
  let (_, _, _, inferred) = call_test_module(
    140UL, b"fn read(value: I32) -> I32 {\n match value {\n (left, right) => left\n }\n}\n",
  )
  assert_true(
    inferred.diagnostics.any(fn(diagnostic) {
      diagnostic is InvalidPatternConstructor(_, _)
    }),
  )
}
