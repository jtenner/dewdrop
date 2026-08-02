///|
fn backend_bench_chain_source(count : Int, cycle : Bool) -> Bytes {
  let output = Buffer(size_hint=count * 48)
  for index in 0..<count {
    output.write_string_utf8("struct Node")
    output.write_string_utf8(index.to_string())
    if index == 0 && !cycle {
      output.write_string_utf8(" {\n  value: I32\n}\n")
    } else {
      output.write_string_utf8(" {\n  next: Node")
      let target = if cycle { (index + 1) % count } else { index - 1 }
      output.write_string_utf8(target.to_string())
      output.write_string_utf8("\n}\n")
    }
  }
  output.to_bytes()
}

///|
fn backend_bench_enum_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 32)
  output.write_string_utf8("enum Value {\n  Empty\n")
  for index in 0..<count {
    output.write_string_utf8("  Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(I32, I64)\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
fn backend_bench_plan(source : Bytes) -> @semantic.PlannedModuleWasmGCFragments {
  let collected = @semantic.collect_bytes(1UL, source)
  let resolved = @semantic.resolve_module_types(collected)
  let layouts = @semantic.plan_module_type_layouts(collected, resolved)
  let functions = @semantic.plan_module_functions(collected, resolved)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
  let initialization = @semantic.plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = @semantic.analyze_module_flows(collected, resolved, inferred)
  let lowering = @semantic.plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  @semantic.plan_module_wasmgc_fragments(resolved, lowering)
}

///|
test "bench Starshine emit dependency chain n=512" (it : @bench.T) {
  let planned = backend_bench_plan(backend_bench_chain_source(512, false))
  it.bench(fn() {
    let section = emit_starshine_type_section(planned)
    it.keep(section)
  })
}

///|
test "bench Starshine emit recursive group n=512" (it : @bench.T) {
  let planned = backend_bench_plan(backend_bench_chain_source(512, true))
  it.bench(fn() {
    let section = emit_starshine_type_section(planned)
    it.keep(section)
  })
}

///|
test "bench Starshine emit enum payloads n=256" (it : @bench.T) {
  let planned = backend_bench_plan(backend_bench_enum_source(256))
  it.bench(fn() {
    let section = emit_starshine_type_section(planned)
    it.keep(section)
  })
}
