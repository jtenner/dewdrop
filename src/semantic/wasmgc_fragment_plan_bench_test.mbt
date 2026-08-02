///|
fn wasmgc_bench_chain_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 48)
  output.write_string_utf8("struct Node0 {\n  value: I32\n}\n")
  for index in 1..<count {
    output.write_string_utf8("struct Node")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  next: Node")
    output.write_string_utf8((index - 1).to_string())
    output.write_string_utf8("\n}\n")
  }
  output.to_bytes()
}

///|
fn wasmgc_bench_cycle_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 48)
  for index in 0..<count {
    output.write_string_utf8("struct Node")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  next: Node")
    output.write_string_utf8(((index + 1) % count).to_string())
    output.write_string_utf8("\n}\n")
  }
  output.to_bytes()
}

///|
fn wasmgc_bench_enum_source(count : Int) -> Bytes {
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
fn wasmgc_bench_lowering(
  source : Bytes,
) -> (ResolvedModuleTypes, PlannedModuleLowering) {
  let collected = collect_bytes(1UL, source)
  let resolved = resolve_module_types(collected)
  let layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  (
    resolved,
    plan_module_lowering(
      collected, resolved, layouts, initialization, functions, names, inferred, flows,
    ),
  )
}

///|
test "bench WasmGC fragments dependency chain n=512" (it : @bench.T) {
  let (resolved, lowering) = wasmgc_bench_lowering(
    wasmgc_bench_chain_source(512),
  )
  it.bench(fn() {
    let planned = plan_module_wasmgc_fragments(resolved, lowering)
    it.keep(planned.type_groups.length())
  })
}

///|
test "bench WasmGC fragments recursive group n=512" (it : @bench.T) {
  let (resolved, lowering) = wasmgc_bench_lowering(
    wasmgc_bench_cycle_source(512),
  )
  it.bench(fn() {
    let planned = plan_module_wasmgc_fragments(resolved, lowering)
    it.keep(planned.physical_types.length())
  })
}

///|
test "bench WasmGC fragments enum payloads n=256" (it : @bench.T) {
  let (resolved, lowering) = wasmgc_bench_lowering(
    wasmgc_bench_enum_source(256),
  )
  it.bench(fn() {
    let planned = plan_module_wasmgc_fragments(resolved, lowering)
    it.keep(planned.fields.length())
  })
}

///|
test "bench WasmGC fragments full pipeline chain n=256" (it : @bench.T) {
  let source = wasmgc_bench_chain_source(256)
  it.bench(fn() {
    let (resolved, lowering) = wasmgc_bench_lowering(source)
    let planned = plan_module_wasmgc_fragments(resolved, lowering)
    it.keep(planned.physical_types.length())
  })
}
