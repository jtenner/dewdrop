///|
fn object_benchmark_declaration(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 24)
  output.write_string_utf8("let object = {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": value + ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench declaration parse-only object fields n=64" (it : @bench.T) {
  let source = object_benchmark_declaration(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench declaration tokenize and parse object fields n=64" (it : @bench.T) {
  let source = object_benchmark_declaration(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench declaration tokenize and parse simple let" (it : @bench.T) {
  let source = b"let value = alpha + beta * gamma\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}

///|
test "bench declaration tokenize and parse generic builtin" (it : @bench.T) {
  let source = b"pub builtin select<t, u>(value: t, fallback: u) -> t = \"select\"\n"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_declaration()
    it.keep(result)
  })
}
