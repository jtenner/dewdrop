///|
fn function_plan_functions_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 72)
  for index in 0..<count {
    output.write_string_utf8("fn function_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t>(value: t, count: I64) -> t {\n  value\n}\n")
  }
  output.to_bytes()
}

///|
fn function_plan_methods_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 72 + 64)
  output.write_string_utf8("struct Item {}\nimpl Item {\n")
  for index in 0..<count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(self, value: I32) -> I32 {\n    value\n  }\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench function plans generic functions n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, function_plan_functions_source(512))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let functions = plan_module_functions(collected, resolved)
    it.keep(functions.parameters.length())
  })
}

///|
test "bench function plans methods n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, function_plan_methods_source(512))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let functions = plan_module_functions(collected, resolved)
    it.keep(functions.callables.length())
  })
}

///|
test "bench function plans full pipeline n=256" (it : @bench.T) {
  let source = function_plan_functions_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let functions = plan_module_functions(collected, resolved)
    it.keep(functions.callables.length())
  })
}
