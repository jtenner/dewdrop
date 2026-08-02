///|
fn backend_primitive_bench_pipeline(
  source : Bytes,
) -> (@semantic.PlannedModuleLowering, @semantic.PlannedModuleWasmGCFragments) {
  let collected = @semantic.collect_program_bytes(2540UL, source)
  let resolved = @semantic.resolve_module_types(collected)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
  let layouts = @semantic.plan_module_type_layouts(collected, resolved)
  let functions = @semantic.plan_module_functions(collected, resolved)
  let initialization = @semantic.plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = @semantic.analyze_module_flows(collected, resolved, inferred)
  let lowering = @semantic.plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  let fragments = @semantic.plan_module_wasmgc_fragments(resolved, lowering)
  (lowering, fragments)
}

///|
fn backend_primitive_bench_source() -> Bytes {
  b"pub fn constants() -> I64 {\n  -9223372036854775808i64\n}\npub fn narrow(value: F64) -> I8 {\n  value.into()\n}\npub fn arithmetic(left: U16, right: U16) -> U16 {\n  (left + right) * (left ^ right)\n}\npub fn swar(left: I8, right: I8) -> U32 {\n  swar64_splat_i8(left).add_i8(swar64_splat_i8(right)).popcnt_i8().bitmask_i8()\n}\npub fn simd(left: I16, right: I16) -> V128 {\n  v128_splat_i16(left).add_sat_s_i16(v128_splat_i16(right))\n}\n"
}

///|
test "bench primitive code emission constants conversions SWAR V128" (
  it : @bench.T,
) {
  let (lowering, fragments) = backend_primitive_bench_pipeline(
    backend_primitive_bench_source(),
  )
  it.bench(fn() {
    let section = emit_starshine_code_section(lowering, fragments).unwrap()
    it.keep(section)
  })
}

///|
test "bench primitive validation and binary encoding" (it : @bench.T) {
  let (lowering, fragments) = backend_primitive_bench_pipeline(
    backend_primitive_bench_source(),
  )
  it.bench(fn() {
    let binary = emit_starshine_binary(lowering, fragments).unwrap()
    it.keep(binary)
  })
}

///|
test "bench primitive full frontend semantic and fragment pipeline" (
  it : @bench.T,
) {
  let source = backend_primitive_bench_source()
  it.bench(fn() {
    let pipeline = backend_primitive_bench_pipeline(source)
    it.keep(pipeline)
  })
}
