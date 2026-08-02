///|
fn aggregate_expression_source(field_count : Int, qualified : Bool) -> Bytes {
  let output = Buffer(size_hint=field_count * 28 + 32)
  if qualified {
    output.write_string_utf8("Message::Data {\n")
  } else {
    output.write_string_utf8("{\n")
  }
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_byte(b'}')
  output.to_bytes()
}

///|
fn if_chain_benchmark_source(depth : Int) -> Bytes {
  let output = Buffer(size_hint=depth * 32 + 24)
  for index in 0..<depth {
    if index == 0 {
      output.write_string_utf8("if condition_")
    } else {
      output.write_string_utf8(" else if condition_")
    }
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n}")
  }
  output.write_string_utf8(" else {\n  0\n}")
  output.to_bytes()
}

///|
fn if_block_benchmark_source(item_count : Int) -> Bytes {
  let output = Buffer(size_hint=item_count * 32 + 64)
  output.write_string_utf8("if condition {\n")
  for index in 0..<item_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  result\n} else {\n  fallback\n}")
  output.to_bytes()
}

///|
test "bench expression parse-only object fields n=64 current" (it : @bench.T) {
  let source = aggregate_expression_source(64, false)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only qualified constructor fields n=64" (
  it : @bench.T,
) {
  let source = aggregate_expression_source(64, true)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse qualified constructor fields n=64" (
  it : @bench.T,
) {
  let source = aggregate_expression_source(64, true)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only else-if chain n=64" (it : @bench.T) {
  let source = if_chain_benchmark_source(64)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse else-if chain n=64" (it : @bench.T) {
  let source = if_chain_benchmark_source(64)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression parse-only if block items n=128" (it : @bench.T) {
  let source = if_block_benchmark_source(128)
  let tokens = @tokenizer.tokens(source).to_array()
  it.bench(fn() {
    let result = Parser::new(tokens.iter()).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse if block items n=128" (it : @bench.T) {
  let source = if_block_benchmark_source(128)
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse short if without else" (it : @bench.T) {
  let source = b"if ready {\n  run()\n}"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}

///|
test "bench expression tokenize and parse short value if" (it : @bench.T) {
  let source = b"if ready {\n  1\n} else {\n  2\n}"
  it.bench(fn() {
    let result = Parser::from_bytes(source).parse_expression()
    it.keep(result)
  })
}
