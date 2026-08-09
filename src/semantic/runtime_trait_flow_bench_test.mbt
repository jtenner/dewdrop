///|
fn runtime_trait_flow_benchmark_source(call_count : Int) -> Bytes {
  let output = Buffer(size_hint=call_count * 112 + 768)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn identity(value: Read) -> Read {\n  value\n}\nfn invoke(value: Read) -> I32 {\n  let selected = if true {\n    value\n  } else {\n    value\n  }\n  selected.read()\n}\nfn forward(value: Read) -> I32 {\n  invoke(identity(value))\n}\npub fn main() -> I32 {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = forward(identity(Box {\n    value: ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }))\n")
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((call_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "bench exact runtime trait flow lowering calls=256" (it : @bench.T) {
  let program = collect_program_manifest(
    2275UL,
    ProgramManifest::new([
      ManifestModule::new("bench.runtime_trait_flow", [
        ManifestFile::new("main.dew", runtime_trait_flow_benchmark_source(256)),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    it.keep(lowering.elided_trait_wrappers.length())
  })
}
