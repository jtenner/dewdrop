///|
fn basic_inference_function_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 176)
  for index in 0..<function_count {
    output.write_string_utf8("fn infer_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "(value: I32, flag: Bool) -> I32 {\n  let first = value + 1\n  let second = if flag {\n    first\n  } else {\n    value\n  }\n  second\n}\n",
    )
  }
  output.to_bytes()
}

///|
fn basic_inference_local_source(local_count : Int) -> Bytes {
  let output = Buffer(size_hint=local_count * 44 + 96)
  output.write_string_utf8("fn infer(initial: I32) -> I32 {\n")
  for index in 0..<local_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    if index == 0 {
      output.write_string_utf8("initial + 1")
    } else {
      output.write_string_utf8("value_")
      output.write_string_utf8((index - 1).to_string())
      output.write_string_utf8(" + 1")
    }
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((local_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
fn basic_inference_if_source(branch_count : Int) -> Bytes {
  let output = Buffer(size_hint=branch_count * 32 + 64)
  output.write_string_utf8("fn choose() -> I32 {\n  ")
  for index in 0..<branch_count {
    if index == 0 {
      output.write_string_utf8("if true {\n      ")
    } else {
      output.write_string_utf8(" else if true {\n      ")
    }
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n    }")
  }
  output.write_string_utf8(" else {\n    0\n  }\n}\n")
  output.to_bytes()
}

///|
fn basic_inference_prefix_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth + 64)
  output.write_string_utf8("fn deep() -> Bool {\n  ")
  for _ in 0..<depth {
    output.write_byte(b'!')
  }
  output.write_string_utf8("true\n}\n")
  output.to_bytes()
}

///|
fn infer_prepared_module(collected : CollectedModule) -> InferredModuleBodies {
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  infer_module_bodies(collected, resolved, names)
}

///|
test "bench inference basic resolve-only functions n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, basic_inference_function_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_types.length())
  })
}

///|
test "bench inference basic collect-events through inference n=256" (
  it : @bench.T,
) {
  let events = @parser.parse_bytes(basic_inference_function_source(256)).to_array()
  it.bench(fn() {
    let inferred = infer_prepared_module(collect_module(1UL, events.iter()))
    it.keep(inferred.expression_types.length())
  })
}

///|
test "bench inference basic full pipeline n=256" (it : @bench.T) {
  let source = basic_inference_function_source(256)
  it.bench(fn() {
    let inferred = infer_prepared_module(collect_bytes(1UL, source))
    it.keep(inferred.expression_types.length())
  })
}

///|
test "bench inference basic sequential locals n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, basic_inference_local_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.local_types.length())
  })
}

///|
test "bench inference basic else-if branches n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, basic_inference_if_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.block_types.length())
  })
}

///|
test "bench inference basic prefix depth=1024" (it : @bench.T) {
  let collected = collect_bytes(1UL, basic_inference_prefix_source(1024))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_types.length())
  })
}
