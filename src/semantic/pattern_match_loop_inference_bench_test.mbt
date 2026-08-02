///|
fn match_variant_arms_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 56 + 128)
  output.write_string_utf8("enum State {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  V")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(I32)\n")
  }
  output.write_string_utf8(
    "}\nfn read(state: State) -> I32 {\n  match state {\n",
  )
  for index in 0..<arm_count {
    output.write_string_utf8("    V")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value) => value\n")
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
fn match_literal_arms_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 24 + 96)
  output.write_string_utf8("fn read(value: I32) -> I32 {\n  match value {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("    ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    _ => 0\n  }\n}\n")
  output.to_bytes()
}

///|
fn struct_pattern_fields_source(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 52 + 160)
  output.write_string_utf8("struct Record {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8(
    "}\nfn read(record: Record) -> I32 {\n  match record {\n    Record {\n",
  )
  for index in 0..<field_count {
    output.write_string_utf8("      field_")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("    } => field_0\n  }\n}\n")
  output.to_bytes()
}

///|
fn alternative_pattern_arms_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 52 + 128)
  output.write_string_utf8(
    "enum State {\n  A(I32)\n  B(I32)\n}\nfn read(state: State) -> I32 {\n  match state {\n",
  )
  for _ in 0..<arm_count {
    output.write_string_utf8("    A(value), B(value) => value\n")
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
fn loop_pattern_arms_bench_source(arm_count : Int) -> Bytes {
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
fn infer_pattern_bench(collected : CollectedModule) -> InferredModuleBodies {
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  infer_module_bodies(collected, resolved, names)
}

///|
test "bench pattern match enum arms n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, match_variant_arms_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.pattern_constructors.length())
  })
}

///|
test "bench pattern match literal arms n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, match_literal_arms_source(512))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.pattern_types.length())
  })
}

///|
test "bench pattern struct fields n=128" (it : @bench.T) {
  let collected = collect_bytes(1UL, struct_pattern_fields_source(128))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.local_types.length())
  })
}

///|
test "bench pattern alternatives arms n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, alternative_pattern_arms_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.pattern_types.length())
  })
}

///|
test "bench functional loop pattern arms n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, loop_pattern_arms_bench_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.control_result_types.length())
  })
}

///|
test "bench pattern match full pipeline arms n=256" (it : @bench.T) {
  let source = match_variant_arms_source(256)
  it.bench(fn() {
    let inferred = infer_pattern_bench(collect_bytes(1UL, source))
    it.keep(inferred.pattern_constructors.length())
  })
}
