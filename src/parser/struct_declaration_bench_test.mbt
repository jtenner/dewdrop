///|
fn struct_benchmark_source(field_count : Int, applied_types : Bool) -> Bytes {
  let output = Buffer(size_hint=field_count * 48)
  output.write_string_utf8("pub struct Benchmark<t> {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    if applied_types {
      output.write_string_utf8(": Map<String, List<t>>\n")
    } else {
      output.write_string_utf8(": t\n")
    }
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench struct parse-only named fields n=128" (it : @bench.T) {
  let source = struct_benchmark_source(128, false)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench struct tokenize-only named fields n=128" (it : @bench.T) {
  let source = struct_benchmark_source(128, false)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench struct tokenize and parse named fields n=128" (it : @bench.T) {
  let source = struct_benchmark_source(128, false)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench struct parse-only applied fields n=64" (it : @bench.T) {
  let source = struct_benchmark_source(64, true)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench struct tokenize-only applied fields n=64" (it : @bench.T) {
  let source = struct_benchmark_source(64, true)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench struct tokenize and parse applied fields n=64" (it : @bench.T) {
  let source = struct_benchmark_source(64, true)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench struct tokenize and parse short generic struct" (it : @bench.T) {
  let source = b"pub struct Pair<a, b> {\n  first: a\n  second: b\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench struct tokenize and parse empty struct" (it : @bench.T) {
  let source = b"struct Empty {}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}
