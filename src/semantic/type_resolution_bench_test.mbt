///|
fn resolved_alias_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 52 + 64)
  output.write_string_utf8("struct List<t> {}\nenum Result<t> {\n  Ok(t)\n}\n")
  for index in 0..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> = Result<List<t>>\n")
  }
  output.to_bytes()
}

///|
fn resolved_signature_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 104 + 32)
  output.write_string_utf8("struct Pair<a, b> {}\n")
  for index in 0..<function_count {
    output.write_string_utf8("fn combine_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "<t>(left: Pair<t, I32>, right: Pair<t, I32>) -> Pair<t, I32> {\n  left\n}\n",
    )
  }
  output.to_bytes()
}

///|
fn resolved_cycle_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 40)
  for index in 0..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = Alias_")
    output.write_string_utf8(((index + 1) % alias_count).to_string())
    output.write_byte(b'\n')
  }
  output.to_bytes()
}

///|
fn normalized_alias_chain_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 44 + 80)
  output.write_string_utf8("type Alias_0 = I32\n")
  for index in 1..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = Alias_")
    output.write_string_utf8((index - 1).to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("fn use(value: Alias_")
  output.write_string_utf8((alias_count - 1).to_string())
  output.write_string_utf8(") -> I32 {\n  value\n}\n")
  output.to_bytes()
}

///|
fn normalized_generic_alias_chain_source(alias_count : Int) -> Bytes {
  let output = Buffer(size_hint=alias_count * 72 + 128)
  output.write_string_utf8(
    "struct Pair<a, b> {}\ntype Alias_0<t> = Pair<t, I32>\n",
  )
  for index in 1..<alias_count {
    output.write_string_utf8("type Alias_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> = Alias_")
    output.write_string_utf8((index - 1).to_string())
    output.write_string_utf8("<Pair<t, I32>>\n")
  }
  output.write_string_utf8("fn use(value: Alias_")
  output.write_string_utf8((alias_count - 1).to_string())
  output.write_string_utf8("<String>) -> Unit {}\n")
  output.to_bytes()
}

///|
test "bench type resolve-only aliases n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, resolved_alias_source(256))
  it.bench(fn() {
    let resolved = resolve_module_types(collected)
    it.keep(resolved.types.length())
  })
}

///|
test "bench type collect-events and resolve aliases n=256" (it : @bench.T) {
  let events = @parser.parse_bytes(resolved_alias_source(256)).to_array()
  it.bench(fn() {
    let resolved = resolve_module_types(collect_module(1UL, events.iter()))
    it.keep(resolved.types.length())
  })
}

///|
test "bench type tokenize parse collect and resolve aliases n=256" (
  it : @bench.T,
) {
  let source = resolved_alias_source(256)
  it.bench(fn() {
    let resolved = resolve_module_types(collect_bytes(1UL, source))
    it.keep(resolved.types.length())
  })
}

///|
test "bench type resolve-only signatures n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, resolved_signature_source(256))
  it.bench(fn() {
    let resolved = resolve_module_types(collected)
    it.keep(resolved.callable_return_types.length())
  })
}

///|
test "bench type collect and resolve signatures n=256" (it : @bench.T) {
  let events = @parser.parse_bytes(resolved_signature_source(256)).to_array()
  it.bench(fn() {
    let resolved = resolve_module_types(collect_module(1UL, events.iter()))
    it.keep(resolved.callable_return_types.length())
  })
}

///|
test "bench type resolve cyclic aliases n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, resolved_cycle_source(256))
  it.bench(fn() {
    let resolved = resolve_module_types(collected)
    it.keep(resolved.alias_cycles.length())
  })
}

///|
test "bench type normalize transparent alias chain n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, normalized_alias_chain_source(256))
  it.bench(fn() {
    let resolved = resolve_module_types(collected)
    it.keep(resolved.parameter_types[0])
  })
}

///|
test "bench type normalize instantiated generic alias chain n=256" (
  it : @bench.T,
) {
  let collected = collect_bytes(1UL, normalized_generic_alias_chain_source(256))
  it.bench(fn() {
    let resolved = resolve_module_types(collected)
    it.keep(resolved.parameter_types[0])
  })
}

///|
test "bench type full generic alias chain n=256" (it : @bench.T) {
  let source = normalized_generic_alias_chain_source(256)
  it.bench(fn() {
    let resolved = resolve_module_types(collect_bytes(1UL, source))
    it.keep(resolved.parameter_types[0])
  })
}
