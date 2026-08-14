///|
fn planning_binary_benchmark_stages() -> (
  CollectedProgram,
  AnalyzedProgramSemantics,
  PlannedProgramLowering,
) {
  let source = Buffer()
  for index in 0..<256 {
    source.write_string_utf8(
      "struct Item_\{index} {\n  value: I32\n  next: I64\n}\nfn value_\{index}(input: I32) -> I32 {\n  input + \{index}\n}\n",
    )
  }
  let program = collect_program_manifest(
    23951UL,
    ProgramManifest::new([
      ManifestModule::new("bench.plans", [
        ManifestFile::new("main.dew", source.to_bytes()),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  (program, analyzed, lowering)
}

///|
test "bench fresh type-layout planning 256 structs" (it : @bench.T) {
  let (program, analyzed, _) = planning_binary_benchmark_stages()
  let collected = program.modules[0]
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  it.bench(fn() {
    let layouts = plan_module_type_layouts(collected, resolved)
    it.keep(layouts.layouts.length())
  })
}

///|
test "bench type-layout binary encode 256 structs" (it : @bench.T) {
  let (_, _, lowering) = planning_binary_benchmark_stages()
  let layouts = lowering.modules[0].type_layouts
  it.bench(fn() {
    let encoded = serialize_planned_module_type_layouts(layouts).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench type-layout binary decode 256 structs" (it : @bench.T) {
  let (_, _, lowering) = planning_binary_benchmark_stages()
  let encoded = serialize_planned_module_type_layouts(
    lowering.modules[0].type_layouts,
  ).unwrap()
  it.bench(fn() {
    let decoded = deserialize_planned_module_type_layouts(encoded).unwrap()
    it.keep(decoded.layouts.length())
  })
}

///|
test "bench fresh WasmGC fragment planning 256 functions" (it : @bench.T) {
  let (_, analyzed, lowering) = planning_binary_benchmark_stages()
  it.bench(fn() {
    let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
    it.keep(fragments.modules[0].functions.length())
  })
}

///|
test "bench WasmGC fragment binary encode 256 functions" (it : @bench.T) {
  let (_, analyzed, lowering) = planning_binary_benchmark_stages()
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering).modules[0]
  it.bench(fn() {
    let encoded = serialize_planned_module_wasmgc_fragments(fragments).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench WasmGC fragment binary decode 256 functions" (it : @bench.T) {
  let (_, analyzed, lowering) = planning_binary_benchmark_stages()
  let encoded = serialize_planned_module_wasmgc_fragments(
    plan_program_wasmgc_fragments(analyzed, lowering).modules[0],
  ).unwrap()
  it.bench(fn() {
    let decoded = deserialize_planned_module_wasmgc_fragments(encoded).unwrap()
    it.keep(decoded.functions.length())
  })
}
