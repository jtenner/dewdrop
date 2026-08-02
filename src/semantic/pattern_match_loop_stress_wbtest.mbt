///|
fn deep_generic_pattern_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 12 + 160)
  output.write_string_utf8("enum Box<t> {\n  Boxed(t)\n}\nfn unwrap(value: ")
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8("I32")
  for _ in 0..<depth {
    output.write_byte(b'>')
  }
  output.write_string_utf8(") -> I32 {\n  match value {\n    ")
  for _ in 0..<depth {
    output.write_string_utf8("Boxed(")
  }
  output.write_string_utf8("item")
  for _ in 0..<depth {
    output.write_byte(b')')
  }
  output.write_string_utf8(" => item\n  }\n}\n")
  output.to_bytes()
}

///|
test "pattern inference remains iterative through 512 generic payload levels" {
  let collected = collect_bytes(149UL, deep_generic_pattern_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  let locals = names.body(collected.bodies[0].id).unwrap().locals
  assert_call_primitive(
    inferred,
    resolved,
    inferred.local_types[locals.start + 1],
    I32Type,
  )
  let mut selected = 0
  for selected_constructor in inferred.pattern_constructors {
    match selected_constructor {
      VariantInferredPatternConstructor(_, _) => selected += 1
      _ => ()
    }
  }
  assert_eq(selected, 512)
}

///|
fn many_loop_arms_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 56 + 128)
  output.write_string_utf8("enum State {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  V")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(I32)\n")
  }
  output.write_string_utf8(
    "}\nfn run(initial: State) -> I32 {\n  while initial {\n",
  )
  for index in 0..<arm_count {
    output.write_string_utf8("    V")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value) => break value\n")
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
test "functional loop inference remains iterative across 512 arms" {
  let collected = collect_bytes(150UL, many_loop_arms_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_call_primitive(
    inferred,
    resolved,
    inferred.body(collected.bodies[0].id).unwrap().root_type,
    I32Type,
  )
}
