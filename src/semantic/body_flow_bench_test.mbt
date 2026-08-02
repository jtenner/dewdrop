///|
fn flow_bench_module(
  source : Bytes,
) -> (CollectedModule, ResolvedModuleTypes, InferredModuleBodies) {
  let collected = collect_bytes(1UL, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  (collected, resolved, inferred)
}

///|
fn repeated_variant_flow_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 20 + 128)
  output.write_string_utf8(
    "enum Flag {\n  On\n  Off\n}\nfn read(flag: Flag) -> I32 {\n  match flag {\n",
  )
  for _ in 0..<arm_count {
    output.write_string_utf8("    On => 1\n")
  }
  output.write_string_utf8("    Off => 0\n  }\n}\n")
  output.to_bytes()
}

///|
fn unreachable_flow_source(item_count : Int) -> Bytes {
  let output = Buffer(size_hint=item_count * 12 + 64)
  output.write_string_utf8("fn stop() -> I32 {\n  return 0\n")
  for index in 0..<item_count {
    output.write_string_utf8("  ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
fn ordinary_flow_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 64)
  for index in 0..<function_count {
    output.write_string_utf8("fn value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "(flag: Bool) -> I32 {\n  if flag {\n    1\n  } else {\n    0\n  }\n}\n",
    )
  }
  output.to_bytes()
}

///|
test "bench flow enum exhaustiveness arms n=256" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    match_variant_arms_source(256),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.missing_cases.length())
  })
}

///|
test "bench flow redundant arms n=512" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    repeated_variant_flow_source(512),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.diagnostics.length())
  })
}

///|
test "bench flow pattern alternatives arms n=256" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    alternative_pattern_arms_source(256),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.arm_flows.length())
  })
}

///|
test "bench flow functional loops arms n=256" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    loop_pattern_arms_bench_source(256),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.arm_flows.length())
  })
}

///|
test "bench flow ordinary functions n=256" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    ordinary_flow_source(256),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.bodies.length())
  })
}

///|
test "bench flow unreachable items n=512" (it : @bench.T) {
  let (collected, resolved, inferred) = flow_bench_module(
    unreachable_flow_source(512),
  )
  it.bench(fn() {
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.diagnostics.length())
  })
}

///|
test "bench flow full pipeline enum arms n=256" (it : @bench.T) {
  let source = match_variant_arms_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    let result = analyze_module_flows(collected, resolved, inferred)
    it.keep(result.expression_flows.length())
  })
}
