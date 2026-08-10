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

///|
fn open_generic_runtime_trait_benchmark_source(
  call_count : Int,
  dynamic : Bool,
) -> Bytes {
  let output = Buffer(size_hint=call_count * 72 + 512)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\n",
  )
  if dynamic {
    output.write_string_utf8(
      "pub fn erase<t: Value>(condition: Bool, value: t) -> Value {\n  if condition {\n    value\n  } else {\n    value\n  }\n}\n",
    )
  } else {
    output.write_string_utf8(
      "fn erase<t: Value>(value: t) -> Value {\n  value\n}\n",
    )
  }
  output.write_string_utf8(
    "fn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = invoke(erase(")
    if dynamic {
      output.write_string_utf8("true, ")
    }
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("))\n")
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((call_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "bench closed open-generic trait erasure link calls=256" (it : @bench.T) {
  let program = collect_program_manifest(
    2276UL,
    ProgramManifest::new([
      ManifestModule::new("bench.open_generic_closed", [
        ManifestFile::new(
          "main.dew",
          open_generic_runtime_trait_benchmark_source(256, false),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    let link = plan_program_wasmgc_link(analyzed, lowering, 0)
    it.keep(link.defined_function_count)
  })
}

///|
test "bench dynamic open-generic trait erasure link calls=256" (it : @bench.T) {
  let program = collect_program_manifest(
    2277UL,
    ProgramManifest::new([
      ManifestModule::new("bench.open_generic_dynamic", [
        ManifestFile::new(
          "main.dew",
          open_generic_runtime_trait_benchmark_source(256, true),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    let link = plan_program_wasmgc_link(analyzed, lowering, 0)
    it.keep(link.trait_dictionary_globals.length())
  })
}

///|
fn external_runtime_trait_static_call_benchmark_source(
  call_count : Int,
) -> Bytes {
  let output = Buffer(size_hint=call_count * 48 + 384)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn consume<t: Read>(value: t) -> I32 {\n  value.read()\n}\nfn consume_value<t: Value>(value: t) -> I32 {\n  consume(Box {\n    value: value\n  })\n}\npub fn read<t: Value>(value: t) -> I32 {\n  consume_value(value)\n}\npub fn main() -> I32 {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = read(")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(")\n")
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((call_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "bench external runtime-evidence prerequisite forwarding calls=256" (
  it : @bench.T,
) {
  let program = collect_program_manifest(
    2279UL,
    ProgramManifest::new([
      ManifestModule::new("bench.external_runtime_trait_static", [
        ManifestFile::new(
          "main.dew",
          external_runtime_trait_static_call_benchmark_source(256),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    let link = plan_program_wasmgc_link(analyzed, lowering, 0)
    it.keep(link.defined_function_count)
  })
}

///|
fn external_runtime_trait_recursive_static_call_benchmark_source(
  call_count : Int,
) -> Bytes {
  let output = Buffer(size_hint=call_count * 48 + 640)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\ntrait Inspect {\n  fn inspect(self) -> I32\n}\nstruct Wrap<t> {\n  value: t\n}\nimpl<t: Read> Inspect for Wrap<t> {\n  fn inspect(self) -> I32 {\n    self.value.read()\n  }\n}\nfn consume<t: Inspect>(value: t) -> I32 {\n  value.inspect()\n}\nfn consume_value<t: Value>(value: t) -> I32 {\n  consume(Wrap {\n    value: Box {\n      value: value\n    }\n  })\n}\npub fn read<t: Value>(value: t) -> I32 {\n  consume_value(value)\n}\npub fn main() -> I32 {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = read(")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(")\n")
  }
  output.write_string_utf8("  value_")
  output.write_string_utf8((call_count - 1).to_string())
  output.write_string_utf8("\n}\n")
  output.to_bytes()
}

///|
test "bench external runtime-evidence recursive prerequisites calls=256" (
  it : @bench.T,
) {
  let program = collect_program_manifest(
    2280UL,
    ProgramManifest::new([
      ManifestModule::new("bench.external_runtime_trait_recursive", [
        ManifestFile::new(
          "main.dew",
          external_runtime_trait_recursive_static_call_benchmark_source(256),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    let link = plan_program_wasmgc_link(analyzed, lowering, 0)
    it.keep(link.defined_function_count)
  })
}

///|
fn open_generic_selector_chain_benchmark_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 96 + 512)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\n",
  )
  for index in 0..<depth {
    output.write_string_utf8("fn select_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t: Value>(value: t) -> Value {\n  ")
    if index == 0 {
      output.write_string_utf8("value")
    } else {
      output.write_string_utf8("select_")
      output.write_string_utf8((index - 1).to_string())
      output.write_string_utf8("(value)")
    }
    output.write_string_utf8("\n}\n")
  }
  output.write_string_utf8(
    "fn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(select_",
  )
  output.write_string_utf8((depth - 1).to_string())
  output.write_string_utf8("(42))\n}\n")
  output.to_bytes()
}

///|
test "bench open-generic selector propagation depth=256" (it : @bench.T) {
  let program = collect_program_manifest(
    2278UL,
    ProgramManifest::new([
      ManifestModule::new("bench.open_generic_selector_chain", [
        ManifestFile::new(
          "main.dew",
          open_generic_selector_chain_benchmark_source(256),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  it.bench(fn() {
    let lowering = plan_program_lowering(program, analyzed)
    it.keep(lowering.elided_trait_wrappers.length())
  })
}
