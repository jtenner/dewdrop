///|
fn many_inherent_methods_source(method_count : Int) -> Bytes {
  let output = Buffer(size_hint=method_count * 96 + 160)
  output.write_string_utf8("struct Item {}\nimpl Item {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(self) -> I32 {\n    ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n")
  }
  output.write_string_utf8("}\nfn use(item: Item) -> I32 {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = item.method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("()\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn many_impl_buckets_source(implementation_count : Int) -> Bytes {
  let output = Buffer(size_hint=implementation_count * 144 + 96)
  for index in 0..<implementation_count {
    output.write_string_utf8("struct Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {}\nimpl Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  fn value(self) -> I32 {\n    ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n}\n")
  }
  output.write_string_utf8("fn use(item: Item")
  output.write_string_utf8((implementation_count - 1).to_string())
  output.write_string_utf8(") -> I32 {\n  item.value()\n}\n")
  output.to_bytes()
}

///|
fn deeply_specialized_impl_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 10 + 320)
  output.write_string_utf8(
    "trait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {}\nimpl<t> Read for Box<t> {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Read for ",
  )
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8("I32")
  for _ in 0..<depth {
    output.write_string_utf8(">")
  }
  output.write_string_utf8(
    " {\n  fn read(self) -> I32 {\n    2\n  }\n}\nfn use(value: ",
  )
  for _ in 0..<depth {
    output.write_string_utf8("Box<")
  }
  output.write_string_utf8("I32")
  for _ in 0..<depth {
    output.write_string_utf8(">")
  }
  output.write_string_utf8(") -> I32 {\n  value.read()\n}\n")
  output.to_bytes()
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "impl indexing handles 512 stable nominal buckets" {
  let collected = collect_bytes(801UL, many_impl_buckets_source(512))
  let resolved = resolve_module_types(collected)
  let index = build_module_impl_index(collected, resolved)
  assert_eq(index.diagnostics.length(), 0)
  assert_eq(index.implementations.length(), 512)
  assert_eq(index.buckets.length(), 512)
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "impl specificity is iterative through 512 applied levels" {
  let (collected, _, _, inferred) = call_test_module(
    803UL,
    deeply_specialized_impl_source(512),
  )
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  assert_eq(inferred.impl_index.implementations[1].specificity, 1)
  let calls = body_calls(collected, collected.bodies[2])
  match inferred.call_targets[calls[0]] {
    SelectedInferredCallTarget(declaration, _) =>
      assert_eq(declaration, collected.methods[2].id)
    _ => fail("expected deeply specialized method")
  }
}

///|
#skip("large compiler stress case; run tools/test-stress-native.sh")
test "method inference handles 512 methods and calls iteratively" {
  let (collected, _, _, inferred) = call_test_module(
    802UL,
    many_inherent_methods_source(512),
  )
  assert_eq(inferred.diagnostics.length(), 0)
  let calls = body_calls(collected, collected.bodies[512])
  assert_eq(calls.length(), 512)
  for index, call in calls {
    match inferred.call_targets[call] {
      SelectedInferredCallTarget(declaration, _) =>
        assert_eq(declaration, collected.methods[index].id)
      _ => fail("expected selected stress method")
    }
  }
}
