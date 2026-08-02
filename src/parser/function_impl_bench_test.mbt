///|
fn function_benchmark_source(item_count : Int) -> Bytes {
  let output = Buffer(size_hint=item_count * 32)
  output.write_string_utf8("fn compute(value: I32) -> I32 {\n")
  for index in 0..<item_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value + ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  value\n}\n")
  output.to_bytes()
}

///|
fn impl_benchmark_source(method_count : Int) -> Bytes {
  let output = Buffer(size_hint=method_count * 72)
  output.write_string_utf8("impl BenchmarkTrait<I32> for Benchmark {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(self, value: I32) -> I32 {\n")
    output.write_string_utf8("    value + ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench function parse-only body items n=64" (it : @bench.T) {
  let source = function_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench function tokenize-only body items n=64" (it : @bench.T) {
  let source = function_benchmark_source(64)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench function tokenize and parse body items n=64" (it : @bench.T) {
  let source = function_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench function tokenize and parse typed receiver" (it : @bench.T) {
  let source = b"fn length(self: List<I32>) -> I32 {\n  0\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench impl parse-only methods n=64" (it : @bench.T) {
  let source = impl_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench impl tokenize-only methods n=64" (it : @bench.T) {
  let source = impl_benchmark_source(64)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench impl tokenize and parse methods n=64" (it : @bench.T) {
  let source = impl_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench impl tokenize and parse short generic impl" (it : @bench.T) {
  let source = b"impl<a> Convert<List<a>> for Wrapper<List<a>> {\n  fn convert(self) -> List<a> {\n    self\n  }\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench impl tokenize and parse short foreign impl" (it : @bench.T) {
  let source = b"foreign impl Display for External {\n  fn display(self) -> String {\n    \"external\"\n  }\n}\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}
