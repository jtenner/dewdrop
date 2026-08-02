///|
fn trait_benchmark_source(method_count : Int, receivers : Bool) -> Bytes {
  let output = Buffer(size_hint=method_count * 52)
  output.write_string_utf8("pub trait Benchmark<t> {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    if receivers {
      output.write_string_utf8("(self, value: t) -> t\n")
    } else {
      output.write_string_utf8("(value: t) -> t\n")
    }
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench trait parse-only static methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, false)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench trait tokenize-only static methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, false)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench trait tokenize and parse static methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, false)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench trait parse-only receiver methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, true)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench trait tokenize-only receiver methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, true)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench trait tokenize and parse receiver methods n=64" (it : @bench.T) {
  let source = trait_benchmark_source(64, true)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench trait tokenize and parse short generic trait" (it : @bench.T) {
  let source = b"pub trait Convert<t> {\n  fn convert(self) -> t\n  fn create(value: t) -> Self\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}
