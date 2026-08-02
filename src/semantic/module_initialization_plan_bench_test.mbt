///|
fn initialization_chain_source(length : Int) -> Bytes {
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
    output.write_string_utf8("\n")
  }
  output.to_bytes()
}

///|
fn initialization_independent_source(length : Int) -> Bytes {
  let output = Buffer(size_hint=length * 24)
  for index in 0..<length {
    output.write_string_utf8("let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n")
  }
  output.to_bytes()
}

///|
fn initialization_cycles_source(cycle_count : Int) -> Bytes {
  let output = Buffer(size_hint=cycle_count * 72)
  for index in 0..<cycle_count {
    output.write_string_utf8("let first_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = second_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\nlet second_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = first_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" + 1\n")
  }
  output.to_bytes()
}

///|
fn initialization_bench_inputs(
  source : Bytes,
) -> (CollectedModule, InferredModuleValues) {
  let collected = collect_bytes(1UL, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  (collected, inferred.module_values)
}

///|
test "bench module initialization chain n=1024" (it : @bench.T) {
  let (collected, inferred) = initialization_bench_inputs(
    initialization_chain_source(1024),
  )
  it.bench(fn() {
    let plan = plan_module_initialization(collected, inferred)
    it.keep(plan.steps.length())
  })
}

///|
test "bench module initialization independent n=512" (it : @bench.T) {
  let (collected, inferred) = initialization_bench_inputs(
    initialization_independent_source(512),
  )
  it.bench(fn() {
    let plan = plan_module_initialization(collected, inferred)
    it.keep(plan.steps.length())
  })
}

///|
test "bench module initialization cycles n=256" (it : @bench.T) {
  let (collected, inferred) = initialization_bench_inputs(
    initialization_cycles_source(256),
  )
  it.bench(fn() {
    let plan = plan_module_initialization(collected, inferred)
    it.keep(plan.diagnostics.length())
  })
}

///|
test "bench module initialization full pipeline chain n=512" (it : @bench.T) {
  let source = initialization_chain_source(512)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    let plan = plan_module_initialization(collected, inferred.module_values)
    it.keep(plan.steps.length())
  })
}
