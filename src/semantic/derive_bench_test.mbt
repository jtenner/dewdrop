///|
fn derive_collection_benchmark_source(
  declaration_count : Int,
  derived : Bool,
) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 48)
  for index in 0..<declaration_count {
    output.write_string_utf8("struct Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  value: I32\n}")
    if derived {
      output.write_string_utf8(" derive(Eq)")
    }
    output.write_byte(0x0A)
  }
  output.to_bytes()
}

///|
fn derive_named_collection_benchmark_source(
  declaration_count : Int,
  prefix : String,
  trait_name : String,
) -> Bytes {
  let output = Buffer(size_hint=declaration_count * 56)
  for index in 0..<declaration_count {
    output.write_string_utf8("struct ")
    output.write_string_utf8(prefix)
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  value: I32\n} derive(")
    output.write_string_utf8(trait_name)
    output.write_string_utf8(")\n")
  }
  output.to_bytes()
}

///|
test "bench collect structs without derives n=512" (it : @bench.T) {
  let source = derive_collection_benchmark_source(512, false)
  it.bench(fn() {
    let collected = collect_bytes(2710UL, source)
    it.keep(collected.declarations.length())
  })
}

///|
test "bench collect structs with derive Eq n=128" (it : @bench.T) {
  let source = derive_collection_benchmark_source(128, true)
  it.bench(fn() {
    let collected = collect_bytes(2711UL, source)
    it.keep(collected.declarations.length())
  })
}

///|
test "bench collect structs with derive Debug n=128" (it : @bench.T) {
  let source = derive_named_collection_benchmark_source(
    128, "DebugItem", "Debug",
  )
  it.bench(fn() {
    let collected = collect_bytes(2712UL, source)
    it.keep(collected.declarations.length())
  })
}

///|
test "bench collect structs with derive Hash n=128" (it : @bench.T) {
  let source = derive_named_collection_benchmark_source(128, "HashItem", "Hash")
  it.bench(fn() {
    let collected = collect_bytes(2713UL, source)
    it.keep(collected.declarations.length())
  })
}
