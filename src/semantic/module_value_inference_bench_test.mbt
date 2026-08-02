///|
fn module_value_chain_bench_source(length : Int) -> Bytes {
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
fn independent_module_values_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 24)
  for index in 0..<count {
    output.write_string_utf8("let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
fn constrained_module_value_cycle_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 32)
  for index in 0..<count {
    output.write_string_utf8("let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value_")
    output.write_string_utf8(((index + 1) % count).to_string())
    if index + 1 == count {
      output.write_string_utf8(" + 1")
    }
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
fn module_value_function_import_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 80 + 32)
  output.write_string_utf8("let base = 1\n")
  for index in 0..<function_count {
    output.write_string_utf8("fn read_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value: I32) -> I32 {\n  base + value\n}\n")
  }
  output.to_bytes()
}

///|
fn applied_module_value_function_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 72 + 160)
  output.write_string_utf8("struct Box<t> {\n  value: t\n}\n")
  output.write_string_utf8("builtin box<t>(value: t) -> Box<t> = \"box\"\n")
  output.write_string_utf8("let boxed = box(1)\n")
  for index in 0..<function_count {
    output.write_string_utf8("fn read_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("() -> Box<I32> {\n  boxed\n}\n")
  }
  output.to_bytes()
}

///|
test "bench module value dependency analysis chain n=1024" (it : @bench.T) {
  let collected = collect_bytes(1UL, module_value_chain_bench_source(1024))
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let dependencies = analyze_module_value_dependencies(collected, names)
    it.keep(dependencies.sccs.length())
  })
}

///|
test "bench module value inference independent n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, independent_module_values_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let values = infer_module_values(collected, resolved, names)
    it.keep(values.let_types.length())
  })
}

///|
test "bench module value inference one SCC n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, constrained_module_value_cycle_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let values = infer_module_values(collected, resolved, names)
    it.keep(values.let_types.length())
  })
}

///|
test "bench module value imports into functions n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, module_value_function_import_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_types.length())
  })
}

///|
test "bench applied module value imports n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, applied_module_value_function_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.types.length())
  })
}

///|
test "bench module value full pipeline chain n=256" (it : @bench.T) {
  let source = module_value_chain_bench_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.module_values.let_types.length())
  })
}
