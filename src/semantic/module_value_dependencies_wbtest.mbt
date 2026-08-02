///|
test "module value dependencies are deduplicated and SCCs are dependency first" {
  let collected = collect_bytes(
    120UL, b"let first = second + second\nlet second = 1\nlet third = first + second\nlet fourth = third\n",
  )
  let names = resolve_module_names(collected)
  let dependencies = analyze_module_value_dependencies(collected, names)
  assert_eq(dependencies.let_dependencies.length(), 4)
  assert_eq(dependencies.let_dependencies[0].length, 1)
  assert_eq(
    dependencies.dependency_declarations[dependencies.let_dependencies[0].start],
    collected.lets[1].declaration,
  )
  assert_eq(dependencies.let_dependencies[1].length, 0)
  assert_eq(dependencies.let_dependencies[2].length, 2)
  assert_eq(dependencies.let_dependencies[3].length, 1)
  assert_eq(dependencies.sccs.length(), 4)
  let expected = [
    collected.lets[1].declaration,
    collected.lets[0].declaration,
    collected.lets[2].declaration,
    collected.lets[3].declaration,
  ]
  for index in 0..<dependencies.sccs.length() {
    assert_eq(dependencies.sccs[index].length, 1)
    assert_eq(
      dependencies.scc_declarations[dependencies.sccs[index].start],
      expected[index],
    )
  }
}

///|
test "module value dependencies group mutual and self cycles" {
  let collected = collect_bytes(
    121UL, b"let first = second\nlet second = first\nlet self = self\nlet independent = 1\n",
  )
  let names = resolve_module_names(collected)
  let dependencies = analyze_module_value_dependencies(collected, names)
  assert_eq(dependencies.sccs.length(), 3)
  let mut mutual_found = false
  let mut self_found = false
  let mut independent_found = false
  for scc in dependencies.sccs {
    if scc.length == 2 {
      mutual_found = true
      assert_eq(
        dependencies.scc_declarations[scc.start],
        collected.lets[0].declaration,
      )
      assert_eq(
        dependencies.scc_declarations[scc.start + 1],
        collected.lets[1].declaration,
      )
    } else {
      let declaration = dependencies.scc_declarations[scc.start]
      if declaration == collected.lets[2].declaration {
        self_found = true
      } else if declaration == collected.lets[3].declaration {
        independent_found = true
      }
    }
  }
  assert_true(mutual_found)
  assert_true(self_found)
  assert_true(independent_found)
}

///|
fn long_module_value_chain(length : Int) -> Bytes {
  let output = Buffer(size_hint=length * 32)
  for index in 0..<length {
    output.write_string_utf8("let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    if index + 1 < length {
      output.write_string_utf8("value_")
      output.write_string_utf8((index + 1).to_string())
    } else {
      output.write_string_utf8("1")
    }
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
test "module value SCC analysis remains iterative for 1024 dependencies" {
  let collected = collect_bytes(122UL, long_module_value_chain(1024))
  let names = resolve_module_names(collected)
  let dependencies = analyze_module_value_dependencies(collected, names)
  assert_eq(dependencies.sccs.length(), 1024)
  assert_eq(
    dependencies.scc_declarations[dependencies.sccs[0].start],
    collected.lets[1023].declaration,
  )
  assert_eq(
    dependencies.scc_declarations[dependencies.sccs[dependencies.sccs.length() -
    1].start],
    collected.lets[0].declaration,
  )
}
