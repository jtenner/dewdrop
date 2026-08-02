///|
fn functional_while_benchmark_source(arm_count : Int) -> Bytes {
  let output = Buffer(size_hint=arm_count * 72 + 48)
  output.write_string_utf8("while state {\n")
  for index in 0..<arm_count {
    output.write_string_utf8("  State::Value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value) if value > ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" => continue value\n")
  }
  output.write_string_utf8("  _ => break 0\n}")
  output.to_bytes()
}

///|
test "bench functional while parse-only guarded arms n=256" (it : @bench.T) {
  let source = functional_while_benchmark_source(256)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench functional while tokenize-only guarded arms n=256" (it : @bench.T) {
  let source = functional_while_benchmark_source(256)
  it.bench(fn() {
    let result = @tokenizer.tokens(source).to_array()
    it.keep(result)
  })
}

///|
test "bench functional while tokenize and parse guarded arms n=256" (
  it : @bench.T,
) {
  let source = functional_while_benchmark_source(256)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench functional while tokenize and parse short state loop" (
  it : @bench.T,
) {
  let source = b"while init {\n  State::Next(value) if value > 0 => continue value\n  _ => break 0\n}"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}
