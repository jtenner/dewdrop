///|
test "bench content hash freeze modules=32 functions=8" (it : @bench.T) {
  let program = collect_program_manifest(
    3200UL,
    module_system_benchmark_manifest(32, 8),
  )
  it.bench(fn() { it.keep(freeze_program_interfaces(program)) }, count=3U)
}

///|
test "bench content hash freeze modules=128 functions=8" (it : @bench.T) {
  let program = collect_program_manifest(
    3200UL,
    module_system_benchmark_manifest(128, 8),
  )
  it.bench(fn() { it.keep(freeze_program_interfaces(program)) }, count=3U)
}
