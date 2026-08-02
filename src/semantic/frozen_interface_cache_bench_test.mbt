///|
fn frozen_interface_cache_benchmark_program() -> CollectedProgram {
  collect_program_manifest(
    7760UL,
    ProgramManifest::new([
      ManifestModule::new("cache.bench", [
        ManifestFile::new(
          "main.dew", b"open dew.std.*\npub fn main() -> U32 {\n  wasi_fd_write(1u32, b\"cache benchmark\")\n}\n",
        ),
      ]),
    ]),
  )
}

///|
test "bench frozen interface cache encode all standard modules" (it : @bench.T) {
  let frozen = freeze_program_interfaces(
    frozen_interface_cache_benchmark_program(),
  )
  it.bench(fn() {
    let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
    it.keep(encoded.length())
  })
}

///|
test "bench frozen interface cache decode all standard modules" (it : @bench.T) {
  let frozen = freeze_program_interfaces(
    frozen_interface_cache_benchmark_program(),
  )
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  it.bench(fn() {
    let decoded = deserialize_frozen_interfaces(encoded).unwrap()
    it.keep(decoded.length())
  })
}

///|
test "bench frozen interface cache hit injection all standard modules" (
  it : @bench.T,
) {
  let program = frozen_interface_cache_benchmark_program()
  let frozen = freeze_program_interfaces(program)
  let decoded = deserialize_frozen_interfaces(
    serialize_frozen_interfaces(frozen.interfaces).unwrap(),
  ).unwrap()
  let cached : Array[FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  for index, interface_ in decoded {
    if interface_.path.has_prefix("dew.std.") {
      cached[index] = Some(interface_)
    }
  }
  it.bench(fn() {
    let hit = freeze_program_interfaces_with_cached(program, cached)
    it.keep(hit.interfaces.length())
  })
}

///|
test "bench frozen interface cache miss freeze all standard modules" (
  it : @bench.T,
) {
  let program = frozen_interface_cache_benchmark_program()
  it.bench(fn() {
    let miss = freeze_program_interfaces(program)
    it.keep(miss.interfaces.length())
  })
}
