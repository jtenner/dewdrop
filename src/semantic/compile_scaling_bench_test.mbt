///|
test "bench freeze chain modules=32" (it : @bench.T) {
  let program = collect_program_manifest(
    3000UL,
    module_system_benchmark_manifest(32, 1),
  )
  it.bench(fn() { it.keep(freeze_program_interfaces(program)) })
}

///|
test "bench freeze chain modules=128" (it : @bench.T) {
  let program = collect_program_manifest(
    3000UL,
    module_system_benchmark_manifest(128, 1),
  )
  it.bench(fn() { it.keep(freeze_program_interfaces(program)) })
}
