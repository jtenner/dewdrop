///|
fn unit_enum_benchmark_source(variant_count : Int) -> Bytes {
  let output = Buffer(size_hint=variant_count * 20)
  output.write_string_utf8("pub enum Benchmark {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_byte(0x0A)
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
fn tuple_enum_benchmark_source(variant_count : Int) -> Bytes {
  let output = Buffer(size_hint=variant_count * 48)
  output.write_string_utf8("pub enum Benchmark<t> {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(Map<String, List<t>>)\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
fn struct_enum_benchmark_source(variant_count : Int) -> Bytes {
  let output = Buffer(size_hint=variant_count * 80)
  output.write_string_utf8("pub enum Benchmark<t> {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  Variant_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      " {\n    value: t\n    metadata: Map<String, t>\n  }\n",
    )
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench enum parse-only unit variants n=256" (it : @bench.T) {
  let source = unit_enum_benchmark_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum tokenize-only unit variants n=256" (it : @bench.T) {
  let source = unit_enum_benchmark_source(256)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench enum tokenize and parse unit variants n=256" (it : @bench.T) {
  let source = unit_enum_benchmark_source(256)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum parse-only tuple variants n=64" (it : @bench.T) {
  let source = tuple_enum_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum tokenize-only tuple variants n=64" (it : @bench.T) {
  let source = tuple_enum_benchmark_source(64)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench enum tokenize and parse tuple variants n=64" (it : @bench.T) {
  let source = tuple_enum_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum parse-only struct variants n=64" (it : @bench.T) {
  let source = struct_enum_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum tokenize-only struct variants n=64" (it : @bench.T) {
  let source = struct_enum_benchmark_source(64)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench enum tokenize and parse struct variants n=64" (it : @bench.T) {
  let source = struct_enum_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum tokenize and parse short mixed generic enum" (it : @bench.T) {
  let source = b"pub enum Result<t, e> {\n  Pending\n  Ok(t)\n  Err {\n    error: e\n  }\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench enum tokenize and parse empty enum" (it : @bench.T) {
  let source = b"enum Never {}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}
