///|
fn lowering_functions_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 64)
  for index in 0..<count {
    output.write_string_utf8("fn function_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value: I32) -> I32 {\n  value + ")
    output.write_string_utf8((index + 1).to_string())
    output.write_string_utf8("\n}\n")
  }
  output.to_bytes()
}

///|
fn lowering_locals_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 48 + 80)
  output.write_string_utf8("fn locals(value: I32) -> I32 {\n")
  for index in 0..<count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    if index == 0 {
      output.write_string_utf8("value")
    } else {
      output.write_string_utf8("value_")
      output.write_string_utf8((index - 1).to_string())
    }
    output.write_string_utf8(" + 1\n")
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
fn lowering_method_calls_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 40 + 160)
  output.write_string_utf8(
    "struct Item {}\nimpl Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nfn use(value: Item) -> I32 {\n",
  )
  for index in 0..<count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value.read()\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn lowering_bench_inputs(
  source : Bytes,
) -> (
  CollectedModule,
  ResolvedModuleTypes,
  PlannedModuleTypeLayouts,
  PlannedModuleFunctions,
  ResolvedModuleNames,
  InferredModuleBodies,
  PlannedModuleInitialization,
  AnalyzedModuleFlows,
) {
  let collected = collect_bytes(1UL, source)
  let resolved = resolve_module_types(collected)
  let type_layouts = plan_module_type_layouts(collected, resolved)
  let functions = plan_module_functions(collected, resolved)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let initialization = plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = analyze_module_flows(collected, resolved, inferred)
  (
    collected, resolved, type_layouts, functions, names, inferred, initialization,
    flows,
  )
}

///|
test "bench lowering plan functions n=256" (it : @bench.T) {
  let (
    collected,
    resolved,
    type_layouts,
    functions,
    names,
    inferred,
    initialization,
    flows,
  ) = lowering_bench_inputs(lowering_functions_source(256))
  it.bench(fn() {
    let planned = plan_module_lowering(
      collected, resolved, type_layouts, initialization, functions, names, inferred,
      flows,
    )
    it.keep(planned.expressions.length())
  })
}

///|
test "bench lowering plan sequential locals n=512" (it : @bench.T) {
  let (
    collected,
    resolved,
    type_layouts,
    functions,
    names,
    inferred,
    initialization,
    flows,
  ) = lowering_bench_inputs(lowering_locals_source(512))
  it.bench(fn() {
    let planned = plan_module_lowering(
      collected, resolved, type_layouts, initialization, functions, names, inferred,
      flows,
    )
    it.keep(planned.block_items.length())
  })
}

///|
test "bench lowering plan method calls n=256" (it : @bench.T) {
  let (
    collected,
    resolved,
    type_layouts,
    functions,
    names,
    inferred,
    initialization,
    flows,
  ) = lowering_bench_inputs(lowering_method_calls_source(256))
  it.bench(fn() {
    let planned = plan_module_lowering(
      collected, resolved, type_layouts, initialization, functions, names, inferred,
      flows,
    )
    it.keep(planned.expressions.length())
  })
}

///|
test "bench lowering plan full pipeline functions n=128" (it : @bench.T) {
  let source = lowering_functions_source(128)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let type_layouts = plan_module_type_layouts(collected, resolved)
    let functions = plan_module_functions(collected, resolved)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    let initialization = plan_module_initialization(
      collected,
      inferred.module_values,
    )
    let flows = analyze_module_flows(collected, resolved, inferred)
    let planned = plan_module_lowering(
      collected, resolved, type_layouts, initialization, functions, names, inferred,
      flows,
    )
    it.keep(planned.expressions.length())
  })
}
